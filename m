From: Stefano Brivio <sbrivio@redhat.com>
Subject: [PATCH net] cxgb4: Fix stack out-of-bounds read due to wrong size to t4_record_mbox()
Date: Fri, 25 Aug 2017 22:48:48 +0200
Message-ID: <04759fe12e6a8eb8e36e46060b907f02c269a826.1503692361.git.sbrivio@redhat.com>
Cc: Hariprasad Shenai <hariprasad@chelsio.com>,
        Casey Leedom <leedom@chelsio.com>,
        Sai Vemuri <svemuri@redhat.com>
To: Ganesh Goudar <ganeshgr@chelsio.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51004 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932586AbdHYUtf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 16:49:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Passing commands for logging to t4_record_mbox() with size
MBOX_LEN, when the actual command size is actually smaller,
causes out-of-bounds stack accesses in t4_record_mbox() while
copying command words here:

	for (i = 0; i < size / 8; i++)
		entry->cmd[i] = be64_to_cpu(cmd[i]);

Up to 48 bytes from the stack are then leaked to debugfs.

This happens whenever we send (and log) commands described by
structs fw_sched_cmd (32 bytes leaked), fw_vi_rxmode_cmd (48),
fw_hello_cmd (48), fw_bye_cmd (48), fw_initialize_cmd (48),
fw_reset_cmd (48), fw_pfvf_cmd (32), fw_eq_eth_cmd (16),
fw_eq_ctrl_cmd (32), fw_eq_ofld_cmd (32), fw_acl_mac_cmd(16),
fw_rss_glb_config_cmd(32), fw_rss_vi_config_cmd(32),
fw_devlog_cmd(32), fw_vi_enable_cmd(48), fw_port_cmd(32),
fw_sched_cmd(32), fw_devlog_cmd(32).

The cxgb4vf driver got this right instead.

When we call t4_record_mbox() to log a command reply, a MBOX_LEN
size can be used though, as get_mbox_rpl() will fill cmd_rpl up
completely.

Fixes: 7f080c3f2ff0 ("cxgb4: Add support to enable logging of firmware mailbox commands")
Signed-off-by: Stefano Brivio <sbrivio@redhat.com>
---
I guess this should be queued up for -stable, back to 4.7.

 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 82bf7aac6cdb..0293b41171a5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -369,12 +369,12 @@ int t4_wr_mbox_meat_timeout(struct adapter *adap, int mbox, const void *cmd,
 		list_del(&entry.list);
 		spin_unlock(&adap->mbox_lock);
 		ret = (v == MBOX_OWNER_FW) ? -EBUSY : -ETIMEDOUT;
-		t4_record_mbox(adap, cmd, MBOX_LEN, access, ret);
+		t4_record_mbox(adap, cmd, size, access, ret);
 		return ret;
 	}
 
 	/* Copy in the new mailbox command and send it on its way ... */
-	t4_record_mbox(adap, cmd, MBOX_LEN, access, 0);
+	t4_record_mbox(adap, cmd, size, access, 0);
 	for (i = 0; i < size; i += 8)
 		t4_write_reg64(adap, data_reg + i, be64_to_cpu(*p++));
 
@@ -426,7 +426,7 @@ int t4_wr_mbox_meat_timeout(struct adapter *adap, int mbox, const void *cmd,
 	}
 
 	ret = (pcie_fw & PCIE_FW_ERR_F) ? -ENXIO : -ETIMEDOUT;
-	t4_record_mbox(adap, cmd, MBOX_LEN, access, ret);
+	t4_record_mbox(adap, cmd, size, access, ret);
 	dev_err(adap->pdev_dev, "command %#x in mailbox %d timed out\n",
 		*(const u8 *)cmd, mbox);
 	t4_report_fw_error(adap);
-- 
2.9.4
