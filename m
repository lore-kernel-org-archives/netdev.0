From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next 2/6] qlcnic: Replace kzalloc() with vzalloc().
Date: Fri, 1 Nov 2013 16:51:25 -0400
Message-ID: <4e485cb2ec05e3cae68fbf59a0f1597a95098a76.1383358893.git.himanshu.madhani@qlogic.com>
References: <cover.1383358893.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:31667 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753759Ab3KAVWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 17:22:43 -0400
In-Reply-To: <cover.1383358893.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o Some of the places kzalloc() is not required. Replace it
  with vzalloc() wherever it is not used appropriately

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c |  4 ++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c   | 12 ++++++------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c     | 12 ++++++------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c    | 21 ++++++++++-----------
 4 files changed, 24 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index f81e2dd..2270a3e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -3544,7 +3544,7 @@ void qlcnic_83xx_free_mailbox(struct qlcnic_mailbox *mbx)
 		return;
 
 	destroy_workqueue(mbx->work_q);
-	kfree(mbx);
+	vfree(mbx);
 }
 
 static inline void
@@ -3817,7 +3817,7 @@ int qlcnic_83xx_init_mailbox_work(struct qlcnic_adapter *adapter)
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	struct qlcnic_mailbox *mbx;
 
-	ahw->mailbox = kzalloc(sizeof(*mbx), GFP_KERNEL);
+	ahw->mailbox = vzalloc(sizeof(*mbx));
 	if (!ahw->mailbox)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 4a8a3f1..475e919 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -1254,24 +1254,24 @@ static int qlcnic_83xx_copy_bootloader(struct qlcnic_adapter *adapter)
 	if (size & 0xF)
 		size = (size + 16) & ~0xF;
 
-	p_cache = kzalloc(size, GFP_KERNEL);
+	p_cache = vzalloc(size);
 	if (p_cache == NULL)
 		return -ENOMEM;
 
 	ret = qlcnic_83xx_lockless_flash_read32(adapter, src, p_cache,
 						size / sizeof(u32));
 	if (ret) {
-		kfree(p_cache);
+		vfree(p_cache);
 		return ret;
 	}
 	/* 16 byte write to MS memory */
 	ret = qlcnic_83xx_ms_mem_write128(adapter, dest, (u32 *)p_cache,
 					  size / 16);
 	if (ret) {
-		kfree(p_cache);
+		vfree(p_cache);
 		return ret;
 	}
-	kfree(p_cache);
+	vfree(p_cache);
 
 	return ret;
 }
@@ -1605,13 +1605,13 @@ int qlcnic_83xx_get_reset_instruction_template(struct qlcnic_adapter *p_dev)
 		prev_ver = p_dev->fw_version;
 		curr_ver = qlcnic_83xx_get_fw_version(p_dev);
 		if (curr_ver > prev_ver)
-			kfree(ahw->reset.buff);
+			vfree(ahw->reset.buff);
 		else
 			return 0;
 	}
 
 	ahw->reset.seq_error = 0;
-	ahw->reset.buff = kzalloc(QLC_83XX_RESTART_TEMPLATE_SIZE, GFP_KERNEL);
+	ahw->reset.buff = vzalloc(QLC_83XX_RESTART_TEMPLATE_SIZE);
 	if (p_dev->ahw->reset.buff == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
index 86bca7c..d8949b5 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
@@ -260,7 +260,7 @@ int qlcnic_register_dcb(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_dcb *dcb;
 
-	dcb = kzalloc(sizeof(struct qlcnic_dcb), GFP_ATOMIC);
+	dcb = vzalloc(sizeof(*dcb));
 	if (!dcb)
 		return -ENOMEM;
 
@@ -292,11 +292,11 @@ static void __qlcnic_dcb_free(struct qlcnic_dcb *dcb)
 		dcb->wq = NULL;
 	}
 
-	kfree(dcb->cfg);
+	vfree(dcb->cfg);
 	dcb->cfg = NULL;
-	kfree(dcb->param);
+	vfree(dcb->param);
 	dcb->param = NULL;
-	kfree(dcb);
+	vfree(dcb);
 	adapter->dcb = NULL;
 }
 
@@ -320,13 +320,13 @@ static int __qlcnic_dcb_attach(struct qlcnic_dcb *dcb)
 		return -1;
 	}
 
-	dcb->cfg = kzalloc(sizeof(struct qlcnic_dcb_cfg), GFP_ATOMIC);
+	dcb->cfg = vzalloc(sizeof(*dcb->cfg));
 	if (!dcb->cfg) {
 		err = -ENOMEM;
 		goto out_free_wq;
 	}
 
-	dcb->param = kzalloc(sizeof(struct qlcnic_dcb_mbx_params), GFP_ATOMIC);
+	dcb->param = vzalloc(sizeof(*dcb->param));
 	if (!dcb->param) {
 		err = -ENOMEM;
 		goto out_free_cfg;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 46ddbd8..8d4536d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -818,8 +818,8 @@ static bool qlcnic_port_eswitch_cfg_capability(struct qlcnic_adapter *adapter)
 
 int qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 {
+	int i, id = 0, ret = 0, j = 0, size;
 	struct qlcnic_pci_info *pci_info;
-	int i, id = 0, ret = 0, j = 0;
 	u16 act_pci_func;
 	u8 pfn;
 
@@ -832,16 +832,15 @@ int qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 		goto err_pci_info;
 
 	act_pci_func = adapter->ahw->act_pci_func;
-
-	adapter->npars = kzalloc(sizeof(struct qlcnic_npar_info) *
-				 act_pci_func, GFP_KERNEL);
+	size = sizeof(struct qlcnic_npar_info) * act_pci_func;
+	adapter->npars = vzalloc(size);
 	if (!adapter->npars) {
 		ret = -ENOMEM;
 		goto err_pci_info;
 	}
 
-	adapter->eswitch = kzalloc(sizeof(struct qlcnic_eswitch) *
-				QLCNIC_NIU_MAX_XG_PORTS, GFP_KERNEL);
+	size = sizeof(struct qlcnic_eswitch) * QLCNIC_NIU_MAX_XG_PORTS;
+	adapter->eswitch = vzalloc(size);
 	if (!adapter->eswitch) {
 		ret = -ENOMEM;
 		goto err_npars;
@@ -892,10 +891,10 @@ int qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 	return 0;
 
 err_eswitch:
-	kfree(adapter->eswitch);
+	vfree(adapter->eswitch);
 	adapter->eswitch = NULL;
 err_npars:
-	kfree(adapter->npars);
+	vfree(adapter->npars);
 	adapter->npars = NULL;
 err_pci_info:
 	kfree(pci_info);
@@ -1881,7 +1880,7 @@ static void qlcnic_free_adapter_resources(struct qlcnic_adapter *adapter)
 		adapter->ahw->fw_dump.tmpl_hdr = NULL;
 	}
 
-	kfree(adapter->ahw->reset.buff);
+	vfree(adapter->ahw->reset.buff);
 	adapter->ahw->fw_dump.tmpl_hdr = NULL;
 }
 
@@ -2480,9 +2479,9 @@ static void qlcnic_remove(struct pci_dev *pdev)
 	qlcnic_detach(adapter);
 
 	if (adapter->npars != NULL)
-		kfree(adapter->npars);
+		vfree(adapter->npars);
 	if (adapter->eswitch != NULL)
-		kfree(adapter->eswitch);
+		vfree(adapter->eswitch);
 
 	if (qlcnic_82xx_check(adapter))
 		qlcnic_clr_all_drv_state(adapter, 0);
-- 
1.8.1.4
