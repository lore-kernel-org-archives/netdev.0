From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 11/11] qed: Replace set_id() api with set_name()
Date: Mon, 22 May 2017 14:32:11 +0300
Message-ID: <1495452731-27171-12-git-send-email-Yuval.Mintz@cavium.com>
References: <1495452731-27171-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Manish Rangankar <Manish.Rangankar@cavium.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0075.outbound.protection.outlook.com ([104.47.33.75]:50378
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932406AbdEVLde (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 07:33:34 -0400
In-Reply-To: <1495452731-27171-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current API between qed and protocol modules allows passing an
additional private string - but it doesn't get utilized by qed
anywhere.

Clarify the API by removing it and renaming it 'set_name'.

CC: Manish Rangankar <Manish.Rangankar@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h        | 1 -
 drivers/net/ethernet/qlogic/qed/qed_main.c   | 9 +++------
 drivers/net/ethernet/qlogic/qede/qede_main.c | 4 ++--
 drivers/scsi/qedf/qedf_main.c                | 2 +-
 drivers/scsi/qedi/qedi_main.c                | 2 +-
 include/linux/qed/qed_if.h                   | 4 +---
 6 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 2eb6031..e0becec 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -638,7 +638,6 @@ struct qed_dev {
 
 	int				pcie_width;
 	int				pcie_speed;
-	u8				ver_str[VER_SIZE];
 
 	/* Add MF related configuration */
 	u8				mcp_rev;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index b5313c5..c5bb80b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -338,6 +338,7 @@ static struct qed_dev *qed_probe(struct pci_dev *pdev,
 	if (!cdev)
 		goto err0;
 
+	cdev->drv_type = DRV_ID_DRV_TYPE_LINUX;
 	cdev->protocol = params->protocol;
 
 	if (params->is_vf)
@@ -1128,17 +1129,13 @@ static int qed_slowpath_stop(struct qed_dev *cdev)
 	return 0;
 }
 
-static void qed_set_id(struct qed_dev *cdev, char name[NAME_SIZE],
-		       char ver_str[VER_SIZE])
+static void qed_set_name(struct qed_dev *cdev, char name[NAME_SIZE])
 {
 	int i;
 
 	memcpy(cdev->name, name, NAME_SIZE);
 	for_each_hwfn(cdev, i)
 		snprintf(cdev->hwfns[i].name, NAME_SIZE, "%s-%d", name, i);
-
-	memcpy(cdev->ver_str, ver_str, VER_SIZE);
-	cdev->drv_type = DRV_ID_DRV_TYPE_LINUX;
 }
 
 static u32 qed_sb_init(struct qed_dev *cdev,
@@ -1692,7 +1689,7 @@ static int qed_update_mtu(struct qed_dev *cdev, u16 mtu)
 	.probe = &qed_probe,
 	.remove = &qed_remove,
 	.set_power_state = &qed_set_power_state,
-	.set_id = &qed_set_id,
+	.set_name = &qed_set_name,
 	.update_pf_params = &qed_update_pf_params,
 	.slowpath_start = &qed_slowpath_start,
 	.slowpath_stop = &qed_slowpath_stop,
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index d496ba7..00c7062 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -259,7 +259,7 @@ static int qede_netdev_event(struct notifier_block *this, unsigned long event,
 		/* Notify qed of the name change */
 		if (!edev->ops || !edev->ops->common)
 			goto done;
-		edev->ops->common->set_id(edev->cdev, edev->ndev->name, "qede");
+		edev->ops->common->set_name(edev->cdev, edev->ndev->name);
 		break;
 	case NETDEV_CHANGEADDR:
 		edev = netdev_priv(ndev);
@@ -967,7 +967,7 @@ static int __qede_probe(struct pci_dev *pdev, u32 dp_module, u8 dp_level,
 		goto err4;
 	}
 
-	edev->ops->common->set_id(cdev, edev->ndev->name, DRV_MODULE_VERSION);
+	edev->ops->common->set_name(cdev, edev->ndev->name);
 
 	/* PTP not supported on VFs */
 	if (!is_vf)
diff --git a/drivers/scsi/qedf/qedf_main.c b/drivers/scsi/qedf/qedf_main.c
index cceddd9..afbb06d 100644
--- a/drivers/scsi/qedf/qedf_main.c
+++ b/drivers/scsi/qedf/qedf_main.c
@@ -2954,7 +2954,7 @@ static int __qedf_probe(struct pci_dev *pdev, int mode)
 		   "WWPN=%016llx.\n", qedf->wwnn, qedf->wwpn);
 
 	sprintf(host_buf, "host_%d", host->host_no);
-	qed_ops->common->set_id(qedf->cdev, host_buf, QEDF_VERSION);
+	qed_ops->common->set_name(qedf->cdev, host_buf);
 
 
 	/* Set xid max values */
diff --git a/drivers/scsi/qedi/qedi_main.c b/drivers/scsi/qedi/qedi_main.c
index 92775a8..073b305 100644
--- a/drivers/scsi/qedi/qedi_main.c
+++ b/drivers/scsi/qedi/qedi_main.c
@@ -1843,7 +1843,7 @@ static int __qedi_probe(struct pci_dev *pdev, int mode)
 		  qedi->mac);
 
 	sprintf(host_buf, "host_%d", qedi->shost->host_no);
-	qedi_ops->common->set_id(qedi->cdev, host_buf, QEDI_MODULE_VERSION);
+	qedi_ops->common->set_name(qedi->cdev, host_buf);
 
 	qedi_ops->register_ops(qedi->cdev, &qedi_cb_ops, qedi);
 
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index b00e675..73c46d6 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -520,9 +520,7 @@ struct qed_common_ops {
 	int		(*set_power_state)(struct qed_dev *cdev,
 					   pci_power_t state);
 
-	void		(*set_id)(struct qed_dev *cdev,
-				  char name[],
-				  char ver_str[]);
+	void (*set_name) (struct qed_dev *cdev, char name[]);
 
 	/* Client drivers need to make this call before slowpath_start.
 	 * PF params required for the call before slowpath_start is
-- 
1.9.3
