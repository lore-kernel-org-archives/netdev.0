From: Mark Brown <broonie@sirena.org.uk>
Subject: [PATCH 2/2] Subject: natsemi: Allow users to disable workaround for
	DspCfg reset
Date: Thu, 03 May 2007 10:36:56 +0100
Message-ID: <20070503093655.7800.43218.stgit@mercator.sirena.org.uk>
References: <20070503093435.7800.38591.stgit@mercator.sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: =?utf-8?b?UmFmYcWC?= Bilski <rafalbilski@interia.pl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tim Hockin <thockin@hockin.org>, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:3886 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030816AbXECJhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 05:37:14 -0400
In-Reply-To: <20070503093435.7800.38591.stgit@mercator.sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The natsemi driver contains a workaround for broken hardware which can
partially reset the chip at unpredictable times, detected by checking for
spontaneous changes in the DspCfg register.  The effects of the hardware
bug appear to be variable and can range from minor problems like small
numbers of corrupted packets to major ones such as the chip becoming
non-functional.  In the case of minor problems the chip reconfiguration
required to work around the hardware can cause more problems than the bug
itself.

Since we have no way of automatically determining how badly the problem
manifests on any given system provide an option in sysfs allowing users to
disable the workaround at runtime and provides a module option to set the
default.

Signed-Off-By: Mark Brown <broonie@sirena.org.uk>
---

 drivers/net/natsemi.c |   68 ++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 66 insertions(+), 2 deletions(-)

diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 109e802..223e0e6 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -81,6 +81,8 @@ static const int multicast_filter_limit = 100;
    Setting to > 1518 effectively disables this feature. */
 static int rx_copybreak;
 
+static int dspcfg_workaround = 1;
+
 /* Used to pass the media type, etc.
    Both 'options[]' and 'full_duplex[]' should exist for driver
    interoperability.
@@ -139,12 +141,14 @@ MODULE_LICENSE("GPL");
 module_param(mtu, int, 0);
 module_param(debug, int, 0);
 module_param(rx_copybreak, int, 0);
+module_param(dspcfg_workaround, int, 1);
 module_param_array(options, int, NULL, 0);
 module_param_array(full_duplex, int, NULL, 0);
 MODULE_PARM_DESC(mtu, "DP8381x MTU (all boards)");
 MODULE_PARM_DESC(debug, "DP8381x default debug level");
 MODULE_PARM_DESC(rx_copybreak,
 	"DP8381x copy breakpoint for copy-only-tiny-frames");
+MODULE_PARM_DESC(dspcfg_workaround, "DP8381x: control DspCfg workaround");
 MODULE_PARM_DESC(options,
 	"DP8381x: Bits 0-3: media type, bit 17: full duplex");
 MODULE_PARM_DESC(full_duplex, "DP8381x full duplex setting(s) (1)");
@@ -590,6 +594,7 @@ struct netdev_private {
 	u32 srr;
 	/* expected DSPCFG value */
 	u16 dspcfg;
+	int dspcfg_workaround;
 	/* parms saved in ethtool format */
 	u16	speed;		/* The forced speed, 10Mb, 100Mb, gigabit */
 	u8	duplex;		/* Duplex, half or full */
@@ -656,6 +661,56 @@ static int netdev_get_regs(struct net_device *dev, u8 *buf);
 static int netdev_get_eeprom(struct net_device *dev, u8 *buf);
 static const struct ethtool_ops ethtool_ops;
 
+#define NATSEMI_ATTR(_name) \
+static ssize_t natsemi_show_##_name(struct device *dev, \
+         struct device_attribute *attr, char *buf); \
+	 static ssize_t natsemi_set_##_name(struct device *dev, \
+		struct device_attribute *attr, \
+	        const char *buf, size_t count); \
+	 static DEVICE_ATTR(_name, 0644, natsemi_show_##_name, natsemi_set_##_name)
+
+#define NATSEMI_CREATE_FILE(_dev, _name) \
+         device_create_file(&_dev->dev, &dev_attr_##_name)
+#define NATSEMI_REMOVE_FILE(_dev, _name) \
+         device_create_file(&_dev->dev, &dev_attr_##_name)
+
+NATSEMI_ATTR(dspcfg_workaround);
+
+static ssize_t natsemi_show_dspcfg_workaround(struct device *dev,
+				  	      struct device_attribute *attr, 
+					      char *buf)
+{
+	struct netdev_private *np = netdev_priv(to_net_dev(dev));
+
+	return sprintf(buf, "%s\n", np->dspcfg_workaround ? "on" : "off");
+}
+
+static ssize_t natsemi_set_dspcfg_workaround(struct device *dev,
+					     struct device_attribute *attr,
+					     const char *buf, size_t count)
+{
+	struct netdev_private *np = netdev_priv(to_net_dev(dev));
+	int new_setting;
+	u32 flags;
+
+        /* Find out the new setting */
+        if (!strncmp("on", buf, count - 1) || !strncmp("1", buf, count - 1))
+                new_setting = 1;
+        else if (!strncmp("off", buf, count - 1)
+                 || !strncmp("0", buf, count - 1))
+		new_setting = 0;
+	else
+                 return count; 
+
+	spin_lock_irqsave(&np->lock, flags);
+
+	np->dspcfg_workaround = new_setting;
+
+	spin_unlock_irqrestore(&np->lock, flags);
+
+	return count;
+}
+
 static inline void __iomem *ns_ioaddr(struct net_device *dev)
 {
 	return (void __iomem *) dev->base_addr;
@@ -820,6 +875,7 @@ static int __devinit natsemi_probe1 (struct pci_dev *pdev,
 		np->ignore_phy = 1;
 	else
 		np->ignore_phy = 0;
+	np->dspcfg_workaround = dspcfg_workaround;
 
 	/* Initial port:
 	 * - If configured to ignore the PHY set up for external.
@@ -899,6 +955,9 @@ static int __devinit natsemi_probe1 (struct pci_dev *pdev,
 	if (i)
 		goto err_register_netdev;
 
+	if (NATSEMI_CREATE_FILE(pdev, dspcfg_workaround))
+		goto err_create_file;
+
 	if (netif_msg_drv(np)) {
 		printk(KERN_INFO "natsemi %s: %s at %#08lx (%s), ",
 			dev->name, natsemi_pci_info[chip_idx].name, iostart,
@@ -915,6 +974,9 @@ static int __devinit natsemi_probe1 (struct pci_dev *pdev,
 	}
 	return 0;
 
+ err_create_file:
+ 	unregister_netdev(dev);
+
  err_register_netdev:
 	iounmap(ioaddr);
 
@@ -1727,7 +1789,8 @@ static void init_registers(struct net_device *dev)
  *    It seems that a reference set for this chip went out with incorrect info,
  *    and there exist boards that aren't quite right.  An unexpected voltage
  *    drop can cause the PHY to get itself in a weird state (basically reset).
- *    NOTE: this only seems to affect revC chips.
+ *    NOTE: this only seems to affect revC chips.  The user can disable
+ *    this check via dspcfg_workaround sysfs option.
  * 3) check of death of the RX path due to OOM
  */
 static void netdev_timer(unsigned long data)
@@ -1753,7 +1816,7 @@ static void netdev_timer(unsigned long data)
 		writew(1, ioaddr+PGSEL);
 		dspcfg = readw(ioaddr+DSPCFG);
 		writew(0, ioaddr+PGSEL);
-		if (dspcfg != np->dspcfg) {
+		if (np->dspcfg_workaround && dspcfg != np->dspcfg) {
 			if (!netif_queue_stopped(dev)) {
 				spin_unlock_irq(&np->lock);
 				if (netif_msg_drv(np))
@@ -3157,6 +3220,7 @@ static void __devexit natsemi_remove1 (struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	void __iomem * ioaddr = ns_ioaddr(dev);
 
+	NATSEMI_REMOVE_FILE(pdev, dspcfg_workaround);
 	unregister_netdev (dev);
 	pci_release_regions (pdev);
 	iounmap(ioaddr);

