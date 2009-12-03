From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/5] cnic: Fix ring I/O address for bnx2x
 devices.
Date: Wed, 2 Dec 2009 17:15:35 -0800
Message-ID: <1259802939-4742-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2984 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753429AbZLCBId (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2009 20:08:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Old code was initializing the ring producers using an incorrect I/O
address.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/cnic.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index ee7eb9e..10c5cc3 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -4131,22 +4131,20 @@ static void cnic_init_rings(struct cnic_dev *dev)
 		cnic_init_bnx2_rx_ring(dev);
 	} else if (test_bit(CNIC_F_BNX2X_CLASS, &dev->flags)) {
 		struct cnic_local *cp = dev->cnic_priv;
-		struct cnic_eth_dev *ethdev = cp->ethdev;
 		u32 cli = BNX2X_ISCSI_CL_ID(CNIC_E1HVN(cp));
 		union l5cm_specific_data l5_data;
 		struct ustorm_eth_rx_producers rx_prods = {0};
-		void __iomem *doorbell;
-		int i;
+		u32 off, i;
 
 		rx_prods.bd_prod = 0;
 		rx_prods.cqe_prod = BNX2X_MAX_RCQ_DESC_CNT;
 		barrier();
 
-		doorbell = ethdev->io_base2 + BAR_USTRORM_INTMEM +
+		off = BAR_USTRORM_INTMEM +
 			USTORM_RX_PRODS_OFFSET(CNIC_PORT(cp), cli);
 
 		for (i = 0; i < sizeof(struct ustorm_eth_rx_producers) / 4; i++)
-			writel(((u32 *) &rx_prods)[i], doorbell + i * 4);
+			CNIC_WR(dev, off + i * 4, ((u32 *) &rx_prods)[i]);
 
 		cnic_init_bnx2x_tx_ring(dev);
 		cnic_init_bnx2x_rx_ring(dev);
-- 
1.6.4.GIT


