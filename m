From: Petri Lehtinen <petri.lehtinen@inoi.fi>
Subject: [PATCH 3/3] ucc_geth: Fix full TX queue processing
Date: Tue, 22 Jun 2010 16:02:32 +0300
Message-ID: <1277211752-14265-4-git-send-email-petri.lehtinen@inoi.fi>
References: <1277211752-14265-1-git-send-email-petri.lehtinen@inoi.fi>
Cc: stable@kernel.org, netdev@vger.kernel.org,
	Jiajun Wu <b06378@freescale.com>,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Stable <stable@vger.kernel.org>, "[2.6.32]"@mail.srv.inoi.fi,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1277211752-14265-1-git-send-email-petri.lehtinen@inoi.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
Signed-off-by: David S. Miller <davem@davemloft.net>

(cherry picked from commit 34692421bc7d6145ef383b014860f4fde10b7505)
---
 drivers/net/ucc_geth.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 5077fd9..b4b25ff 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3276,13 +3276,12 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
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
1.7.1
