From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: 2.4.29, e100 and a WOL packet causes keventd going mad
Date: Sun, 30 Jan 2005 21:00:15 -0800
Message-ID: <1107147615.18167.433.camel@localhost.localdomain>
References: <20050130171849.GA3354@hardeman.nu>
	 <1107143255.18167.428.camel@localhost.localdomain>
	 <1107143905.21273.33.camel@desktop.cunninghams>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David =?ISO-8859-1?Q?H=E4rdeman?= <david@2gen.com>,
	Michael Gernoth <simigern@stud.uni-erlangen.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261917AbVAaE6q@vger.kernel.org>
To: ncunningham@linuxmail.org
In-Reply-To: <1107143905.21273.33.camel@desktop.cunninghams>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2005-01-30 at 19:58, Nigel Cunningham wrote:
> Do you also disable the WOL event when resuming?

Good catch.  How's this look?

--- linux-2.6.11-rc2/drivers/net/e100.c.orig	2005-01-30 19:13:56.850497376 -0800
+++ linux-2.6.11-rc2/drivers/net/e100.c	2005-01-30 20:53:22.630560952 -0800
@@ -1868,7 +1868,6 @@ static int e100_set_wol(struct net_devic
 	else
 		nic->flags &= ~wol_magic;
 
-	pci_enable_wake(nic->pdev, 0, nic->flags & (wol_magic | e100_asf(nic)));
 	e100_exec_cb(nic, NULL, e100_configure);
 
 	return 0;
@@ -2262,8 +2261,6 @@ static int __devinit e100_probe(struct p
 	   (nic->eeprom[eeprom_id] & eeprom_id_wol))
 		nic->flags |= wol_magic;
 
-	pci_enable_wake(pdev, 0, nic->flags & (wol_magic | e100_asf(nic)));
-
 	strcpy(netdev->name, "eth%d");
 	if((err = register_netdev(netdev))) {
 		DPRINTK(PROBE, ERR, "Cannot register net device, aborting.\n");
@@ -2320,7 +2317,8 @@ static int e100_suspend(struct pci_dev *
 	netif_device_detach(netdev);
 
 	pci_save_state(pdev);
-	pci_enable_wake(pdev, state, nic->flags & (wol_magic | e100_asf(nic)));
+	pci_enable_wake(pdev, pci_choose_state(pdev, state),
+		nic->flags & (wol_magic | e100_asf(nic)));
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
 
@@ -2333,6 +2331,7 @@ static int e100_resume(struct pci_dev *p
 	struct nic *nic = netdev_priv(netdev);
 
 	pci_set_power_state(pdev, PCI_D0);
+	pci_enable_wake(pdev, PCI_D0, 0);
 	pci_restore_state(pdev);
 	e100_hw_init(nic);
 
@@ -2344,6 +2343,15 @@ static int e100_resume(struct pci_dev *p
 }
 #endif
 
+static void e100_shutdown(struct device *dev)
+{
+	struct pci_dev *pdev = container_of(dev, struct pci_dev, dev);
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct nic *nic = netdev_priv(netdev);
+
+	pci_enable_wake(pdev, PCI_D0, nic->flags & (wol_magic | e100_asf(nic)));
+}
+
 static struct pci_driver e100_driver = {
 	.name =         DRV_NAME,
 	.id_table =     e100_id_table,
@@ -2353,6 +2361,9 @@ static struct pci_driver e100_driver = {
 	.suspend =      e100_suspend,
 	.resume =       e100_resume,
 #endif
+	.driver = {
+		.shutdown = e100_shutdown,
+	}
 };
 
 static int __init e100_init_module(void)
