From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: NetXen crash in sysfs_create_file
Date: Fri, 18 Dec 2009 16:20:54 -0800
Message-ID: <20091218162054.7b19d98f@nehalam>
References: <200912181324.29906.bjorn.helgaas@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Amit Kumar Salecha <amit.salecha@qlogic.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bjorn Helgaas <bjorn.helgaas@hp.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53903 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754715AbZLSAVO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2009 19:21:14 -0500
In-Reply-To: <200912181324.29906.bjorn.helgaas@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Dec 2009 13:24:28 -0700
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:

> With CONFIG_NETXEN_NIC=y, I got the following crash.  Turning off
> NETXEN_NIC avoided it (this machine has no NetXen NIC).
> 
> This is on bea4c899f2b5fad80099aea979780ef19f9b1987 (Linus upstream from
> yesterday).
> 
> Bjorn

Subject: [PATCH] netxen: use module parameter correctly

Netxen driver is doing this bogus thing to create a control file.
This fails if device doesn't exist, and overall is a bad way to do
the module parameter. Rather than fix borked code, just rewrite.
Just using a writeable module parameter of 0/1 is the correct way

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/netxen/netxen_nic_main.c	2009-12-18 16:13:20.169390067 -0800
+++ b/drivers/net/netxen/netxen_nic_main.c	2009-12-18 16:17:43.650014965 -0800
@@ -57,7 +57,9 @@ static int use_msi = 1;
 
 static int use_msi_x = 1;
 
-static unsigned long auto_fw_reset = AUTO_FW_RESET_ENABLED;
+static int auto_fw_reset = AUTO_FW_RESET_ENABLED;
+module_param(auto_fw_reset, int, 0644);
+MODULE_PARM_DESC(auto_fw_reset,"Auto firmware reset (0=disabled, 1=enabled");
 
 static int __devinit netxen_nic_probe(struct pci_dev *pdev,
 		const struct pci_device_id *ent);
@@ -2534,42 +2536,6 @@ static struct bin_attribute bin_attr_mem
 	.write = netxen_sysfs_write_mem,
 };
 
-#ifdef CONFIG_MODULES
-static ssize_t
-netxen_store_auto_fw_reset(struct module_attribute *mattr,
-		struct module *mod, const char *buf, size_t count)
-
-{
-	unsigned long new;
-
-	if (strict_strtoul(buf, 16, &new))
-		return -EINVAL;
-
-	if ((new == AUTO_FW_RESET_ENABLED) || (new == AUTO_FW_RESET_DISABLED)) {
-		auto_fw_reset = new;
-		return count;
-	}
-
-	return -EINVAL;
-}
-
-static ssize_t
-netxen_show_auto_fw_reset(struct module_attribute *mattr,
-		struct module *mod, char *buf)
-
-{
-	if (auto_fw_reset == AUTO_FW_RESET_ENABLED)
-		return sprintf(buf, "enabled\n");
-	else
-		return sprintf(buf, "disabled\n");
-}
-
-static struct module_attribute mod_attr_fw_reset = {
-	.attr = {.name = "auto_fw_reset", .mode = (S_IRUGO | S_IWUSR)},
-	.show = netxen_show_auto_fw_reset,
-	.store = netxen_store_auto_fw_reset,
-};
-#endif
 
 static void
 netxen_create_sysfs_entries(struct netxen_adapter *adapter)
@@ -2775,23 +2741,12 @@ static struct pci_driver netxen_driver =
 
 static int __init netxen_init_module(void)
 {
-#ifdef CONFIG_MODULES
-	struct module *mod = THIS_MODULE;
-#endif
-
 	printk(KERN_INFO "%s\n", netxen_nic_driver_string);
 
 #ifdef CONFIG_INET
 	register_netdevice_notifier(&netxen_netdev_cb);
 	register_inetaddr_notifier(&netxen_inetaddr_cb);
 #endif
-
-#ifdef CONFIG_MODULES
-	if (sysfs_create_file(&mod->mkobj.kobj, &mod_attr_fw_reset.attr))
-		printk(KERN_ERR "%s: Failed to create auto_fw_reset "
-				"sysfs entry.", netxen_nic_driver_name);
-#endif
-
 	return pci_register_driver(&netxen_driver);
 }
 
@@ -2799,12 +2754,6 @@ module_init(netxen_init_module);
 
 static void __exit netxen_exit_module(void)
 {
-#ifdef CONFIG_MODULES
-	struct module *mod = THIS_MODULE;
-
-	sysfs_remove_file(&mod->mkobj.kobj, &mod_attr_fw_reset.attr);
-#endif
-
 	pci_unregister_driver(&netxen_driver);
 
 #ifdef CONFIG_INET


