From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH v2 net-next 2/4] cnic: Add the interfaces to get FC-NPIV table.
Date: Tue, 4 Aug 2015 09:37:28 +0300
Message-ID: <1438670250-20130-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1438670250-20130-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <James.bottomley@HansenPartnership.com>,
	<linux-scsi-owner@vger.kernel.org>, <chad.dupuis@qlogic.com>,
	<Ariel.Elior@qlogic.com>,
	Adheer Chandravanshi <adheer.chandravanshi@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:64511 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751967AbbHDGhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 02:37:52 -0400
In-Reply-To: <1438670250-20130-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adheer Chandravanshi <adheer.chandravanshi@qlogic.com>

Signed-off-by: Adheer Chandravanshi <adheer.chandravanshi@qlogic.com>
Signed-off-by: Chad Dupuis <chad.dupuis@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/broadcom/cnic.c    | 18 ++++++++++++++++++
 drivers/net/ethernet/broadcom/cnic_if.h | 16 ++++++++++++++--
 2 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index d9e3567..b69dc58 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -5445,6 +5445,23 @@ static void cnic_free_dev(struct cnic_dev *dev)
 	kfree(dev);
 }
 
+static int cnic_get_fc_npiv_tbl(struct cnic_dev *dev,
+				struct cnic_fc_npiv_tbl *npiv_tbl)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
+	int ret;
+
+	if (!test_bit(CNIC_F_CNIC_UP, &dev->flags))
+		return -EAGAIN;     /* bnx2x is down */
+
+	if (!BNX2X_CHIP_IS_E2_PLUS(bp))
+		return -EINVAL;
+
+	ret = cp->ethdev->drv_get_fc_npiv_tbl(dev->netdev, npiv_tbl);
+	return ret;
+}
+
 static struct cnic_dev *cnic_alloc_dev(struct net_device *dev,
 				       struct pci_dev *pdev)
 {
@@ -5463,6 +5480,7 @@ static struct cnic_dev *cnic_alloc_dev(struct net_device *dev,
 	cdev->register_device = cnic_register_device;
 	cdev->unregister_device = cnic_unregister_device;
 	cdev->iscsi_nl_msg_recv = cnic_iscsi_nl_msg_recv;
+	cdev->get_fc_npiv_tbl = cnic_get_fc_npiv_tbl;
 
 	cp = cdev->cnic_priv;
 	cp->dev = cdev;
diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index d0cf006..789e5c7 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -15,8 +15,8 @@
 
 #include "bnx2x/bnx2x_mfw_req.h"
 
-#define CNIC_MODULE_VERSION	"2.5.21"
-#define CNIC_MODULE_RELDATE	"January 29, 2015"
+#define CNIC_MODULE_VERSION	"2.5.22"
+#define CNIC_MODULE_RELDATE	"July 20, 2015"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
@@ -166,6 +166,15 @@ struct drv_ctl_info {
 	} data;
 };
 
+#define MAX_NPIV_ENTRIES 64
+#define FC_NPIV_WWN_SIZE 8
+
+struct cnic_fc_npiv_tbl {
+	u8 wwpn[MAX_NPIV_ENTRIES][FC_NPIV_WWN_SIZE];
+	u8 wwnn[MAX_NPIV_ENTRIES][FC_NPIV_WWN_SIZE];
+	u32 count;
+};
+
 struct cnic_ops {
 	struct module	*cnic_owner;
 	/* Calls to these functions are protected by RCU.  When
@@ -231,6 +240,8 @@ struct cnic_eth_dev {
 	int		(*drv_submit_kwqes_16)(struct net_device *,
 					       struct kwqe_16 *[], u32);
 	int		(*drv_ctl)(struct net_device *, struct drv_ctl_info *);
+	int		(*drv_get_fc_npiv_tbl)(struct net_device *,
+					       struct cnic_fc_npiv_tbl *);
 	unsigned long	reserved1[2];
 	union drv_info_to_mcp	*addr_drv_info_to_mcp;
 };
@@ -319,6 +330,7 @@ struct cnic_dev {
 	struct cnic_dev *(*cm_select_dev)(struct sockaddr_in *, int ulp_type);
 	int (*iscsi_nl_msg_recv)(struct cnic_dev *dev, u32 msg_type,
 				 char *data, u16 data_size);
+	int (*get_fc_npiv_tbl)(struct cnic_dev *, struct cnic_fc_npiv_tbl *);
 	unsigned long	flags;
 #define CNIC_F_CNIC_UP		1
 #define CNIC_F_BNX2_CLASS	3
-- 
1.7.12.4
