From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 15/21] [next] qlge: Get rid of local xgmac control.
Date: Fri, 23 Jan 2009 07:16:33 -0800
Message-ID: <1232723799-8620-15-git-send-email-ron.mercer@qlogic.com>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48587 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754401AbZAWPSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 10:18:09 -0500
In-Reply-To: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's done by firmware now.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |  106 ------------------------------------------
 1 files changed, 0 insertions(+), 106 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index ec01dbf..ea9ca3f 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -720,25 +720,6 @@ exit:
  * register pair.  Each read/write requires us to wait for the ready
  * bit before reading/writing the data.
  */
-static int ql_write_xgmac_reg(struct ql_adapter *qdev, u32 reg, u32 data)
-{
-	int status;
-	/* wait for reg to come ready */
-	status = ql_wait_reg_rdy(qdev,
-			XGMAC_ADDR, XGMAC_ADDR_RDY, XGMAC_ADDR_XME);
-	if (status)
-		return status;
-	/* write the data to the data reg */
-	ql_write32(qdev, XGMAC_DATA, data);
-	/* trigger the write */
-	ql_write32(qdev, XGMAC_ADDR, reg);
-	return status;
-}
-
-/* xgmac register are located behind the xgmac_addr and xgmac_data
- * register pair.  Each read/write requires us to wait for the ready
- * bit before reading/writing the data.
- */
 int ql_read_xgmac_reg(struct ql_adapter *qdev, u32 reg, u32 *data)
 {
 	int status = 0;
@@ -781,87 +762,6 @@ exit:
 	return status;
 }
 
-/* Take the MAC Core out of reset.
- * Enable statistics counting.
- * Take the transmitter/receiver out of reset.
- * This functionality may be done in the MPI firmware at a
- * later date.
- */
-static int ql_port_initialize(struct ql_adapter *qdev)
-{
-	int status = 0;
-	u32 data;
-
-	if (ql_sem_trylock(qdev, qdev->xg_sem_mask)) {
-		/* Another function has the semaphore, so
-		 * wait for the port init bit to come ready.
-		 */
-		QPRINTK(qdev, LINK, INFO,
-			"Another function has the semaphore, so wait for the port init bit to come ready.\n");
-		status = ql_wait_reg_rdy(qdev, STS, qdev->port_init, 0);
-		if (status) {
-			QPRINTK(qdev, LINK, CRIT,
-				"Port initialize timed out.\n");
-		}
-		return status;
-	}
-
-	QPRINTK(qdev, LINK, INFO, "Got xgmac semaphore!.\n");
-	/* Set the core reset. */
-	status = ql_read_xgmac_reg(qdev, GLOBAL_CFG, &data);
-	if (status)
-		goto end;
-	data |= GLOBAL_CFG_RESET;
-	status = ql_write_xgmac_reg(qdev, GLOBAL_CFG, data);
-	if (status)
-		goto end;
-
-	/* Clear the core reset and turn on jumbo for receiver. */
-	data &= ~GLOBAL_CFG_RESET;	/* Clear core reset. */
-	data |= GLOBAL_CFG_JUMBO;	/* Turn on jumbo. */
-	data |= GLOBAL_CFG_TX_STAT_EN;
-	data |= GLOBAL_CFG_RX_STAT_EN;
-	status = ql_write_xgmac_reg(qdev, GLOBAL_CFG, data);
-	if (status)
-		goto end;
-
-	/* Enable transmitter, and clear it's reset. */
-	status = ql_read_xgmac_reg(qdev, TX_CFG, &data);
-	if (status)
-		goto end;
-	data &= ~TX_CFG_RESET;	/* Clear the TX MAC reset. */
-	data |= TX_CFG_EN;	/* Enable the transmitter. */
-	status = ql_write_xgmac_reg(qdev, TX_CFG, data);
-	if (status)
-		goto end;
-
-	/* Enable receiver and clear it's reset. */
-	status = ql_read_xgmac_reg(qdev, RX_CFG, &data);
-	if (status)
-		goto end;
-	data &= ~RX_CFG_RESET;	/* Clear the RX MAC reset. */
-	data |= RX_CFG_EN;	/* Enable the receiver. */
-	status = ql_write_xgmac_reg(qdev, RX_CFG, data);
-	if (status)
-		goto end;
-
-	/* Turn on jumbo. */
-	status =
-	    ql_write_xgmac_reg(qdev, MAC_TX_PARAMS, MAC_TX_PARAMS_JUMBO | (0x2580 << 16));
-	if (status)
-		goto end;
-	status =
-	    ql_write_xgmac_reg(qdev, MAC_RX_PARAMS, 0x2580);
-	if (status)
-		goto end;
-
-	/* Signal to the world that the port is enabled.        */
-	ql_write32(qdev, STS, ((qdev->port_init << 16) | qdev->port_init));
-end:
-	ql_sem_unlock(qdev, qdev->xg_sem_mask);
-	return status;
-}
-
 /* Get the next large buffer. */
 static struct bq_desc *ql_get_curr_lbuf(struct rx_ring *rx_ring)
 {
@@ -3023,12 +2923,6 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
 		}
 	}
 
-	status = ql_port_initialize(qdev);
-	if (status) {
-		QPRINTK(qdev, IFUP, ERR, "Failed to start port.\n");
-		return status;
-	}
-
 	/* Set up the MAC address and frame routing filter. */
 	status = ql_cam_route_initialize(qdev);
 	if (status) {
-- 
1.6.0.2

