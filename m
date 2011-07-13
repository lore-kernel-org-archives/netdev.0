From: Chetan Loke <loke.chetan@gmail.com>
Subject: [PATCH net-next v2 1/1] af-packet: fix - avoid reading stale data
Date: Tue, 12 Jul 2011 22:47:49 -0400
Message-ID: <1310525269-1288-1-git-send-email-loke.chetan@gmail.com>
Cc: lokechetan@gmail.com, eric.dumazet@gmail.com,
	Chetan Loke <loke.chetan@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:36558 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758175Ab1GMCsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 22:48:01 -0400
Received: by vxb39 with SMTP id 39so3896729vxb.19
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 19:48:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we flush tp_status and then flush the remainder of the header+payload.
tp_status should be flushed in the end to avoid stale data being read by user-space.

Incorrectly re-ordered barriers in v1.

Signed-off-by: Chetan Loke <loke.chetan@gmail.com>
---
 net/packet/af_packet.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index d2294ad..c698cec 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1129,7 +1129,6 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	else
 		sll->sll_ifindex = dev->ifindex;
 
-	__packet_set_status(po, h.raw, status);
 	smp_mb();
 #if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE == 1
 	{
@@ -1138,8 +1137,10 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 		end = (u8 *)PAGE_ALIGN((unsigned long)h.raw + macoff + snaplen);
 		for (start = h.raw; start < end; start += PAGE_SIZE)
 			flush_dcache_page(pgv_to_page(start));
+		smp_wmb();
 	}
 #endif
+	__packet_set_status(po, h.raw, status);
 
 	sk->sk_data_ready(sk, 0);
 
-- 
1.7.5.2

