From: Chetan Loke <loke.chetan@gmail.com>
Subject: [PATCH net-next 1/1] af-packet: fix - avoid reading stale data
Date: Tue, 12 Jul 2011 21:42:19 -0400
Message-ID: <1310521339-1115-1-git-send-email-loke.chetan@gmail.com>
Cc: lokechetan@gmail.com, Chetan Loke <loke.chetan@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:33985 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755008Ab1GMBmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 21:42:35 -0400
Received: by vxb39 with SMTP id 39so3873069vxb.19
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 18:42:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we flush tp_status and then flush the remainder of the header+payload.
tp_status should be flushed in the end to avoid stale data being read by user-space.


Signed-off-by: Chetan Loke <loke.chetan@gmail.com>
---
 net/packet/af_packet.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index d2294ad..f7be71f 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1129,8 +1129,6 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	else
 		sll->sll_ifindex = dev->ifindex;
 
-	__packet_set_status(po, h.raw, status);
-	smp_mb();
 #if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE == 1
 	{
 		u8 *start, *end;
@@ -1140,6 +1138,8 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 			flush_dcache_page(pgv_to_page(start));
 	}
 #endif
+	smp_mb();
+	__packet_set_status(po, h.raw, status);
 
 	sk->sk_data_ready(sk, 0);
 
-- 
1.7.5.2

