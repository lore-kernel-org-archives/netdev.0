From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.6 4/6] e100: Fix Wake on lan related
 issues
Date: Thu, 28 Apr 2005 19:17:54 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281914170.29008-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix Wake on lan related issues

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/e100.c net-drivers-2.6/drivers/net/e100.c.new
--- net-drivers-2.6/drivers/net/e100.c	2005-04-07 03:22:36.805273784 -0700
+++ net-drivers-2.6/drivers/net/e100.c.new	2005-04-07 03:22:37.251205992 -0700
@@ -971,7 +971,8 @@ static void e100_configure(struct nic *n
 	if(nic->flags & multicast_all)
 		config->multicast_all = 0x1;		/* 1=accept, 0=no */
 
-	if(!(nic->flags & wol_magic))
+	/* disable WoL when up */
+	if(netif_running(nic->netdev) || !(nic->flags & wol_magic))
 		config->magic_packet_disable = 0x1;	/* 1=off, 0=on */
 
 	if(nic->mac >= mac_82558_D101_A4) {
@@ -1718,6 +1719,7 @@ static int e100_change_mtu(struct net_de
 	return 0;
 }
 
+#ifdef CONFIG_PM
 static int e100_asf(struct nic *nic)
 {
 	/* ASF can be enabled from eeprom */
@@ -1726,6 +1728,7 @@ static int e100_asf(struct nic *nic)
 	   !(nic->eeprom[eeprom_config_asf] & eeprom_gcl) &&
 	   ((nic->eeprom[eeprom_smbus_addr] & 0xFF) != 0xFE));
 }
+#endif
 
 static int e100_up(struct nic *nic)
 {
@@ -1938,7 +1941,6 @@ static int e100_set_wol(struct net_devic
 	else
 		nic->flags &= ~wol_magic;
 
-	pci_enable_wake(nic->pdev, 0, nic->flags & (wol_magic | e100_asf(nic)));
 	e100_exec_cb(nic, NULL, e100_configure);
 
 	return 0;
@@ -2336,7 +2338,8 @@ static int __devinit e100_probe(struct p
 	   (nic->eeprom[eeprom_id] & eeprom_id_wol))
 		nic->flags |= wol_magic;
 
-	pci_enable_wake(pdev, 0, nic->flags & (wol_magic | e100_asf(nic)));
+	/* ack any pending wake events, disable PME */
+	pci_enable_wake(pdev, 0, 0);
 
 	strcpy(netdev->name, "eth%d");
 	if((err = register_netdev(netdev))) {
@@ -2408,6 +2347,8 @@ static int e100_resume(struct pci_dev *p
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
+	/* ack any pending wake events, disable PME */
+	pci_enable_wake(pdev, 0, 0);
 	if(e100_hw_init(nic))
 		DPRINTK(HW, ERR, "e100_hw_init failed\n");
 
@@ -2419,6 +2424,21 @@ static int e100_resume(struct pci_dev *p
 }
 #endif
 
+
+static void e100_shutdown(struct device *dev)
+{
+	struct pci_dev *pdev = container_of(dev, struct pci_dev, dev);
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct nic *nic = netdev_priv(netdev);
+
+#ifdef CONFIG_PM
+	pci_enable_wake(pdev, 0, nic->flags & (wol_magic | e100_asf(nic)));
+#else
+	pci_enable_wake(pdev, 0, nic->flags & (wol_magic));
+#endif
+}
+
+
 static struct pci_driver e100_driver = {
 	.name =         DRV_NAME,
 	.id_table =     e100_id_table,
@@ -2428,6 +2448,11 @@ static struct pci_driver e100_driver = {
 	.suspend =      e100_suspend,
 	.resume =       e100_resume,
 #endif
+
+	.driver = {
+		.shutdown = e100_shutdown,
+	}
+
 };
 
 static int __init e100_init_module(void)
