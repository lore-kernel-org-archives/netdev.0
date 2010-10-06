From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 03/19] cnic: Fine-tune ring init code.
Date: Wed, 6 Oct 2010 15:17:22 +0200
Message-ID: <1286371042.30552.18.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1170 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758922Ab0JFNjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 09:39:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>

Initialize the rings only during cnic_uio_open() and shut them down
during cnic_uio_close().  Check for the new bit CNIC_LCL_FL_RINGS_INITED
before checking for ring interrupt.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
---
 drivers/net/cnic.c |   24 ++++++++++++++++++------
 drivers/net/cnic.h |    1 +
 2 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 50cded7..4e9d4ae 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2202,13 +2202,14 @@ static int cnic_l2_completion(struct cnic_local *cp)
 
 static void cnic_chk_pkt_rings(struct cnic_local *cp)
 {
-	u16 rx_cons = *cp->rx_cons_ptr;
-	u16 tx_cons = *cp->tx_cons_ptr;
+	u16 rx_cons, tx_cons;
 	int comp = 0;
 
-	if (!test_bit(CNIC_F_CNIC_UP, &cp->dev->flags))
+	if (!test_bit(CNIC_LCL_FL_RINGS_INITED, &cp->cnic_local_flags))
 		return;
 
+	rx_cons = *cp->rx_cons_ptr;
+	tx_cons = *cp->tx_cons_ptr;
 	if (cp->tx_cons != tx_cons || cp->rx_cons != rx_cons) {
 		if (test_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags))
 			comp = cnic_l2_completion(cp);
@@ -4202,17 +4203,20 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 	if (ret)
 		return ret;
 
-	cnic_init_bnx2x_tx_ring(dev);
-	cnic_init_bnx2x_rx_ring(dev);
-
 	return 0;
 }
 
 static void cnic_init_rings(struct cnic_dev *dev)
 {
+	struct cnic_local *cp = dev->cnic_priv;
+
+	if (test_bit(CNIC_LCL_FL_RINGS_INITED, &cp->cnic_local_flags))
+		return;
+
 	if (test_bit(CNIC_F_BNX2_CLASS, &dev->flags)) {
 		cnic_init_bnx2_tx_ring(dev);
 		cnic_init_bnx2_rx_ring(dev);
+		set_bit(CNIC_LCL_FL_RINGS_INITED, &cp->cnic_local_flags);
 	} else if (test_bit(CNIC_F_BNX2X_CLASS, &dev->flags)) {
 		struct cnic_local *cp = dev->cnic_priv;
 		u32 cli = BNX2X_ISCSI_CL_ID(CNIC_E1HVN(cp));
@@ -4235,6 +4239,8 @@ static void cnic_init_rings(struct cnic_dev *dev)
 		cnic_init_bnx2x_tx_ring(dev);
 		cnic_init_bnx2x_rx_ring(dev);
 
+		set_bit(CNIC_LCL_FL_RINGS_INITED, &cp->cnic_local_flags);
+
 		l5_data.phy_address.lo = cli;
 		l5_data.phy_address.hi = 0;
 		cnic_submit_kwqe_16(dev, RAMROD_CMD_ID_ETH_CLIENT_SETUP,
@@ -4254,6 +4260,11 @@ static void cnic_init_rings(struct cnic_dev *dev)
 
 static void cnic_shutdown_rings(struct cnic_dev *dev)
 {
+	struct cnic_local *cp = dev->cnic_priv;
+
+	if (!test_bit(CNIC_LCL_FL_RINGS_INITED, &cp->cnic_local_flags))
+		return;
+
 	if (test_bit(CNIC_F_BNX2_CLASS, &dev->flags)) {
 		cnic_shutdown_bnx2_rx_ring(dev);
 	} else if (test_bit(CNIC_F_BNX2X_CLASS, &dev->flags)) {
@@ -4286,6 +4297,7 @@ static void cnic_shutdown_rings(struct cnic_dev *dev)
 			(1 << SPE_HDR_COMMON_RAMROD_SHIFT), &l5_data);
 		msleep(10);
 	}
+	clear_bit(CNIC_LCL_FL_RINGS_INITED, &cp->cnic_local_flags);
 }
 
 static int cnic_register_netdev(struct cnic_dev *dev)
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index ef2c25e..4816183 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -192,6 +192,7 @@ struct cnic_local {
 	unsigned long cnic_local_flags;
 #define	CNIC_LCL_FL_KWQ_INIT		0x0
 #define	CNIC_LCL_FL_L2_WAIT		0x1
+#define	CNIC_LCL_FL_RINGS_INITED	0x2
 
 	struct cnic_dev *dev;
 
-- 
1.7.1




