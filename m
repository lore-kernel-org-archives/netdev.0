From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 8/8] qlge: Add module param to force firmware core dump.
Date: Fri, 15 Jan 2010 15:31:34 -0800
Message-ID: <1263598294-5685-9-git-send-email-ron.mercer@qlogic.com>
References: <1263598294-5685-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:37681 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758664Ab0AOXiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 18:38:14 -0500
In-Reply-To: <1263598294-5685-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Default setting is 'off', don't allow force firmware dump.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    3 +++
 drivers/net/qlge/qlge_dbg.c  |   25 +++++++++++++++++++++++++
 drivers/net/qlge/qlge_main.c |   11 +++++++++--
 drivers/net/qlge/qlge_mpi.c  |   16 ++++++++++++++++
 4 files changed, 53 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 05feb03..9169c4c 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -2004,6 +2004,7 @@ enum {
 	QL_CAM_RT_SET = 8,
 	QL_SELFTEST = 9,
 	QL_LB_LINK_UP = 10,
+	QL_FRC_COREDUMP = 11,
 };
 
 /* link_status bit definitions */
@@ -2230,6 +2231,7 @@ int ql_dump_risc_ram_area(struct ql_adapter *qdev, void *buf,
 		u32 ram_addr, int word_count);
 int ql_core_dump(struct ql_adapter *qdev,
 		struct ql_mpi_coredump *mpi_coredump);
+int ql_mb_sys_err(struct ql_adapter *qdev);
 int ql_mb_about_fw(struct ql_adapter *qdev);
 int ql_wol(struct ql_adapter *qdev);
 int ql_mb_wol_set_magic(struct ql_adapter *qdev, u32 enable_wol);
@@ -2246,6 +2248,7 @@ void ql_gen_reg_dump(struct ql_adapter *qdev,
 			struct ql_reg_dump *mpi_coredump);
 netdev_tx_t ql_lb_send(struct sk_buff *skb, struct net_device *ndev);
 void ql_check_lb_frame(struct ql_adapter *, struct sk_buff *);
+int ql_own_firmware(struct ql_adapter *qdev);
 int ql_clean_lb_rx_ring(struct rx_ring *rx_ring, int budget);
 
 #if 1
diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index ec4349a..57df835 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -1222,6 +1222,28 @@ err:
 
 }
 
+static void ql_get_core_dump(struct ql_adapter *qdev)
+{
+	if (!ql_own_firmware(qdev)) {
+		QPRINTK(qdev, DRV, ERR, "%s: Don't own firmware!\n",
+					qdev->ndev->name);
+		return;
+	}
+
+	if (!netif_running(qdev->ndev)) {
+		QPRINTK(qdev, IFUP, ERR,
+			"Force Coredump can only be done from interface "
+			"that is up.\n");
+		return;
+	}
+
+	if (ql_mb_sys_err(qdev)) {
+		QPRINTK(qdev, IFUP, ERR,
+			"Fail force coredump with ql_mb_sys_err().\n");
+		return;
+	}
+}
+
 void ql_gen_reg_dump(struct ql_adapter *qdev,
 			struct ql_reg_dump *mpi_coredump)
 {
@@ -1297,6 +1319,9 @@ void ql_gen_reg_dump(struct ql_adapter *qdev,
 	status = ql_get_ets_regs(qdev, &mpi_coredump->ets[0]);
 	if (status)
 		return;
+
+	if (test_bit(QL_FRC_COREDUMP, &qdev->flags))
+		ql_get_core_dump(qdev);
 }
 
 /* Coredump to messages log file using separate worker thread */
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index e588923..95fb63d 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -77,8 +77,13 @@ static int qlge_mpi_coredump;
 module_param(qlge_mpi_coredump, int, 0);
 MODULE_PARM_DESC(qlge_mpi_coredump,
 		"Option to enable MPI firmware dump. "
-		"Default is OFF - Do Not allocate memory. "
-		"Do not perform firmware coredump.");
+		"Default is OFF - Do Not allocate memory. ");
+
+static int qlge_force_coredump;
+module_param(qlge_force_coredump, int, 0);
+MODULE_PARM_DESC(qlge_force_coredump,
+		"Option to allow force of firmware core dump. "
+		"Default is OFF - Do not allow.");
 
 static DEFINE_PCI_DEVICE_TABLE(qlge_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QLGE_DEVICE_ID_8012)},
@@ -4496,6 +4501,8 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 			err = -ENOMEM;
 			goto err_out;
 		}
+		if (qlge_force_coredump)
+			set_bit(QL_FRC_COREDUMP, &qdev->flags);
 	}
 	/* make sure the EEPROM is good */
 	err = qdev->nic_ops->get_flash(qdev);
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 3304eb7..e2c846f 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -607,6 +607,22 @@ end:
 	return status;
 }
 
+int ql_mb_sys_err(struct ql_adapter *qdev)
+{
+	struct mbox_params mbc;
+	struct mbox_params *mbcp = &mbc;
+	int status;
+
+	memset(mbcp, 0, sizeof(struct mbox_params));
+
+	mbcp->in_count = 1;
+	mbcp->out_count = 0;
+
+	mbcp->mbox_in[0] = MB_CMD_MAKE_SYS_ERR;
+
+	status = ql_mailbox_command(qdev, mbcp);
+	return status;
+}
 
 /* Get MPI firmware version. This will be used for
  * driver banner and for ethtool info.
-- 
1.6.0.2

