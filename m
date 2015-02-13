From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH] ipv6: address issue in __ip6_append_data
Date: Fri, 13 Feb 2015 17:30:59 +0200
Message-ID: <1423841459-21880-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Madalin Bucur <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>, <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0137.outbound.protection.outlook.com ([157.56.110.137]:55284
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752023AbbBMREE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Feb 2015 12:04:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I think I've found a problem that allows generic IPv6 traffic to be
sent by the stack with CHECKSUM_PARTIAL to a netdevice that declares
NETIF_F_IPV6_CSUM. The NETIF_F_IPV6_CSUM flag is based on the
NETIF_F_IPV6_CSUM_BIT that is described as referring only to TCP and
UDP but in my test ICMPv6 frames with CHECKSUM_PARTIAL are seen:

NETIF_F_IPV6_CSUM_BIT,          /* Can checksum TCP/UDP over IPV6 */

I've traced the issue to a recent commit that includes this check:

	rt->dst.dev->features & NETIF_F_V6_CSUM

The problem with this is that NETIF_F_V6_CSUM is more than one bit:

#define NETIF_F_V6_CSUM         (NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)

Thus the above check should be either:

	(rt->dst.dev->features & NETIF_F_V6_CSUM) == NETIF_F_V6_CSUM

or probably should use NETIF_F_HW_CSUM only:

	rt->dst.dev->features & NETIF_F_HW_CSUM

The mentioned commit is 32dce968dd987adfb0c00946d78dad9154f64759

> Author: Vlad Yasevich <vyasevich@gmail.com>
> Date:   Sat Jan 31 10:40:18 2015 -0500
>
>	ipv6: Allow for partial checksums on non-ufo packets
>
>	Currntly, if we are not doing UFO on the packet, all UDP
>	packets will start with CHECKSUM_NONE and thus perform full
>	checksum computations in software even if device support
>	IPv6 checksum offloading.

>	Let's start start with CHECKSUM_PARTIAL if the device
>	supports it and we are sending only a single packet at
>	or below mtu size.

>	Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>	Signed-off-by: David S. Miller <davem@davemloft.net>

Reverting this commit solved the issue, then the changes below were
validated as well. The problem was evidentiated by running ping6
but it should be visible with any IPv6 payload that it is not UDP
nor TCP.

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
---
 net/ipv6/ip6_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d33df4c..7177f63 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1275,7 +1275,7 @@ emsgsize:
 	 */
 	if (!skb &&
 	    length + fragheaderlen < mtu &&
-	    rt->dst.dev->features & NETIF_F_V6_CSUM &&
+	    (rt->dst.dev->features & NETIF_F_V6_CSUM) == NETIF_F_V6_CSUM &&
 	    !exthdrlen)
 		csummode = CHECKSUM_PARTIAL;
 	/*
-- 
1.7.11.7
