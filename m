From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 20/20] [PATCH] [IPV6] MIP6: Transformation support mobility header.
Date: Sat, 29 Jul 2006 18:39:10 +0900
Message-ID: <11541659501671-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:54915 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1422726AbWG2JjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:39:11 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Transformation support mobility header.
Based on MIPL2 kernel patch.
---
 include/net/xfrm.h      |    5 +++++
 net/ipv6/xfrm6_policy.c |   15 +++++++++++++++
 2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 0d14b1f..85398b0 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -587,6 +587,11 @@ u16 xfrm_flowi_sport(struct flowi *fl)
 	case IPPROTO_ICMPV6:
 		port = htons(fl->fl_icmp_type);
 		break;
+#ifdef CONFIG_IPV6_MIP6
+	case IPPROTO_MH:
+		port = htons(fl->fl_mh_type);
+		break;
+#endif
 	default:
 		port = 0;	/*XXX*/
 	}
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index eaa1b0d..98e407e 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -19,6 +19,9 @@ #include <net/xfrm.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
+#ifdef CONFIG_IPV6_MIP6
+#include <net/mip6.h>
+#endif
 
 static struct dst_ops xfrm6_dst_ops;
 static struct xfrm_policy_afinfo xfrm6_policy_afinfo;
@@ -247,6 +250,18 @@ _decode_session6(struct sk_buff *skb, st
 			fl->proto = nexthdr;
 			return;
 
+#ifdef CONFIG_IPV6_MIP6
+		case IPPROTO_MH:
+			if (pskb_may_pull(skb, skb->nh.raw + offset + 3 - skb->data)) {
+				struct ip6_mh *mh;
+				mh = (struct ip6_mh *)exthdr;
+
+				fl->fl_mh_type = mh->ip6mh_type;
+			}
+			fl->proto = nexthdr;
+			return;
+#endif
+
 		/* XXX Why are there these headers? */
 		case IPPROTO_AH:
 		case IPPROTO_ESP:
-- 
1.4.1

