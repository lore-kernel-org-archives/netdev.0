From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 4/8] cxgb4: collect firmware mbox and device log dump
Date: Thu, 12 Oct 2017 13:54:41 +0530
Message-ID: <17186a827de1b2bed6cd610ce70f73d86ea6cf53.1507795407.git.rahul.lakkireddy@chelsio.com>
References: <cover.1507795407.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, ganeshgr@chelsio.com, nirranjan@chelsio.com,
        indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:24954 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754212AbdJLI0I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 04:26:08 -0400
In-Reply-To: <cover.1507795407.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1507795407.git.rahul.lakkireddy@chelsio.com>
References: <cover.1507795407.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Collect firmware mbox and device logs before collecting the rest of
the hardware dumps to snap the firmware state before the mailbox logs
are updated by other hardware dumps.

Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cudbg_entity.h |  6 ++
 drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h     |  2 +
 drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c    | 84 +++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h    |  6 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c  |  9 +++
 5 files changed, 107 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cudbg_entity.h b/drivers/net/ethernet/chelsio/cxgb4/cudbg_entity.h
index 71a426dd22f5..2b717e700bbc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cudbg_entity.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cudbg_entity.h
@@ -26,4 +26,10 @@ struct card_mem {
 	u16 size_edc1;
 	u16 mem_flag;
 };
+
+struct cudbg_mbox_log {
+	struct mbox_cmd entry;
+	u32 hi[MBOX_LEN / 8];
+	u32 lo[MBOX_LEN / 8];
+};
 #endif /* __CUDBG_ENTITY_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h b/drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h
index e45690fd0932..89c47e4c5e82 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h
@@ -28,8 +28,10 @@
 
 enum cudbg_dbg_entity_type {
 	CUDBG_REG_DUMP = 1,
+	CUDBG_DEV_LOG = 2,
 	CUDBG_EDC0 = 18,
 	CUDBG_EDC1 = 19,
+	CUDBG_MBOX_LOG = 66,
 	CUDBG_MAX_ENTITY = 70,
 };
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c b/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c
index b0a747a6fbb2..b9039562e5d4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c
@@ -90,6 +90,45 @@ int collect_reg_dump(struct cudbg_init *pdbg_init,
 	return rc;
 }
 
+int collect_fw_devlog(struct cudbg_init *pdbg_init,
+		      struct cudbg_buffer *dbg_buff,
+		      struct cudbg_error *cudbg_err)
+{
+	struct adapter *padap = pdbg_init->adap;
+	struct cudbg_buffer temp_buff = { 0 };
+	struct devlog_params *dparams;
+	int rc = 0;
+
+	rc = t4_init_devlog_params(padap);
+	if (rc < 0) {
+		cudbg_err->sys_err = rc;
+		return rc;
+	}
+
+	dparams = &padap->params.devlog;
+	rc = get_cudbg_buff(dbg_buff, dparams->size, &temp_buff);
+	if (rc)
+		return rc;
+
+	/* Collect FW devlog */
+	if (dparams->start != 0) {
+		spin_lock(&padap->win0_lock);
+		rc = t4_memory_rw(padap, padap->params.drv_memwin,
+				  dparams->memtype, dparams->start,
+				  dparams->size,
+				  (__be32 *)(char *)temp_buff.data,
+				  1);
+		spin_unlock(&padap->win0_lock);
+		if (rc) {
+			cudbg_err->sys_err = rc;
+			put_cudbg_buff(&temp_buff, dbg_buff);
+			return rc;
+		}
+	}
+	write_and_release_buff(&temp_buff, dbg_buff);
+	return rc;
+}
+
 static int read_fw_mem(struct cudbg_init *pdbg_init,
 		       struct cudbg_buffer *dbg_buff, u8 mem_type,
 		       unsigned long tot_len, struct cudbg_error *cudbg_err)
@@ -209,3 +248,48 @@ int collect_edc1_meminfo(struct cudbg_init *pdbg_init,
 {
 	return collect_mem_region(pdbg_init, dbg_buff, cudbg_err, MEM_EDC1);
 }
+
+int collect_mbox_log(struct cudbg_init *pdbg_init,
+		     struct cudbg_buffer *dbg_buff,
+		     struct cudbg_error *cudbg_err)
+{
+	struct adapter *padap = pdbg_init->adap;
+	struct cudbg_mbox_log *mboxlog = NULL;
+	struct cudbg_buffer temp_buff = { 0 };
+	struct mbox_cmd_log *log = NULL;
+	struct mbox_cmd *entry;
+	unsigned int entry_idx;
+	u16 mbox_cmds;
+	int i, k, rc;
+	u64 flit;
+	u32 size;
+
+	log = padap->mbox_log;
+	mbox_cmds = padap->mbox_log->size;
+	size = sizeof(struct cudbg_mbox_log) * mbox_cmds;
+	rc = get_cudbg_buff(dbg_buff, size, &temp_buff);
+	if (rc)
+		return rc;
+
+	mboxlog = (struct cudbg_mbox_log *)temp_buff.data;
+	for (k = 0; k < mbox_cmds; k++) {
+		entry_idx = log->cursor + k;
+		if (entry_idx >= log->size)
+			entry_idx -= log->size;
+
+		entry = mbox_cmd_log_entry(log, entry_idx);
+		/* skip over unused entries */
+		if (entry->timestamp == 0)
+			continue;
+
+		memcpy(&mboxlog->entry, entry, sizeof(struct mbox_cmd));
+		for (i = 0; i < MBOX_LEN / 8; i++) {
+			flit = entry->cmd[i];
+			mboxlog->hi[i] = (u32)(flit >> 32);
+			mboxlog->lo[i] = (u32)flit;
+		}
+		mboxlog++;
+	}
+	write_and_release_buff(&temp_buff, dbg_buff);
+	return rc;
+}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h b/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h
index 04d66807c153..4a3e522a26ed 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h
@@ -21,12 +21,18 @@
 int collect_reg_dump(struct cudbg_init *pdbg_init,
 		     struct cudbg_buffer *dbg_buff,
 		     struct cudbg_error *cudbg_err);
+int collect_fw_devlog(struct cudbg_init *pdbg_init,
+		      struct cudbg_buffer *dbg_buff,
+		      struct cudbg_error *cudbg_err);
 int collect_edc0_meminfo(struct cudbg_init *pdbg_init,
 			 struct cudbg_buffer *dbg_buff,
 			 struct cudbg_error *cudbg_err);
 int collect_edc1_meminfo(struct cudbg_init *pdbg_init,
 			 struct cudbg_buffer *dbg_buff,
 			 struct cudbg_error *cudbg_err);
+int collect_mbox_log(struct cudbg_init *pdbg_init,
+		     struct cudbg_buffer *dbg_buff,
+		     struct cudbg_error *cudbg_err);
 
 struct cudbg_entity_hdr *get_entity_hdr(void *outbuf, int i);
 void align_debug_buffer(struct cudbg_buffer *dbg_buff,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c
index cd8599083a69..337593afe60b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c
@@ -18,6 +18,7 @@
 #include "t4_regs.h"
 #include "cxgb4.h"
 #include "cxgb4_cudbg.h"
+#include "cudbg_entity.h"
 
 static const struct cudbg_collect_entity collect_mem_dump[] = {
 	{ CUDBG_EDC0, collect_edc0_meminfo },
@@ -25,6 +26,8 @@ static const struct cudbg_collect_entity collect_mem_dump[] = {
 };
 
 static const struct cudbg_collect_entity collect_hw_dump[] = {
+	{ CUDBG_MBOX_LOG, collect_mbox_log },
+	{ CUDBG_DEV_LOG, collect_fw_devlog },
 	{ CUDBG_REG_DUMP, collect_reg_dump },
 };
 
@@ -46,6 +49,9 @@ static u32 cxgb4_get_entity_length(struct adapter *adap, u32 entity)
 			break;
 		}
 		break;
+	case CUDBG_DEV_LOG:
+		len = adap->params.devlog.size;
+		break;
 	case CUDBG_EDC0:
 		value = t4_read_reg(adap, MA_TARGET_MEM_ENABLE_A);
 		if (value & EDRAM0_ENABLE_F) {
@@ -62,6 +68,9 @@ static u32 cxgb4_get_entity_length(struct adapter *adap, u32 entity)
 		}
 		len = mbytes_to_bytes(len);
 		break;
+	case CUDBG_MBOX_LOG:
+		len = sizeof(struct cudbg_mbox_log) * adap->mbox_log->size;
+		break;
 	default:
 		break;
 	}
-- 
2.14.1
