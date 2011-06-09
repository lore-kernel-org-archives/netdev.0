From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 5/5 net-next] cnic, bnx2: Check iSCSI support early in
 bnx2_init_one()
Date: Wed, 8 Jun 2011 22:29:36 -0700
Message-ID: <1307597376-5379-5-git-send-email-mchan@broadcom.com>
References: <1307597376-5379-1-git-send-email-mchan@broadcom.com>
 <1307597376-5379-2-git-send-email-mchan@broadcom.com>
 <1307597376-5379-3-git-send-email-mchan@broadcom.com>
 <1307597376-5379-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Neil Horman" <nhorman@tuxdriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4183 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751419Ab1FIGVG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 02:21:06 -0400
In-Reply-To: <1307597376-5379-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on earlier patch from Neil Horman <nhorman@tuxdriver.com>

If iSCSI is not supported on a bnx2 device, bnx2_cnic_probe() will
return NULL and the cnic device will not be visible to bnx2i.  This
will prevent bnx2i from registering and then unregistering during
cnic_start() and cause the warning message:

bnx2 0003:01:00.1: eth1: Failed waiting for ULP up call to complete

Signed-off-by: Michael Chan <mchan@broadcom.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
---
 drivers/net/bnx2.c |    7 +++++++
 drivers/net/cnic.c |   12 ++----------
 2 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 57d3293..74580bb 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -416,6 +416,9 @@ struct cnic_eth_dev *bnx2_cnic_probe(struct net_device *dev)
 	struct bnx2 *bp = netdev_priv(dev);
 	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
 
+	if (!cp->max_iscsi_conn)
+		return NULL;
+
 	cp->drv_owner = THIS_MODULE;
 	cp->chip_id = bp->chip_id;
 	cp->pdev = bp->pdev;
@@ -8177,6 +8180,10 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bp->timer.data = (unsigned long) bp;
 	bp->timer.function = bnx2_timer;
 
+#ifdef BCM_CNIC
+	bp->cnic_eth_dev.max_iscsi_conn =
+		bnx2_reg_rd_ind(bp, BNX2_FW_MAX_ISCSI_CONN);
+#endif
 	pci_save_state(pdev);
 
 	return 0;
diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 6c544b3..363c7f3 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -4225,14 +4225,6 @@ static void cnic_enable_bnx2_int(struct cnic_dev *dev)
 		BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID | cp->last_status_idx);
 }
 
-static void cnic_get_bnx2_iscsi_info(struct cnic_dev *dev)
-{
-	u32 max_conn;
-
-	max_conn = cnic_reg_rd_ind(dev, BNX2_FW_MAX_ISCSI_CONN);
-	dev->max_iscsi_conn = max_conn;
-}
-
 static void cnic_disable_bnx2_int_sync(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
@@ -4557,8 +4549,6 @@ static int cnic_start_bnx2_hw(struct cnic_dev *dev)
 		return err;
 	}
 
-	cnic_get_bnx2_iscsi_info(dev);
-
 	return 0;
 }
 
@@ -5224,6 +5214,8 @@ static struct cnic_dev *init_bnx2_cnic(struct net_device *dev)
 	cdev->pcidev = pdev;
 	cp->chip_id = ethdev->chip_id;
 
+	cdev->max_iscsi_conn = ethdev->max_iscsi_conn;
+
 	cp->cnic_ops = &cnic_bnx2_ops;
 	cp->start_hw = cnic_start_bnx2_hw;
 	cp->stop_hw = cnic_stop_bnx2_hw;
-- 
1.6.4.GIT


