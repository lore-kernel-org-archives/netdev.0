From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 7/7] netxen: sysfs control for auto firmware recovery
Date: Thu, 15 Oct 2009 23:09:13 -0700
Message-ID: <1255673353-31797-8-git-send-email-dhananjay@netxen.com>
References: <1255673353-31797-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, Narender Kumar <narender.kumar@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:45980 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754577AbZJPGKb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2009 02:10:31 -0400
In-Reply-To: <1255673353-31797-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Narender Kumar <narender.kumar@qlogic.com>

Firmware hang detection and recovery (reset) need to
be disabled for diagnostic tools, which can run
some disruptive tests.

This adds a driver level control to turn off this
feature by diag tools.

Signed-off-by: Narender Kumar <narender.kumar@qlogic.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    3 ++
 drivers/net/netxen/netxen_nic_main.c |   50 +++++++++++++++++++++++++++++++++-
 2 files changed, 52 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index ae4bc7b..9936f92 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1044,6 +1044,9 @@ typedef struct {
 #define LINKEVENT_LINKSPEED_MBPS	0
 #define LINKEVENT_LINKSPEED_ENCODED	1
 
+#define AUTO_FW_RESET_ENABLED	0xEF10AF12
+#define AUTO_FW_RESET_DISABLED	0xDCBAAF12
+
 /* firmware response header:
  *	63:58 - message type
  *	57:56 - owner
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 30d9afe..bfe8fcc 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -52,6 +52,8 @@ static int use_msi = 1;
 
 static int use_msi_x = 1;
 
+static unsigned long auto_fw_reset = AUTO_FW_RESET_ENABLED;
+
 /* Local functions to NetXen NIC driver */
 static int __devinit netxen_nic_probe(struct pci_dev *pdev,
 		const struct pci_device_id *ent);
@@ -2264,7 +2266,8 @@ netxen_check_health(struct netxen_adapter *adapter)
 	dev_info(&netdev->dev, "firmware hang detected\n");
 
 detach:
-	if (!test_and_set_bit(__NX_RESETTING, &adapter->state))
+	if ((auto_fw_reset == AUTO_FW_RESET_ENABLED) &&
+			!test_and_set_bit(__NX_RESETTING, &adapter->state))
 		netxen_schedule_work(adapter, netxen_detach_work, 0);
 	return 1;
 }
@@ -2496,6 +2499,41 @@ static struct bin_attribute bin_attr_mem = {
 	.write = netxen_sysfs_write_mem,
 };
 
+static ssize_t
+netxen_store_auto_fw_reset(struct module_attribute *mattr,
+		struct module *mod, const char *buf, size_t count)
+
+{
+	unsigned long new;
+
+	if (strict_strtoul(buf, 16, &new))
+		return -EINVAL;
+
+	if ((new == AUTO_FW_RESET_ENABLED) || (new == AUTO_FW_RESET_DISABLED)) {
+		auto_fw_reset = new;
+		return count;
+	}
+
+	return -EINVAL;
+}
+
+static ssize_t
+netxen_show_auto_fw_reset(struct module_attribute *mattr,
+		struct module *mod, char *buf)
+
+{
+	if (auto_fw_reset == AUTO_FW_RESET_ENABLED)
+		return sprintf(buf, "enabled\n");
+	else
+		return sprintf(buf, "disabled\n");
+}
+
+static struct module_attribute mod_attr_fw_reset = {
+	.attr = {.name = "auto_fw_reset", .mode = (S_IRUGO | S_IWUSR)},
+	.show = netxen_show_auto_fw_reset,
+	.store = netxen_store_auto_fw_reset,
+};
+
 static void
 netxen_create_sysfs_entries(struct netxen_adapter *adapter)
 {
@@ -2700,12 +2738,18 @@ static struct pci_driver netxen_driver = {
 
 static int __init netxen_init_module(void)
 {
+	struct module *mod = THIS_MODULE;
+
 	printk(KERN_INFO "%s\n", netxen_nic_driver_string);
 
 #ifdef CONFIG_INET
 	register_netdevice_notifier(&netxen_netdev_cb);
 	register_inetaddr_notifier(&netxen_inetaddr_cb);
 #endif
+	
+	if (sysfs_create_file(&mod->mkobj.kobj, &mod_attr_fw_reset.attr))
+		printk(KERN_ERR "%s: Failed to create auto_fw_reset "
+				"sysfs entry.", netxen_nic_driver_name);
 
 	return pci_register_driver(&netxen_driver);
 }
@@ -2714,6 +2758,10 @@ module_init(netxen_init_module);
 
 static void __exit netxen_exit_module(void)
 {
+	struct module *mod = THIS_MODULE;
+
+	sysfs_remove_file(&mod->mkobj.kobj, &mod_attr_fw_reset.attr);
+
 	pci_unregister_driver(&netxen_driver);
 
 #ifdef CONFIG_INET
-- 
1.6.0.2

