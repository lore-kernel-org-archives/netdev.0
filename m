From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 01/19] ipv4: fix path MTU discovery with connection tracking
Date: Tue, 28 Aug 2012 23:48:41 +0200
Message-ID: <1346190539-9963-2-git-send-email-kaber@trash.net>
References: <1346190539-9963-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59143 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753364Ab2H1VtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 17:49:03 -0400
In-Reply-To: <1346190539-9963-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv4 conntrack defragments incoming packet at the PRE_ROUTING hook and
(in case of forwarded packets) refragments them at POST_ROUTING
independent of the IP_DF flag. Refragmentation uses the dst_mtu() of
the local route without caring about the original fragment sizes,
thereby breaking PMTUD.

This patch fixes this by keeping track of the largest received fragment
with IP_DF set and generates an ICMP fragmentation required error during
refragmentation if that size exceeds the MTU.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Acked-by: Eric Dumazet <edumazet@google.com>
Acked-by: David S. Miller <davem@davemloft.net>
---
 include/net/inet_frag.h |    2 ++
 include/net/ip.h        |    2 ++
 net/ipv4/ip_fragment.c  |    8 +++++++-
 net/ipv4/ip_output.c    |    4 +++-
 4 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 2431cf8..5098ee7 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -29,6 +29,8 @@ struct inet_frag_queue {
 #define INET_FRAG_COMPLETE	4
 #define INET_FRAG_FIRST_IN	2
 #define INET_FRAG_LAST_IN	1
+
+	u16			max_size;
 };
 
 #define INETFRAGS_HASHSZ		64
diff --git a/include/net/ip.h b/include/net/ip.h
index 5a5d84d..0707fb9 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -42,6 +42,8 @@ struct inet_skb_parm {
 #define IPSKB_XFRM_TRANSFORMED	4
 #define IPSKB_FRAG_COMPLETE	8
 #define IPSKB_REROUTED		16
+
+	u16			frag_max_size;
 };
 
 static inline unsigned int ip_hdrlen(const struct sk_buff *skb)
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 8d07c97..fa6a12c 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -523,6 +523,10 @@ found:
 	if (offset == 0)
 		qp->q.last_in |= INET_FRAG_FIRST_IN;
 
+	if (ip_hdr(skb)->frag_off & htons(IP_DF) &&
+	    skb->len + ihl > qp->q.max_size)
+		qp->q.max_size = skb->len + ihl;
+
 	if (qp->q.last_in == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
 	    qp->q.meat == qp->q.len)
 		return ip_frag_reasm(qp, prev, dev);
@@ -646,9 +650,11 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 	head->next = NULL;
 	head->dev = dev;
 	head->tstamp = qp->q.stamp;
+	IPCB(head)->frag_max_size = qp->q.max_size;
 
 	iph = ip_hdr(head);
-	iph->frag_off = 0;
+	/* max_size != 0 implies at least one fragment had IP_DF set */
+	iph->frag_off = qp->q.max_size ? htons(IP_DF) : 0;
 	iph->tot_len = htons(len);
 	iph->tos |= ecn;
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMOKS);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index c196d74..a5beab1 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -467,7 +467,9 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 
 	iph = ip_hdr(skb);
 
-	if (unlikely((iph->frag_off & htons(IP_DF)) && !skb->local_df)) {
+	if (unlikely(((iph->frag_off & htons(IP_DF)) && !skb->local_df) ||
+		     (IPCB(skb)->frag_max_size &&
+		      IPCB(skb)->frag_max_size > dst_mtu(&rt->dst)))) {
 		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 			  htonl(ip_skb_dst_mtu(skb)));
-- 
1.7.1
