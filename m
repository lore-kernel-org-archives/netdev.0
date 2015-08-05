From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH 02/10] net: Use VRF device index for lookups on RX
Date: Wed,  5 Aug 2015 11:14:45 -0600
Message-ID: <1438794894-70217-3-git-send-email-dsa@cumulusnetworks.com>
References: <1438794894-70217-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net, svaidya@brocade.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:35071 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912AbbHERQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 13:16:24 -0400
Received: by iodd187 with SMTP id d187so55947952iod.2
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2015 10:16:23 -0700 (PDT)
In-Reply-To: <1438794894-70217-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On ingress use index of VRF master device for route lookups if real device
is enslaved. Rules are expected to be installed for the VRF device to
direct lookups to a specific table.

Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/fib_frontend.c | 8 +++++++-
 net/ipv4/route.c        | 3 ++-
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 6b98de0d7949..d8ced1d89f1b 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -45,6 +45,7 @@
 #include <net/ip_fib.h>
 #include <net/rtnetlink.h>
 #include <net/xfrm.h>
+#include <net/vrf.h>
 
 #ifndef CONFIG_IP_MULTIPLE_TABLES
 
@@ -309,7 +310,9 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	bool dev_match;
 
 	fl4.flowi4_oif = 0;
-	fl4.flowi4_iif = oif ? : LOOPBACK_IFINDEX;
+	fl4.flowi4_iif = vrf_master_ifindex_rcu(dev);
+	if (!fl4.flowi4_iif)
+		fl4.flowi4_iif = oif ? : LOOPBACK_IFINDEX;
 	fl4.daddr = src;
 	fl4.saddr = dst;
 	fl4.flowi4_tos = tos;
@@ -339,6 +342,9 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 		if (nh->nh_dev == dev) {
 			dev_match = true;
 			break;
+		} else if (vrf_master_ifindex_rcu(nh->nh_dev) == dev->ifindex) {
+			dev_match = true;
+			break;
 		}
 	}
 #else
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 18fd7c9095c7..c26ff1f7067d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -112,6 +112,7 @@
 #endif
 #include <net/secure_seq.h>
 #include <net/ip_tunnels.h>
+#include <net/vrf.h>
 
 #define RT_FL_TOS(oldflp4) \
 	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
@@ -1726,7 +1727,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	 *	Now we are ready to route packet.
 	 */
 	fl4.flowi4_oif = 0;
-	fl4.flowi4_iif = dev->ifindex;
+	fl4.flowi4_iif = vrf_master_ifindex_rcu(dev) ? : dev->ifindex;
 	fl4.flowi4_mark = skb->mark;
 	fl4.flowi4_tos = tos;
 	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
-- 
2.3.2 (Apple Git-55)
