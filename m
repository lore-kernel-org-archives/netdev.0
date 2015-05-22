From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 2/2] ip_fragment: don't forward defragmented DF packet
Date: Fri, 22 May 2015 16:32:51 +0200
Message-ID: <1432305171-21932-3-git-send-email-fw@strlen.de>
References: <1432305171-21932-1-git-send-email-fw@strlen.de>
Cc: hannes@stressinduktion.org, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:38013 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756977AbbEVOdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 10:33:18 -0400
In-Reply-To: <1432305171-21932-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently always send fragments without DF bit set.

Thus, given following setup:

mtu1500 - mtu1500:1400 - mtu1400:1280 - mtu1280
   A           R1              R2         B

Where R1 and R2 run linux with netfilter defragmentation/conntrack
enabled, then if Host A sent a fragmented packet _with_ DF set to B, R1
will respond with icmp too big error if one of these fragments exceeded
1400 bytes.

However, if R1 receives fragment sizes 1200 and 100, it would
forward the reassembled packet without refragmenting, i.e.
R2 will send an icmp error in response to a packet that was never sent,
citing mtu that the original sender never exceeded.

The other minor issue is that a refragmentation on R1 will conceal the
MTU of R2-B since refragmentation does not set DF bit on the fragments.

This modifies ip_fragment so that we track largest fragment size seen
both for DF and non-DF packets, and set frag_max_size to the largest
value.

If the DF fragment size is larger or equal to the non-df one, we will
consider the packet a path mtu probe:
We set DF bit on the reassembled skb and also tag it with a new IPCB flag
to force refragmentation even if skb fits outdev mtu.

We will also set DF bit on each fragment in this case.

Joint work with Hannes Frederic Sowa.

Reported-by: Jesse Gross <jesse@nicira.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/inet_frag.h |  2 +-
 include/net/ip.h        |  1 +
 net/ipv4/ip_fragment.c  | 31 ++++++++++++++++++++++++++-----
 net/ipv4/ip_output.c    | 12 ++++++++++--
 4 files changed, 38 insertions(+), 8 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 8d17655..e1300b3 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -43,7 +43,7 @@ enum {
  * @len: total length of the original datagram
  * @meat: length of received fragments so far
  * @flags: fragment queue flags
- * @max_size: (ipv4 only) maximum received fragment size with IP_DF set
+ * @max_size: maximum received fragment size
  * @net: namespace that this frag belongs to
  */
 struct inet_frag_queue {
diff --git a/include/net/ip.h b/include/net/ip.h
index 7921a36..9b976cf 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -45,6 +45,7 @@ struct inet_skb_parm {
 #define IPSKB_FRAG_COMPLETE	BIT(3)
 #define IPSKB_REROUTED		BIT(4)
 #define IPSKB_DOREDIRECT	BIT(5)
+#define IPSKB_FRAG_PMTU		BIT(6)
 
 	u16			frag_max_size;
 };
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 47fa64e..a50dc6d 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -75,6 +75,7 @@ struct ipq {
 	__be16		id;
 	u8		protocol;
 	u8		ecn; /* RFC3168 support */
+	u16		max_df_size; /* largest frag with DF set seen */
 	int             iif;
 	unsigned int    rid;
 	struct inet_peer *peer;
@@ -326,6 +327,7 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 {
 	struct sk_buff *prev, *next;
 	struct net_device *dev;
+	unsigned int fragsize;
 	int flags, offset;
 	int ihl, end;
 	int err = -ENOENT;
@@ -481,9 +483,14 @@ found:
 	if (offset == 0)
 		qp->q.flags |= INET_FRAG_FIRST_IN;
 
+	fragsize = skb->len + ihl;
+
+	if (fragsize > qp->q.max_size)
+		qp->q.max_size = fragsize;
+
 	if (ip_hdr(skb)->frag_off & htons(IP_DF) &&
-	    skb->len + ihl > qp->q.max_size)
-		qp->q.max_size = skb->len + ihl;
+	    fragsize > qp->max_df_size)
+		qp->max_df_size = fragsize;
 
 	if (qp->q.flags == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
 	    qp->q.meat == qp->q.len) {
@@ -613,13 +620,27 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 	head->next = NULL;
 	head->dev = dev;
 	head->tstamp = qp->q.stamp;
-	IPCB(head)->frag_max_size = qp->q.max_size;
+	IPCB(head)->frag_max_size = max(qp->max_df_size, qp->q.max_size);
 
 	iph = ip_hdr(head);
-	/* max_size != 0 implies at least one fragment had IP_DF set */
-	iph->frag_off = qp->q.max_size ? htons(IP_DF) : 0;
 	iph->tot_len = htons(len);
 	iph->tos |= ecn;
+
+	/* When we set IP_DF on a refragmented skb we must also force a
+	 * call to ip_fragment to avoid forwarding a DF-skb of size s while
+	 * original sender only sent fragments of size f (where f < s).
+	 *
+	 * We only set DF/IPSKB_FRAG_PMTU if such DF fragment was the largest
+	 * frag seen to avoid sending tiny DF-fragments in case skb was built
+	 * from one very small df-fragment and one large non-df frag.
+	 */
+	if (qp->max_df_size == qp->q.max_size) {
+		IPCB(head)->flags |= IPSKB_FRAG_PMTU;
+		iph->frag_off = htons(IP_DF);
+	} else {
+		iph->frag_off = 0;
+	}
+
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMOKS);
 	qp->q.fragments = NULL;
 	qp->q.fragments_tail = NULL;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index e84a389..9b55ef6 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -278,7 +278,7 @@ static int ip_finish_output(struct sock *sk, struct sk_buff *skb)
 	if (skb_is_gso(skb))
 		return ip_finish_output_gso(sk, skb, mtu);
 
-	if (skb->len > mtu)
+	if (skb->len > mtu || (IPCB(skb)->flags & IPSKB_FRAG_PMTU))
 		return ip_fragment(sk, skb, mtu, ip_finish_output2);
 
 	return ip_finish_output2(sk, skb);
@@ -492,7 +492,10 @@ static int ip_fragment(struct sock *sk, struct sk_buff *skb,
 {
 	struct iphdr *iph = ip_hdr(skb);
 
-	if (unlikely(((iph->frag_off & htons(IP_DF)) && !skb->ignore_df) ||
+	if ((iph->frag_off & htons(IP_DF)) == 0)
+		return ip_do_fragment(sk, skb, output);
+
+	if (unlikely(!skb->ignore_df ||
 		     (IPCB(skb)->frag_max_size &&
 		      IPCB(skb)->frag_max_size > mtu))) {
 		struct rtable *rt = skb_rtable(skb);
@@ -537,6 +540,8 @@ int ip_do_fragment(struct sock *sk, struct sk_buff *skb,
 	iph = ip_hdr(skb);
 
 	mtu = ip_skb_dst_mtu(skb);
+	if (IPCB(skb)->frag_max_size && IPCB(skb)->frag_max_size < mtu)
+		mtu = IPCB(skb)->frag_max_size;
 
 	/*
 	 *	Setup starting values.
@@ -732,6 +737,9 @@ slow_path:
 		iph = ip_hdr(skb2);
 		iph->frag_off = htons((offset >> 3));
 
+		if (IPCB(skb)->flags & IPSKB_FRAG_PMTU)
+			iph->frag_off |= htons(IP_DF);
+
 		/* ANK: dirty, but effective trick. Upgrade options only if
 		 * the segment to be fragmented was THE FIRST (otherwise,
 		 * options are already fixed) and make it ONCE
-- 
2.0.5
