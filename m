From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (09/12) Probe2 -- arlan
Date: Tue, 14 Oct 2003 15:34:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310142234.h9EMYAZ30173@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert arlan driver to new probing.  This meant a rather large
rework of the probing code for this driver since it did a lot ofnon
standard things.
	

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Oct 14 14:35:00 2003
+++ b/drivers/net/Space.c	Tue Oct 14 14:35:00 2003
@@ -59,7 +59,7 @@
 extern int ewrk3_probe(struct net_device *);
 extern int el1_probe(struct net_device *);
 extern int wavelan_probe(struct net_device *);
-extern int arlan_probe(struct net_device *);
+extern struct net_device *arlan_probe(int unit);
 extern struct net_device *el16_probe(int unit);
 extern int elmc_probe(struct net_device *);
 extern int skmca_probe(struct net_device *);
@@ -268,13 +268,13 @@
 #ifdef CONFIG_WAVELAN		/* WaveLAN */
 	{wavelan_probe, 0},
 #endif
-#ifdef CONFIG_ARLAN		/* Aironet */
-	{arlan_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_ARLAN		/* Aironet */
+	{arlan_probe, 0},
+#endif
 #ifdef CONFIG_EL16		/* 3c507 */
 	{el16_probe, 0},
 #endif
diff -Nru a/drivers/net/wireless/arlan-main.c b/drivers/net/wireless/arlan-main.c
--- a/drivers/net/wireless/arlan-main.c	Tue Oct 14 14:35:00 2003
+++ b/drivers/net/wireless/arlan-main.c	Tue Oct 14 14:35:00 2003
@@ -19,9 +19,7 @@
 static int SID = SIDUNKNOWN;
 static int radioNodeId = radioNodeIdUNKNOWN;
 static char encryptionKey[12] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'};
-static int mem = memUNKNOWN;
 int arlan_debug = debugUNKNOWN;
-static int numDevices = numDevicesUNKNOWN;
 static int spreadingCode = spreadingCodeUNKNOWN;
 static int channelNumber = channelNumberUNKNOWN;
 static int channelSet = channelSetUNKNOWN;
@@ -45,9 +43,7 @@
 
 MODULE_PARM(irq, "i");
 MODULE_PARM(mem, "i");
-MODULE_PARM(probe, "i");
 MODULE_PARM(arlan_debug, "i");
-MODULE_PARM(numDevices, "i");
 MODULE_PARM(testMemory, "i");
 MODULE_PARM(spreadingCode, "i");
 MODULE_PARM(channelNumber, "i");
@@ -69,9 +65,7 @@
 MODULE_PARM(arlan_EEPROM_bad, "i");
 MODULE_PARM_DESC(irq, "(unused)");
 MODULE_PARM_DESC(mem, "Arlan memory address for single device probing");
-MODULE_PARM_DESC(probe, "Arlan probe at initialization (0-1)");
 MODULE_PARM_DESC(arlan_debug, "Arlan debug enable (0-1)");
-MODULE_PARM_DESC(numDevices, "Number of Arlan devices; ignored if >1");
 MODULE_PARM_DESC(testMemory, "(unused)");
 MODULE_PARM_DESC(mdebug, "Arlan multicast debugging (0-1)");
 MODULE_PARM_DESC(retries, "Arlan maximum packet retransmisions");
@@ -88,7 +82,6 @@
 struct arlan_conf_stru arlan_conf[MAX_ARLANS];
 static int arlans_found;
 
-static  int 	arlan_probe_here(struct net_device *dev, int ioaddr);
 static  int 	arlan_open(struct net_device *dev);
 static  int 	arlan_tx(struct sk_buff *skb, struct net_device *dev);
 static  irqreturn_t arlan_interrupt(int irq, void *dev_id, struct pt_regs *regs);
@@ -975,24 +968,27 @@
  * probes on the ISA bus. A good device probes avoids doing writes, and
  * verifies that the correct device exists and functions.
  */
-
-static int __init arlan_check_fingerprint(int memaddr)
+#define ARLAN_SHMEM_SIZE	0x2000
+static int __init arlan_check_fingerprint(unsigned long memaddr)
 {
-	static char probeText[] = "TELESYSTEM SLW INC.    ARLAN \0";
-	char tempBuf[49];
+	static const char probeText[] = "TELESYSTEM SLW INC.    ARLAN \0";
 	volatile struct arlan_shmem *arlan = (struct arlan_shmem *) memaddr;
+	unsigned long paddr = virt_to_phys((void *) memaddr);
+	char tempBuf[49];
 
 	ARLAN_DEBUG_ENTRY("arlan_check_fingerprint");
-	if (check_mem_region(virt_to_phys((void *)memaddr),0x2000 )){
-		// printk(KERN_WARNING "arlan: memory region %lx excluded from probing \n",virt_to_phys((void*)memaddr));
+
+	if (!request_mem_region(paddr, ARLAN_SHMEM_SIZE, "arlan")) {
+		// printk(KERN_WARNING "arlan: memory region %lx excluded from probing \n",paddr);
 		return -ENODEV;
 	}
+
 	memcpy_fromio(tempBuf, arlan->textRegion, 29);
 	tempBuf[30] = 0;
 
 	/* check for card at this address */
 	if (0 != strncmp(tempBuf, probeText, 29)){
-// not 		release_mem_region(virt_to_phys((void*)memaddr),0x2000);
+ 		release_mem_region(paddr, ARLAN_SHMEM_SIZE);
 		return -ENODEV;
 	}
 
@@ -1000,51 +996,8 @@
 	ARLAN_DEBUG_EXIT("arlan_check_fingerprint");
 
 	return 0;
-
-
-}
-
-static int __init arlan_probe_everywhere(struct net_device *dev)
-{
-	int m;
-	int probed = 0;
-	int found = 0;
-
-	SET_MODULE_OWNER(dev);
-
-	ARLAN_DEBUG_ENTRY("arlan_probe_everywhere");
-	if (mem != 0 && numDevices == 1)	/* Check a single specified location. */
-	{
-		if (arlan_probe_here(dev, (int) phys_to_virt(  mem) ) == 0)
-			return 0;
-		else
-			return -ENODEV;
-	}
-	for (m = (int)phys_to_virt(lastFoundAt) + 0x2000; m <= (int)phys_to_virt(0xDE000); m += 0x2000)
-	{
-		if (arlan_probe_here(dev, m) == 0)
-		{
-			found++;
-			lastFoundAt = (int)virt_to_phys((void*)m);
-			break;
-		}
-		probed++;
-	}
-	if (found == 0 && probed != 0)
-	{
-		if (lastFoundAt == 0xbe000)
-			printk(KERN_ERR "arlan: No Arlan devices found \n");
-		return -ENODEV;
-	}
-	else
-		return 0;
-
-	ARLAN_DEBUG_EXIT("arlan_probe_everywhere");
-
-	return -ENODEV;
 }
 
-
 static int arlan_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct arlan_private *priv = dev->priv;
@@ -1085,47 +1038,14 @@
 
 
 
-
-static int __init
-	      arlan_allocate_device(int num, struct net_device *devs)
+static void __init arlan_setup_device(struct net_device *dev, int num)
 {
+	struct arlan_private *ap = dev->priv;
 
-	struct net_device *dev;
-	struct arlan_private *ap;
+	ARLAN_DEBUG_ENTRY("arlan_setup_device");
 
-	ARLAN_DEBUG_ENTRY("arlan_allocate_device");
+	ap->conf = (struct arlan_shmem *)(ap+1);
 
-	if (!devs) {
-		dev = init_etherdev(0, sizeof(struct arlan_private) + sizeof(struct arlan_shmem));
-		if (!dev) {
-			printk(KERN_ERR "ARLAN: init_etherdev failed\n");
-			return 0;
-		}
-		ap = dev->priv;
-		ap->conf = dev->priv + sizeof(struct arlan_private);
-		ap->init_etherdev_alloc = 1;
-	} else {
-		dev = devs;
-		dev->priv = kmalloc(sizeof(struct arlan_private) + sizeof(struct arlan_shmem), GFP_KERNEL);
-		if (!dev->priv) {
-			printk(KERN_ERR "ARLAN: kmalloc of dev->priv failed\n");
-			return 0;
-		}
-		ap = dev->priv;
-		ap->conf = dev->priv + sizeof(struct arlan_private);
-		memset(ap, 0, sizeof(*ap));
-	}
-
-	/* Fill in the 'dev' fields. */
-	dev->base_addr = 0;
-	dev->mem_start = 0;
-	dev->mem_end = 0;
-	dev->mtu = 1500;
-	dev->flags = 0;		/* IFF_BROADCAST & IFF_MULTICAST & IFF_PROMISC; */
-	dev->irq = 0;
-	dev->dma = 0;
-	dev->tx_queue_len = tx_queue_len;
-	ether_setup(dev);
 	dev->tx_queue_len = tx_queue_len;
 	dev->open = arlan_open;
 	dev->stop = arlan_close;
@@ -1145,34 +1065,29 @@
 	ap->Conf->rx_tweak1 = 30;
 	ap->Conf->rx_tweak2 = 0;
 
-	ARLAN_DEBUG_EXIT("arlan_allocate_device");
-	return (int) dev;
+	ARLAN_DEBUG_EXIT("arlan_setup_device");
 }
 
-
-static int __init arlan_probe_here(struct net_device *dev, int memaddr)
+static int __init arlan_probe_here(struct net_device *dev, 
+				   unsigned long memaddr)
 {
-	volatile struct arlan_shmem *arlan;
+	struct arlan_private *ap = dev->priv;
 
 	ARLAN_DEBUG_ENTRY("arlan_probe_here");
 
 	if (arlan_check_fingerprint(memaddr))
 		return -ENODEV;
 
-	printk(KERN_NOTICE "%s: Arlan found at %x, \n ", dev->name, (int) virt_to_phys((void*)memaddr));
-
-	if (!arlan_allocate_device(arlans_found, dev))
-		return -1;
-
-	((struct arlan_private *) dev->priv)->card = (struct arlan_shmem *) memaddr;
-	arlan = (void *) memaddr;
+	printk(KERN_NOTICE "%s: Arlan found at %x, \n ", dev->name, 
+	       (int) virt_to_phys((void*)memaddr));
 
+	ap->card = (void *) memaddr;
 	dev->mem_start = memaddr;
-	dev->mem_end = memaddr + 0x1FFF;
+	dev->mem_end = memaddr + ARLAN_SHMEM_SIZE-1;
 
 	if (dev->irq < 2)
 	{
-		READSHM(dev->irq, arlan->irqLevel, u_char);
+		READSHM(dev->irq, ap->card->irqLevel, u_char);
 	} else if (dev->irq == 2)
 		dev->irq = 9;
 
@@ -1183,8 +1098,6 @@
 }
 
 
-
-
 static int arlan_open(struct net_device *dev)
 {
 	struct arlan_private *priv = dev->priv;
@@ -1193,12 +1106,6 @@
 
 	ARLAN_DEBUG_ENTRY("arlan_open");
 
-	if (dev->mem_start == 0)
-		ret = arlan_probe_everywhere(dev);
-	if (ret != 0)
-		return ret;
-
-	arlan = priv->card;
 	ret = request_irq(dev->irq, &arlan_interrupt, 0, dev->name, dev);
 	if (ret)
 	{
@@ -1768,14 +1675,9 @@
 {
 	struct arlan_private *priv = dev->priv;
 
-	if (!priv)
-	{
-		printk(KERN_CRIT "arlan: No Device priv \n");
-		return 0;
-	}
 	ARLAN_DEBUG_ENTRY("arlan_close");
 
-	del_timer(&priv->timer);
+	del_timer_sync(&priv->timer);
 
 	arlan_command(dev, ARLAN_COMMAND_POWERDOWN);
 
@@ -1867,39 +1769,68 @@
 }
 
 
-int __init arlan_probe(struct net_device *dev)
+struct net_device * __init arlan_probe(int unit)
 {
-	printk("Arlan driver %s\n", arlan_version);
+	struct net_device *dev;
+	int m;
 
-	if (arlan_probe_everywhere(dev))
-		return -ENODEV;
+	ARLAN_DEBUG_ENTRY("arlan_probe");
 
-	arlans_found++;
-	return 0;
-}
+	if (arlans_found == MAX_ARLANS)
+		return ERR_PTR(-ENODEV);
 
-#ifdef  MODULE
+	/* 
+	 * Reserve space for local data and a copy of the shared memory
+	 * that is used by the /proc interface.
+	 */
+	dev = alloc_etherdev(sizeof(struct arlan_private)
+			     + sizeof(struct arlan_shmem));
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
 
-static int probe = probeUNKNOWN;
+	SET_MODULE_OWNER(dev);
 
-static int __init arlan_find_devices(void)
-{
-	int m;
-	int found = 0;
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+		
+		if (dev->mem_start) {
+			if (arlan_probe_here(dev, dev->mem_start) == 0)
+				goto found;
+			goto not_found;
+		}
+			
+	}
 
-	ARLAN_DEBUG_ENTRY("arlan_find_devices");
-	if (mem != 0 && numDevices == 1)	/* Check a single specified location. */
-		return 1;
-	for (m =(int) phys_to_virt(0xc0000); m <=(int) phys_to_virt(0xDE000); m += 0x2000)
+
+	for (m = (int)phys_to_virt(lastFoundAt) + ARLAN_SHMEM_SIZE; 
+	     m <= (int)phys_to_virt(0xDE000); 
+	     m += ARLAN_SHMEM_SIZE)
 	{
-		if (arlan_check_fingerprint(m) == 0)
-			found++;
+		if (arlan_probe_here(dev, m) == 0)
+		{
+			lastFoundAt = (int)virt_to_phys((void*)m);
+			goto found;
+		}
+	}
+
+	if (lastFoundAt == 0xbe000)
+		printk(KERN_ERR "arlan: No Arlan devices found \n");
+
+ not_found:
+	free_netdev(dev);
+	return ERR_PTR(-ENODEV);
+
+ found:
+	arlan_setup_device(dev, arlans_found++);
+	if (arlans_found == 1) {
+		printk(KERN_INFO "Arlan driver %s\n", arlan_version);
 	}
-	ARLAN_DEBUG_EXIT("arlan_find_devices");
 
-	return found;
+	return dev;
 }
 
+#ifdef  MODULE
 int init_module(void)
 {
 	int i = 0;
@@ -1909,21 +1840,11 @@
 	if (channelSet != channelSetUNKNOWN || channelNumber != channelNumberUNKNOWN || systemId != systemIdUNKNOWN)
 		return -EINVAL;
 
-	numDevices = arlan_find_devices();
-	if (numDevices == 0)
-		return -ENODEV;
+	for (i = 0; i < MAX_ARLANS; i++) {
+		struct net_device *dev = arlan_probe(i);
 
-	for (i = 0; i < numDevices && i < MAX_ARLANS; i++)
-	{
-		if (!arlan_allocate_device(i, NULL))
-			return -ENOMEM;
-
-		if (arlan_device[i] == NULL)
-			return -ENOMEM;
-
-		if (probe)
-			arlan_probe_everywhere(arlan_device[i]);
-//		arlan_command(arlan_device[i], ARLAN_COMMAND_POWERDOWN );
+		if (IS_ERR(dev)) 
+			return PTR_ERR(dev);
 	}
 	init_arlan_proc();
 	printk(KERN_INFO "Arlan driver %s\n", arlan_version);
@@ -1935,7 +1856,7 @@
 void cleanup_module(void)
 {
 	int i = 0;
-	struct arlan_private *ap;
+	struct net_device *dev;
 
 	ARLAN_DEBUG_ENTRY("cleanup_module");
 
@@ -1946,22 +1867,18 @@
 
 	for (i = 0; i < MAX_ARLANS; i++)
 	{
-		if (arlan_device[i])
-		{
-			arlan_command(arlan_device[i], ARLAN_COMMAND_POWERDOWN );
-
-//			release_mem_region(virt_to_phys(arlan_device[i]->mem_start), 0x2000 );
-			unregister_netdev(arlan_device[i]);
-			ap = arlan_device[i]->priv;
-			if (ap->init_etherdev_alloc) {
-				free_netdev(arlan_device[i]);
-				arlan_device[i] = NULL;
-			} else {
-				kfree(ap);
-				ap = NULL;
-			}
+		dev = arlan_device[i];
+		if (dev) {
+			arlan_command(dev, ARLAN_COMMAND_POWERDOWN );
+
+			unregister_netdev(dev);
+			release_mem_region(virt_to_phys((void *) dev->mem_start), 
+					   ARLAN_SHMEM_SIZE);
+			free_netdev(dev);
+			arlan_device[i] = NULL;
 		}
 	}
+
 	ARLAN_DEBUG_EXIT("cleanup_module");
 }
 
diff -Nru a/drivers/net/wireless/arlan.h b/drivers/net/wireless/arlan.h
--- a/drivers/net/wireless/arlan.h	Tue Oct 14 14:35:00 2003
+++ b/drivers/net/wireless/arlan.h	Tue Oct 14 14:35:00 2003
@@ -57,12 +57,8 @@
  
 #define SIDUNKNOWN -1
 #define radioNodeIdUNKNOWN -1
-#define encryptionKeyUNKNOWN '\0';
 #define irqUNKNOWN 0
-#define memUNKNOWN 0
 #define debugUNKNOWN 0
-#define probeUNKNOWN 1
-#define numDevicesUNKNOWN 1
 #define testMemoryUNKNOWN 1
 #define spreadingCodeUNKNOWN 0
 #define channelNumberUNKNOWN 0
@@ -81,6 +77,8 @@
 #else
 	#define ARLAN_DEBUG(a,b) 
 #endif
+
+#define ARLAN_SHMEM_SIZE	0x2000
 
 struct arlan_shmem
 {
