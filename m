From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 03/12] net: axienet: Service completion interrupts ASAP
Date: Tue,  5 May 2015 11:25:56 +0200
Message-ID: <2effdfc484793a74e6f53ee7e1b2ef5cebb2bfe9.1430817941.git.michal.simek@xilinx.com>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
Cc: Peter Crosthwaite <peter.crosthwaite@xilinx.com>,
	=?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
	monstr@monstr.eu, John Linn <John.Linn@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
In-Reply-To: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Crosthwaite <peter.crosthwaite@xilinx.com>

The packet completion interrupts for TX and RX should be serviced before
the packets are consumed. This ensures against the degenerate case when a
new completion interrupt is raised after the handler has exited but before
the interrupts are cleared. In this case its possible for the ISR to clear
an unhandled interrupt (leading to potential deadlock).

Signed-off-by: Peter Crosthwaite <peter.crosthwaite@xilinx.com>
Tested-by: Jason Wu <huanyu@xilinx.com>
Acked-by: Michal Simek <michal.simek@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index a4840952d372..b83425393a24 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -809,6 +809,7 @@ static irqreturn_t axienet_tx_irq(int irq, void *_ndev)
 
 	status = axienet_dma_in32(lp, XAXIDMA_TX_SR_OFFSET);
 	if (status & (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_DELAY_MASK)) {
+		axienet_dma_out32(lp, XAXIDMA_TX_SR_OFFSET, status);
 		axienet_start_xmit_done(lp->ndev);
 		goto out;
 	}
@@ -832,9 +833,9 @@ static irqreturn_t axienet_tx_irq(int irq, void *_ndev)
 		axienet_dma_out32(lp, XAXIDMA_RX_CR_OFFSET, cr);
 
 		tasklet_schedule(&lp->dma_err_tasklet);
+		axienet_dma_out32(lp, XAXIDMA_TX_SR_OFFSET, status);
 	}
 out:
-	axienet_dma_out32(lp, XAXIDMA_TX_SR_OFFSET, status);
 	return IRQ_HANDLED;
 }
 
@@ -857,6 +858,7 @@ static irqreturn_t axienet_rx_irq(int irq, void *_ndev)
 
 	status = axienet_dma_in32(lp, XAXIDMA_RX_SR_OFFSET);
 	if (status & (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_DELAY_MASK)) {
+		axienet_dma_out32(lp, XAXIDMA_RX_SR_OFFSET, status);
 		axienet_recv(lp->ndev);
 		goto out;
 	}
@@ -880,9 +882,9 @@ static irqreturn_t axienet_rx_irq(int irq, void *_ndev)
 		axienet_dma_out32(lp, XAXIDMA_RX_CR_OFFSET, cr);
 
 		tasklet_schedule(&lp->dma_err_tasklet);
+		axienet_dma_out32(lp, XAXIDMA_RX_SR_OFFSET, status);
 	}
 out:
-	axienet_dma_out32(lp, XAXIDMA_RX_SR_OFFSET, status);
 	return IRQ_HANDLED;
 }
 
-- 
2.3.5
