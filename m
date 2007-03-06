From: akpm@linux-foundation.org
Subject: [patch 12/19] fix irq problem with NAPI + NETPOLL
Date: Tue, 06 Mar 2007 02:41:56 -0800
Message-ID: <200703061041.l26AfusT019768@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	anemo@mba.ocn.ne.jp, davem@davemloft.net, romieu@fr.zoreil.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34742 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934074AbXCFKnC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 05:43:02 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>

It seems netif_receive_skb() was designed not to call from irq context, but
NAPI + NETPOLL break this rule.  If netif_receive_skb() was called from irq
context, redirect to netif_rx() instead of processing the skb in that
context.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/core/dev.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff -puN net/core/dev.c~8139too-fix-irq-problem-with-napi-netpoll net/core/dev.c
--- a/net/core/dev.c~8139too-fix-irq-problem-with-napi-netpoll
+++ a/net/core/dev.c
@@ -1769,8 +1769,15 @@ int netif_receive_skb(struct sk_buff *sk
 	__be16 type;
 
 	/* if we've gotten here through NAPI, check netpoll */
-	if (skb->dev->poll && netpoll_rx(skb))
-		return NET_RX_DROP;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	if (skb->dev->poll && skb->dev->poll_controller) {
+		/* NAPI poll might be called in irq context on NETPOLL */
+		if (in_irq() || irqs_disabled())
+			return netif_rx(skb);
+		if (netpoll_rx(skb))
+			return NET_RX_DROP;
+	}
+#endif
 
 	if (!skb->tstamp.off_sec)
 		net_timestamp(skb);
_
