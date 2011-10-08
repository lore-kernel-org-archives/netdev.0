From: Yinglin Sun <Yinglin.Sun@emc.com>
Subject: [PATCH] bonding: L2L3 xmit doesn't support IPv6
Date: Fri,  7 Oct 2011 22:36:45 -0700
Message-ID: <1318052205-21991-1-git-send-email-Yinglin.Sun@emc.com>
Cc: netdev@vger.kernel.org, Yinglin Sun <Yinglin.Sun@emc.com>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:50456 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929Ab1JHFhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2011 01:37:25 -0400
Received: by iakk32 with SMTP id k32so4975789iak.19
        for <netdev@vger.kernel.org>; Fri, 07 Oct 2011 22:37:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IPv6 support in L2L3 xmit policy.
L3L4 doesn't support IPv6 either, and I'll try to fix that later.

Signed-off-by: Yinglin Sun <Yinglin.Sun@emc.com>
---
 drivers/net/bonding/bond_main.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6d79b78..d6fd282 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -41,8 +41,10 @@
 #include <linux/ptrace.h>
 #include <linux/ioport.h>
 #include <linux/in.h>
+#include <linux/in6.h>
 #include <net/ip.h>
 #include <linux/ip.h>
+#include <linux/ipv6.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/slab.h>
@@ -3372,10 +3374,15 @@ static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count)
 {
 	struct ethhdr *data = (struct ethhdr *)skb->data;
 	struct iphdr *iph = ip_hdr(skb);
+	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 
 	if (skb->protocol == htons(ETH_P_IP)) {
 		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
 			(data->h_dest[5] ^ data->h_source[5])) % count;
+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		return ((ntohl(ipv6h->saddr.s6_addr32[3] ^
+			       ipv6h->daddr.s6_addr32[3]) & 0xffff) ^
+			(data->h_dest[5] ^ data->h_source[5])) % count;
 	}
 
 	return (data->h_dest[5] ^ data->h_source[5]) % count;
-- 
1.7.4.1
