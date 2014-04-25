From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 4/6] qlcnic: Add driver logs in error path.
Date: Fri, 25 Apr 2014 17:43:59 -0400
Message-ID: <1398462241-15478-5-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1398462241-15478-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shahed.shaikh@qlogic.com>,
	<Dept-HSGLinuxNICDev@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:18640 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751974AbaDYWWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 18:22:05 -0400
In-Reply-To: <1398462241-15478-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c   |  3 +++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c |  2 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c       | 13 +++++++++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c      |  5 +++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c     |  2 ++
 5 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index b7cffb4..4ea15ba 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -879,6 +879,9 @@ int qlcnic_83xx_alloc_mbx_args(struct qlcnic_cmd_args *mbx,
 			return 0;
 		}
 	}
+
+	dev_err(&adapter->pdev->dev, "%s: Invalid mailbox command opcode 0x%x\n",
+		__func__, type);
 	return -EINVAL;
 }
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index ba20c72..34d2737 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -2181,6 +2181,8 @@ int qlcnic_83xx_configure_opmode(struct qlcnic_adapter *adapter)
 		max_sds_rings = QLCNIC_MAX_SDS_RINGS;
 		max_tx_rings = QLCNIC_MAX_TX_RINGS;
 	} else {
+		dev_err(&adapter->pdev->dev, "%s: Invalid opmode %d\n",
+			__func__, ret);
 		return -EIO;
 	}
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index c1e11f5..304e247 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -1027,8 +1027,11 @@ int qlcnic_config_port_mirroring(struct qlcnic_adapter *adapter, u8 id,
 	u32 arg1;
 
 	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC ||
-	    !(adapter->eswitch[id].flags & QLCNIC_SWITCH_ENABLE))
+	    !(adapter->eswitch[id].flags & QLCNIC_SWITCH_ENABLE)) {
+		dev_err(&adapter->pdev->dev, "%s: Not a management function\n",
+			__func__);
 		return err;
+	}
 
 	arg1 = id | (enable_mirroring ? BIT_4 : 0);
 	arg1 |= pci_func << 8;
@@ -1318,8 +1321,12 @@ int qlcnic_config_switch_port(struct qlcnic_adapter *adapter,
 	u32 arg1, arg2 = 0;
 	u8 pci_func;
 
-	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC) {
+		dev_err(&adapter->pdev->dev, "%s: Not a management function\n",
+			__func__);
 		return err;
+	}
+
 	pci_func = esw_cfg->pci_func;
 	index = qlcnic_is_valid_nic_func(adapter, pci_func);
 	if (index < 0)
@@ -1363,6 +1370,8 @@ int qlcnic_config_switch_port(struct qlcnic_adapter *adapter,
 			arg1 &= ~(0x0ffff << 16);
 			break;
 	default:
+		dev_err(&adapter->pdev->dev, "%s: Invalid opmode 0x%x\n",
+			__func__, esw_cfg->op_mode);
 		return err;
 	}
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index e96ecca..42f4dfe 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1014,6 +1014,8 @@ int qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 
 		if (pfn >= ahw->max_vnic_func) {
 			ret = QL_STATUS_INVALID_PARAM;
+			dev_err(&adapter->pdev->dev, "%s: Invalid function 0x%x, max 0x%x\n",
+				__func__, pfn, ahw->max_vnic_func);
 			goto err_eswitch;
 		}
 
@@ -2531,8 +2533,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 				dev_err(&pdev->dev, "Adapter initialization failed. Please reboot\n");
 				goto err_out_free_hw;
 			default:
-				dev_err(&pdev->dev, "Adapter initialization failed. A reboot may be required to recover from this failure\n");
-				dev_err(&pdev->dev, "If reboot does not help to recover from this failure, try a flash update of the adapter\n");
+				dev_err(&pdev->dev, "Adapter initialization failed. Driver will load in maintenance mode to recover the adapter using the application\n");
 				goto err_out_maintenance_mode;
 			}
 		}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index eee5fc9..f5786d5 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -362,6 +362,8 @@ int qlcnic_is_valid_nic_func(struct qlcnic_adapter *adapter, u8 pci_func)
 		if (adapter->npars[i].pci_func == pci_func)
 			return i;
 	}
+
+	dev_err(&adapter->pdev->dev, "%s: Invalid nic function\n", __func__);
 	return -EINVAL;
 }
 
-- 
1.8.1.4
