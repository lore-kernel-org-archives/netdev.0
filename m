From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 17/20] [PATCH] [IPV6] MIP6: Add receiving mobility header functions through raw socket.
Date: Sat, 29 Jul 2006 18:39:03 +0900
Message-ID: <11541659431164-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:51843 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1422724AbWG2JjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:39:04 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Like ICMPv6, mobility header is handled through raw socket.
In inbound case, check only whether ICMPv6 error should be sent as a reply
or not by kernel.
Based on MIPL2 kernel patch.
---
 include/net/mip6.h |    4 ++
 net/ipv6/mip6.c    |   87 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/raw.c     |   29 +++++++++++++++++
 3 files changed, 119 insertions(+), 1 deletions(-)

diff --git a/include/net/mip6.h b/include/net/mip6.h
index fd43178..68263c6 100644
--- a/include/net/mip6.h
+++ b/include/net/mip6.h
@@ -25,6 +25,9 @@
 #ifndef _NET_MIP6_H
 #define _NET_MIP6_H
 
+#include <linux/skbuff.h>
+#include <net/sock.h>
+
 #define MIP6_OPT_PAD_1	0
 #define MIP6_OPT_PAD_N	1
 
@@ -53,5 +56,6 @@ #define IP6_MH_TYPE_MAX		IP6_MH_TYPE_BER
 
 extern int mip6_init(void);
 extern void mip6_fini(void);
+extern int mip6_mh_filter(struct sock *sk, struct sk_buff *skb);
 
 #endif
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index ebe2f76..fb973d9 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -27,7 +27,10 @@ #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/time.h>
 #include <linux/ipv6.h>
+#include <linux/icmpv6.h>
+#include <net/sock.h>
 #include <net/ipv6.h>
+#include <net/ip6_checksum.h>
 #include <net/xfrm.h>
 #include <net/mip6.h>
 
@@ -58,6 +61,90 @@ static inline void *mip6_padn(__u8 *data
 }
 
 /*****************************
+ * Mobility Header
+ *****************************/
+
+static int _mh_len(int type)
+{
+	int len = 0;
+
+	switch (type) {
+	case IP6_MH_TYPE_BRR:
+		len = 0;
+		break;
+	case IP6_MH_TYPE_HOTI:
+	case IP6_MH_TYPE_COTI:
+	case IP6_MH_TYPE_BU:
+	case IP6_MH_TYPE_BACK:
+		len = 1;
+		break;
+	case IP6_MH_TYPE_HOT:
+	case IP6_MH_TYPE_COT:
+	case IP6_MH_TYPE_BERROR:
+		len = 2;
+		break;
+	}
+	return len;
+}
+
+static inline void mip6_param_prob(struct sk_buff *skb, int code, int pos)
+{
+	icmpv6_send(skb, ICMPV6_PARAMPROB, code, pos, skb->dev);
+}
+
+int mip6_mh_filter(struct sock *sk, struct sk_buff *skb)
+{
+	struct ip6_mh *mh;
+	int mhlen;
+
+	if (!pskb_may_pull(skb, (skb->h.raw - skb->data) + 8) ||
+	    !pskb_may_pull(skb, (skb->h.raw - skb->data) + ((skb->h.raw[1] + 1) << 3)))
+		return -1;
+
+	mh = (struct ip6_mh *)skb->h.raw;
+
+	if (mh->ip6mh_hdrlen < _mh_len(mh->ip6mh_type)) {
+		LIMIT_NETDEBUG(KERN_DEBUG "mip6: MH message too short: %d vs >=%d\n",
+			       mh->ip6mh_hdrlen, _mh_len(mh->ip6mh_type));
+		mip6_param_prob(skb, 0, (&mh->ip6mh_hdrlen) - skb->nh.raw);
+		return -1;
+	}
+	mhlen = (mh->ip6mh_hdrlen + 1) << 3;
+
+	if (skb->ip_summed == CHECKSUM_HW) {
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		if (csum_ipv6_magic(&skb->nh.ipv6h->saddr,
+				    &skb->nh.ipv6h->daddr,
+				    mhlen, IPPROTO_MH,
+				    skb->csum)) {
+			LIMIT_NETDEBUG(KERN_DEBUG "mip6: MH hw checksum failed\n");
+			skb->ip_summed = CHECKSUM_NONE;
+		}
+	}
+	if (skb->ip_summed == CHECKSUM_NONE) {
+		if (csum_ipv6_magic(&skb->nh.ipv6h->saddr,
+				    &skb->nh.ipv6h->daddr,
+				    mhlen, IPPROTO_MH,
+				    skb_checksum(skb, 0, mhlen, 0))) {
+			LIMIT_NETDEBUG(KERN_DEBUG "mip6: MH checksum failed [%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x > %04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x]\n",
+				       NIP6(skb->nh.ipv6h->saddr),
+				       NIP6(skb->nh.ipv6h->daddr));
+			return -1;
+		}
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	}
+
+	if (mh->ip6mh_proto != IPPROTO_NONE) {
+		LIMIT_NETDEBUG(KERN_DEBUG "mip6: MH invalid payload proto = %d\n",
+			       mh->ip6mh_proto);
+		mip6_param_prob(skb, 0, (&mh->ip6mh_proto) - skb->nh.raw);
+		return -1;
+	}
+
+	return 0;
+}
+
+/*****************************
  * Destination Options Header
  *****************************/
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index fa1ce0a..e0faf4d 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -50,6 +50,9 @@ #include <net/transp_v6.h>
 #include <net/udp.h>
 #include <net/inet_common.h>
 #include <net/tcp_states.h>
+#ifdef CONFIG_IPV6_MIP6
+#include <net/mip6.h>
+#endif
 
 #include <net/rawv6.h>
 #include <net/xfrm.h>
@@ -169,8 +172,32 @@ int ipv6_raw_deliver(struct sk_buff *skb
 	sk = __raw_v6_lookup(sk, nexthdr, daddr, saddr, IP6CB(skb)->iif);
 
 	while (sk) {
+		int filtered;
+
 		delivered = 1;
-		if (nexthdr != IPPROTO_ICMPV6 || !icmpv6_filter(sk, skb)) {
+		switch (nexthdr) {
+		case IPPROTO_ICMPV6:
+			filtered = icmpv6_filter(sk, skb);
+			break;
+#ifdef CONFIG_IPV6_MIP6
+		case IPPROTO_MH:
+			/* XXX: MH validation: To validate only once, this is
+			 * placed here. It should be after checking xfrm
+			 * policy, however, it doesn't. The checking xfrm
+			 * policy is placed in rawv6_rcv() because it is
+			 * required for each socket. Fix it.
+			 */
+			filtered = mip6_mh_filter(sk, skb);
+			break;
+#endif
+		default:
+			filtered = 0;
+			break;
+		}
+
+		if (filtered < 0)
+			break;
+		if (filtered == 0) {
 			struct sk_buff *clone = skb_clone(skb, GFP_ATOMIC);
 
 			/* Not releasing hash table! */
-- 
1.4.1

