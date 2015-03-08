From: Wilco Baan Hofman <wilco@baanhofman.nl>
Subject: [PATCH] Fix multipoint GRE per-packet lookup in neighbour table
Date: Sun, 08 Mar 2015 02:54:56 +0100
Message-ID: <54FBABF0.1090706@baanhofman.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps.baanhofman.nl ([92.222.219.102]:59233 "EHLO
	vps.baanhofman.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbbCHBzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 20:55:19 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by vps.baanhofman.nl (Postfix) with ESMTP id E57DF1040C2F
	for <netdev@vger.kernel.org>; Sun,  8 Mar 2015 02:55:18 +0100 (CET)
Received: from vps.baanhofman.nl ([127.0.0.1])
	by localhost (vps.baanhofman.nl [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id aBc1lTJ2UQeS for <netdev@vger.kernel.org>;
	Sun,  8 Mar 2015 02:54:56 +0100 (CET)
Received: from [IPv6:2001:470:7b66:0:b037:a91d:56f5:3620] (unknown [IPv6:2001:470:7b66:0:b037:a91d:56f5:3620])
	(Authenticated sender: wilco)
	by vps.baanhofman.nl (Postfix) with ESMTPSA id 87ABA1040D32
	for <netdev@vger.kernel.org>; Sun,  8 Mar 2015 02:54:56 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

For multipoint GRE, there is no CAP_XMIT, because it is determined
per-packet if the destination can be reached.

In the transmit function though, it still only checks against CAP_XMIT.

This patch fixes that, and allows forwarding via GRE through the
neighbour table.

After patch, this works:

$ ip -6 neigh list|grep fe80::3
fe80::3 dev gre1 lladdr fc:00:00:00:00:00:00:00:00:00:00:00:00:00:00:03
STALE

$ ping6 fe80::3%gre1
PING fe80::3%gre1(fe80::3) 56 data bytes
64 bytes from fe80::3: icmp_seq=1 ttl=64 time=0.750 ms

-- Wilco Baan Hofman


>From 2092aa4525ebc29301564fd3836485781ca6b205 Mon Sep 17 00:00:00 2001
From: Wilco Baan Hofman <wilco@baanhofman.nl>
Date: Sun, 8 Mar 2015 02:47:22 +0100
Subject: [PATCH] Fix multipoint GRE (per packet transmit)

---
 net/ipv6/ip6_gre.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index c9aee7d..0fdc55a 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -902,7 +902,7 @@ static netdev_tx_t ip6gre_tunnel_xmit(struct sk_buff
*skb,
     struct net_device_stats *stats = &t->dev->stats;
     int ret;
 
-    if (!ip6_tnl_xmit_ctl(t, &t->parms.laddr, &t->parms.raddr))
+    if (!ip6_tnl_xmit_ctl(t, &t->parms.laddr, &t->parms.raddr) &&
!(t->parms.flags & IP6_TNL_F_CAP_PER_PACKET))
         goto tx_err;
 
     switch (skb->protocol) {
-- 
2.1.4
