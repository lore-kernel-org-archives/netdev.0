From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] tulip, kernel 2.4.26-rc2, 3rd try
Date: Fri, 09 Apr 2004 16:59:15 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40770EA3.6040102@pobox.com>
References: <Pine.LNX.4.43.0404091631060.19041-100000@skyhawk.ecc.engr.uky.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020704050303040808080803"
Cc: tulip-devel@lists.sourceforge.net, netdev@oss.sgi.com,
        Jay Estabrook <Jay.Estabrook@hp.com>, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Timothy I Mattox <tmattox@engr.uky.edu>
In-Reply-To: <Pine.LNX.4.43.0404091631060.19041-100000@skyhawk.ecc.engr.uky.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020704050303040808080803
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Timothy I Mattox wrote:
> Attached is the patch with the netif_carrier_xxx() calls active
> for the ADMtek Comet version of the tulip.
> I tested pulling the cable & reconnecting it on both a laptop as well
> as a desktop machine with a LNE100TX v4.1 and tulip_debug=2.
> All appears to work as expected.

Thanks, patch applied to 2.4 and 2.6.


> If you like, I can submit a seperate patch enabling netif_carrier_xxx()
> in the rest of the tulip driver, but I don't have other flavors of
> tulip cards to test on.  It looks like the calls are all there, just
> that they are commented out.

It's not ready to turn them all on yet, unfortunately.  Tulip driver 
desperately wants ethtool support, too.

Dr. Jamal Salim ported the phy code from a recent version of Donald 
Becker's tulip.c to upstream...  that's what we really want to merge. 
Jay Estabrook updated this while pursuing tulip problems on alpha.  This 
patch needs testing and merging...

	Jeff



--------------020704050303040808080803
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff -Naurp old/drivers/net/tulip/21142.c new/drivers/net/tulip/21142.c
--- old/drivers/net/tulip/21142.c	Wed Dec 17 21:58:28 2003
+++ new/drivers/net/tulip/21142.c	Wed Jan 21 12:45:05 2004
@@ -23,6 +23,114 @@ static u16 t21142_csr13[] = { 0x0001, 0x
 u16 t21142_csr14[] =	    { 0xFFFF, 0x0705, 0x0705, 0x0000, 0x7F3D, };
 static u16 t21142_csr15[] = { 0x0008, 0x0006, 0x000E, 0x0008, 0x0008, };
 
+void
+print_csr12(unsigned int new,unsigned int old) {
+	printk("BIT FIELD     NEW       OLD\n");
+	printk("LPC          %04x      %04x\n", ((new & 0xffff0000) >> 16),
+						 ((old & 0xffff0000) >> 16));
+	printk("LPN             %01x         %01x\n", ((new & 0x8000) >> 15),
+						 ((old & 0x8000) >> 15));
+	printk("ANS             %01x         %01x\n", ((new & 0x7000) >> 12),
+						 ((old & 0x7000) >> 12));
+	printk("TRF             %01x         %01x\n", ((new & 0x800) >> 11),
+						 ((old & 0x800) >> 11));
+	printk("NSN             %01x         %01x\n", ((new & 0x400) >> 10),
+						 ((old & 0x400) >> 10));
+	printk("TRA             %01x         %01x\n", ((new & 0x200) >> 9),
+						 ((old & 0x200) >> 9));
+	printk("ARA             %01x         %01x\n", ((new & 0x100) >> 8),
+						 ((old & 0x100) >> 8));
+	printk("APS             %01x         %01x\n", ((new & 0x8) >> 3),
+						 ((old & 0x8) >> 3));
+	printk("LS10            %01x         %01x\n", ((new & 0x4) >> 2),
+						 ((old & 0x4) >> 2));
+	printk("LS100           %01x         %01x\n", ((new & 0x2) >> 1),
+						 ((old & 0x2) >> 1));
+	printk("MRA             %01x         %01x\n", (new & 0x1),
+						 (old & 0x1));
+
+	
+}
+
+void
+chk_lnk_st( struct net_device *dev) 
+{
+	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	unsigned long flags;
+	long ioaddr = dev->base_addr;
+	int csr12 = inl(ioaddr + CSR12);
+
+
+	spin_lock_irqsave (&tp->lock, flags);
+	
+	if (tp->lnc) {
+lnk_changed:
+		if (tp->scsr12 != csr12) {
+
+//			print_csr12(csr12,tp->scsr12);
+
+			if ((csr12 & 0x6) == (tp->scsr12 & 0x6))
+				goto done;	/* no interest in other bits */
+
+			if (tp->medialock) {
+			       if(!tulip_chk_fixed_media(dev)) 
+					goto link_down;
+			}
+
+			if (!(tp->lnc & MEDIA_CONNECTED)) {
+				if ((tp->lnc & MEDIA_INITIALIZED)) {
+				       if ((!(csr12 & 4) || !(csr12 & 2)) && 
+					((tp->scsr12 & 4) && (tp->scsr12 & 2))){
+						printk("\n %s %s Link up!\n",dev->name,medianame[dev->if_port]);
+						tp->lnc |= MEDIA_CONNECTED;
+						netif_carrier_on(dev);
+				       } 
+				} else { /* first time */
+				       if (!(csr12 & 4) || !(csr12 & 2)) {
+						printk("\n %s %s Link up!\n",dev->name,medianame[dev->if_port]);
+						tp->lnc |= MEDIA_INITIALIZED;
+						tp->lnc |= MEDIA_CONNECTED;
+						netif_carrier_on(dev);
+				       }
+				}
+			} else {
+				if (!(tp->lnc & MEDIA_INITIALIZED)) {
+					printk(" \nBUG on INIT !\n");
+				}
+
+				if ((!(tp->scsr12 & 4) || !(tp->scsr12 & 2)) && 
+				   ((csr12 & 4) && (csr12 & 2))) { 
+link_down:
+					printk(" \n %s Link down!\n",dev->name);
+					tp->lnc &= ~MEDIA_CONNECTED;
+					netif_carrier_off(dev);
+				} else {
+					if (tp->medialock) {
+						if(tulip_chk_fixed_media(dev)) {
+							tp->scsr12 = csr12;
+							goto done;
+						}
+					}
+				       printk(" BUG3: %s lnc %x csr12 %x old csr12 %x\n",dev->name,tp->lnc,csr12,tp->scsr12);
+				}
+			}
+
+			tp->scsr12 = csr12;
+		} 
+
+done:
+		tp->lnc &= ~(MEDIA_CHANGED);
+	} else {
+		/* FIXME: weird behavior: we missed other sides interupt
+		 * needs investigation */
+		if (tulip_debug > 1)
+			printk("\n %s csr12 %x  not lnc!!\n",dev->name,csr12);
+		tp->lnc &= MEDIA_CHANGED;
+		goto lnk_changed;
+	}
+	spin_unlock_irqrestore (&tp->lock, flags);
+
+}
 
 /* Handle the 21143 uniquely: do autoselect with NWay, not the EEPROM list
    of available transceivers.  */
@@ -35,9 +143,7 @@ void t21142_timer(unsigned long data)
 	int next_tick = 60*HZ;
 	int new_csr6 = 0;
 
-	if (tulip_debug > 2)
-		printk(KERN_INFO"%s: 21143 negotiation status %8.8x, %s.\n",
-			   dev->name, csr12, medianame[dev->if_port]);
+
 	if (tulip_media_cap[dev->if_port] & MediaIsMII) {
 		if (tulip_check_duplex(dev) < 0) {
 			netif_carrier_off(dev);
@@ -52,7 +158,12 @@ void t21142_timer(unsigned long data)
 			printk(KERN_INFO"%s: Using NWay-set %s media, csr12 %8.8x.\n",
 				   dev->name, medianame[dev->if_port], csr12);
 	} else if (tp->medialock) {
-			;
+
+		if (tp->lnc&MEDIA_CONNECTED && !tulip_chk_fixed_media(dev)) {
+			printk("timer: %s recovering fixed media new csr12 %x old %x\n",dev->name,csr12,tp->scsr12);
+			tulip_select_fixed_media(dev);
+		}
+
 	} else if (dev->if_port == 3) {
 		if (csr12 & 2) {	/* No 100mbps link beat, revert to 10mbps. */
 			if (tulip_debug > 1)
@@ -85,15 +196,18 @@ void t21142_timer(unsigned long data)
 		if (tulip_debug > 1)
 			printk(KERN_INFO"%s: Testing new 21143 media %s.\n",
 				   dev->name, medianame[dev->if_port]);
-		if (new_csr6 != (tp->csr6 & ~0x00D5)) {
-			tp->csr6 &= 0x00D5;
+		if (new_csr6 != (tp->csr6 & ~0x20D7)) {
+			tp->csr6 &= 0x20D7;
 			tp->csr6 |= new_csr6;
 			outl(0x0301, ioaddr + CSR12);
-			tulip_restart_rxtx(tp);
+			outl(tp->csr6 | RxOn, ioaddr + CSR6);
+			outl(tp->csr6 | TxOn | RxOn, ioaddr + CSR6);
 		}
 		next_tick = 3*HZ;
 	}
 
+	chk_lnk_st(dev);
+
 	/* mod_timer synchronizes us with potential add_timer calls
 	 * from interrupts.
 	 */
@@ -108,6 +222,9 @@ void t21142_start_nway(struct net_device
 	int csr14 = ((tp->sym_advertise & 0x0780) << 9)  |
 		((tp->sym_advertise & 0x0020) << 1) | 0xffbf;
 
+	if(tp->medialock)
+		return;
+
 	dev->if_port = 0;
 	tp->nway = tp->mediasense = 1;
 	tp->nwayset = tp->lpar = 0;
@@ -115,9 +232,9 @@ void t21142_start_nway(struct net_device
 		printk(KERN_DEBUG "%s: Restarting 21143 autonegotiation, csr14=%8.8x.\n",
 			   dev->name, csr14);
 	outl(0x0001, ioaddr + CSR13);
-	udelay(100);
 	outl(csr14, ioaddr + CSR14);
-	tp->csr6 = 0x82420000 | (tp->sym_advertise & 0x0040 ? FullDuplex : 0);
+	tp->csr6 = 0x82420000 | (tp->sym_advertise & 0x0040 ? FullDuplex : 0) 
+		| (tp->csr6 & 0x20ff);
 	outl(tp->csr6, ioaddr + CSR6);
 	if (tp->mtable  &&  tp->mtable->csr15dir) {
 		outl(tp->mtable->csr15dir, ioaddr + CSR15);
@@ -128,7 +245,6 @@ void t21142_start_nway(struct net_device
 }
 
 
-
 void t21142_lnk_change(struct net_device *dev, int csr5)
 {
 	struct tulip_private *tp = (struct tulip_private *)dev->priv;
@@ -136,8 +252,10 @@ void t21142_lnk_change(struct net_device
 	int csr12 = inl(ioaddr + CSR12);
 
 	if (tulip_debug > 1)
-		printk(KERN_INFO"%s: 21143 link status interrupt %8.8x, CSR5 %x, "
-			   "%8.8x.\n", dev->name, csr12, csr5, inl(ioaddr + CSR14));
+		printk(KERN_INFO"%s: IN 21143 link status interrupt %8.8x, media %d, CSR5 %x, "
+			   "%8.8x.\n", dev->name, csr12, dev->if_port, csr5, inl(ioaddr + CSR14));
+
+	tp->lnc |= MEDIA_CHANGED;
 
 	/* If NWay finished and we have a negotiated partner capability. */
 	if (tp->nway  &&  !tp->nwayset  &&  (csr12 & 0x7000) == 0x5000) {
@@ -172,9 +290,9 @@ void t21142_lnk_change(struct net_device
 			int i;
 			for (i = 0; i < tp->mtable->leafcount; i++)
 				if (tp->mtable->mleaf[i].media == dev->if_port) {
-					int startup = ! ((tp->chip_id == DC21143 && tp->revision == 65));
+					//int startup = ! ((tp->chip_id == DC21143 && tp->revision == 65));
 					tp->cur_index = i;
-					tulip_select_media(dev, startup);
+					tulip_select_media(dev, 0);
 					setup_done = 1;
 					break;
 				}
@@ -215,7 +333,7 @@ void t21142_lnk_change(struct net_device
 			t21142_start_nway(dev);
 			tp->timer.expires = RUN_AT(3*HZ);
 			add_timer(&tp->timer);
-		} else if (dev->if_port == 5)
+		} else if (!tp->medialock && dev->if_port == 5)
 			outl(inl(ioaddr + CSR14) & ~0x080, ioaddr + CSR14);
 	} else if (dev->if_port == 0  ||  dev->if_port == 4) {
 		if ((csr12 & 4) == 0)
@@ -225,7 +343,8 @@ void t21142_lnk_change(struct net_device
 		if (tulip_debug)
 			printk(KERN_INFO"%s: 21143 10mbps sensed media.\n",
 				   dev->name);
-		dev->if_port = 0;
+		if (!tp->medialock)
+			dev->if_port = 0;
 	} else if (tp->nwayset) {
 		if (tulip_debug)
 			printk(KERN_INFO"%s: 21143 using NWay-set %s, csr6 %8.8x.\n",
@@ -234,12 +353,18 @@ void t21142_lnk_change(struct net_device
 		if (tulip_debug)
 			printk(KERN_INFO"%s: 21143 100baseTx sensed media.\n",
 				   dev->name);
-		dev->if_port = 3;
-		tp->csr6 = 0x838E0000 | (tp->csr6 & 0x20ff);
-		outl(0x0003FF7F, ioaddr + CSR14);
-		outl(0x0301, ioaddr + CSR12);
-		tulip_restart_rxtx(tp);
+		if (!tp->medialock) {
+			dev->if_port = 3;
+			tp->csr6 = 0x838E0000 | (tp->csr6 & 0x20ff);
+			outl(0x0003FF7F, ioaddr + CSR14);
+			outl(0x0301, ioaddr + CSR12);
+			outl(tp->csr6 | RxOn, ioaddr + CSR6);
+			outl(tp->csr6 | RxOn | TxOn, ioaddr + CSR6);
+			//tulip_restart_rxtx(tp);
+		}
 	}
-}
 
+	chk_lnk_st( dev);
+
+}
 
diff -Naurp old/drivers/net/tulip/media.c new/drivers/net/tulip/media.c
--- old/drivers/net/tulip/media.c	Wed Dec 17 21:58:29 2003
+++ new/drivers/net/tulip/media.c	Wed Jan 21 12:45:05 2004
@@ -71,6 +71,8 @@ int tulip_mdio_read(struct net_device *d
 		outl(0x60020000 + (phy_id<<23) + (location<<18), ioaddr + 0xA0);
 		inl(ioaddr + 0xA0);
 		inl(ioaddr + 0xA0);
+		inl(ioaddr + 0xA0);
+		inl(ioaddr + 0xA0);
 		while (--i > 0) {
 			barrier();
 			if ( ! ((retval = inl(ioaddr + 0xA0)) & 0x80000000))
@@ -166,6 +168,116 @@ void tulip_mdio_write(struct net_device 
 	spin_unlock_irqrestore(&tp->mii_lock, flags);
 }
 
+int tulip_chk_fixed_media(struct net_device *dev)
+{
+	long ioaddr = dev->base_addr;
+	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	u32 csr12 = inl(ioaddr + CSR12);
+	int ret = 0;
+
+	if (!tp->medialock) {
+			printk(KERN_DEBUG "%s: Bad call to check force media %s\n",
+					   dev->name, medianame[dev->if_port]);
+			return 0;
+	}
+
+	switch(dev->if_port) {
+
+		case 4:
+		case 12:
+			if (! (csr12&4))
+				ret = 1;
+			break;
+		case 5:
+			/* Fall Through */
+		case 3:
+			if (! (csr12&2))
+				ret = 1;
+			break;
+		default:
+			printk(KERN_DEBUG " %s: Bad type force media chk %s\n",
+					   dev->name, medianame[dev->if_port]);
+	}
+
+
+	return ret;
+}
+
+void tulip_select_fixed_media(struct net_device *dev)
+{
+	long ioaddr = dev->base_addr;
+	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	u32 csr6=0, csr13=0, csr14=0, csr15=0,csr12=0;
+	int goodm = 0;
+
+	csr6 = tp->csr6 & ~(FullDuplex | csr6_om_int_loop | csr6_ps) ;
+
+	if (!tp->medialock) {
+			printk(KERN_DEBUG "%s: Bad call to force media to %s\n",
+					   dev->name, medianame[dev->if_port]);
+			return;
+	}
+
+	switch(dev->if_port) {
+
+		case 12:
+			goodm = 1;
+			tp->csr6 = csr6;
+			csr14 = 0x7F3F;
+			csr13 = 1;
+			break;
+		case 4:
+			goodm = 1;
+			csr13 = 0x0001;
+			csr14 = 0x7F3D;
+			tp->csr6 = csr6 | FullDuplex;
+			break;
+
+		case 5:
+			goodm = 1;
+			tp->csr6 = csr6 | FullDuplex;
+			/* Fall Through */
+
+		case 3:
+			goodm = 1;
+			csr13 = 0x0000;
+			csr14 = 0x0000;
+			tp->csr6 |= csr6_ps | csr6_hbd;
+			break;
+
+		default:
+			printk(KERN_DEBUG " %s: Bad type force media to %s\n",
+					   dev->name, medianame[dev->if_port]);
+	}
+
+	if (goodm) {
+			printk(KERN_DEBUG " %s: Fixed force media to %s\n",
+					   dev->name, medianame[dev->if_port]);
+			if (tp->sym_advertise) {
+				csr15 = 0x40000|8;
+				tp->csr6 |= (csr6_pcs | csr6_scr);
+			} else {
+				csr15 = 8;
+			}
+			outl(tp->csr6,ioaddr + CSR6);
+			outl(0,ioaddr + CSR13);
+			udelay(1);
+			outl(csr14,ioaddr + CSR14);
+			outl(csr13,ioaddr + CSR13);
+				outl(csr15,ioaddr + CSR15);
+			udelay(5);
+			csr12 = inl(ioaddr+CSR12);
+			if (tulip_debug > 1)
+				printk(" -->fixed media: csr6 %x csr7 %x valid %x csr12 %x\n",inl(ioaddr+CSR6),inl(ioaddr+CSR7),tulip_tbl[tp->chip_id].valid_intrs,csr12);
+			if (tulip_chk_fixed_media(dev)) {
+				tp->lnc |= MEDIA_INITIALIZED;
+				tp->scsr12 = csr12;
+				printk("%s %s Link up!\n",dev->name,medianame[dev->if_port]);
+				netif_carrier_on(dev);
+			}
+	}
+
+}
 
 /* Set up the transceiver control registers for the selected media type. */
 void tulip_select_media(struct net_device *dev, int startup)
@@ -176,11 +288,18 @@ void tulip_select_media(struct net_devic
 	u32 new_csr6;
 	int i;
 
+	if (tp->medialock) {
+			printk(KERN_DEBUG "===> %s: forced media to %s\n",
+					   dev->name, medianame[dev->if_port]);
+			tulip_select_fixed_media(dev);
+			return;
+	}
+
 	if (mtable) {
 		struct medialeaf *mleaf = &mtable->mleaf[tp->cur_index];
 		unsigned char *p = mleaf->leafdata;
 		switch (mleaf->type) {
-		case 0:					/* 21140 non-MII xcvr. */
+		case 0:		/* 21140 non-MII xcvr. */
 			if (tulip_debug > 1)
 				printk(KERN_DEBUG "%s: Using a 21140 non-MII transceiver"
 					   " with control setting %2.2x.\n",
@@ -226,7 +345,7 @@ void tulip_select_media(struct net_devic
 				outl(csr13val, ioaddr + CSR13);
 			} else {
 				csr13val = 1;
-				csr14val = 0;
+				csr14val = 0x0003FFFF;
 				csr15dir = (setup[0]<<16) | 0x0008;
 				csr15val = (setup[1]<<16) | 0x0008;
 				if (dev->if_port <= 4)
@@ -243,7 +362,7 @@ void tulip_select_media(struct net_devic
 				printk(KERN_DEBUG "%s:  Setting CSR15 to %8.8x/%8.8x.\n",
 					   dev->name, csr15dir, csr15val);
 			if (mleaf->type == 4)
-				new_csr6 = 0x82020000 | ((setup[2] & 0x71) << 18);
+				new_csr6 = 0x820A0000 | ((setup[2] & 0x71) << 18);
 			else
 				new_csr6 = 0x82420000;
 			break;
diff -Naurp old/drivers/net/tulip/tulip.h new/drivers/net/tulip/tulip.h
--- old/drivers/net/tulip/tulip.h	Wed Dec 17 21:59:39 2003
+++ new/drivers/net/tulip/tulip.h	Wed Jan 21 13:32:07 2004
@@ -29,7 +29,7 @@
 
 
 /* undefine, or define to various debugging levels (>4 == obscene levels) */
-#define TULIP_DEBUG 1
+#define TULIP_DEBUG 4
 
 /* undefine USE_IO_OPS for MMIO, define for PIO */
 #ifdef CONFIG_TULIP_MMIO
@@ -156,6 +156,7 @@ enum tulip_mode_bits {
 	AcceptAllPhys		= 0x0040,
 	AcceptRunt		= 0x0008,
 	RxOn			= 0x0002,
+	CSR6_OM_INTLB		= 0x00000400, /* Internal loopback mode*/
 	RxTx			= (TxOn | RxOn),
 };
 
@@ -380,9 +381,15 @@ struct tulip_private {
 	unsigned long nir;
 	unsigned long base_addr;
 	int csr12_shadow;
+	unsigned int scsr12;	
+	unsigned int lnc;	
 	int pad0;		/* Used for 8-byte alignment */
 };
 
+#define MEDIA_CONNECTED 0x1
+#define MEDIA_CHANGED 0x2
+#define MEDIA_INITIALIZED 0x4
+
 
 struct eeprom_fixup {
 	char *name;
@@ -399,6 +406,7 @@ void t21142_timer(unsigned long data);
 void t21142_start_nway(struct net_device *dev);
 void t21142_lnk_change(struct net_device *dev, int csr5);
 
+int tulip_chk_fixed_media(struct net_device *dev);
 
 /* PNIC2.c */
 void pnic2_lnk_change(struct net_device *dev, int csr5);
@@ -419,6 +427,7 @@ int tulip_refill_rx(struct net_device *d
 /* media.c */
 int tulip_mdio_read(struct net_device *dev, int phy_id, int location);
 void tulip_mdio_write(struct net_device *dev, int phy_id, int location, int value);
+void tulip_select_fixed_media(struct net_device *dev);
 void tulip_select_media(struct net_device *dev, int startup);
 int tulip_check_duplex(struct net_device *dev);
 void tulip_find_mii (struct net_device *dev, int board_idx);
diff -Naurp old/drivers/net/tulip/tulip_core.c new/drivers/net/tulip/tulip_core.c
--- old/drivers/net/tulip/tulip_core.c	Wed Dec 17 21:58:57 2003
+++ new/drivers/net/tulip/tulip_core.c	Wed Jan 21 12:56:06 2004
@@ -515,86 +515,50 @@ static void tulip_tx_timeout(struct net_
 	unsigned long flags;
 
 	spin_lock_irqsave (&tp->lock, flags);
+	tulip_stop_rxtx(tp);
 
-	if (tulip_media_cap[dev->if_port] & MediaIsMII) {
-		/* Do nothing -- the media monitor should handle this. */
-		if (tulip_debug > 1)
-			printk(KERN_WARNING "%s: Transmit timeout using MII device.\n",
-				   dev->name);
-	} else if (tp->chip_id == DC21140 || tp->chip_id == DC21142
-			   || tp->chip_id == MX98713 || tp->chip_id == COMPEX9881
-			   || tp->chip_id == DM910X) {
-		printk(KERN_WARNING "%s: 21140 transmit timed out, status %8.8x, "
-			   "SIA %8.8x %8.8x %8.8x %8.8x, resetting...\n",
-			   dev->name, inl(ioaddr + CSR5), inl(ioaddr + CSR12),
-			   inl(ioaddr + CSR13), inl(ioaddr + CSR14), inl(ioaddr + CSR15));
-		if ( ! tp->medialock  &&  tp->mtable) {
-			do
-				--tp->cur_index;
-			while (tp->cur_index >= 0
-				   && (tulip_media_cap[tp->mtable->mleaf[tp->cur_index].media]
-					   & MediaIsFD));
-			if (--tp->cur_index < 0) {
-				/* We start again, but should instead look for default. */
-				tp->cur_index = tp->mtable->leafcount - 1;
-			}
-			tulip_select_media(dev, 0);
-			printk(KERN_WARNING "%s: transmit timed out, switching to %s "
-				   "media.\n", dev->name, medianame[dev->if_port]);
-		}
-	} else if (tp->chip_id == PNIC2) {
-		printk(KERN_WARNING "%s: PNIC2 transmit timed out, status %8.8x, "
-		       "CSR6/7 %8.8x / %8.8x CSR12 %8.8x, resetting...\n",
-		       dev->name, (int)inl(ioaddr + CSR5), (int)inl(ioaddr + CSR6),
-		       (int)inl(ioaddr + CSR7), (int)inl(ioaddr + CSR12));
-	} else {
-		printk(KERN_WARNING "%s: Transmit timed out, status %8.8x, CSR12 "
-			   "%8.8x, resetting...\n",
-			   dev->name, inl(ioaddr + CSR5), inl(ioaddr + CSR12));
-		dev->if_port = 0;
-	}
+	printk("\n%s: Possibly a bug in the driver, contact author\n",
+	       dev->name);
+	printk(KERN_WARNING "%s:transmit timed out, \nstatus %8.8x, "
+	       "SIA %8.8x %8.8x %8.8x %8.8x\n",
+	       dev->name, inl(ioaddr + CSR5), inl(ioaddr + CSR12),
+	       inl(ioaddr + CSR13), inl(ioaddr + CSR14),inl(ioaddr + CSR15));
+	printk("%s: CSR6 %8.8x CSR7 %8.8x\n",
+	       dev->name, inl(ioaddr + CSR6), inl(ioaddr + CSR7));
+	if (tp->lnc) {
+		printk("%s: Link status",dev->name);
+
+		if (tp->lnc & MEDIA_CONNECTED)
+			printk(": other side detected");
+		else
+			printk(": No Cable connected");
+
+		if (tp->lnc & MEDIA_INITIALIZED)
+			printk(": INITIALIZED");
+		else
+			printk(": Havent initialized detection");
 
-#if defined(way_too_many_messages)
-	if (tulip_debug > 3) {
-		int i;
-		for (i = 0; i < RX_RING_SIZE; i++) {
-			u8 *buf = (u8 *)(tp->rx_ring[i].buffer1);
-			int j;
-			printk(KERN_DEBUG "%2d: %8.8x %8.8x %8.8x %8.8x  "
-				   "%2.2x %2.2x %2.2x.\n",
-				   i, (unsigned int)tp->rx_ring[i].status,
-				   (unsigned int)tp->rx_ring[i].length,
-				   (unsigned int)tp->rx_ring[i].buffer1,
-				   (unsigned int)tp->rx_ring[i].buffer2,
-				   buf[0], buf[1], buf[2]);
-			for (j = 0; buf[j] != 0xee && j < 1600; j++)
-				if (j < 100) printk(" %2.2x", buf[j]);
-			printk(" j=%d.\n", j);
-		}
-		printk(KERN_DEBUG "  Rx ring %8.8x: ", (int)tp->rx_ring);
-		for (i = 0; i < RX_RING_SIZE; i++)
-			printk(" %8.8x", (unsigned int)tp->rx_ring[i].status);
-		printk("\n" KERN_DEBUG "  Tx ring %8.8x: ", (int)tp->tx_ring);
-		for (i = 0; i < TX_RING_SIZE; i++)
-			printk(" %8.8x", (unsigned int)tp->tx_ring[i].status);
+		if (tp->lnc & MEDIA_CHANGED)
+			printk(": CHANGED");
 		printk("\n");
 	}
-#endif
+  
+	/* we should really free the ring .. */
 
-	/* Stop and restart the chip's Tx processes . */
 #ifdef CONFIG_NET_HW_FLOWCONTROL
-        if (tp->fc_bit && test_bit(tp->fc_bit,&netdev_fc_xoff))
-                printk("BUG tx_timeout restarting rx when fc on\n");
+	if (tp->fc_bit && test_bit(tp->fc_bit,&netdev_fc_xoff))
+		printk("BUG tx_timeout restarting rx when fc on\n");
 #endif
-	tulip_restart_rxtx(tp);
+
+	/* (Re)start the chip's Tx processes. */
+	tulip_start_rxtx(tp);
+
 	/* Trigger an immediate transmit demand. */
 	outl(0, ioaddr + CSR1);
-
 	tp->stats.tx_errors++;
 
 	spin_unlock_irqrestore (&tp->lock, flags);
 	dev->trans_start = jiffies;
-	netif_wake_queue (dev);
 }
 
 

--------------020704050303040808080803--
