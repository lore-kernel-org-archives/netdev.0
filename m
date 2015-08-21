From: Ondrej Zary <linux@rainbow-software.org>
Subject: ipg and dl2k mess
Date: Fri, 21 Aug 2015 22:23:58 +0200
Message-ID: <201508212224.00090.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Kernel development list <linux-kernel@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Sorbica Shieh <sorbica@icplus.com.tw>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
I've got an Asus NX1101 card with ICPlus IP1000A chip:
02:01.0 Ethernet controller [0200]: Sundance Technology Inc / IC Plus Corp IP1000 Family Gigabit Ethernet [13f0:1023] (rev 41)
        Subsystem: ASUSTeK Computer Inc. NX1101 [1043:8180]
        Flags: bus master, 66MHz, medium devsel, latency 32, IRQ 19
        I/O ports at a000 [size=256]
        Memory at f5000000 (32-bit, non-prefetchable) [size=256]
        [virtual] Expansion ROM at 30000000 [disabled] [size=64K]
        Capabilities: [50] Power Management version 2

It does not work properly because the ipg driver is broken - it loses packets
(easily reproduced by ping -f) and stops working under load with no messages
(copying a 200MB file using scp at 100mbit is enough to reproduce it).

The dl2k (for TC902x chips, DL2000 is probably a rebranded TC902x) driver is
very similar to ipg (for IP1000A). According to datasheets, IP1000A chip looks
like a TC9021 with integrated PHY.

The patch below is enough to make my IP1000A card work with dl2k driver - no
more lost packets and hangs. Haven't tested gigabit speed yet - the PHY will
probably need some tweaking but that should be easy.

So maybe we should add IP1000A support to dl2k and remove the broken ipg
driver. Does anyone have HW to test?

diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index cf0a5fc..d5a60fe 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -433,9 +455,9 @@ rio_open (struct net_device *dev)
 
 	alloc_list (dev);
 
-	/* Get station address */
-	for (i = 0; i < 6; i++)
-		dw8(StationAddr0 + i, dev->dev_addr[i]);
+	/* Set station address */
+	for (i = 0; i < 3; i++)
+		dw16(StationAddr0 + 2 * i, cpu_to_le16(((u16 *)dev->dev_addr)[i]));
 
 	set_multicast (dev);
 	if (np->coalesce) {
diff --git a/drivers/net/ethernet/dlink/dl2k.h b/drivers/net/ethernet/dlink/dl2k.h
index 23c07b0..da35e66 100644
--- a/drivers/net/ethernet/dlink/dl2k.h
+++ b/drivers/net/ethernet/dlink/dl2k.h
@@ -411,6 +411,7 @@ struct netdev_private {
 static const struct pci_device_id rio_pci_tbl[] = {
 	{0x1186, 0x4000, PCI_ANY_ID, PCI_ANY_ID, },
 	{0x13f0, 0x1021, PCI_ANY_ID, PCI_ANY_ID, },
+	{0x13f0, 0x1023, PCI_ANY_ID, PCI_ANY_ID, },
 	{ }
 };
 MODULE_DEVICE_TABLE (pci, rio_pci_tbl);


-- 
Ondrej Zary
