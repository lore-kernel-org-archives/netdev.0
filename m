From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 2/2] qlcnic: Do not read QLCNIC_FW_CAPABILITY_MORE_CAPS bit for 83xx adapter
Date: Fri, 25 Oct 2013 10:38:37 -0400
Message-ID: <1382711917-28501-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1382711917-28501-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:63269 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754732Ab3JYPJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 11:09:36 -0400
In-Reply-To: <1382711917-28501-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Only 82xx adapter advertises QLCNIC_FW_CAPABILITY_MORE_CAPS bit.
Reading this bit from 83xx adapter causes the driver to skip
extra capabilities registers.

Because of this, driver was not issuing qlcnic_fw_cmd_set_drv_version()
for 83xx adapter.

This bug was introduced in commit 8af3f33db05c6d0146ad14905145a5c923770856
 ("qlcnic: Add support for 'set driver version' in 83XX").

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c | 6 +++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c    | 6 ++++--
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 3ca00e0..ace217c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -2276,9 +2276,9 @@ int qlcnic_83xx_get_nic_info(struct qlcnic_adapter *adapter,
 		temp = (cmd.rsp.arg[8] & 0x7FFE0000) >> 17;
 		npar_info->max_linkspeed_reg_offset = temp;
 	}
-	if (npar_info->capabilities & QLCNIC_FW_CAPABILITY_MORE_CAPS)
-		memcpy(ahw->extra_capability, &cmd.rsp.arg[16],
-		       sizeof(ahw->extra_capability));
+
+	memcpy(ahw->extra_capability, &cmd.rsp.arg[16],
+	       sizeof(ahw->extra_capability));
 
 out:
 	qlcnic_free_mbx_args(&cmd);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 9e61eb8..d8f4897 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1131,7 +1131,10 @@ qlcnic_initialize_nic(struct qlcnic_adapter *adapter)
 		if (err == -EIO)
 			return err;
 		adapter->ahw->extra_capability[0] = temp;
+	} else {
+		adapter->ahw->extra_capability[0] = 0;
 	}
+
 	adapter->ahw->max_mac_filters = nic_info.max_mac_filters;
 	adapter->ahw->max_mtu = nic_info.max_mtu;
 
@@ -2159,8 +2162,7 @@ void qlcnic_set_drv_version(struct qlcnic_adapter *adapter)
 	else if (qlcnic_83xx_check(adapter))
 		fw_cmd = QLCNIC_CMD_83XX_SET_DRV_VER;
 
-	if ((ahw->capabilities & QLCNIC_FW_CAPABILITY_MORE_CAPS) &&
-	    (ahw->extra_capability[0] & QLCNIC_FW_CAPABILITY_SET_DRV_VER))
+	if (ahw->extra_capability[0] & QLCNIC_FW_CAPABILITY_SET_DRV_VER)
 		qlcnic_fw_cmd_set_drv_version(adapter, fw_cmd);
 }
 
-- 
1.8.1.4
