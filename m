From: Sven Hartge <sven@svenhartge.de>
Subject: [PATCH v2] via-velocity: use driver string instead of dev->name
 before register_netdev()
Date: Fri, 24 Oct 2008 01:03:44 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.0810240057090.17076@ds9.feds.ath.cx>
References: <alpine.DEB.2.00.0810230114180.17076@ds9.feds.ath.cx> <20081022170422.7851ea9a@extreme>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenhartge.de ([81.169.140.245]:48101 "EHLO svenhartge.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751552AbYJWXDq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Oct 2008 19:03:46 -0400
Received: from ds9.argh.org ([10.19.78.3])
	by svenhartge.de with esmtp (Exim 4.69)
	(envelope-from <sven@svenhartge.de>)
	id 1Kt9DV-0002Fb-IO
	for netdev@vger.kernel.org; Fri, 24 Oct 2008 01:03:45 +0200
Received: from localhost ([127.0.0.1] ident=oweh)
	by ds9.feds.ath.cx with esmtps (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <sven@svenhartge.de>)
	id 1Kt9DV-0006az-Bj
	for netdev@vger.kernel.org; Fri, 24 Oct 2008 01:03:45 +0200
In-Reply-To: <20081022170422.7851ea9a@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Um 17:04 Uhr am 22.10.08 schrieb Stephen Hemminger:

> NAK
> 
> There is nothing to prevent that device name from being allocated by another device
> at that point.  The correct fix is to not use dev->name until after registering
> the network device.  Change the order of registration or pass dev_driver_string(&pdev->dev)
> instead of dev->name to velocity_get_options

Ok, here is a new version.

This patch corrects a cosmetic bug in the via-velocity driver which 
bothered me for some time.

The messages printed during device init look like the following:

[    8.486422] eth%d: set value of parameter Wake On Lan options to 0
                  ^^!
[    8.487340] eth0: VIA Networking Velocity Family Gigabit Ethernet Adapter

Note the unresolved format string.

dev->name is unavailable before register_netdev, so use 
dev_driver_string(&pdev->dev), which is also consistent with other 
drivers.

"char *devname" parameters had to be converted to "const char *devname" to 
be consistent with dev_driver_string return value.

Signed-off-by: Sven Hartge <sven@svenhartge.de>


diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 2dced38..3590ea5 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -521,7 +521,7 @@ static void __devexit velocity_remove1(struct pci_dev *pdev)
  *	we don't duplicate code for each option.
  */
 
-static void __devinit velocity_set_int_opt(int *opt, int val, int min, int max, int def, char *name, char *devname)
+static void __devinit velocity_set_int_opt(int *opt, int val, int min, int max, int def, char *name, const char *devname)
 {
 	if (val == -1)
 		*opt = def;
@@ -550,7 +550,7 @@ static void __devinit velocity_set_int_opt(int *opt, int val, int min, int max,
  *	we don't duplicate code for each option.
  */
 
-static void __devinit velocity_set_bool_opt(u32 * opt, int val, int def, u32 flag, char *name, char *devname)
+static void __devinit velocity_set_bool_opt(u32 * opt, int val, int def, u32 flag, char *name, const char *devname)
 {
 	(*opt) &= (~flag);
 	if (val == -1)
@@ -576,7 +576,7 @@ static void __devinit velocity_set_bool_opt(u32 * opt, int val, int def, u32 fla
  *	for the current device
  */
 
-static void __devinit velocity_get_options(struct velocity_opt *opts, int index, char *devname)
+static void __devinit velocity_get_options(struct velocity_opt *opts, int index, const char *devname)
 {
 
 	velocity_set_int_opt(&opts->rx_thresh, rx_thresh[index], RX_THRESH_MIN, RX_THRESH_MAX, RX_THRESH_DEF, "rx_thresh", devname);
@@ -863,6 +863,7 @@ static int __devinit velocity_found1(struct pci_dev *pdev, const struct pci_devi
 	static int first = 1;
 	struct net_device *dev;
 	int i;
+	const char *drv_string;
 	const struct velocity_info_tbl *info = &chip_info_table[ent->driver_data];
 	struct velocity_info *vptr;
 	struct mac_regs __iomem * regs;
@@ -935,7 +936,9 @@ static int __devinit velocity_found1(struct pci_dev *pdev, const struct pci_devi
 		dev->dev_addr[i] = readb(&regs->PAR[i]);
 
 
-	velocity_get_options(&vptr->options, velocity_nics, dev->name);
+	drv_string = dev_driver_string(&pdev->dev);
+
+	velocity_get_options(&vptr->options, velocity_nics, drv_string);
 
 	/*
 	 *	Mask out the options cannot be set to the chip
