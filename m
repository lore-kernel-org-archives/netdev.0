From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 7/7] ipv6: Store Router Alert option in IP6CB directly.
Date: Mon, 14 Jan 2013 00:02:45 +0900
Message-ID: <50F2CC95.1040205@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:38247 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755019Ab3AMPCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 10:02:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Router Alert option is very small and we can store the value
itself in the skb.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/ipv6.h      |    3 ++-
 include/uapi/linux/ipv6.h |    2 ++
 net/ipv6/exthdrs.c        |    3 ++-
 net/ipv6/ip6_input.c      |    5 ++---
 4 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 304a9f4..e971e37 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -84,7 +84,7 @@ static inline struct ipv6hdr *ipipv6_hdr(const struct sk_buff *skb)
 
 struct inet6_skb_parm {
 	int			iif;
-	__u16			ra;
+	__be16			ra;
 	__u16			hop;
 	__u16			dst0;
 	__u16			srcrt;
@@ -100,6 +100,7 @@ struct inet6_skb_parm {
 #define IP6SKB_XFRM_TRANSFORMED	1
 #define IP6SKB_FORWARDED	2
 #define IP6SKB_REROUTED		4
+#define IP6SKB_ROUTERALERT	8
 };
 
 #define IP6CB(skb)	((struct inet6_skb_parm*)((skb)->cb))
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 5a2991c..4bda4cf 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -63,6 +63,8 @@ struct ipv6_opt_hdr {
 #define ipv6_destopt_hdr ipv6_opt_hdr
 #define ipv6_hopopt_hdr  ipv6_opt_hdr
 
+/* Router Alert option values (RFC2711) */
+#define IPV6_OPT_ROUTERALERT_MLD	0x0000	/* MLD(RFC2710) */
 
 /*
  *	routing header type 0 (used in cmsghdr struct)
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 473f628..07a7d65 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -553,7 +553,8 @@ static bool ipv6_hop_ra(struct sk_buff *skb, int optoff)
 	const unsigned char *nh = skb_network_header(skb);
 
 	if (nh[optoff + 1] == 2) {
-		IP6CB(skb)->ra = optoff;
+		IP6CB(skb)->flags |= IP6SKB_ROUTERALERT;
+		memcpy(&IP6CB(skb)->ra, nh + optoff + 2, sizeof(IP6CB(skb)->ra));
 		return true;
 	}
 	LIMIT_NETDEBUG(KERN_DEBUG "ipv6_hop_ra: wrong RA length %d\n",
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 2ccd35e..4ac5bf3 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -280,9 +280,8 @@ int ip6_mc_input(struct sk_buff *skb)
 		struct inet6_skb_parm *opt = IP6CB(skb);
 
 		/* Check for MLD */
-		if (unlikely(opt->ra)) {
+		if (unlikely(opt->flags & IP6SKB_ROUTERALERT)) {
 			/* Check if this is a mld message */
-			u8 *ptr = skb_network_header(skb) + opt->ra;
 			u8 nexthdr = hdr->nexthdr;
 			__be16 frag_off;
 			int offset;
@@ -290,7 +289,7 @@ int ip6_mc_input(struct sk_buff *skb)
 			/* Check if the value of Router Alert
 			 * is for MLD (0x0000).
 			 */
-			if ((ptr[2] | ptr[3]) == 0) {
+			if (opt->ra == htons(IPV6_OPT_ROUTERALERT_MLD)) {
 				deliver = false;
 
 				if (!ipv6_ext_hdr(nexthdr)) {
-- 
1.7.9.5
