From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 7/8] be2net: send a max of 8 EQs to be_cmd_modify_eqd() on Lancer
Date: Fri, 12 Sep 2014 17:39:20 +0530
Message-ID: <1410523761-1744-8-git-send-email-sathya.perla@emulex.com>
References: <1410523761-1744-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:24676 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753899AbaILMGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 08:06:50 -0400
In-Reply-To: <1410523761-1744-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

The MODIFY_EQ_DELAY FW cmd on Lancer is supported for a max of 8 EQs per cmd.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   23 +++++++++++++++++++++--
 1 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 85edde6..cd213d9 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1783,8 +1783,8 @@ err:
 /* set the EQ delay interval of an EQ to specified value
  * Uses async mcc
  */
-int be_cmd_modify_eqd(struct be_adapter *adapter, struct be_set_eqd *set_eqd,
-		      int num)
+int __be_cmd_modify_eqd(struct be_adapter *adapter, struct be_set_eqd *set_eqd,
+			int num)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_modify_eq_delay *req;
@@ -1817,6 +1817,25 @@ err:
 	return status;
 }
 
+int be_cmd_modify_eqd(struct be_adapter *adapter, struct be_set_eqd *set_eqd,
+		      int num)
+{
+	int num_eqs, i = 0;
+
+	if (lancer_chip(adapter) && num > 8) {
+		while (num) {
+			num_eqs = min(num, 8);
+			__be_cmd_modify_eqd(adapter, &set_eqd[i], num_eqs);
+			i += num_eqs;
+			num -= num_eqs;
+		}
+	} else {
+		__be_cmd_modify_eqd(adapter, set_eqd, num);
+	}
+
+	return 0;
+}
+
 /* Uses sycnhronous mcc */
 int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
 		       u32 num)
-- 
1.7.1
