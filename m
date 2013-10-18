From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next v4 5/8] qlcnic: Remove redundant eSwitch enable commands
Date: Fri, 18 Oct 2013 12:22:32 -0400
Message-ID: <aa4009dd13952b135dc0ec4856b0f88808aacb01.1382090311.git.himanshu.madhani@qlogic.com>
References: <cover.1382090311.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:51603 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932106Ab3JRQxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 12:53:18 -0400
In-Reply-To: <cover.1382090311.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

When more than one NIC physical functions are enabled on a port,
eSwitch on that port gets enabled automatically. Driver
need not explicitly enable the eSwitch.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |  2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c  | 23 ++++------------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   | 13 ++++++------
 3 files changed, 12 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 2883b57..9f4e4c4 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -629,7 +629,7 @@ int qlcnic_83xx_config_vnic_opmode(struct qlcnic_adapter *);
 int qlcnic_83xx_get_vnic_vport_info(struct qlcnic_adapter *,
 				    struct qlcnic_info *, u8);
 int qlcnic_83xx_get_vnic_pf_info(struct qlcnic_adapter *, struct qlcnic_info *);
-int qlcnic_83xx_enable_port_eswitch(struct qlcnic_adapter *, int);
+int qlcnic_83xx_set_port_eswitch_status(struct qlcnic_adapter *, int, int *);
 
 void qlcnic_83xx_get_minidump_template(struct qlcnic_adapter *);
 void qlcnic_83xx_get_stats(struct qlcnic_adapter *adapter, u64 *data);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
index 60a477f..734d286 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
@@ -256,8 +256,8 @@ int qlcnic_83xx_check_vnic_state(struct qlcnic_adapter *adapter)
 	return 0;
 }
 
-static int qlcnic_83xx_get_eswitch_port_info(struct qlcnic_adapter *adapter,
-					     int func, int *port_id)
+int qlcnic_83xx_set_port_eswitch_status(struct qlcnic_adapter *adapter,
+					int func, int *port_id)
 {
 	struct qlcnic_info nic_info;
 	int err = 0;
@@ -273,23 +273,8 @@ static int qlcnic_83xx_get_eswitch_port_info(struct qlcnic_adapter *adapter,
 	else
 		err = -EIO;
 
-	return err;
-}
-
-int qlcnic_83xx_enable_port_eswitch(struct qlcnic_adapter *adapter, int func)
-{
-	int id, err = 0;
-
-	err = qlcnic_83xx_get_eswitch_port_info(adapter, func, &id);
-	if (err)
-		return err;
-
-	if (!(adapter->eswitch[id].flags & QLCNIC_SWITCH_ENABLE)) {
-		if (!qlcnic_enable_eswitch(adapter, id, 1))
-			adapter->eswitch[id].flags |= QLCNIC_SWITCH_ENABLE;
-		else
-			err = -EIO;
-	}
+	if (!err)
+		adapter->eswitch[*port_id].flags |= QLCNIC_SWITCH_ENABLE;
 
 	return err;
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 5195972..725d76f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -819,7 +819,7 @@ static bool qlcnic_port_eswitch_cfg_capability(struct qlcnic_adapter *adapter)
 int qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_pci_info *pci_info;
-	int i, ret = 0, j = 0;
+	int i, id = 0, ret = 0, j = 0;
 	u16 act_pci_func;
 	u8 pfn;
 
@@ -860,7 +860,8 @@ int qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 			continue;
 
 		if (qlcnic_port_eswitch_cfg_capability(adapter)) {
-			if (!qlcnic_83xx_enable_port_eswitch(adapter, pfn))
+			if (!qlcnic_83xx_set_port_eswitch_status(adapter, pfn,
+								 &id))
 				adapter->npars[j].eswitch_status = true;
 			else
 				continue;
@@ -879,12 +880,12 @@ int qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 		j++;
 	}
 
-	if (qlcnic_82xx_check(adapter)) {
+	/* Update eSwitch status for adapters without per port eSwitch
+	 * configuration capability
+	 */
+	if (!qlcnic_port_eswitch_cfg_capability(adapter)) {
 		for (i = 0; i < QLCNIC_NIU_MAX_XG_PORTS; i++)
 			adapter->eswitch[i].flags |= QLCNIC_SWITCH_ENABLE;
-	} else if (!qlcnic_port_eswitch_cfg_capability(adapter)) {
-		for (i = 0; i < QLCNIC_NIU_MAX_XG_PORTS; i++)
-			qlcnic_enable_eswitch(adapter, i, 1);
 	}
 
 	kfree(pci_info);
-- 
1.8.1.4
