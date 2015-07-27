From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 04/16] net: Use VRF device index for lookups on RX
Date: Mon, 27 Jul 2015 12:30:57 -0600
Message-ID: <1438021869-49186-5-git-send-email-dsa@cumulusnetworks.com>
References: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net, svaidya@brocade.com,
	mingo@kernel.org, luto@amacapital.net,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:38487 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753628AbbG0Sc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 14:32:58 -0400
Received: by iggf3 with SMTP id f3so89044551igg.1
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 11:32:57 -0700 (PDT)
In-Reply-To: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
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
index c565fc182240..6e68a003d0fd 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -45,6 +45,7 @@
 #include <net/ip_fib.h>
 #include <net/rtnetlink.h>
 #include <net/xfrm.h>
+#include <net/vrf.h>
 
 #ifndef CONFIG_IP_MULTIPLE_TABLES
 
@@ -311,7 +312,9 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	bool dev_match;
 
 	fl4.flowi4_oif = 0;
-	fl4.flowi4_iif = oif ? : LOOPBACK_IFINDEX;
+	fl4.flowi4_iif = vrf_master_dev_ifindex(dev);
+	if (!fl4.flowi4_iif)
+		fl4.flowi4_iif = oif ? : LOOPBACK_IFINDEX;
 	fl4.daddr = src;
 	fl4.saddr = dst;
 	fl4.flowi4_tos = tos;
@@ -341,6 +344,9 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 		if (nh->nh_dev == dev) {
 			dev_match = true;
 			break;
+		} else if (vrf_master_dev_ifindex(nh->nh_dev) == dev->ifindex) {
+			dev_match = true;
+			break;
 		}
 	}
 #else
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ef140919211f..ba74c83c05be 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -112,6 +112,7 @@
 #endif
 #include <net/secure_seq.h>
 #include <net/ip_tunnels.h>
+#include <net/vrf.h>
 
 #define RT_FL_TOS(oldflp4) \
 	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
@@ -1735,7 +1736,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	 *	Now we are ready to route packet.
 	 */
 	fl4.flowi4_oif = 0;
-	fl4.flowi4_iif = dev->ifindex;
+	fl4.flowi4_iif = vrf_master_dev_ifindex(dev) ? : dev->ifindex;
 	fl4.flowi4_mark = skb->mark;
 	fl4.flowi4_tos = tos;
 	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
-- 
2.3.2 (Apple Git-55)
