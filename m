From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] ucc_geth: Fix full TX queue processing
Date: Mon, 18 Jan 2010 18:47:50 +0300
Message-ID: <20100118154750.GA9224@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Wu Jiajun-B06378 <B06378@freescale.com>,
	Li Yang <leoli@freescale.com>, lsorense@csclub.uwaterloo.ca,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dev.rtsoft.ru ([213.79.90.226]:55131 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754072Ab0ARPrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 10:47:52 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiajun Wu <b06378@freescale.com>

commit 7583605b6d29f1f7f6fc505b883328089f3485ad ("ucc_geth: Fix empty
TX queue processing") fixed empty TX queue mishandling, but didn't
account another corner case: when TX queue becomes full.

Without this patch the driver will stop transmiting when TX queue
becomes full since 'bd == ugeth->txBd[txQ]' actually checks for
two things: queue empty or full.

Let's better check for NULL skb, which unambiguously signals an empty
queue.

Signed-off-by: Jiajun Wu <b06378@freescale.com>
Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
Cc: Stable <stable@vger.kernel.org> [2.6.32]
---

On Mon, Jan 11, 2010 at 07:52:26PM +0800, Wu Jiajun-B06378 wrote:
> Yes,'if (!skb)' is enough.
> You can reproduce transmitting stopping if you use
> 'if ((bd == ugeth->txBd[txQ])' and run ipforwarding with MTU=64
> 1Gbps 100%linerate.

OK, let's resend the patch with just !skb check?

 drivers/net/ucc_geth.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 96bdc0b..eb8fe7e 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3279,13 +3279,12 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 		/* Handle the transmitted buffer and release */
 		/* the BD to be used with the current frame  */
 
-		if (bd == ugeth->txBd[txQ]) /* queue empty? */
+		skb = ugeth->tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]];
+		if (!skb)
 			break;
 
 		dev->stats.tx_packets++;
 
-		skb = ugeth->tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]];
-
 		if (skb_queue_len(&ugeth->rx_recycle) < RX_BD_RING_LEN &&
 			     skb_recycle_check(skb,
 				    ugeth->ug_info->uf_info.max_rx_buf_length +
-- 
1.6.5.7
