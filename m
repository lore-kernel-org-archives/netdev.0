From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net] qed: Fix stack corruption on probe
Date: Sun, 18 Sep 2016 11:14:43 +0300
Message-ID: <1474186483-30831-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:38115 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750849AbcIRIPJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 04:15:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit fe56b9e6a8d95 ("qed: Add module with basic common support")
has introduced a stack corruption during probe, where filling a
local struct with data to be sent to management firmware is incorrectly
filled; The data is written outside of the struct and corrupts
the stack.

Fixes: fe56b9e6a8d95 ("qed: Add module with basic common support")
Signed-off-by: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
---
Hi Dave,

In case it isn't obvious at first glance, the corruption is due
to the next line in the for-loop, which isn't changed by the patch.

Please consider applying this to `net'.

Thanks,
Yuval
---
 drivers/net/ethernet/qlogic/qed/qed_mcp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index a240f26..69f5b04 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -1153,8 +1153,8 @@ qed_mcp_send_drv_version(struct qed_hwfn *p_hwfn,
 	p_drv_version = &union_data.drv_version;
 	p_drv_version->version = p_ver->version;
 
-	for (i = 0; i < MCP_DRV_VER_STR_SIZE - 1; i += 4) {
-		val = cpu_to_be32(p_ver->name[i]);
+	for (i = 0; i < (MCP_DRV_VER_STR_SIZE - 4) / sizeof(u32); i++) {
+		val = cpu_to_be32(p_ver->name[i * sizeof(u32)]);
 		*(__be32 *)&p_drv_version->name[i * sizeof(u32)] = val;
 	}
 
-- 
1.9.3
