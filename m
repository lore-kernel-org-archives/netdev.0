From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH v2 net-next 1/4] cnic: Populate upper layer driver state in MFW
Date: Tue, 4 Aug 2015 09:37:27 +0300
Message-ID: <1438670250-20130-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1438670250-20130-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <James.bottomley@HansenPartnership.com>,
	<linux-scsi-owner@vger.kernel.org>, <chad.dupuis@qlogic.com>,
	<Ariel.Elior@qlogic.com>, Tej Parkash <tej.parkash@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:15360 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751967AbbHDGhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 02:37:48 -0400
In-Reply-To: <1438670250-20130-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tej Parkash <tej.parkash@qlogic.com>

Signed-off-by: Tej Parkash <tej.parkash@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/broadcom/cnic.c    | 18 +++++++++++++++---
 drivers/net/ethernet/broadcom/cnic_if.h |  5 +++++
 2 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 17c145f..d9e3567 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -192,6 +192,7 @@ static void cnic_ctx_wr(struct cnic_dev *dev, u32 cid_addr, u32 off, u32 val)
 	struct drv_ctl_info info;
 	struct drv_ctl_io *io = &info.data.io;
 
+	memset(&info, 0, sizeof(struct drv_ctl_info));
 	info.cmd = DRV_CTL_CTX_WR_CMD;
 	io->cid_addr = cid_addr;
 	io->offset = off;
@@ -206,6 +207,7 @@ static void cnic_ctx_tbl_wr(struct cnic_dev *dev, u32 off, dma_addr_t addr)
 	struct drv_ctl_info info;
 	struct drv_ctl_io *io = &info.data.io;
 
+	memset(&info, 0, sizeof(struct drv_ctl_info));
 	info.cmd = DRV_CTL_CTXTBL_WR_CMD;
 	io->offset = off;
 	io->dma_addr = addr;
@@ -219,6 +221,7 @@ static void cnic_ring_ctl(struct cnic_dev *dev, u32 cid, u32 cl_id, int start)
 	struct drv_ctl_info info;
 	struct drv_ctl_l2_ring *ring = &info.data.ring;
 
+	memset(&info, 0, sizeof(struct drv_ctl_info));
 	if (start)
 		info.cmd = DRV_CTL_START_L2_CMD;
 	else
@@ -236,6 +239,7 @@ static void cnic_reg_wr_ind(struct cnic_dev *dev, u32 off, u32 val)
 	struct drv_ctl_info info;
 	struct drv_ctl_io *io = &info.data.io;
 
+	memset(&info, 0, sizeof(struct drv_ctl_info));
 	info.cmd = DRV_CTL_IO_WR_CMD;
 	io->offset = off;
 	io->data = val;
@@ -249,13 +253,14 @@ static u32 cnic_reg_rd_ind(struct cnic_dev *dev, u32 off)
 	struct drv_ctl_info info;
 	struct drv_ctl_io *io = &info.data.io;
 
+	memset(&info, 0, sizeof(struct drv_ctl_info));
 	info.cmd = DRV_CTL_IO_RD_CMD;
 	io->offset = off;
 	ethdev->drv_ctl(dev->netdev, &info);
 	return io->data;
 }
 
-static void cnic_ulp_ctl(struct cnic_dev *dev, int ulp_type, bool reg)
+static void cnic_ulp_ctl(struct cnic_dev *dev, int ulp_type, bool reg, int state)
 {
 	struct cnic_local *cp = dev->cnic_priv;
 	struct cnic_eth_dev *ethdev = cp->ethdev;
@@ -263,6 +268,7 @@ static void cnic_ulp_ctl(struct cnic_dev *dev, int ulp_type, bool reg)
 	struct fcoe_capabilities *fcoe_cap =
 		&info.data.register_data.fcoe_features;
 
+	memset(&info, 0, sizeof(struct drv_ctl_info));
 	if (reg) {
 		info.cmd = DRV_CTL_ULP_REGISTER_CMD;
 		if (ulp_type == CNIC_ULP_FCOE && dev->fcoe_cap)
@@ -272,6 +278,7 @@ static void cnic_ulp_ctl(struct cnic_dev *dev, int ulp_type, bool reg)
 	}
 
 	info.data.ulp_type = ulp_type;
+	info.drv_state = state;
 	ethdev->drv_ctl(dev->netdev, &info);
 }
 
@@ -286,6 +293,7 @@ static void cnic_spq_completion(struct cnic_dev *dev, int cmd, u32 count)
 	struct cnic_eth_dev *ethdev = cp->ethdev;
 	struct drv_ctl_info info;
 
+	memset(&info, 0, sizeof(struct drv_ctl_info));
 	info.cmd = cmd;
 	info.data.credit.credit_count = count;
 	ethdev->drv_ctl(dev->netdev, &info);
@@ -591,7 +599,7 @@ static int cnic_register_device(struct cnic_dev *dev, int ulp_type,
 
 	mutex_unlock(&cnic_lock);
 
-	cnic_ulp_ctl(dev, ulp_type, true);
+	cnic_ulp_ctl(dev, ulp_type, true, DRV_ACTIVE);
 
 	return 0;
 
@@ -636,7 +644,10 @@ static int cnic_unregister_device(struct cnic_dev *dev, int ulp_type)
 	if (test_bit(ULP_F_CALL_PENDING, &cp->ulp_flags[ulp_type]))
 		netdev_warn(dev->netdev, "Failed waiting for ULP up call to complete\n");
 
-	cnic_ulp_ctl(dev, ulp_type, false);
+	if (test_bit(ULP_F_INIT, &cp->ulp_flags[ulp_type]))
+		cnic_ulp_ctl(dev, ulp_type, false, DRV_UNLOADED);
+	else
+		cnic_ulp_ctl(dev, ulp_type, false, DRV_INACTIVE);
 
 	return 0;
 }
@@ -4267,6 +4278,7 @@ static void cnic_delete_task(struct work_struct *work)
 
 		cnic_ulp_stop_one(cp, CNIC_ULP_ISCSI);
 
+		memset(&info, 0, sizeof(struct drv_ctl_info));
 		info.cmd = DRV_CTL_ISCSI_STOPPED_CMD;
 		cp->ethdev->drv_ctl(dev->netdev, &info);
 	}
diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index ef6125b..d0cf006 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -151,6 +151,11 @@ struct drv_ctl_register_data {
 
 struct drv_ctl_info {
 	int	cmd;
+	int     drv_state;
+#define DRV_NOP		0
+#define DRV_ACTIVE	1
+#define DRV_INACTIVE	2
+#define DRV_UNLOADED	3
 	union {
 		struct drv_ctl_spq_credit credit;
 		struct drv_ctl_io io;
-- 
1.7.12.4
