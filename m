From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH 7/13] macsonic: fix crash on PowerBook 520
Date: Wed, 4 Nov 2009 00:42:40 +1100 (EST)
Message-ID: <alpine.OSX.2.00.0911031448060.483@silk.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	netdev@vger.kernel.org, linux-m68k@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No-one seems to know where the PowerBook 500 series store their ethernet 
MAC addresses. So, rather than crash, use a MAC address from the SONIC 
CAM. Failing that, generate a random one.

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

---
 drivers/net/macsonic.c |  113 +++++++++++++++++++++++++------------------------
 1 file changed, 58 insertions(+), 55 deletions(-)

Index: linux-2.6.31/drivers/net/macsonic.c
===================================================================
--- linux-2.6.31.orig/drivers/net/macsonic.c	2009-11-03 03:23:42.000000000 +1100
+++ linux-2.6.31/drivers/net/macsonic.c	2009-11-03 03:23:42.000000000 +1100
@@ -222,69 +222,73 @@ static int __devinit macsonic_init(struc
 	return 0;
 }
 
-static int __devinit mac_onboard_sonic_ethernet_addr(struct net_device *dev)
+#define INVALID_MAC(mac) (memcmp(mac, "\x08\x00\x07", 3) && \
+                          memcmp(mac, "\x00\xA0\x40", 3) && \
+                          memcmp(mac, "\x00\x80\x19", 3) && \
+                          memcmp(mac, "\x00\x05\x02", 3))
+
+static void __devinit mac_onboard_sonic_ethernet_addr(struct net_device *dev)
 {
 	struct sonic_local *lp = netdev_priv(dev);
 	const int prom_addr = ONBOARD_SONIC_PROM_BASE;
-	int i;
+	unsigned short val;
 
-	/* On NuBus boards we can sometimes look in the ROM resources.
-	   No such luck for comm-slot/onboard. */
-	for(i = 0; i < 6; i++)
-		dev->dev_addr[i] = SONIC_READ_PROM(i);
+	/*
+	 * On NuBus boards we can sometimes look in the ROM resources.
+	 * No such luck for comm-slot/onboard.
+	 * On the PowerBook 520, the PROM base address is a mystery.
+	 */
+	if (hwreg_present((void *)prom_addr)) {
+		int i;
+
+		for (i = 0; i < 6; i++)
+			dev->dev_addr[i] = SONIC_READ_PROM(i);
+		if (!INVALID_MAC(dev->dev_addr))
+			return;
 
-	/* Most of the time, the address is bit-reversed.  The NetBSD
-	   source has a rather long and detailed historical account of
-	   why this is so. */
-	if (memcmp(dev->dev_addr, "\x08\x00\x07", 3) &&
-	    memcmp(dev->dev_addr, "\x00\xA0\x40", 3) &&
-	    memcmp(dev->dev_addr, "\x00\x80\x19", 3) &&
-	    memcmp(dev->dev_addr, "\x00\x05\x02", 3))
+		/*
+		 * Most of the time, the address is bit-reversed. The NetBSD
+		 * source has a rather long and detailed historical account of
+		 * why this is so.
+		 */
 		bit_reverse_addr(dev->dev_addr);
-	else
-		return 0;
+		if (!INVALID_MAC(dev->dev_addr))
+			return;
 
-	/* If we still have what seems to be a bogus address, we'll
-           look in the CAM.  The top entry should be ours. */
-	/* Danger! This only works if MacOS has already initialized
-           the card... */
-	if (memcmp(dev->dev_addr, "\x08\x00\x07", 3) &&
-	    memcmp(dev->dev_addr, "\x00\xA0\x40", 3) &&
-	    memcmp(dev->dev_addr, "\x00\x80\x19", 3) &&
-	    memcmp(dev->dev_addr, "\x00\x05\x02", 3))
-	{
-		unsigned short val;
+		/*
+		 * If we still have what seems to be a bogus address, we'll
+		 * look in the CAM. The top entry should be ours.
+		 */
+		printk(KERN_WARNING "macsonic: MAC address in PROM seems "
+		                    "to be invalid, trying CAM\n");
+	} else {
+		printk(KERN_WARNING "macsonic: cannot read MAC address from "
+		                    "PROM, trying CAM\n");
+	}
 
-		printk(KERN_INFO "macsonic: PROM seems to be wrong, trying CAM entry 15\n");
+	/* This only works if MacOS has already initialized the card. */
 
-		SONIC_WRITE(SONIC_CMD, SONIC_CR_RST);
-		SONIC_WRITE(SONIC_CEP, 15);
+	SONIC_WRITE(SONIC_CMD, SONIC_CR_RST);
+	SONIC_WRITE(SONIC_CEP, 15);
 
-		val = SONIC_READ(SONIC_CAP2);
-		dev->dev_addr[5] = val >> 8;
-		dev->dev_addr[4] = val & 0xff;
-		val = SONIC_READ(SONIC_CAP1);
-		dev->dev_addr[3] = val >> 8;
-		dev->dev_addr[2] = val & 0xff;
-		val = SONIC_READ(SONIC_CAP0);
-		dev->dev_addr[1] = val >> 8;
-		dev->dev_addr[0] = val & 0xff;
-
-		printk(KERN_INFO "HW Address from CAM 15: %pM\n",
-		       dev->dev_addr);
-	} else return 0;
-
-	if (memcmp(dev->dev_addr, "\x08\x00\x07", 3) &&
-	    memcmp(dev->dev_addr, "\x00\xA0\x40", 3) &&
-	    memcmp(dev->dev_addr, "\x00\x80\x19", 3) &&
-	    memcmp(dev->dev_addr, "\x00\x05\x02", 3))
-	{
-		/*
-		 * Still nonsense ... messed up someplace!
-		 */
-		printk(KERN_ERR "macsonic: ERROR (INVALID MAC)\n");
-		return -EIO;
-	} else return 0;
+	val = SONIC_READ(SONIC_CAP2);
+	dev->dev_addr[5] = val >> 8;
+	dev->dev_addr[4] = val & 0xff;
+	val = SONIC_READ(SONIC_CAP1);
+	dev->dev_addr[3] = val >> 8;
+	dev->dev_addr[2] = val & 0xff;
+	val = SONIC_READ(SONIC_CAP0);
+	dev->dev_addr[1] = val >> 8;
+	dev->dev_addr[0] = val & 0xff;
+
+	if (!INVALID_MAC(dev->dev_addr))
+		return;
+
+	/* Still nonsense ... messed up someplace! */
+
+	printk(KERN_WARNING "macsonic: MAC address in CAM entry 15 "
+	                    "seems invalid, will use a random MAC\n");
+	random_ether_addr(dev->dev_addr);
 }
 
 static int __devinit mac_onboard_sonic_probe(struct net_device *dev)
@@ -401,8 +405,7 @@ static int __devinit mac_onboard_sonic_p
 	SONIC_WRITE(SONIC_ISR, 0x7fff);
 
 	/* Now look for the MAC address. */
-	if (mac_onboard_sonic_ethernet_addr(dev) != 0)
-		return -ENODEV;
+	mac_onboard_sonic_ethernet_addr(dev);
 
 	/* Shared init code */
 	return macsonic_init(dev);
