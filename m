From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 2/2] qlcnic: Fix memory leak.
Date: Wed, 23 Apr 2014 09:59:56 -0400
Message-ID: <1398261596-7296-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1398261596-7296-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:41875 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756132AbaDWOhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 10:37:36 -0400
In-Reply-To: <1398261596-7296-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

o In case QLC_83XX_MBX_CMD_NO_WAIT command type the calling
  function does not free the memory as it does not wait for
  response. So free it when get a response from adapter after
  sending the command.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index 0638c18..6afe9c1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -1370,7 +1370,7 @@ static int qlcnic_sriov_issue_cmd(struct qlcnic_adapter *adapter,
 
 	rsp = qlcnic_sriov_alloc_bc_trans(&trans);
 	if (rsp)
-		return rsp;
+		goto free_cmd;
 
 	rsp = qlcnic_sriov_prepare_bc_hdr(trans, cmd, seq, QLC_BC_COMMAND);
 	if (rsp)
@@ -1425,6 +1425,13 @@ err_out:
 
 cleanup_transaction:
 	qlcnic_sriov_cleanup_transaction(trans);
+
+free_cmd:
+	if (cmd->type == QLC_83XX_MBX_CMD_NO_WAIT) {
+		qlcnic_free_mbx_args(cmd);
+		kfree(cmd);
+	}
+
 	return rsp;
 }
 
-- 
1.5.6
