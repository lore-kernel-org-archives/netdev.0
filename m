From: Petri Lehtinen <petri.lehtinen@inoi.fi>
Subject: [PATCH 1/3] ucc_geth: Fix empty TX queue processing
Date: Tue, 22 Jun 2010 16:02:30 +0300
Message-ID: <1277211752-14265-2-git-send-email-petri.lehtinen@inoi.fi>
References: <1277211752-14265-1-git-send-email-petri.lehtinen@inoi.fi>
Cc: stable@kernel.org, netdev@vger.kernel.org,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Stable <stable@vger.kernel.org>, "[2.6.32]"@mail.srv.inoi.fi,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1277211752-14265-1-git-send-email-petri.lehtinen@inoi.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Anton Vorontsov <avorontsov@ru.mvista.com>

Following oops was seen with the ucc_geth driver:

 Unable to handle kernel paging request for data at address 0x00000058
 Faulting instruction address: 0xc024f2fc
 Oops: Kernel access of bad area, sig: 11 [#1]
 [...]
 NIP [c024f2fc] skb_recycle_check+0x14/0x100
 LR [e30aa0a4] ucc_geth_poll+0xd8/0x4e0 [ucc_geth_driver]
 Call Trace:
 [df857d50] [c000b03c] __ipipe_grab_irq+0x3c/0xa4 (unreliable)
 [df857d60] [e30aa0a4] ucc_geth_poll+0xd8/0x4e0 [ucc_geth_driver]
 [df857dd0] [c0258cf8] net_rx_action+0xf8/0x1b8
 [df857e10] [c0032a38] __do_softirq+0xb8/0x13c
 [df857e60] [c00065cc] do_softirq+0xa0/0xac
 [...]

This is because ucc_geth_tx() tries to process an empty queue when
queues are logically stopped. Stopping the queues doesn't disable
polling, and since nowadays ucc_geth_tx() is actually called from
the polling routine, the oops above might pop up.

Fix this by removing 'netif_queue_stopped() == 0' check.

Reported-by: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
Tested-by: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Cc: Stable <stable@vger.kernel.org> [2.6.32]
Signed-off-by: David S. Miller <davem@davemloft.net>

(cherry picked from commit 7583605b6d29f1f7f6fc505b883328089f3485ad)
---
 drivers/net/ucc_geth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 4469f24..20aa5b5 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3273,7 +3273,7 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 		/* Handle the transmitted buffer and release */
 		/* the BD to be used with the current frame  */
 
-		if ((bd == ugeth->txBd[txQ]) && (netif_queue_stopped(dev) == 0))
+		if (bd == ugeth->txBd[txQ]) /* queue empty? */
 			break;
 
 		dev->stats.tx_packets++;
-- 
1.7.1
