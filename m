From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/2] cxgb4: Check for firmware errors in the mailbox command loop
Date: Tue,  3 May 2016 18:58:02 +0530
Message-ID: <1462282082-6894-3-git-send-email-hariprasad@chelsio.com>
References: <1462282082-6894-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, leedom@chelsio.com,
	swise@opengridcomputing.com, nirranjan@chelsio.com,
	santosh@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:27721 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755785AbcECNXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 09:23:48 -0400
In-Reply-To: <1462282082-6894-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check for firmware errors in the mailbox command loop and report
them differently rather than simply timing out when the firmware goes
belly up.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 59f5e0b40286..a63addb4e72c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -293,6 +293,7 @@ int t4_wr_mbox_meat_timeout(struct adapter *adap, int mbox, const void *cmd,
 	u32 data_reg = PF_REG(mbox, CIM_PF_MAILBOX_DATA_A);
 	u32 ctl_reg = PF_REG(mbox, CIM_PF_MAILBOX_CTRL_A);
 	__be64 cmd_rpl[MBOX_LEN / 8];
+	u32 pcie_fw;
 
 	if ((size & 15) || size > MBOX_LEN)
 		return -EINVAL;
@@ -331,7 +332,10 @@ int t4_wr_mbox_meat_timeout(struct adapter *adap, int mbox, const void *cmd,
 	delay_idx = 0;
 	ms = delay[0];
 
-	for (i = 0; i < timeout; i += ms) {
+	for (i = 0;
+	     !((pcie_fw = t4_read_reg(adap, PCIE_FW_A)) & PCIE_FW_ERR_F) &&
+	     i < timeout;
+	     i += ms) {
 		if (sleep_ok) {
 			ms = delay[delay_idx];  /* last element may repeat */
 			if (delay_idx < ARRAY_SIZE(delay) - 1)
@@ -366,7 +370,7 @@ int t4_wr_mbox_meat_timeout(struct adapter *adap, int mbox, const void *cmd,
 		}
 	}
 
-	ret = -ETIMEDOUT;
+	ret = (pcie_fw & PCIE_FW_ERR_F) ? -ENXIO : -ETIMEDOUT;
 	t4_record_mbox(adap, cmd, MBOX_LEN, access, ret);
 	dev_err(adap->pdev_dev, "command %#x in mailbox %d timed out\n",
 		*(const u8 *)cmd, mbox);
-- 
2.3.4
