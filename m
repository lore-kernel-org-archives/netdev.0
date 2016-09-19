From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net v2] qed: Fix stack corruption on probe
Date: Mon, 19 Sep 2016 17:47:41 +0300
Message-ID: <1474296461-22558-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <David.Laight@ACULAB.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:45720 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751148AbcISOsG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 10:48:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit fe56b9e6a8d95 ("qed: Add module with basic common support")
has introduced a stack corruption during probe, where filling a
local struct with data to be sent to management firmware is incorrectly
filled; The data is written outside of the struct and corrupts
the stack.

Changes from v1:
----------------
 - Correct the value written [Caught by David Laight]

Fixes: fe56b9e6a8d95 ("qed: Add module with basic common support")
Signed-off-by: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
---
Hi Dave,

Please consider applying this to `net'.

Thanks,
Yuval
---
 drivers/net/ethernet/qlogic/qed/qed_mcp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index a240f26..59c81ce 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -1153,8 +1153,8 @@ qed_mcp_send_drv_version(struct qed_hwfn *p_hwfn,
 	p_drv_version = &union_data.drv_version;
 	p_drv_version->version = p_ver->version;
 
-	for (i = 0; i < MCP_DRV_VER_STR_SIZE - 1; i += 4) {
-		val = cpu_to_be32(p_ver->name[i]);
+	for (i = 0; i < (MCP_DRV_VER_STR_SIZE - 4) / sizeof(u32); i++) {
+		val = cpu_to_be32(*((u32 *)&p_ver->name[i * sizeof(u32)]));
 		*(__be32 *)&p_drv_version->name[i * sizeof(u32)] = val;
 	}
 
-- 
1.9.3
