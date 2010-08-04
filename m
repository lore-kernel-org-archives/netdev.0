From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: use the nf_bridge of the last received skb in a fragment queue
Date: Thu,  5 Aug 2010 07:53:04 +0800
Message-ID: <1280965984-22883-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As we don't hold references to net devices in nf_bridge_info to prevent the
net devices go, we should always use the nf_bridge of the last received skb
in a fragment queue.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/ipv4/ip_fragment.c                  |   11 ++++++++---
 net/ipv6/netfilter/nf_conntrack_reasm.c |   10 ++++++++--
 net/ipv6/reassembly.c                   |   11 ++++++++---
 3 files changed, 24 insertions(+), 8 deletions(-)
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index b7c4165..cd0a630 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -88,7 +88,7 @@ int ip_frag_mem(struct net *net)
 }
 
 static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
-			 struct net_device *dev);
+			 struct net_device *dev, struct sk_buff *curr);
 
 struct ip4_create_arg {
 	struct iphdr *iph;
@@ -478,7 +478,7 @@ found:
 
 	if (qp->q.last_in == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
 	    qp->q.meat == qp->q.len)
-		return ip_frag_reasm(qp, prev, dev);
+		return ip_frag_reasm(qp, prev, dev, skb);
 
 	write_lock(&ip4_frags.lock);
 	list_move_tail(&qp->q.lru_list, &qp->q.net->lru_list);
@@ -494,7 +494,7 @@ err:
 /* Build a new IP datagram from all its fragments. */
 
 static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
-			 struct net_device *dev)
+			 struct net_device *dev, struct sk_buff *curr)
 {
 	struct net *net = container_of(qp->q.net, struct net, ipv4.frags);
 	struct iphdr *iph;
@@ -579,6 +579,11 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 	head->next = NULL;
 	head->dev = dev;
 	head->tstamp = qp->q.stamp;
+#ifdef CONFIG_BRIDGE_NETFILTER
+	nf_bridge_get(curr->nf_bridge);
+	nf_bridge_put(head->nf_bridge);
+	head->nf_bridge = curr->nf_bridge;
+#endif
 
 	iph = ip_hdr(head);
 	iph->frag_off = 0;
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 098a050..b5afad3 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -385,7 +385,8 @@ err:
  *	the last and the first frames arrived and all the bits are here.
  */
 static struct sk_buff *
-nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
+nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev,
+		  struct sk_buff *curr)
 {
 	struct sk_buff *fp, *op, *head = fq->q.fragments;
 	int    payload_len;
@@ -464,6 +465,11 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 	head->dev = dev;
 	head->tstamp = fq->q.stamp;
 	ipv6_hdr(head)->payload_len = htons(payload_len);
+#ifdef CONFIG_BRIDGE_NETFILTER
+	nf_bridge_get(curr->nf_bridge);
+	nf_bridge_put(head->nf_bridge);
+	head->nf_bridge = curr->nf_bridge;
+#endif
 
 	/* Yes, and fold redundant checksum back. 8) */
 	if (head->ip_summed == CHECKSUM_COMPLETE)
@@ -622,7 +628,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 
 	if (fq->q.last_in == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
 	    fq->q.meat == fq->q.len) {
-		ret_skb = nf_ct_frag6_reasm(fq, dev);
+		ret_skb = nf_ct_frag6_reasm(fq, dev, clone);
 		if (ret_skb == NULL)
 			pr_debug("Can't reassemble fragmented packets\n");
 	}
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 545c414..9ea4308 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -95,7 +95,7 @@ int ip6_frag_mem(struct net *net)
 }
 
 static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
-			  struct net_device *dev);
+			  struct net_device *dev, struct sk_buff *curr);
 
 /*
  * callers should be careful not to use the hash value outside the ipfrag_lock
@@ -429,7 +429,7 @@ found:
 
 	if (fq->q.last_in == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
 	    fq->q.meat == fq->q.len)
-		return ip6_frag_reasm(fq, prev, dev);
+		return ip6_frag_reasm(fq, prev, dev, skb);
 
 	write_lock(&ip6_frags.lock);
 	list_move_tail(&fq->q.lru_list, &fq->q.net->lru_list);
@@ -453,7 +453,7 @@ err:
  *	the last and the first frames arrived and all the bits are here.
  */
 static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
-			  struct net_device *dev)
+			  struct net_device *dev, struct sk_buff *curr)
 {
 	struct net *net = container_of(fq->q.net, struct net, ipv6.frags);
 	struct sk_buff *fp, *head = fq->q.fragments;
@@ -548,6 +548,11 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 	head->tstamp = fq->q.stamp;
 	ipv6_hdr(head)->payload_len = htons(payload_len);
 	IP6CB(head)->nhoff = nhoff;
+#ifdef CONFIG_BRIDGE_NETFILTER
+	nf_bridge_get(curr->nf_bridge);
+	nf_bridge_put(head->nf_bridge);
+	head->nf_bridge = curr->nf_bridge;
+#endif
 
 	/* Yes, and fold redundant checksum back. 8) */
 	if (head->ip_summed == CHECKSUM_COMPLETE)
