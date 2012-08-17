From: Cong Wang <amwang@redhat.com>
Subject: [RFC Patch net-next] ipv6: unify conntrack reassembly expire code with standard one
Date: Fri, 17 Aug 2012 16:02:45 +0800
Message-ID: <1345190565-21689-1-git-send-email-amwang@redhat.com>
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Shan Wei <shanwei@cn.fujitsu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two years ago, Shan Wei tried to fix this:
http://patchwork.ozlabs.org/patch/43905/

The problem is that RFC2460 requires an ICMP Time
Exceeded -- Fragment Reassembly Time Exceeded message should be
sent to the source of that fragment, if the defragmentation
times out.

"
   If insufficient fragments are received to complete reassembly of a
   packet within 60 seconds of the reception of the first-arriving
   fragment of that packet, reassembly of that packet must be
   abandoned and all the fragments that have been received for that
   packet must be discarded.  If the first fragment (i.e., the one
   with a Fragment Offset of zero) has been received, an ICMP Time
   Exceeded -- Fragment Reassembly Time Exceeded message should be
   sent to the source of that fragment.
"

As Herbert suggested, we could actually use the standard IPv6
reassembly code which follows RFC2460.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Shan Wei <shanwei@cn.fujitsu.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: netfilter-devel@vger.kernel.org
Signed-off-by: Cong Wang <amwang@redhat.com>

---

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 6d01fb0..958221b 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -408,6 +408,24 @@ struct ip6_create_arg {
 void ip6_frag_init(struct inet_frag_queue *q, void *a);
 bool ip6_frag_match(struct inet_frag_queue *q, void *a);
 
+/*
+ *	Equivalent of ipv4 struct ip
+ */
+struct frag_queue {
+	struct inet_frag_queue	q;
+
+	__be32			id;		/* fragment id		*/
+	u32			user;
+	struct in6_addr		saddr;
+	struct in6_addr		daddr;
+
+	int			iif;
+	unsigned int		csum;
+	__u16			nhoffset;
+};
+
+void ip6_expire_frag_queue(struct frag_queue *fq, struct inet_frags *frags);
+
 static inline bool ipv6_addr_any(const struct in6_addr *a)
 {
 #if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index c9c78c2..7c42cf1 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -57,19 +57,6 @@ struct nf_ct_frag6_skb_cb
 
 #define NFCT_FRAG6_CB(skb)	((struct nf_ct_frag6_skb_cb*)((skb)->cb))
 
-struct nf_ct_frag6_queue
-{
-	struct inet_frag_queue	q;
-
-	__be32			id;		/* fragment id		*/
-	u32			user;
-	struct in6_addr		saddr;
-	struct in6_addr		daddr;
-
-	unsigned int		csum;
-	__u16			nhoffset;
-};
-
 static struct inet_frags nf_frags;
 static struct netns_frags nf_init_frags;
 
@@ -104,9 +91,9 @@ static struct ctl_table_header *nf_ct_frag6_sysctl_header;
 
 static unsigned int nf_hashfn(struct inet_frag_queue *q)
 {
-	const struct nf_ct_frag6_queue *nq;
+	const struct frag_queue *nq;
 
-	nq = container_of(q, struct nf_ct_frag6_queue, q);
+	nq = container_of(q, struct frag_queue, q);
 	return inet6_hash_frag(nq->id, &nq->saddr, &nq->daddr, nf_frags.rnd);
 }
 
@@ -116,21 +103,6 @@ static void nf_skb_free(struct sk_buff *skb)
 		kfree_skb(NFCT_FRAG6_CB(skb)->orig);
 }
 
-/* Destruction primitives. */
-
-static __inline__ void fq_put(struct nf_ct_frag6_queue *fq)
-{
-	inet_frag_put(&fq->q, &nf_frags);
-}
-
-/* Kill fq entry. It is not destroyed immediately,
- * because caller (and someone more) holds reference count.
- */
-static __inline__ void fq_kill(struct nf_ct_frag6_queue *fq)
-{
-	inet_frag_kill(&fq->q, &nf_frags);
-}
-
 static void nf_ct_frag6_evictor(void)
 {
 	local_bh_disable();
@@ -140,26 +112,16 @@ static void nf_ct_frag6_evictor(void)
 
 static void nf_ct_frag6_expire(unsigned long data)
 {
-	struct nf_ct_frag6_queue *fq;
+	struct frag_queue *fq;
 
 	fq = container_of((struct inet_frag_queue *)data,
-			struct nf_ct_frag6_queue, q);
-
-	spin_lock(&fq->q.lock);
-
-	if (fq->q.last_in & INET_FRAG_COMPLETE)
-		goto out;
-
-	fq_kill(fq);
-
-out:
-	spin_unlock(&fq->q.lock);
-	fq_put(fq);
+			struct frag_queue, q);
+	ip6_expire_frag_queue(fq, &nf_frags);
 }
 
 /* Creation primitives. */
 
-static __inline__ struct nf_ct_frag6_queue *
+static __inline__ struct frag_queue*
 fq_find(__be32 id, u32 user, struct in6_addr *src, struct in6_addr *dst)
 {
 	struct inet_frag_queue *q;
@@ -179,14 +141,14 @@ fq_find(__be32 id, u32 user, struct in6_addr *src, struct in6_addr *dst)
 	if (q == NULL)
 		goto oom;
 
-	return container_of(q, struct nf_ct_frag6_queue, q);
+	return container_of(q, struct frag_queue, q);
 
 oom:
 	return NULL;
 }
 
 
-static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
+static int nf_ct_frag6_queue(struct frag_queue*fq, struct sk_buff *skb,
 			     const struct frag_hdr *fhdr, int nhoff)
 {
 	struct sk_buff *prev, *next;
@@ -322,7 +284,7 @@ found:
 	return 0;
 
 discard_fq:
-	fq_kill(fq);
+	inet_frag_kill(&fq->q, &nf_frags);
 err:
 	return -1;
 }
@@ -337,12 +299,12 @@ err:
  *	the last and the first frames arrived and all the bits are here.
  */
 static struct sk_buff *
-nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
+nf_ct_frag6_reasm(struct frag_queue *fq, struct net_device *dev)
 {
 	struct sk_buff *fp, *op, *head = fq->q.fragments;
 	int    payload_len;
 
-	fq_kill(fq);
+	inet_frag_kill(&fq->q, &nf_frags);
 
 	WARN_ON(head == NULL);
 	WARN_ON(NFCT_FRAG6_CB(head)->offset != 0);
@@ -521,7 +483,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 	struct sk_buff *clone;
 	struct net_device *dev = skb->dev;
 	struct frag_hdr *fhdr;
-	struct nf_ct_frag6_queue *fq;
+	struct frag_queue *fq;
 	struct ipv6hdr *hdr;
 	int fhoff, nhoff;
 	u8 prevhdr;
@@ -567,7 +529,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 	if (nf_ct_frag6_queue(fq, clone, fhdr, nhoff) < 0) {
 		spin_unlock_bh(&fq->q.lock);
 		pr_debug("Can't insert skb to queue\n");
-		fq_put(fq);
+		inet_frag_put(&fq->q, &nf_frags);
 		goto ret_orig;
 	}
 
@@ -579,7 +541,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 	}
 	spin_unlock_bh(&fq->q.lock);
 
-	fq_put(fq);
+	inet_frag_put(&fq->q, &nf_frags);
 	return ret_skb;
 
 ret_orig:
@@ -614,7 +576,7 @@ int nf_ct_frag6_init(void)
 	nf_frags.constructor = ip6_frag_init;
 	nf_frags.destructor = NULL;
 	nf_frags.skb_free = nf_skb_free;
-	nf_frags.qsize = sizeof(struct nf_ct_frag6_queue);
+	nf_frags.qsize = sizeof(struct frag_queue);
 	nf_frags.match = ip6_frag_match;
 	nf_frags.frag_expire = nf_ct_frag6_expire;
 	nf_frags.secret_interval = 10 * 60 * HZ;
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 4ff9af6..abb0d88 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -65,24 +65,6 @@ struct ip6frag_skb_cb
 #define FRAG6_CB(skb)	((struct ip6frag_skb_cb*)((skb)->cb))
 
 
-/*
- *	Equivalent of ipv4 struct ipq
- */
-
-struct frag_queue
-{
-	struct inet_frag_queue	q;
-
-	__be32			id;		/* fragment id		*/
-	u32			user;
-	struct in6_addr		saddr;
-	struct in6_addr		daddr;
-
-	int			iif;
-	unsigned int		csum;
-	__u16			nhoffset;
-};
-
 static struct inet_frags ip6_frags;
 
 int ip6_frag_nqueues(struct net *net)
@@ -159,21 +141,6 @@ void ip6_frag_init(struct inet_frag_queue *q, void *a)
 }
 EXPORT_SYMBOL(ip6_frag_init);
 
-/* Destruction primitives. */
-
-static __inline__ void fq_put(struct frag_queue *fq)
-{
-	inet_frag_put(&fq->q, &ip6_frags);
-}
-
-/* Kill fq entry. It is not destroyed immediately,
- * because caller (and someone more) holds reference count.
- */
-static __inline__ void fq_kill(struct frag_queue *fq)
-{
-	inet_frag_kill(&fq->q, &ip6_frags);
-}
-
 static void ip6_evictor(struct net *net, struct inet6_dev *idev)
 {
 	int evicted;
@@ -183,20 +150,17 @@ static void ip6_evictor(struct net *net, struct inet6_dev *idev)
 		IP6_ADD_STATS_BH(net, idev, IPSTATS_MIB_REASMFAILS, evicted);
 }
 
-static void ip6_frag_expire(unsigned long data)
+void ip6_expire_frag_queue(struct frag_queue *fq, struct inet_frags *frags)
 {
-	struct frag_queue *fq;
 	struct net_device *dev = NULL;
 	struct net *net;
 
-	fq = container_of((struct inet_frag_queue *)data, struct frag_queue, q);
-
 	spin_lock(&fq->q.lock);
 
 	if (fq->q.last_in & INET_FRAG_COMPLETE)
 		goto out;
 
-	fq_kill(fq);
+	inet_frag_kill(&fq->q, frags);
 
 	net = container_of(fq->q.net, struct net, ipv6.frags);
 	rcu_read_lock();
@@ -222,7 +186,18 @@ out_rcu_unlock:
 	rcu_read_unlock();
 out:
 	spin_unlock(&fq->q.lock);
-	fq_put(fq);
+	inet_frag_put(&fq->q, frags);
+
+}
+EXPORT_SYMBOL(ip6_expire_frag_queue);
+
+static void ip6_frag_expire(unsigned long data)
+{
+	struct frag_queue *fq;
+
+	fq = container_of((struct inet_frag_queue *)data, struct frag_queue, q);
+
+	ip6_expire_frag_queue(fq, &ip6_frags);
 }
 
 static __inline__ struct frag_queue *
@@ -391,7 +366,7 @@ found:
 	return -1;
 
 discard_fq:
-	fq_kill(fq);
+	inet_frag_kill(&fq->q, &ip6_frags);
 err:
 	IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
 		      IPSTATS_MIB_REASMFAILS);
@@ -417,7 +392,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 	unsigned int nhoff;
 	int sum_truesize;
 
-	fq_kill(fq);
+	inet_frag_kill(&fq->q, &ip6_frags);
 
 	/* Make the one we just received the head. */
 	if (prev) {
@@ -586,7 +561,7 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 		ret = ip6_frag_queue(fq, skb, fhdr, IP6CB(skb)->nhoff);
 
 		spin_unlock(&fq->q.lock);
-		fq_put(fq);
+		inet_frag_put(&fq->q, &ip6_frags);
 		return ret;
 	}
 
