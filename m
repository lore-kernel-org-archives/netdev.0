From: Roger Luethi <rl@hellgate.ch>
Subject: [3/9][PATCH 2.6] Remove lingering PHY special casing
Date: Tue, 15 Jun 2004 19:48:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040615174839.GA11191@k3.hellgate.ch>
References: <20040615174732.GA10241@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040615174732.GA10241@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

All this code is broken (e.g. unconditionally programs all PHYs as if
they were the same model) and/or unused (IntrLinkChange never occurs
with driver as is).

Signed-off-by: Roger Luethi <rl@hellgate.ch>

--- orig/drivers/net/via-rhine.c
+++ mod/drivers/net/via-rhine.c
@@ -373,7 +373,6 @@
 enum rhine_quirks {
 	rqWOL		= 0x0001,	/* Wake-On-LAN support */
 	rqForceReset	= 0x0002,
-	rqDavicomPhy	= 0x0020,
 	rq6patterns	= 0x0040,	/* 6 instead of 4 patterns for WOL */
 	rqStatusWBRace	= 0x0080,	/* Tx Status Writeback Error possible */
 	rqRhineI	= 0x0100,	/* See comment below */
@@ -698,7 +697,7 @@
 
 	io_size = 256;
 	if (pci_rev < VT6102) {
-		quirks = rqRhineI | rqDavicomPhy;
+		quirks = rqRhineI;
 		io_size = 128;
 		name = "VT86C100A Rhine";
 	}
@@ -1113,11 +1112,6 @@
 	writew(rp->chip_cmd, ioaddr + ChipCmd);
 
 	rhine_check_duplex(dev);
-
-	/* The LED outputs of various MII xcvrs should be configured. */
-	/* For NS or Mison phys, turn on bit 1 in register 0x17 */
-	mdio_write(dev, rp->phys[0], 0x17, mdio_read(dev, rp->phys[0], 0x17) |
-		   0x0001);
 }
 
 /* Read and write over the MII Management Data I/O (MDIO) interface. */
@@ -1692,12 +1686,7 @@
 	spin_lock(&rp->lock);
 
 	if (intr_status & (IntrLinkChange)) {
-		if (readb(ioaddr + MIIStatus) & 0x02) {
-			/* Link failed, restart autonegotiation. */
-			if (rp->quirks & rqRhineI)
-				mdio_write(dev, rp->phys[0], MII_BMCR, 0x3300);
-		} else
-			rhine_check_duplex(dev);
+		rhine_check_duplex(dev);
 		if (debug)
 			printk(KERN_ERR "%s: MII status changed: "
 			       "Autonegotiation advertising %4.4x partner "
