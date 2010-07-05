From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 2/6] qlge: Don't use firmware when forcing firmware dump.
Date: Mon,  5 Jul 2010 15:19:38 -0700
Message-ID: <1278368382-23887-3-git-send-email-ron.mercer@qlogic.com>
References: <1278368382-23887-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:42713 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755199Ab0GEXFT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jul 2010 19:05:19 -0400
In-Reply-To: <1278368382-23887-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some cases the firmware may be dead.  Instead we dump the firmware
parameters and then restart it.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h     |    1 -
 drivers/net/qlge/qlge_dbg.c |    7 +------
 drivers/net/qlge/qlge_mpi.c |   17 -----------------
 3 files changed, 1 insertions(+), 24 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 01b0634..27f83d6 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -2227,7 +2227,6 @@ int ql_dump_risc_ram_area(struct ql_adapter *qdev, void *buf,
 		u32 ram_addr, int word_count);
 int ql_core_dump(struct ql_adapter *qdev,
 		struct ql_mpi_coredump *mpi_coredump);
-int ql_mb_sys_err(struct ql_adapter *qdev);
 int ql_mb_about_fw(struct ql_adapter *qdev);
 int ql_wol(struct ql_adapter *qdev);
 int ql_mb_wol_set_magic(struct ql_adapter *qdev, u32 enable_wol);
diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index 68a1c9b..548e901 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -1237,12 +1237,7 @@ static void ql_get_core_dump(struct ql_adapter *qdev)
 			  "Force Coredump can only be done from interface that is up.\n");
 		return;
 	}
-
-	if (ql_mb_sys_err(qdev)) {
-		netif_err(qdev, ifup, qdev->ndev,
-			  "Fail force coredump with ql_mb_sys_err().\n");
-		return;
-	}
+	ql_queue_fw_error(qdev);
 }
 
 void ql_gen_reg_dump(struct ql_adapter *qdev,
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 3c00462..f84e857 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -606,23 +606,6 @@ end:
 	return status;
 }
 
-int ql_mb_sys_err(struct ql_adapter *qdev)
-{
-	struct mbox_params mbc;
-	struct mbox_params *mbcp = &mbc;
-	int status;
-
-	memset(mbcp, 0, sizeof(struct mbox_params));
-
-	mbcp->in_count = 1;
-	mbcp->out_count = 0;
-
-	mbcp->mbox_in[0] = MB_CMD_MAKE_SYS_ERR;
-
-	status = ql_mailbox_command(qdev, mbcp);
-	return status;
-}
-
 /* Get MPI firmware version. This will be used for
  * driver banner and for ethtool info.
  * Returns zero on success.
-- 
1.6.0.2

