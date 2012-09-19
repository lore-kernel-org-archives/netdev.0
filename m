From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 2/4] ipv6: unify conntrack reassembly expire code with standard one
Date: Wed, 19 Sep 2012 10:50:09 +0800
Message-ID: <1348023011-16195-3-git-send-email-amwang@redhat.com>
References: <1348023011-16195-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, Cong Wang <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	=?UTF-8?q?Michal=20Kube=C4=8Dek?= <mkubecek@suse.cz>,
	David Miller <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1348023011-16195-1-git-send-email-amwang@redhat.com>
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

With this patch applied, I can see ICMP Time Exceeded sent
from the receiver when the sender sent out 3/4 fragmented
IPv6 UPD packet.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Michal Kube=C4=8Dek <mkubecek@suse.cz>
Cc: David Miller <davem@davemloft.net>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: netfilter-devel@vger.kernel.org
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/net/ipv6.h                      |   19 ++++++++
 net/ipv6/netfilter/nf_conntrack_reasm.c |   74 ++++++++---------------=
--------
 net/ipv6/reassembly.c                   |   63 ++++++++---------------=
---
 3 files changed, 57 insertions(+), 99 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 9bed5d4..81d4455 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -411,6 +411,25 @@ struct ip6_create_arg {
 void ip6_frag_init(struct inet_frag_queue *q, void *a);
 bool ip6_frag_match(struct inet_frag_queue *q, void *a);
=20
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
+void ip6_expire_frag_queue(struct net *net, struct frag_queue *fq,
+			   struct inet_frags *frags);
+
 static inline bool ipv6_addr_any(const struct in6_addr *a)
 {
 #if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG =3D=
=3D 64
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilt=
er/nf_conntrack_reasm.c
index f40f327..54274c3 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -57,19 +57,6 @@ struct nf_ct_frag6_skb_cb
=20
 #define NFCT_FRAG6_CB(skb)	((struct nf_ct_frag6_skb_cb*)((skb)->cb))
=20
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
=20
 #ifdef CONFIG_SYSCTL
@@ -151,9 +138,9 @@ static void __net_exit nf_ct_frags6_sysctl_unregist=
er(struct net *net)
=20
 static unsigned int nf_hashfn(struct inet_frag_queue *q)
 {
-	const struct nf_ct_frag6_queue *nq;
+	const struct frag_queue *nq;
=20
-	nq =3D container_of(q, struct nf_ct_frag6_queue, q);
+	nq =3D container_of(q, struct frag_queue, q);
 	return inet6_hash_frag(nq->id, &nq->saddr, &nq->daddr, nf_frags.rnd);
 }
=20
@@ -163,44 +150,21 @@ static void nf_skb_free(struct sk_buff *skb)
 		kfree_skb(NFCT_FRAG6_CB(skb)->orig);
 }
=20
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
 static void nf_ct_frag6_expire(unsigned long data)
 {
-	struct nf_ct_frag6_queue *fq;
-
-	fq =3D container_of((struct inet_frag_queue *)data,
-			struct nf_ct_frag6_queue, q);
+	struct frag_queue *fq;
+	struct net *net;
=20
-	spin_lock(&fq->q.lock);
+	fq =3D container_of((struct inet_frag_queue *)data, struct frag_queue=
, q);
+	net =3D container_of(fq->q.net, struct net, nf_frag.frags);
=20
-	if (fq->q.last_in & INET_FRAG_COMPLETE)
-		goto out;
-
-	fq_kill(fq);
-
-out:
-	spin_unlock(&fq->q.lock);
-	fq_put(fq);
+	ip6_expire_frag_queue(net, fq, &nf_frags);
 }
=20
 /* Creation primitives. */
-static inline struct nf_ct_frag6_queue *fq_find(struct net *net, __be3=
2 id,
-						u32 user, struct in6_addr *src,
-						struct in6_addr *dst)
+static inline struct frag_queue *fq_find(struct net *net, __be32 id,
+					 u32 user, struct in6_addr *src,
+					 struct in6_addr *dst)
 {
 	struct inet_frag_queue *q;
 	struct ip6_create_arg arg;
@@ -219,14 +183,14 @@ static inline struct nf_ct_frag6_queue *fq_find(s=
truct net *net, __be32 id,
 	if (q =3D=3D NULL)
 		goto oom;
=20
-	return container_of(q, struct nf_ct_frag6_queue, q);
+	return container_of(q, struct frag_queue, q);
=20
 oom:
 	return NULL;
 }
=20
=20
-static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_b=
uff *skb,
+static int nf_ct_frag6_queue(struct frag_queue *fq, struct sk_buff *sk=
b,
 			     const struct frag_hdr *fhdr, int nhoff)
 {
 	struct sk_buff *prev, *next;
@@ -367,7 +331,7 @@ found:
 	return 0;
=20
 discard_fq:
-	fq_kill(fq);
+	inet_frag_kill(&fq->q, &nf_frags);
 err:
 	return -1;
 }
@@ -382,12 +346,12 @@ err:
  *	the last and the first frames arrived and all the bits are here.
  */
 static struct sk_buff *
-nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev=
)
+nf_ct_frag6_reasm(struct frag_queue *fq, struct net_device *dev)
 {
 	struct sk_buff *fp, *op, *head =3D fq->q.fragments;
 	int    payload_len;
=20
-	fq_kill(fq);
+	inet_frag_kill(&fq->q, &nf_frags);
=20
 	WARN_ON(head =3D=3D NULL);
 	WARN_ON(NFCT_FRAG6_CB(head)->offset !=3D 0);
@@ -570,7 +534,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *=
skb, u32 user)
 	struct net *net =3D skb_dst(skb) ? dev_net(skb_dst(skb)->dev)
 				       : dev_net(skb->dev);
 	struct frag_hdr *fhdr;
-	struct nf_ct_frag6_queue *fq;
+	struct frag_queue *fq;
 	struct ipv6hdr *hdr;
 	int fhoff, nhoff;
 	u8 prevhdr;
@@ -619,7 +583,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *=
skb, u32 user)
 	if (nf_ct_frag6_queue(fq, clone, fhdr, nhoff) < 0) {
 		spin_unlock_bh(&fq->q.lock);
 		pr_debug("Can't insert skb to queue\n");
-		fq_put(fq);
+		inet_frag_put(&fq->q, &nf_frags);
 		goto ret_orig;
 	}
=20
@@ -631,7 +595,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *=
skb, u32 user)
 	}
 	spin_unlock_bh(&fq->q.lock);
=20
-	fq_put(fq);
+	inet_frag_put(&fq->q, &nf_frags);
 	return ret_skb;
=20
 ret_orig:
@@ -695,7 +659,7 @@ int nf_ct_frag6_init(void)
 	nf_frags.constructor =3D ip6_frag_init;
 	nf_frags.destructor =3D NULL;
 	nf_frags.skb_free =3D nf_skb_free;
-	nf_frags.qsize =3D sizeof(struct nf_ct_frag6_queue);
+	nf_frags.qsize =3D sizeof(struct frag_queue);
 	nf_frags.match =3D ip6_frag_match;
 	nf_frags.frag_expire =3D nf_ct_frag6_expire;
 	nf_frags.secret_interval =3D 10 * 60 * HZ;
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 4ff9af6..0ee5533 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -65,24 +65,6 @@ struct ip6frag_skb_cb
 #define FRAG6_CB(skb)	((struct ip6frag_skb_cb*)((skb)->cb))
=20
=20
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
=20
 int ip6_frag_nqueues(struct net *net)
@@ -159,21 +141,6 @@ void ip6_frag_init(struct inet_frag_queue *q, void=
 *a)
 }
 EXPORT_SYMBOL(ip6_frag_init);
=20
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
@@ -183,22 +150,18 @@ static void ip6_evictor(struct net *net, struct i=
net6_dev *idev)
 		IP6_ADD_STATS_BH(net, idev, IPSTATS_MIB_REASMFAILS, evicted);
 }
=20
-static void ip6_frag_expire(unsigned long data)
+void ip6_expire_frag_queue(struct net *net, struct frag_queue *fq,
+			   struct inet_frags *frags)
 {
-	struct frag_queue *fq;
 	struct net_device *dev =3D NULL;
-	struct net *net;
-
-	fq =3D container_of((struct inet_frag_queue *)data, struct frag_queue=
, q);
=20
 	spin_lock(&fq->q.lock);
=20
 	if (fq->q.last_in & INET_FRAG_COMPLETE)
 		goto out;
=20
-	fq_kill(fq);
+	inet_frag_kill(&fq->q, frags);
=20
-	net =3D container_of(fq->q.net, struct net, ipv6.frags);
 	rcu_read_lock();
 	dev =3D dev_get_by_index_rcu(net, fq->iif);
 	if (!dev)
@@ -222,7 +185,19 @@ out_rcu_unlock:
 	rcu_read_unlock();
 out:
 	spin_unlock(&fq->q.lock);
-	fq_put(fq);
+	inet_frag_put(&fq->q, frags);
+}
+EXPORT_SYMBOL(ip6_expire_frag_queue);
+
+static void ip6_frag_expire(unsigned long data)
+{
+	struct frag_queue *fq;
+	struct net *net;
+
+	fq =3D container_of((struct inet_frag_queue *)data, struct frag_queue=
, q);
+	net =3D container_of(fq->q.net, struct net, ipv6.frags);
+
+	ip6_expire_frag_queue(net, fq, &ip6_frags);
 }
=20
 static __inline__ struct frag_queue *
@@ -391,7 +366,7 @@ found:
 	return -1;
=20
 discard_fq:
-	fq_kill(fq);
+	inet_frag_kill(&fq->q, &ip6_frags);
 err:
 	IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
 		      IPSTATS_MIB_REASMFAILS);
@@ -417,7 +392,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, st=
ruct sk_buff *prev,
 	unsigned int nhoff;
 	int sum_truesize;
=20
-	fq_kill(fq);
+	inet_frag_kill(&fq->q, &ip6_frags);
=20
 	/* Make the one we just received the head. */
 	if (prev) {
@@ -586,7 +561,7 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 		ret =3D ip6_frag_queue(fq, skb, fhdr, IP6CB(skb)->nhoff);
=20
 		spin_unlock(&fq->q.lock);
-		fq_put(fq);
+		inet_frag_put(&fq->q, &ip6_frags);
 		return ret;
 	}
=20
--=20
1.7.7.6

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
