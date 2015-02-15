From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH] ehea: Register memory hotplug, reboot and crash hooks on adapter probe
Date: Sun, 15 Feb 2015 17:44:20 -0200
Message-ID: <1424029460-8587-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: Anton Blanchard <anton@samba.org>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:44653 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754398AbbBOTpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 14:45:01 -0500
Received: from /spool/local
	by e24smtp05.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Sun, 15 Feb 2015 17:44:55 -0200
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.13.184.25])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id C144E1DC0051
	for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 14:43:55 -0500 (EST)
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay03.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t1FJiDKb65798188
	for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 16:44:14 -0300
Received: from d24av05.br.ibm.com (localhost [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t1FJio0I023553
	for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 14:44:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>

ehea creates memory hotplug, reboot and crash hooks even if there
are no adapters in the box. Just create them when we probe our
first adapter.

[cascardo: use ehea_register_memory_hooks return code]
Signed-off-by: Anton Blanchard <anton@samba.org>
Tested-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c |  246 +++++++++++++++++------------
 1 file changed, 141 insertions(+), 105 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 566b17d..6adfcdb 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -3262,6 +3262,139 @@ static void ehea_remove_device_sysfs(struct platform_device *dev)
 	device_remove_file(&dev->dev, &dev_attr_remove_port);
 }
 
+static int ehea_reboot_notifier(struct notifier_block *nb,
+				unsigned long action, void *unused)
+{
+	if (action == SYS_RESTART) {
+		pr_info("Reboot: freeing all eHEA resources\n");
+		ibmebus_unregister_driver(&ehea_driver);
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block ehea_reboot_nb = {
+	.notifier_call = ehea_reboot_notifier,
+};
+
+static int ehea_mem_notifier(struct notifier_block *nb,
+			     unsigned long action, void *data)
+{
+	int ret = NOTIFY_BAD;
+	struct memory_notify *arg = data;
+
+	mutex_lock(&dlpar_mem_lock);
+
+	switch (action) {
+	case MEM_CANCEL_OFFLINE:
+		pr_info("memory offlining canceled");
+		/* Fall through: re-add canceled memory block */
+
+	case MEM_ONLINE:
+		pr_info("memory is going online");
+		set_bit(__EHEA_STOP_XFER, &ehea_driver_flags);
+		if (ehea_add_sect_bmap(arg->start_pfn, arg->nr_pages))
+			goto out_unlock;
+		ehea_rereg_mrs();
+		break;
+
+	case MEM_GOING_OFFLINE:
+		pr_info("memory is going offline");
+		set_bit(__EHEA_STOP_XFER, &ehea_driver_flags);
+		if (ehea_rem_sect_bmap(arg->start_pfn, arg->nr_pages))
+			goto out_unlock;
+		ehea_rereg_mrs();
+		break;
+
+	default:
+		break;
+	}
+
+	ehea_update_firmware_handles();
+	ret = NOTIFY_OK;
+
+out_unlock:
+	mutex_unlock(&dlpar_mem_lock);
+	return ret;
+}
+
+static struct notifier_block ehea_mem_nb = {
+	.notifier_call = ehea_mem_notifier,
+};
+
+static void ehea_crash_handler(void)
+{
+	int i;
+
+	if (ehea_fw_handles.arr)
+		for (i = 0; i < ehea_fw_handles.num_entries; i++)
+			ehea_h_free_resource(ehea_fw_handles.arr[i].adh,
+					     ehea_fw_handles.arr[i].fwh,
+					     FORCE_FREE);
+
+	if (ehea_bcmc_regs.arr)
+		for (i = 0; i < ehea_bcmc_regs.num_entries; i++)
+			ehea_h_reg_dereg_bcmc(ehea_bcmc_regs.arr[i].adh,
+					      ehea_bcmc_regs.arr[i].port_id,
+					      ehea_bcmc_regs.arr[i].reg_type,
+					      ehea_bcmc_regs.arr[i].macaddr,
+					      0, H_DEREG_BCMC);
+}
+
+static atomic_t ehea_memory_hooks_registered;
+
+/* Register memory hooks on probe of first adapter */
+static int ehea_register_memory_hooks(void)
+{
+	int ret = 0;
+
+	if (atomic_inc_and_test(&ehea_memory_hooks_registered))
+		return 0;
+
+	ret = ehea_create_busmap();
+	if (ret) {
+		pr_info("ehea_create_busmap failed\n");
+		goto out;
+	}
+
+	ret = register_reboot_notifier(&ehea_reboot_nb);
+	if (ret) {
+		pr_info("register_reboot_notifier failed\n");
+		goto out;
+	}
+
+	ret = register_memory_notifier(&ehea_mem_nb);
+	if (ret) {
+		pr_info("register_memory_notifier failed\n");
+		goto out2;
+	}
+
+	ret = crash_shutdown_register(ehea_crash_handler);
+	if (ret) {
+		pr_info("crash_shutdown_register failed\n");
+		goto out3;
+	}
+
+	return 0;
+
+out3:
+	unregister_memory_notifier(&ehea_mem_nb);
+out2:
+	unregister_reboot_notifier(&ehea_reboot_nb);
+out:
+	return ret;
+}
+
+static void ehea_unregister_memory_hooks(void)
+{
+	if (atomic_read(&ehea_memory_hooks_registered))
+		return;
+
+	unregister_reboot_notifier(&ehea_reboot_nb);
+	if (crash_shutdown_unregister(ehea_crash_handler))
+		pr_info("failed unregistering crash handler\n");
+	unregister_memory_notifier(&ehea_mem_nb);
+}
+
 static int ehea_probe_adapter(struct platform_device *dev)
 {
 	struct ehea_adapter *adapter;
@@ -3269,6 +3402,10 @@ static int ehea_probe_adapter(struct platform_device *dev)
 	int ret;
 	int i;
 
+	ret = ehea_register_memory_hooks();
+	if (ret)
+		return ret;
+
 	if (!dev || !dev->dev.of_node) {
 		pr_err("Invalid ibmebus device probed\n");
 		return -EINVAL;
@@ -3392,81 +3529,6 @@ static int ehea_remove(struct platform_device *dev)
 	return 0;
 }
 
-static void ehea_crash_handler(void)
-{
-	int i;
-
-	if (ehea_fw_handles.arr)
-		for (i = 0; i < ehea_fw_handles.num_entries; i++)
-			ehea_h_free_resource(ehea_fw_handles.arr[i].adh,
-					     ehea_fw_handles.arr[i].fwh,
-					     FORCE_FREE);
-
-	if (ehea_bcmc_regs.arr)
-		for (i = 0; i < ehea_bcmc_regs.num_entries; i++)
-			ehea_h_reg_dereg_bcmc(ehea_bcmc_regs.arr[i].adh,
-					      ehea_bcmc_regs.arr[i].port_id,
-					      ehea_bcmc_regs.arr[i].reg_type,
-					      ehea_bcmc_regs.arr[i].macaddr,
-					      0, H_DEREG_BCMC);
-}
-
-static int ehea_mem_notifier(struct notifier_block *nb,
-                             unsigned long action, void *data)
-{
-	int ret = NOTIFY_BAD;
-	struct memory_notify *arg = data;
-
-	mutex_lock(&dlpar_mem_lock);
-
-	switch (action) {
-	case MEM_CANCEL_OFFLINE:
-		pr_info("memory offlining canceled");
-		/* Readd canceled memory block */
-	case MEM_ONLINE:
-		pr_info("memory is going online");
-		set_bit(__EHEA_STOP_XFER, &ehea_driver_flags);
-		if (ehea_add_sect_bmap(arg->start_pfn, arg->nr_pages))
-			goto out_unlock;
-		ehea_rereg_mrs();
-		break;
-	case MEM_GOING_OFFLINE:
-		pr_info("memory is going offline");
-		set_bit(__EHEA_STOP_XFER, &ehea_driver_flags);
-		if (ehea_rem_sect_bmap(arg->start_pfn, arg->nr_pages))
-			goto out_unlock;
-		ehea_rereg_mrs();
-		break;
-	default:
-		break;
-	}
-
-	ehea_update_firmware_handles();
-	ret = NOTIFY_OK;
-
-out_unlock:
-	mutex_unlock(&dlpar_mem_lock);
-	return ret;
-}
-
-static struct notifier_block ehea_mem_nb = {
-	.notifier_call = ehea_mem_notifier,
-};
-
-static int ehea_reboot_notifier(struct notifier_block *nb,
-				unsigned long action, void *unused)
-{
-	if (action == SYS_RESTART) {
-		pr_info("Reboot: freeing all eHEA resources\n");
-		ibmebus_unregister_driver(&ehea_driver);
-	}
-	return NOTIFY_DONE;
-}
-
-static struct notifier_block ehea_reboot_nb = {
-	.notifier_call = ehea_reboot_notifier,
-};
-
 static int check_module_parm(void)
 {
 	int ret = 0;
@@ -3520,26 +3582,10 @@ static int __init ehea_module_init(void)
 	if (ret)
 		goto out;
 
-	ret = ehea_create_busmap();
-	if (ret)
-		goto out;
-
-	ret = register_reboot_notifier(&ehea_reboot_nb);
-	if (ret)
-		pr_info("failed registering reboot notifier\n");
-
-	ret = register_memory_notifier(&ehea_mem_nb);
-	if (ret)
-		pr_info("failed registering memory remove notifier\n");
-
-	ret = crash_shutdown_register(ehea_crash_handler);
-	if (ret)
-		pr_info("failed registering crash handler\n");
-
 	ret = ibmebus_register_driver(&ehea_driver);
 	if (ret) {
 		pr_err("failed registering eHEA device driver on ebus\n");
-		goto out2;
+		goto out;
 	}
 
 	ret = driver_create_file(&ehea_driver.driver,
@@ -3547,32 +3593,22 @@ static int __init ehea_module_init(void)
 	if (ret) {
 		pr_err("failed to register capabilities attribute, ret=%d\n",
 		       ret);
-		goto out3;
+		goto out2;
 	}
 
 	return ret;
 
-out3:
-	ibmebus_unregister_driver(&ehea_driver);
 out2:
-	unregister_memory_notifier(&ehea_mem_nb);
-	unregister_reboot_notifier(&ehea_reboot_nb);
-	crash_shutdown_unregister(ehea_crash_handler);
+	ibmebus_unregister_driver(&ehea_driver);
 out:
 	return ret;
 }
 
 static void __exit ehea_module_exit(void)
 {
-	int ret;
-
 	driver_remove_file(&ehea_driver.driver, &driver_attr_capabilities);
 	ibmebus_unregister_driver(&ehea_driver);
-	unregister_reboot_notifier(&ehea_reboot_nb);
-	ret = crash_shutdown_unregister(ehea_crash_handler);
-	if (ret)
-		pr_info("failed unregistering crash handler\n");
-	unregister_memory_notifier(&ehea_mem_nb);
+	ehea_unregister_memory_hooks();
 	kfree(ehea_fw_handles.arr);
 	kfree(ehea_bcmc_regs.arr);
 	ehea_destroy_busmap();
-- 
1.7.10.4
