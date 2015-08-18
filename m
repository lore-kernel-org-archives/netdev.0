From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH ipsec-next] xfrm: Use VRF master index if output device is enslaved
Date: Tue, 18 Aug 2015 09:54:56 -0600
Message-ID: <1439913296-6026-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: steffen.klassert@secunet.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:36717 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753429AbbHRPzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 11:55:48 -0400
Received: by igxp17 with SMTP id p17so84172967igx.1
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 08:55:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Directs route lookups to VRF table. Compiles out if NET_VRF is not
enabled. With this patch able to successfully bring up ipsec tunnels
in VRFs, even with duplicate network configuration (IPv4 tested).

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/xfrm4_policy.c | 7 +++++--
 net/ipv6/xfrm6_policy.c | 7 +++++--
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 55b3c0f4dde5..35757f6af2d5 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -15,6 +15,7 @@
 #include <net/dst.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
+#include <net/vrf.h>
 
 static struct xfrm_policy_afinfo xfrm4_policy_afinfo;
 
@@ -107,8 +108,10 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 	struct flowi4 *fl4 = &fl->u.ip4;
 	int oif = 0;
 
-	if (skb_dst(skb))
-		oif = skb_dst(skb)->dev->ifindex;
+	if (skb_dst(skb)) {
+		oif = vrf_master_ifindex_rcu(skb_dst(skb)->dev) ?
+			: skb_dst(skb)->dev->ifindex;
+	}
 
 	memset(fl4, 0, sizeof(struct flowi4));
 	fl4->flowi4_mark = skb->mark;
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index a74013d3eceb..4a88b89becf5 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -20,6 +20,7 @@
 #include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
+#include <net/vrf.h>
 #if IS_ENABLED(CONFIG_IPV6_MIP6)
 #include <net/mip6.h>
 #endif
@@ -131,8 +132,10 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 
 	nexthdr = nh[nhoff];
 
-	if (skb_dst(skb))
-		oif = skb_dst(skb)->dev->ifindex;
+	if (skb_dst(skb)) {
+		oif = vrf_master_ifindex_rcu(skb_dst(skb)->dev) ?
+			: skb_dst(skb)->dev->ifindex;
+	}
 
 	memset(fl6, 0, sizeof(struct flowi6));
 	fl6->flowi6_mark = skb->mark;
-- 
2.3.2 (Apple Git-55)
