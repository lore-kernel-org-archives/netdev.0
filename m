From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 1/1] qlge: Fix deadlock when cancelling worker.
Date: Sat, 11 Dec 2010 13:06:50 -0800
Message-ID: <1292101610-30661-1-git-send-email-ron.mercer@qlogic.com>
References: <4CF95995.1070506@gmail.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com, jarkao2@gmail.com,
	mingo@elte.hu, Linux-Driver@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:41230 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751597Ab0LKVTj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Dec 2010 16:19:39 -0500
In-Reply-To: <4CF95995.1070506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removing usage of rtnl_lock() to protect firmware interface registers.
These registers are accessed in some worker threads and can create a
deadlock if rtnl_lock is taken by upper layers while the worker is still
pending.
We remove rtnl_lock and use a driver mutex just while mailboxes are
accessed.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    1 +
 drivers/net/qlge/qlge_main.c |    1 +
 drivers/net/qlge/qlge_mpi.c  |   12 ++++--------
 3 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 2282139..9787dff 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -2083,6 +2083,7 @@ struct ql_adapter {
 	u32 mailbox_in;
 	u32 mailbox_out;
 	struct mbox_params idc_mbc;
+	struct mutex	mpi_mutex;
 
 	int tx_ring_size;
 	int rx_ring_size;
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 528eaef..2555b1d 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -4629,6 +4629,7 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 	INIT_DELAYED_WORK(&qdev->mpi_idc_work, ql_mpi_idc_work);
 	INIT_DELAYED_WORK(&qdev->mpi_core_to_log, ql_mpi_core_to_log);
 	init_completion(&qdev->ide_completion);
+	mutex_init(&qdev->mpi_mutex);
 
 	if (!cards_found) {
 		dev_info(&pdev->dev, "%s\n", DRV_STRING);
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 0e7c7c7..a2e919b 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -534,6 +534,7 @@ static int ql_mailbox_command(struct ql_adapter *qdev, struct mbox_params *mbcp)
 	int status;
 	unsigned long count;
 
+	mutex_lock(&qdev->mpi_mutex);
 
 	/* Begin polled mode for MPI */
 	ql_write32(qdev, INTR_MASK, (INTR_MASK_PI << 16));
@@ -603,6 +604,7 @@ done:
 end:
 	/* End polled mode for MPI */
 	ql_write32(qdev, INTR_MASK, (INTR_MASK_PI << 16) | INTR_MASK_PI);
+	mutex_unlock(&qdev->mpi_mutex);
 	return status;
 }
 
@@ -1099,9 +1101,7 @@ int ql_wait_fifo_empty(struct ql_adapter *qdev)
 static int ql_set_port_cfg(struct ql_adapter *qdev)
 {
 	int status;
-	rtnl_lock();
 	status = ql_mb_set_port_cfg(qdev);
-	rtnl_unlock();
 	if (status)
 		return status;
 	status = ql_idc_wait(qdev);
@@ -1122,9 +1122,7 @@ void ql_mpi_port_cfg_work(struct work_struct *work)
 	    container_of(work, struct ql_adapter, mpi_port_cfg_work.work);
 	int status;
 
-	rtnl_lock();
 	status = ql_mb_get_port_cfg(qdev);
-	rtnl_unlock();
 	if (status) {
 		netif_err(qdev, drv, qdev->ndev,
 			  "Bug: Failed to get port config data.\n");
@@ -1167,7 +1165,6 @@ void ql_mpi_idc_work(struct work_struct *work)
 	u32 aen;
 	int timeout;
 
-	rtnl_lock();
 	aen = mbcp->mbox_out[1] >> 16;
 	timeout = (mbcp->mbox_out[1] >> 8) & 0xf;
 
@@ -1231,7 +1228,6 @@ void ql_mpi_idc_work(struct work_struct *work)
 		}
 		break;
 	}
-	rtnl_unlock();
 }
 
 void ql_mpi_work(struct work_struct *work)
@@ -1242,7 +1238,7 @@ void ql_mpi_work(struct work_struct *work)
 	struct mbox_params *mbcp = &mbc;
 	int err = 0;
 
-	rtnl_lock();
+	mutex_lock(&qdev->mpi_mutex);
 	/* Begin polled mode for MPI */
 	ql_write32(qdev, INTR_MASK, (INTR_MASK_PI << 16));
 
@@ -1259,7 +1255,7 @@ void ql_mpi_work(struct work_struct *work)
 
 	/* End polled mode for MPI */
 	ql_write32(qdev, INTR_MASK, (INTR_MASK_PI << 16) | INTR_MASK_PI);
-	rtnl_unlock();
+	mutex_unlock(&qdev->mpi_mutex);
 	ql_enable_completion_interrupt(qdev, 0);
 }
 
-- 
1.6.0.2

