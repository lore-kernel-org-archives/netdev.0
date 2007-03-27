From: akpm@linux-foundation.org
Subject: [patch 1/7] fix irq problem with NAPI + NETPOLL
Date: Mon, 26 Mar 2007 21:49:57 -0800
Message-ID: <200703270549.l2R5nv9E008366@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	anemo@mba.ocn.ne.jp, jeff@garzik.org, romieu@fr.zoreil.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40343 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934044AbXC0FuK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 01:50:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>

This patch is to make netif_receive_skb() robust on NAPI+NETPOLL case.

1. netpoll_send_skb() calls netpoll_poll() with interrupt disabled.
2. netpoll_poll() calls poll_napi().
3. poll_napi() calls dev->poll().
4. dev->poll() (for example rtl8139_poll()) calls rtl8139_rx().
5. rtl8139_rx() calls netif_receive_skb().
6. netif_receive_skb() calls netpoll_rx().

If netpoll_rx() returned 1, no problem.  If netpoll_rx() returned 0,
netif_receive_skb() continues to processing the skb with interrupt
disabled.  It might cause some problems, for example,

netif_receive_skb() -> deliver_skb() -> arp_rcv() -> arp_process() ->
neigh_lookup() -> read_unlock_bh() -> local_bh_enable() ->
WARN_ON_ONCE(irqs_disabled()).

The patch tries to avoid this by redirecting skb to netif_rx() if
netif_receive_skb() was called from irq context or irq disabled.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/core/dev.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff -puN net/core/dev.c~fix-irq-problem-with-napi-netpoll net/core/dev.c
--- a/net/core/dev.c~fix-irq-problem-with-napi-netpoll
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
