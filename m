From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 1/2] qlge: Add firmware info to ethtool get regs.
Date: Wed, 27 Oct 2010 07:58:26 -0700
Message-ID: <1288191507-1994-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	jitendra.kalsaria@qlogic.com, ying.lok@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:38337 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933342Ab0J0PK2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Oct 2010 11:10:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default we add firmware information to ethtool get regs.
Optionally firmware info can instead be sent to log.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h         |    2 ++
 drivers/net/qlge/qlge_dbg.c     |   21 ++++++++++++++++++++-
 drivers/net/qlge/qlge_ethtool.c |   19 ++++++++++++++++---
 3 files changed, 38 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index a478786..0474d20 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -2221,6 +2221,7 @@ int ql_write_mpi_reg(struct ql_adapter *qdev, u32 reg, u32 data);
 int ql_unpause_mpi_risc(struct ql_adapter *qdev);
 int ql_pause_mpi_risc(struct ql_adapter *qdev);
 int ql_hard_reset_mpi_risc(struct ql_adapter *qdev);
+int ql_soft_reset_mpi_risc(struct ql_adapter *qdev);
 int ql_dump_risc_ram_area(struct ql_adapter *qdev, void *buf,
 		u32 ram_addr, int word_count);
 int ql_core_dump(struct ql_adapter *qdev,
@@ -2237,6 +2238,7 @@ int ql_mb_set_mgmnt_traffic_ctl(struct ql_adapter *qdev, u32 control);
 int ql_mb_get_port_cfg(struct ql_adapter *qdev);
 int ql_mb_set_port_cfg(struct ql_adapter *qdev);
 int ql_wait_fifo_empty(struct ql_adapter *qdev);
+void ql_get_dump(struct ql_adapter *qdev, void *buff);
 void ql_gen_reg_dump(struct ql_adapter *qdev,
 			struct ql_reg_dump *mpi_coredump);
 netdev_tx_t ql_lb_send(struct sk_buff *skb, struct net_device *ndev);
diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index 4747492..fca804f 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -1317,9 +1317,28 @@ void ql_gen_reg_dump(struct ql_adapter *qdev,
 	status = ql_get_ets_regs(qdev, &mpi_coredump->ets[0]);
 	if (status)
 		return;
+}
+
+void ql_get_dump(struct ql_adapter *qdev, void *buff)
+{
+	/*
+	 * If the dump has already been taken and is stored
+	 * in our internal buffer and if force dump is set then
+	 * just start the spool to dump it to the log file
+	 * and also, take a snapshot of the general regs to
+	 * to the user's buffer or else take complete dump
+	 * to the user's buffer if force is not set.
+	 */
 
-	if (test_bit(QL_FRC_COREDUMP, &qdev->flags))
+	if (!test_bit(QL_FRC_COREDUMP, &qdev->flags)) {
+		if (!ql_core_dump(qdev, buff))
+			ql_soft_reset_mpi_risc(qdev);
+		else
+			netif_err(qdev, drv, qdev->ndev, "coredump failed!\n");
+	} else {
+		ql_gen_reg_dump(qdev, buff);
 		ql_get_core_dump(qdev);
+	}
 }
 
 /* Coredump to messages log file using separate worker thread */
diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_ethtool.c
index 4892d64..8149cc9 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -375,7 +375,10 @@ static void ql_get_drvinfo(struct net_device *ndev,
 	strncpy(drvinfo->bus_info, pci_name(qdev->pdev), 32);
 	drvinfo->n_stats = 0;
 	drvinfo->testinfo_len = 0;
-	drvinfo->regdump_len = 0;
+	if (!test_bit(QL_FRC_COREDUMP, &qdev->flags))
+		drvinfo->regdump_len = sizeof(struct ql_mpi_coredump);
+	else
+		drvinfo->regdump_len = sizeof(struct ql_reg_dump);
 	drvinfo->eedump_len = 0;
 }
 
@@ -547,7 +550,12 @@ static void ql_self_test(struct net_device *ndev,
 
 static int ql_get_regs_len(struct net_device *ndev)
 {
-	return sizeof(struct ql_reg_dump);
+	struct ql_adapter *qdev = netdev_priv(ndev);
+
+	if (!test_bit(QL_FRC_COREDUMP, &qdev->flags))
+		return sizeof(struct ql_mpi_coredump);
+	else
+		return sizeof(struct ql_reg_dump);
 }
 
 static void ql_get_regs(struct net_device *ndev,
@@ -555,7 +563,12 @@ static void ql_get_regs(struct net_device *ndev,
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
 
-	ql_gen_reg_dump(qdev, p);
+	ql_get_dump(qdev, p);
+	qdev->core_is_dumped = 0;
+	if (!test_bit(QL_FRC_COREDUMP, &qdev->flags))
+		regs->len = sizeof(struct ql_mpi_coredump);
+	else
+		regs->len = sizeof(struct ql_reg_dump);
 }
 
 static int ql_get_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
-- 
1.6.0.2

