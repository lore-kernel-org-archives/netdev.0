From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/42) ewrk3
Date: Wed, 12 Nov 2003 16:40:28 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130040.hAD0eSK29895@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert ewrk3 to dynamic allocation
	* get rid of private device allocation method
	* fix deeply nested function

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 10:22:14 2003
+++ b/drivers/net/Space.c	Tue Nov 11 10:22:14 2003
@@ -56,7 +56,7 @@
 extern int fmv18x_probe(struct net_device *);
 extern int eth16i_probe(struct net_device *);
 extern struct net_device *i82596_probe(int unit);
-extern int ewrk3_probe(struct net_device *);
+extern struct net_device *ewrk3_probe(int unit);
 extern struct net_device *el1_probe(int unit);
 extern struct net_device *wavelan_probe(int unit);
 extern struct net_device *arlan_probe(int unit);
@@ -256,13 +256,13 @@
 #ifdef CONFIG_EEXPRESS_PRO	/* Intel EtherExpress Pro/10 */
 	{eepro_probe, 0},
 #endif
-#ifdef CONFIG_EWRK3             /* DEC EtherWORKS 3 */
-    	{ewrk3_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_EWRK3             /* DEC EtherWORKS 3 */
+    	{ewrk3_probe, 0},
+#endif
 #if defined(CONFIG_APRICOT) || defined(CONFIG_MVME16x_NET) || defined(CONFIG_BVME6000_NET)	/* Intel I82596 */
 	{i82596_probe, 0},
 #endif
diff -Nru a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
--- a/drivers/net/ewrk3.c	Tue Nov 11 10:22:14 2003
+++ b/drivers/net/ewrk3.c	Tue Nov 11 10:22:14 2003
@@ -324,25 +324,14 @@
 static int Write_EEPROM(short data, u_long iobase, u_char eaddr);
 static u_char get_hw_addr(struct net_device *dev, u_char * eeprom_image, char chipType);
 
-static void isa_probe(struct net_device *dev, u_long iobase);
-static void eisa_probe(struct net_device *dev, u_long iobase);
-static struct net_device *alloc_device(struct net_device *dev, u_long iobase);
-static int ewrk3_dev_index(char *s);
-static struct net_device *insert_device(struct net_device *dev, u_long iobase, int (*init) (struct net_device *));
+static int ewrk3_probe1(struct net_device *dev, u_long iobase, int irq);
+static int isa_probe(struct net_device *dev, u_long iobase);
+static int eisa_probe(struct net_device *dev, u_long iobase);
 
-
-#ifdef MODULE
-static int autoprobed = 1, loading_module = 1;
-
-#else
-static u_char irq[] =
-{5, 0, 10, 3, 11, 9, 15, 12};
-static int autoprobed, loading_module;
-
-#endif				/* MODULE */
+static u_char irq[MAX_NUM_EWRK3S+1] = {5, 0, 10, 3, 11, 9, 15, 12};
 
 static char name[EWRK3_STRLEN + 1];
-static int num_ewrk3s, num_eth;
+static int num_ewrks3s;
 
 /*
    ** Miscellaneous defines...
@@ -352,38 +341,50 @@
     mdelay(1);\
 }
 
-int __init ewrk3_probe(struct net_device *dev)
+struct net_device * __init ewrk3_probe(int unit)
 {
-	int tmp = num_ewrk3s, status = -ENODEV;
-	u_long iobase = dev->base_addr;
+	struct net_device *dev = alloc_etherdev(sizeof(struct ewrk3_private));
+	int err;
+
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
 
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+	}
 	SET_MODULE_OWNER(dev);
 
-	if ((iobase == 0) && loading_module) {
-		printk("Autoprobing is not supported when loading a module based driver.\n");
-		status = -EIO;
-	} else {		/* First probe for the Ethernet */
-		/* Address PROM pattern */
-		isa_probe(dev, iobase);
-		eisa_probe(dev, iobase);
-
-		if ((tmp == num_ewrk3s) && (iobase != 0) && loading_module) {
-			printk("%s: ewrk3_probe() cannot find device at 0x%04lx.\n", dev->name,
-			       iobase);
-		}
-		/*
-		   ** Walk the device list to check that at least one device
-		   ** initialised OK
-		 */
-		for (; (dev->priv == NULL) && (dev->next != NULL); dev = dev->next);
+	err = ewrk3_probe1(dev, dev->base_addr, dev->irq);
+	if (err) 
+		goto out;
+	return dev;
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
+	
+}
 
-		if (dev->priv)
-			status = 0;
-		if (iobase == 0)
-			autoprobed = 1;
-	}
+static int __init ewrk3_probe1(struct net_device *dev, u_long iobase, int irq)
+{
+	int err;
 
-	return status;
+	dev->base_addr = iobase;
+	dev->irq = irq;
+
+	/* Address PROM pattern */
+	err = isa_probe(dev, iobase);
+	if (err != 0) 
+		err = eisa_probe(dev, iobase);
+
+	if (err)
+		return err;
+
+	err = register_netdev(dev);
+	if (err)
+		release_region(dev->base_addr, EWRK3_TOTAL_SIZE);
+
+	return err;
 }
 
 static int __init 
@@ -396,8 +397,8 @@
 	u_char eeprom_image[EEPROM_MAX], chksum, eisa_cr = 0;
 
 	/*
-	   ** Stop the EWRK3. Enable the DBR ROM. Disable interrupts and remote boot.
-	   ** This also disables the EISA_ENABLE bit in the EISA Control Register.
+	** Stop the EWRK3. Enable the DBR ROM. Disable interrupts and remote boot.
+	** This also disables the EISA_ENABLE bit in the EISA Control Register.
 	 */
 	if (iobase > 0x400)
 		eisa_cr = inb(EISA_CR);
@@ -409,232 +410,210 @@
 	icr &= 0x70;
 	outb(icr, EWRK3_ICR);	/* Disable all the IRQs */
 
-	if (nicsr == (CSR_TXD | CSR_RXD)) {
+	if (nicsr == (CSR_TXD | CSR_RXD))
+		return -ENXIO;
 
-		/* Check that the EEPROM is alive and well and not living on Pluto... */
-		for (chksum = 0, i = 0; i < EEPROM_MAX; i += 2) {
-			union {
-				short val;
-				char c[2];
-			} tmp;
-
-			tmp.val = (short) Read_EEPROM(iobase, (i >> 1));
-			eeprom_image[i] = tmp.c[0];
-			eeprom_image[i + 1] = tmp.c[1];
-			chksum += eeprom_image[i] + eeprom_image[i + 1];
-		}
-
-		if (chksum != 0) {	/* Bad EEPROM Data! */
-			printk("%s: Device has a bad on-board EEPROM.\n", dev->name);
-			status = -ENXIO;
-		} else {
-			EthwrkSignature(name, eeprom_image);
-			if (*name != '\0') {	/* found a EWRK3 device */
-				dev->base_addr = iobase;
-
-				if (iobase > 0x400) {
-					outb(eisa_cr, EISA_CR);		/* Rewrite the EISA CR */
-				}
-				lemac = eeprom_image[EEPROM_CHIPVER];
-				cmr = inb(EWRK3_CMR);
-
-				if (((lemac == LeMAC) && ((cmr & CMR_NO_EEPROM) != CMR_NO_EEPROM)) ||
-				((lemac == LeMAC2) && !(cmr & CMR_HS))) {
-					printk("%s: %s at %#4lx", dev->name, name, iobase);
-					hard_strapped = 1;
-				} else if ((iobase & 0x0fff) == EWRK3_EISA_IO_PORTS) {
-					/* EISA slot address */
-					printk("%s: %s at %#4lx (EISA slot %ld)",
-					       dev->name, name, iobase, ((iobase >> 12) & 0x0f));
-				} else {	/* ISA port address */
-					printk("%s: %s at %#4lx", dev->name, name, iobase);
-				}
-
-				if (!status) {
-					printk(", h/w address ");
-					if (lemac != LeMAC2)
-						DevicePresent(iobase);	/* need after EWRK3_INIT */
-					status = get_hw_addr(dev, eeprom_image, lemac);
-					for (i = 0; i < ETH_ALEN - 1; i++) {	/* get the ethernet addr. */
-						printk("%2.2x:", dev->dev_addr[i]);
-					}
-					printk("%2.2x,\n", dev->dev_addr[i]);
 
-					if (status) {
-						printk("      which has an EEPROM CRC error.\n");
-						status = -ENXIO;
-					} else {
-						if (lemac == LeMAC2) {	/* Special LeMAC2 CMR things */
-							cmr &= ~(CMR_RA | CMR_WB | CMR_LINK | CMR_POLARITY | CMR_0WS);
-							if (eeprom_image[EEPROM_MISC0] & READ_AHEAD)
-								cmr |= CMR_RA;
-							if (eeprom_image[EEPROM_MISC0] & WRITE_BEHIND)
-								cmr |= CMR_WB;
-							if (eeprom_image[EEPROM_NETMAN0] & NETMAN_POL)
-								cmr |= CMR_POLARITY;
-							if (eeprom_image[EEPROM_NETMAN0] & NETMAN_LINK)
-								cmr |= CMR_LINK;
-							if (eeprom_image[EEPROM_MISC0] & _0WS_ENA)
-								cmr |= CMR_0WS;
-						}
-						if (eeprom_image[EEPROM_SETUP] & SETUP_DRAM)
-							cmr |= CMR_DRAM;
-						outb(cmr, EWRK3_CMR);
-
-						cr = inb(EWRK3_CR);	/* Set up the Control Register */
-						cr |= eeprom_image[EEPROM_SETUP] & SETUP_APD;
-						if (cr & SETUP_APD)
-							cr |= eeprom_image[EEPROM_SETUP] & SETUP_PS;
-						cr |= eeprom_image[EEPROM_MISC0] & FAST_BUS;
-						cr |= eeprom_image[EEPROM_MISC0] & ENA_16;
-						outb(cr, EWRK3_CR);
+	/* Check that the EEPROM is alive and well and not living on Pluto... */
+	for (chksum = 0, i = 0; i < EEPROM_MAX; i += 2) {
+		union {
+			short val;
+			char c[2];
+		} tmp;
+
+		tmp.val = (short) Read_EEPROM(iobase, (i >> 1));
+		eeprom_image[i] = tmp.c[0];
+		eeprom_image[i + 1] = tmp.c[1];
+		chksum += eeprom_image[i] + eeprom_image[i + 1];
+	}
+
+	if (chksum != 0) {	/* Bad EEPROM Data! */
+		printk("%s: Device has a bad on-board EEPROM.\n", dev->name);
+		return -ENXIO;
+	}
+	
+	EthwrkSignature(name, eeprom_image);
+	if (*name == '\0') 
+		return -ENXIO;
+
+	dev->base_addr = iobase;
+				
+	if (iobase > 0x400) {
+		outb(eisa_cr, EISA_CR);		/* Rewrite the EISA CR */
+	}
+	lemac = eeprom_image[EEPROM_CHIPVER];
+	cmr = inb(EWRK3_CMR);
+	
+	if (((lemac == LeMAC) && ((cmr & CMR_NO_EEPROM) != CMR_NO_EEPROM)) ||
+	    ((lemac == LeMAC2) && !(cmr & CMR_HS))) {
+		printk("%s: %s at %#4lx", dev->name, name, iobase);
+		hard_strapped = 1;
+	} else if ((iobase & 0x0fff) == EWRK3_EISA_IO_PORTS) {
+		/* EISA slot address */
+		printk("%s: %s at %#4lx (EISA slot %ld)",
+		       dev->name, name, iobase, ((iobase >> 12) & 0x0f));
+	} else {	/* ISA port address */
+		printk("%s: %s at %#4lx", dev->name, name, iobase);
+	}
+
+	printk(", h/w address ");
+	if (lemac != LeMAC2)
+		DevicePresent(iobase);	/* need after EWRK3_INIT */
+	status = get_hw_addr(dev, eeprom_image, lemac);
+	for (i = 0; i < ETH_ALEN - 1; i++) {	/* get the ethernet addr. */
+		printk("%2.2x:", dev->dev_addr[i]);
+	}
+	printk("%2.2x,\n", dev->dev_addr[i]);
+	
+	if (status) {
+		printk("      which has an EEPROM CRC error.\n");
+		return -ENXIO;
+	}
+
+	if (lemac == LeMAC2) {	/* Special LeMAC2 CMR things */
+		cmr &= ~(CMR_RA | CMR_WB | CMR_LINK | CMR_POLARITY | CMR_0WS);
+		if (eeprom_image[EEPROM_MISC0] & READ_AHEAD)
+			cmr |= CMR_RA;
+		if (eeprom_image[EEPROM_MISC0] & WRITE_BEHIND)
+			cmr |= CMR_WB;
+		if (eeprom_image[EEPROM_NETMAN0] & NETMAN_POL)
+			cmr |= CMR_POLARITY;
+		if (eeprom_image[EEPROM_NETMAN0] & NETMAN_LINK)
+			cmr |= CMR_LINK;
+		if (eeprom_image[EEPROM_MISC0] & _0WS_ENA)
+			cmr |= CMR_0WS;
+	}
+	if (eeprom_image[EEPROM_SETUP] & SETUP_DRAM)
+		cmr |= CMR_DRAM;
+	outb(cmr, EWRK3_CMR);
+	
+	cr = inb(EWRK3_CR);	/* Set up the Control Register */
+	cr |= eeprom_image[EEPROM_SETUP] & SETUP_APD;
+	if (cr & SETUP_APD)
+		cr |= eeprom_image[EEPROM_SETUP] & SETUP_PS;
+	cr |= eeprom_image[EEPROM_MISC0] & FAST_BUS;
+	cr |= eeprom_image[EEPROM_MISC0] & ENA_16;
+	outb(cr, EWRK3_CR);
 
-						/*
-						   ** Determine the base address and window length for the EWRK3
-						   ** RAM from the memory base register.
-						 */
-						mem_start = inb(EWRK3_MBR);
-						shmem_length = 0;
-						if (mem_start != 0) {
-							if ((mem_start >= 0x0a) && (mem_start <= 0x0f)) {
-								mem_start *= SHMEM_64K;
-								shmem_length = SHMEM_64K;
-							} else if ((mem_start >= 0x14) && (mem_start <= 0x1f)) {
-								mem_start *= SHMEM_32K;
-								shmem_length = SHMEM_32K;
-							} else if ((mem_start >= 0x40) && (mem_start <= 0xff)) {
-								mem_start = mem_start * SHMEM_2K + 0x80000;
-								shmem_length = SHMEM_2K;
-							} else {
-								status = -ENXIO;
-							}
-						}
-						/*
-						   ** See the top of this source code for comments about
-						   ** uncommenting this line.
-						 */
+	/*
+	** Determine the base address and window length for the EWRK3
+	** RAM from the memory base register.
+	*/
+	mem_start = inb(EWRK3_MBR);
+	shmem_length = 0;
+	if (mem_start != 0) {
+		if ((mem_start >= 0x0a) && (mem_start <= 0x0f)) {
+			mem_start *= SHMEM_64K;
+			shmem_length = SHMEM_64K;
+		} else if ((mem_start >= 0x14) && (mem_start <= 0x1f)) {
+			mem_start *= SHMEM_32K;
+			shmem_length = SHMEM_32K;
+		} else if ((mem_start >= 0x40) && (mem_start <= 0xff)) {
+			mem_start = mem_start * SHMEM_2K + 0x80000;
+			shmem_length = SHMEM_2K;
+		} else {
+			return -ENXIO;
+		}
+	}
+	/*
+	** See the top of this source code for comments about
+	** uncommenting this line.
+	*/
 /*          FORCE_2K_MODE; */
+	
+	if (hard_strapped) {
+		printk("      is hard strapped.\n");
+	} else if (mem_start) {
+		printk("      has a %dk RAM window", (int) (shmem_length >> 10));
+		printk(" at 0x%.5lx", mem_start);
+	} else {
+		printk("      is in I/O only mode");
+	}
 
-						if (!status) {
-							if (hard_strapped) {
-								printk("      is hard strapped.\n");
-							} else if (mem_start) {
-								printk("      has a %dk RAM window", (int) (shmem_length >> 10));
-								printk(" at 0x%.5lx", mem_start);
-							} else {
-								printk("      is in I/O only mode");
-							}
-
-							/* private area & initialise */
-							dev->priv = (void *) kmalloc(sizeof(struct ewrk3_private),
-							     GFP_KERNEL);
-							if (dev->priv == NULL) {
-								return -ENOMEM;
-							}
-							lp = (struct ewrk3_private *) dev->priv;
-							memset(dev->priv, 0, sizeof(struct ewrk3_private));
-							lp->shmem_base = mem_start;
-							lp->shmem_length = shmem_length;
-							lp->lemac = lemac;
-							lp->hard_strapped = hard_strapped;
-							lp->led_mask = CR_LED;
-							spin_lock_init(&lp->hw_lock);
-
-							lp->mPage = 64;
-							if (cmr & CMR_DRAM)
-								lp->mPage <<= 1;	/* 2 DRAMS on module */
-
-							sprintf(lp->adapter_name, "%s (%s)", name, dev->name);
-							request_region(iobase, EWRK3_TOTAL_SIZE, lp->adapter_name);
-
-							lp->irq_mask = ICR_TNEM | ICR_TXDM | ICR_RNEM | ICR_RXDM;
-
-							if (!hard_strapped) {
-								/*
-								   ** Enable EWRK3 board interrupts for autoprobing
-								 */
-								icr |= ICR_IE;	/* Enable interrupts */
-								outb(icr, EWRK3_ICR);
-
-								/* The DMA channel may be passed in on this parameter. */
-								dev->dma = 0;
-
-								/* To auto-IRQ we enable the initialization-done and DMA err,
-								   interrupts. For now we will always get a DMA error. */
-								if (dev->irq < 2) {
+	lp = (struct ewrk3_private *) dev->priv;
+	lp->shmem_base = mem_start;
+	lp->shmem_length = shmem_length;
+	lp->lemac = lemac;
+	lp->hard_strapped = hard_strapped;
+	lp->led_mask = CR_LED;
+	spin_lock_init(&lp->hw_lock);
+	
+	lp->mPage = 64;
+	if (cmr & CMR_DRAM)
+		lp->mPage <<= 1;	/* 2 DRAMS on module */
+	
+	sprintf(lp->adapter_name, "%s (%s)", name, dev->name);
+	
+	lp->irq_mask = ICR_TNEM | ICR_TXDM | ICR_RNEM | ICR_RXDM;
+	
+	if (!hard_strapped) {
+		/*
+		** Enable EWRK3 board interrupts for autoprobing
+		*/
+		icr |= ICR_IE;	/* Enable interrupts */
+		outb(icr, EWRK3_ICR);
+		
+		/* The DMA channel may be passed in on this parameter. */
+		dev->dma = 0;
+		
+		/* To auto-IRQ we enable the initialization-done and DMA err,
+		   interrupts. For now we will always get a DMA error. */
+		if (dev->irq < 2) {
 #ifndef MODULE
-									u_char irqnum;
-									unsigned long irq_mask;
+			u_char irqnum;
+			unsigned long irq_mask;
 			
 
-									irq_mask = probe_irq_on();
-
-									/*
-									   ** Trigger a TNE interrupt.
-									 */
-									icr |= ICR_TNEM;
-									outb(1, EWRK3_TDQ);	/* Write to the TX done queue */
-									outb(icr, EWRK3_ICR);	/* Unmask the TXD interrupt */
-
-									irqnum = irq[((icr & IRQ_SEL) >> 4)];
-
-									mdelay(20);
-									dev->irq = probe_irq_off(irq_mask);
-									if ((dev->irq) && (irqnum == dev->irq)) {
-										printk(" and uses IRQ%d.\n", dev->irq);
-									} else {
-										if (!dev->irq) {
-											printk(" and failed to detect IRQ line.\n");
-										} else if ((irqnum == 1) && (lemac == LeMAC2)) {
-											printk(" and an illegal IRQ line detected.\n");
-										} else {
-											printk(", but incorrect IRQ line detected.\n");
-										}
-										status = -ENXIO;
-									}
-
-									DISABLE_IRQs;	/* Mask all interrupts */
-
-#endif				/* MODULE */
-								} else {
-									printk(" and requires IRQ%d.\n", dev->irq);
-								}
-							}
-							if (status)
-								release_region(iobase, EWRK3_TOTAL_SIZE);
-						} else {
-							status = -ENXIO;
-						}
-					}
-				}
+			irq_mask = probe_irq_on();
+			
+			/*
+			** Trigger a TNE interrupt.
+			*/
+			icr |= ICR_TNEM;
+			outb(1, EWRK3_TDQ);	/* Write to the TX done queue */
+			outb(icr, EWRK3_ICR);	/* Unmask the TXD interrupt */
+			
+			irqnum = irq[((icr & IRQ_SEL) >> 4)];
+			
+			mdelay(20);
+			dev->irq = probe_irq_off(irq_mask);
+			if ((dev->irq) && (irqnum == dev->irq)) {
+				printk(" and uses IRQ%d.\n", dev->irq);
 			} else {
-				status = -ENXIO;
-			}
-		}
-
-		if (!status) {
-			if (ewrk3_debug > 1) {
-				printk(version);
+				if (!dev->irq) {
+					printk(" and failed to detect IRQ line.\n");
+				} else if ((irqnum == 1) && (lemac == LeMAC2)) {
+					printk(" and an illegal IRQ line detected.\n");
+				} else {
+					printk(", but incorrect IRQ line detected.\n");
+				}
+				return -ENXIO;
 			}
-			/* The EWRK3-specific entries in the device structure. */
-			dev->open = ewrk3_open;
-			dev->hard_start_xmit = ewrk3_queue_pkt;
-			dev->stop = ewrk3_close;
-			dev->get_stats = ewrk3_get_stats;
-			dev->set_multicast_list = set_multicast_list;
-			dev->do_ioctl = ewrk3_ioctl;
-			dev->tx_timeout = ewrk3_timeout;
-			dev->watchdog_timeo = QUEUE_PKT_TIMEOUT;
 
-			dev->mem_start = 0;
+			DISABLE_IRQs;	/* Mask all interrupts */
 
-			/* Fill in the generic field of the device structure. */
-			ether_setup(dev);
+#endif				/* MODULE */
+		} else {
+			printk(" and requires IRQ%d.\n", dev->irq);
 		}
-	} else {
-		status = -ENXIO;
 	}
-	return status;
+
+	if (ewrk3_debug > 1) {
+		printk(version);
+	}
+	/* The EWRK3-specific entries in the device structure. */
+	dev->open = ewrk3_open;
+	dev->hard_start_xmit = ewrk3_queue_pkt;
+	dev->stop = ewrk3_close;
+	dev->get_stats = ewrk3_get_stats;
+	dev->set_multicast_list = set_multicast_list;
+	dev->do_ioctl = ewrk3_ioctl;
+	dev->tx_timeout = ewrk3_timeout;
+	dev->watchdog_timeo = QUEUE_PKT_TIMEOUT;
+	
+	dev->mem_start = 0;
+
+	return 0;
 }
 
 
@@ -1269,15 +1248,15 @@
 /*
    ** ISA bus I/O device probe
  */
-static void __init isa_probe(struct net_device *dev, u_long ioaddr)
+static int __init isa_probe(struct net_device *dev, u_long ioaddr)
 {
-	int i = num_ewrk3s, maxSlots;
+	int i = num_ewrks3s, maxSlots;
+	int ret = -ENODEV;
+
 	u_long iobase;
 
-	if (!ioaddr && autoprobed)
-		return;		/* Been here before ! */
 	if (ioaddr >= 0x400)
-		return;		/* Not ISA */
+		goto out;
 
 	if (ioaddr == 0) {	/* Autoprobing */
 		iobase = EWRK3_IO_BASE;		/* Get the first slot address */
@@ -1287,38 +1266,37 @@
 		maxSlots = i + 1;
 	}
 
-	for (; (i < maxSlots) && (dev != NULL); iobase += EWRK3_IOP_INC, i++) {
-		if (!check_region(iobase, EWRK3_TOTAL_SIZE)) {
+	for (; (i < maxSlots) && (dev != NULL);
+	     iobase += EWRK3_IOP_INC, i++)
+	{
+		if (request_region(iobase, EWRK3_TOTAL_SIZE, dev->name)) {
 			if (DevicePresent(iobase) == 0) {
-				if ((dev = alloc_device(dev, iobase)) != NULL) {
-					if (ewrk3_hw_init(dev, iobase) == 0) {
-						num_ewrk3s++;
-					}
-					num_eth++;
-				}
+				int irq = dev->irq;
+				ret = ewrk3_hw_init(dev, iobase);
+				if (!ret)
+					break;
+				dev->irq = irq;
 			}
-		} else if (autoprobed) {
-			printk("%s: region already allocated at 0x%04lx.\n", dev->name, iobase);
+			release_region(iobase, EWRK3_TOTAL_SIZE);
 		}
 	}
+ out:
 
-	return;
+	return ret;
 }
 
 /*
    ** EISA bus I/O device probe. Probe from slot 1 since slot 0 is usually
    ** the motherboard.
  */
-static void __init eisa_probe(struct net_device *dev, u_long ioaddr)
+static int __init eisa_probe(struct net_device *dev, u_long ioaddr)
 {
 	int i, maxSlots;
 	u_long iobase;
-	char name[EWRK3_STRLEN];
+	int ret = -ENODEV;
 
-	if (!ioaddr && autoprobed)
-		return;		/* Been here before ! */
 	if (ioaddr < 0x1000)
-		return;		/* Not EISA */
+		goto out;
 
 	if (ioaddr == 0) {	/* Autoprobing */
 		iobase = EISA_SLOT_INC;		/* Get the first slot address */
@@ -1332,114 +1310,22 @@
 
 	for (i = 1; (i < maxSlots) && (dev != NULL); i++, iobase += EISA_SLOT_INC) {
 		if (EISA_signature(name, EISA_ID) == 0) {
-			if (!check_region(iobase, EWRK3_TOTAL_SIZE)) {
-				if (DevicePresent(iobase) == 0) {
-					if ((dev = alloc_device(dev, iobase)) != NULL) {
-						if (ewrk3_hw_init(dev, iobase) == 0) {
-							num_ewrk3s++;
-						}
-						num_eth++;
-					}
-				}
-			} else if (autoprobed) {
-				printk("%s: region already allocated at 0x%04lx.\n", dev->name, iobase);
+			if (request_region(iobase, EWRK3_TOTAL_SIZE, dev->name) &&
+			    DevicePresent(iobase) == 0) {
+				int irq = dev->irq;
+				ret = ewrk3_hw_init(dev, iobase);
+				if (!ret)
+					break;
+				dev->irq = irq;
 			}
+			release_region(iobase, EWRK3_TOTAL_SIZE);
 		}
 	}
 
-	return;
+ out:
+	return ret;
 }
 
-/*
-   ** Search the entire 'eth' device list for a fixed probe. If a match isn't
-   ** found then check for an autoprobe or unused device location. If they
-   ** are not available then insert a new device structure at the end of
-   ** the current list.
- */
-static struct net_device * __init  alloc_device(struct net_device *dev, u_long iobase)
-{
-	struct net_device *adev = NULL;
-	int fixed = 0, new_dev = 0;
-
-	num_eth = ewrk3_dev_index(dev->name);
-	if (loading_module)
-		return dev;
-
-	while (1) {
-		if (((dev->base_addr == EWRK3_NDA) || (dev->base_addr == 0)) && !adev) {
-			adev = dev;
-		} else if ((dev->priv == NULL) && (dev->base_addr == iobase)) {
-			fixed = 1;
-		} else {
-			if (dev->next == NULL) {
-				new_dev = 1;
-			} else if (strncmp(dev->next->name, "eth", 3) != 0) {
-				new_dev = 1;
-			}
-		}
-		if ((dev->next == NULL) || new_dev || fixed)
-			break;
-		dev = dev->next;
-		num_eth++;
-	}
-	if (adev && !fixed) {
-		dev = adev;
-		num_eth = ewrk3_dev_index(dev->name);
-		new_dev = 0;
-	}
-	if (((dev->next == NULL) &&
-	     ((dev->base_addr != EWRK3_NDA) && (dev->base_addr != 0)) && !fixed) ||
-	    new_dev) {
-		num_eth++;	/* New device */
-		dev = insert_device(dev, iobase, ewrk3_probe);
-	}
-	return dev;
-}
-
-/*
-   ** If at end of eth device list and can't use current entry, malloc
-   ** one up. If memory could not be allocated, print an error message.
- */
-static struct net_device * __init
-insert_device(struct net_device *dev, u_long iobase, int (*init) (struct net_device *))
-{
-	struct net_device *new;
-
-	new = (struct net_device *) kmalloc(sizeof(struct net_device) + 8, GFP_KERNEL);
-	if (new == NULL) {
-		printk("eth%d: Device not initialised, insufficient memory\n", num_eth);
-		return NULL;
-	} else {
-		new->next = dev->next;
-		dev->next = new;
-		dev = dev->next;	/* point to the new device */
-		if (num_eth > 9999) {
-			sprintf(dev->name, "eth????");	/* New device name */
-		} else {
-			sprintf(dev->name, "eth%d", num_eth);	/* New device name */
-		}
-		dev->base_addr = iobase;	/* assign the io address */
-		dev->init = init;	/* initialisation routine */
-	}
-
-	return dev;
-}
-
-static int __init 
-ewrk3_dev_index(char *s)
-{
-	int i = 0, j = 0;
-
-	for (; *s; s++) {
-		if (isdigit(*s)) {
-			j = 1;
-			i = (i * 10) + (*s - '0');
-		} else if (j)
-			break;
-	}
-
-	return i;
-}
 
 /*
    ** Read the EWRK3 EEPROM using this routine
@@ -2074,8 +1960,7 @@
 #ifdef MODULE
 static struct net_device *ewrk3_devs[MAX_NUM_EWRK3S];
 static int ndevs;
-static int io[MAX_NUM_EWRK3S+1] = { 0x300, 0, };	/* <--- EDIT THESE LINES FOR YOUR CONFIGURATION */
-static int irq[MAX_NUM_EWRK3S+1] = { 5, 0, };		/* or use the insmod io= irq= options           */
+static int io[MAX_NUM_EWRK3S+1] = { 0x300, 0, };
 
 /* '21' below should really be 'MAX_NUM_EWRK3S' */
 MODULE_PARM(io, "0-21i");
@@ -2083,50 +1968,39 @@
 MODULE_PARM_DESC(io, "EtherWORKS 3 I/O base address(es)");
 MODULE_PARM_DESC(irq, "EtherWORKS 3 IRQ number(s)");
 
-static void ewrk3_exit_module(void)
+static __exit void ewrk3_exit_module(void)
 {
 	int i;
 
 	for( i=0; i<ndevs; i++ ) {
 		unregister_netdev(ewrk3_devs[i]);
-		if (ewrk3_devs[i]->priv) {
-			kfree(ewrk3_devs[i]->priv);
-			ewrk3_devs[i]->priv = NULL;
-		}
-		ewrk3_devs[i]->irq = 0;
-
 		release_region(ewrk3_devs[i]->base_addr, EWRK3_TOTAL_SIZE);
 		free_netdev(ewrk3_devs[i]);
 		ewrk3_devs[i] = NULL;
 	}
 }
 
-static int ewrk3_init_module(void)
+static __init int ewrk3_init_module(void)
 {
 	int i=0;
 
 	while( io[i] && irq[i] ) {
-		ewrk3_devs[ndevs] = kmalloc(sizeof(struct net_device), GFP_KERNEL);
-		if (!ewrk3_devs[ndevs])
-			goto error; 
-		memset(ewrk3_devs[ndevs], 0, sizeof(struct net_device));
-		ewrk3_devs[ndevs]->base_addr = io[i];
-		ewrk3_devs[ndevs]->irq = irq[i];
-		ewrk3_devs[ndevs]->init = ewrk3_probe;
-
-		if (register_netdev(ewrk3_devs[ndevs]) == 0)
-			ndevs++;
-		else
-			kfree(ewrk3_devs[ndevs]);
+		struct net_device *dev
+			= alloc_etherdev(sizeof(struct ewrk3_private));
+
+		if (!dev)
+			break;
 
+		if (ewrk3_probe1(dev, io[i], irq[i]) != 0) {
+			free_netdev(dev);
+			break;
+		}
+
+		ewrk3_devs[ndevs++] = dev;
 		i++;
 	}
 
 	return ndevs ? 0 : -EIO;
-
-error:
-	ewrk3_exit_module();
-	return -ENOMEM;
 }
 
 
