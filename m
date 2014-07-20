From: Beniamino Galvani <b.galvani@gmail.com>
Subject: [RFC PATCH 1/2] net: arc_emac: enable tx interrupts
Date: Sun, 20 Jul 2014 17:44:57 +0200
Message-ID: <1405871098-5663-2-git-send-email-b.galvani@gmail.com>
References: <1405871098-5663-1-git-send-email-b.galvani@gmail.com>
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	=?UTF-8?q?Heiko=20St=C3=BCbner?= <heiko@sntech.de>,
	Max Schwarz <max.schwarz@online.de>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	Thierry Reding <thierry.reding@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org,
	Beniamino Galvani <b.galvani@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:40892 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752559AbaGTPrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2014 11:47:23 -0400
In-Reply-To: <1405871098-5663-1-git-send-email-b.galvani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

arc_emac_tx_clean() is called by the the napi poll handler, which is
scheduled only when a rx interrupt is raised. In absence of received
packets the reclaim of used buffers is not executed, blocking further
transmissions.

This can be easily reproduced starting the transmission of a UDP flow
with iperf, which blocks almost immediately because skbs are not freed
and the socket send buffer becomes full:

iperf           S c037a308     0    87     82 0x00000000
[<c037a308>] (__schedule) from [<c0379da4>] (schedule_timeout+0x124/0x178)
[<c0379da4>] (schedule_timeout) from [<c02c253c>] (sock_alloc_send_pskb+0x2a8/0x3a4)
[<c02c253c>] (sock_alloc_send_pskb) from [<c02c265c>] (sock_alloc_send_skb+0x24/0x2c)
[<c02c265c>] (sock_alloc_send_skb) from [<c02fd0e4>] (__ip_append_data+0x670/0x9b0)
[<c02fd0e4>] (__ip_append_data) from [<c02ffd1c>] (ip_make_skb+0xb0/0xe4)
[<c02ffd1c>] (ip_make_skb) from [<c0322c78>] (udp_sendmsg+0x210/0x7d4)
[<c0322c78>] (udp_sendmsg) from [<c032c798>] (inet_sendmsg+0x7c/0xb4)
[<c032c798>] (inet_sendmsg) from [<c02bf734>] (sock_aio_write+0xcc/0xec)
[<c02bf734>] (sock_aio_write) from [<c00e0bfc>] (do_sync_write+0x84/0xac)
[<c00e0bfc>] (do_sync_write) from [<c00e174c>] (vfs_write+0x108/0x1ac)
[<c00e174c>] (vfs_write) from [<c00e1af8>] (SyS_write+0x40/0x8c)
[<c00e1af8>] (SyS_write) from [<c000e620>] (ret_fast_syscall+0x0/0x30)

The patch schedules a napi poll after tx interrupts to allow the tx
reclaim to run in the described situation.

Signed-off-by: Beniamino Galvani <b.galvani@gmail.com>
---
 drivers/net/ethernet/arc/emac_main.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 18e2fac..4adc01f 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -298,7 +298,7 @@ static int arc_emac_poll(struct napi_struct *napi, int budget)
 	work_done = arc_emac_rx(ndev, budget);
 	if (work_done < budget) {
 		napi_complete(napi);
-		arc_reg_or(priv, R_ENABLE, RXINT_MASK);
+		arc_reg_or(priv, R_ENABLE, RXINT_MASK | TXINT_MASK);
 	}
 
 	return work_done;
@@ -327,9 +327,9 @@ static irqreturn_t arc_emac_intr(int irq, void *dev_instance)
 	/* Reset all flags except "MDIO complete" */
 	arc_reg_set(priv, R_STATUS, status);
 
-	if (status & RXINT_MASK) {
+	if (status & (RXINT_MASK | TXINT_MASK)) {
 		if (likely(napi_schedule_prep(&priv->napi))) {
-			arc_reg_clr(priv, R_ENABLE, RXINT_MASK);
+			arc_reg_clr(priv, R_ENABLE, RXINT_MASK | TXINT_MASK);
 			__napi_schedule(&priv->napi);
 		}
 	}
@@ -440,7 +440,7 @@ static int arc_emac_open(struct net_device *ndev)
 	arc_reg_set(priv, R_TX_RING, (unsigned int)priv->txbd_dma);
 
 	/* Enable interrupts */
-	arc_reg_set(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
+	arc_reg_set(priv, R_ENABLE, RXINT_MASK | TXINT_MASK | ERR_MASK);
 
 	/* Set CONTROL */
 	arc_reg_set(priv, R_CTRL,
@@ -511,7 +511,7 @@ static int arc_emac_stop(struct net_device *ndev)
 	netif_stop_queue(ndev);
 
 	/* Disable interrupts */
-	arc_reg_clr(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
+	arc_reg_clr(priv, R_ENABLE, RXINT_MASK | TXINT_MASK | ERR_MASK);
 
 	/* Disable EMAC */
 	arc_reg_clr(priv, R_CTRL, EN_MASK);
-- 
1.7.10.4
