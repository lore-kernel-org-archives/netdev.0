From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 32/44] [IPV6] MIP6: Add receiving mobility header functions through raw socket.
Date: Thu, 24 Aug 2006 00:02:33 +0900
Message-ID: <11563453671187-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org> <11563453662913-git-send-email-yoshfuji@linux-ipv6.org> <11563453663400-git-send-email-yoshfuji@linux-ipv6.org> <1156345366549-git-send-email-yoshfuji@linux-ipv6.org> <11563453662956-git-send-email-yoshfuji@linux-ipv6.org> <11563453661764-git-send-email-yoshfuji@linux-ipv6.org> <11563453663275-git-send-email-yoshfuji@linux-ipv6.org> <11563453671174-git-send-email-yoshfuji@linux-ipv6.org> <11563453674049-git-send-email-yoshfuji@linux-ipv6.org> <11563453673517-git-send-email-yoshfuji@linux-ipv6.org> <11563453674137-git-send-email-yoshfuji@linux-ipv6.org> <11563453671944-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:8329 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964947AbWHWPCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:51 -0400
To: davem@davemloft.net
In-Reply-To: <11563453671944-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Like ICMPv6, mobility header is handled through raw socket.
In inbound case, check only whether ICMPv6 error should be sent as a reply
or not by kernel.
Based on MIPL2 kernel patch.

This patch was also written by: Ville Nuorvala <vnuorval@tcs.hut.fi>
This patch was also written by: Antti Tuominen <anttit@tcs.hut.fi>

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/mip6.h |    4 +++
 net/ipv6/mip6.c    |   83 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/raw.c     |   29 ++++++++++++++++++
 3 files changed, 115 insertions(+), 1 deletions(-)

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
index a8adf89..7b5f893 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -26,7 +26,10 @@ #include <linux/config.h>
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/ipv6.h>
+#include <linux/icmpv6.h>
+#include <net/sock.h>
 #include <net/ipv6.h>
+#include <net/ip6_checksum.h>
 #include <net/xfrm.h>
 #include <net/mip6.h>
 
@@ -55,6 +58,86 @@ static inline void *mip6_padn(__u8 *data
 	return data + padlen;
 }
 
+static inline void mip6_param_prob(struct sk_buff *skb, int code, int pos)
+{
+	icmpv6_send(skb, ICMPV6_PARAMPROB, code, pos, skb->dev);
+}
+
+static int mip6_mh_len(int type)
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
+	if (mh->ip6mh_hdrlen < mip6_mh_len(mh->ip6mh_type)) {
+		LIMIT_NETDEBUG(KERN_DEBUG "mip6: MH message too short: %d vs >=%d\n",
+			       mh->ip6mh_hdrlen, mip6_mh_len(mh->ip6mh_type));
+		mip6_param_prob(skb, 0, (&mh->ip6mh_hdrlen) - skb->nh.raw);
+		return -1;
+	}
+	mhlen = (mh->ip6mh_hdrlen + 1) << 3;
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE) {
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
 static int mip6_destopt_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ipv6hdr *iph = skb->nh.ipv6h;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index bf55b5b..2178a2a 100644
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
+			/* XXX: To validate MH only once for each packet,
+			 * this is placed here. It should be after checking
+			 * xfrm policy, however it doesn't. The checking xfrm
+			 * policy is placed in rawv6_rcv() because it is
+			 * required for each socket.
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
1.4.0

