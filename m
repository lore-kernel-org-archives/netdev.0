From: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>
Subject: [PATCH 2.6.10 1/5] eepro: cache EEPROM values
Date: Fri, 7 Jan 2005 09:54:19 -0200
Message-ID: <20050107115419.GX27328@cathedrallabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

eepro: cache EEPROM values

Signed-off-by: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>

--- 2.6-inc/drivers/net/eepro.c	2004-09-13 15:54:43.000000000 -0300
+++ 2.6-foo/drivers/net/eepro.c	2004-09-14 13:46:15.000000000 -0300
@@ -214,6 +214,7 @@ struct eepro_local {
 	short rcv_lower_limit;
 	short rcv_upper_limit;
 	unsigned char eeprom_reg;
+	unsigned short word[8];
 };
 
 /* The station (ethernet) address prefix, used for IDing the board. */
@@ -608,16 +609,22 @@ out:
 }
 #endif
 
-static void __init printEEPROMInfo(short ioaddr, struct net_device *dev)
+static void __init printEEPROMInfo(struct net_device *dev)
 {
+	struct eepro_local *lp = (struct eepro_local *)dev->priv;
+	int ioaddr = dev->base_addr;
 	unsigned short Word;
 	int i,j;
 
-	for (i=0, j=ee_Checksum; i<ee_SIZE; i++)
-		j+=read_eeprom(ioaddr,i,dev);
+	j = ee_Checksum;
+	for (i = 0; i < 8; i++)
+		j += lp->word[i];
+	for ( ; i < ee_SIZE; i++)
+		j += read_eeprom(ioaddr, i, dev);
+
 	printk(KERN_DEBUG "Checksum: %#x\n",j&0xffff);
 
-	Word=read_eeprom(ioaddr, 0, dev);
+	Word = lp->word[0];
 	printk(KERN_DEBUG "Word0:\n");
 	printk(KERN_DEBUG " Plug 'n Pray: %d\n",GetBit(Word,ee_PnP));
 	printk(KERN_DEBUG " Buswidth: %d\n",(GetBit(Word,ee_BusWidth)+1)*8 );
@@ -625,7 +632,7 @@ static void __init printEEPROMInfo(short
 	printk(KERN_DEBUG " IO Address: %#x\n", (Word>>ee_IO0)<<4);
 
 	if (net_debug>4)  {
-		Word=read_eeprom(ioaddr, 1, dev);
+		Word = lp->word[1];
 		printk(KERN_DEBUG "Word1:\n");
 		printk(KERN_DEBUG " INT: %d\n", Word & ee_IntMask);
 		printk(KERN_DEBUG " LI: %d\n", GetBit(Word,ee_LI));
@@ -636,7 +643,7 @@ static void __init printEEPROMInfo(short
 		printk(KERN_DEBUG " Duplex: %d\n", GetBit(Word,ee_Duplex));
 	}
 
-	Word=read_eeprom(ioaddr, 5, dev);
+	Word = lp->word[5];
 	printk(KERN_DEBUG "Word5:\n");
 	printk(KERN_DEBUG " BNC: %d\n",GetBit(Word,ee_BNC_TPE));
 	printk(KERN_DEBUG " NumConnectors: %d\n",GetBit(Word,ee_NumConn));
@@ -646,12 +653,12 @@ static void __init printEEPROMInfo(short
 	if (GetBit(Word,ee_PortAUI)) printk(KERN_DEBUG "AUI ");
 	printk(KERN_DEBUG "port(s) \n");
 
-	Word=read_eeprom(ioaddr, 6, dev);
+	Word = lp->word[6];
 	printk(KERN_DEBUG "Word6:\n");
 	printk(KERN_DEBUG " Stepping: %d\n",Word & ee_StepMask);
 	printk(KERN_DEBUG " BoardID: %d\n",Word>>ee_BoardID);
 
-	Word=read_eeprom(ioaddr, 7, dev);
+	Word = lp->word[7];
 	printk(KERN_DEBUG "Word7:\n");
 	printk(KERN_DEBUG " INT to IRQ:\n");
 
@@ -725,7 +732,7 @@ static void __init eepro_print_info (str
 		printk(", %s.\n", ifmap[dev->if_port]);
 
 	if (net_debug > 3) {
-		i = read_eeprom(dev->base_addr, 5, dev);
+		i = lp->word[5];
 		if (i & 0x2000) /* bit 13 of EEPROM word 5 */
 			printk(KERN_DEBUG "%s: Concurrent Processing is "
 				"enabled but not used!\n", dev->name);
@@ -733,7 +740,7 @@ static void __init eepro_print_info (str
 
 	/* Check the station address for the manufacturer's code */
 	if (net_debug>3)
-		printEEPROMInfo(dev->base_addr, dev);
+		printEEPROMInfo(dev);
 }
 
 /* This is the real probe routine.  Linux has a history of friendly device
@@ -796,11 +803,16 @@ static int __init eepro_probe1(struct ne
 		lp->xmt_bar = XMT_BAR_10;
 		station_addr[0] = read_eeprom(ioaddr, 2, dev);
 	}
-	station_addr[1] = read_eeprom(ioaddr, 3, dev);
-	station_addr[2] = read_eeprom(ioaddr, 4, dev);
+
+	/* get all words at once. will be used here and for ethtool */
+	for (i = 0; i < 8; i++) {
+		lp->word[i] = read_eeprom(ioaddr, i, dev);
+	}
+	station_addr[1] = lp->word[3];
+	station_addr[2] = lp->word[4];
 
 	if (!lp->eepro) {
-		if (read_eeprom(ioaddr,7,dev)== ee_FX_INT2IRQ)
+		if (lp->word[7] == ee_FX_INT2IRQ)
 			lp->eepro = 2;
 		else if (station_addr[2] == SA_ADDR1)
 			lp->eepro = 1;
@@ -817,15 +829,15 @@ static int __init eepro_probe1(struct ne
 	/* calculate {xmt,rcv}_{lower,upper}_limit */
 	eepro_recalc(dev);
 
-	if (GetBit( read_eeprom(ioaddr, 5, dev),ee_BNC_TPE))
+	if (GetBit(lp->word[5], ee_BNC_TPE))
 		dev->if_port = BNC;
 	else
 		dev->if_port = TPE;
 
  	if (dev->irq < 2 && lp->eepro != 0) {
  		/* Mask off INT number */
- 		int count = read_eeprom(ioaddr, 1, dev) & 7;
- 		unsigned irqMask = read_eeprom(ioaddr, 7, dev);
+ 		int count = lp->word[1] & 7;
+ 		unsigned irqMask = lp->word[7];
  
  		while (count--)
  			irqMask &= irqMask - 1;
@@ -941,7 +953,7 @@ static int eepro_open(struct net_device 
 	if (net_debug > 3)
 		printk(KERN_DEBUG "%s: entering eepro_open routine.\n", dev->name);
 
-	irqMask = read_eeprom(ioaddr,7,dev);
+	irqMask = lp->word[7];
 
 	if (lp->eepro == LAN595FX_10ISA) {
 		if (net_debug > 3) printk(KERN_DEBUG "p->eepro = 3;\n");
