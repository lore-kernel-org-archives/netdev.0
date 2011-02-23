From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/2 net-next-2.6] r6040: fix multicast operations
Date: Wed, 23 Feb 2011 15:32:34 +0100
Message-ID: <201102231532.34849.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51767 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719Ab1BWOcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 09:32:31 -0500
Received: by wwb39 with SMTP id 39so1623904wwb.1
        for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 06:32:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Lin <shawn@dmp.com.tw>

The original code does not work well when the number of mulitcast
address to handle is greater than MCAST_MAX. It only enable promiscous
mode instead of multicast hash table mode, so the hash table function
will not be activated and all multicast frames will be recieved in this
condition.

This patch fixes the following issues with the r6040 NIC operating in
multicast:

1) When the IFF_ALLMULTI flag is set, we should write 0xffff to the NIC
hash table registers to make it process multicast traffic.

2) When the number of multicast address to handle is smaller than
MCAST_MAX, we should use the NIC multicast registers MID1_{L,M,H}.

3) The hashing of the address was not correct, due to an invalid
substraction (15 - (crc & 0x0f)) instead of (crc & 0x0f) and an
incorrect crc algorithm (ether_crc_le) instead of (ether_crc).

4) If necessary, we should set HASH_EN flag in MCR0 to enable multicast
hash table function.

CC: stable@kernel.org
Reported-by: Marc Leclerc <marc-leclerc@signaturealpha.com>
Tested-by: Marc Leclerc <marc-leclerc@signaturealpha.com>
Signed-off-by: Shawn Lin <shawn@dmp.com.tw>
Signed-off-by: Albert Chen <albert.chen@rdc.com.tw>
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
Stable: 2.6.33+

diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 27e6f6d..7965ae4 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -69,6 +69,8 @@

 /* MAC registers */
 #define MCR0		0x00	/* Control register 0 */
+#define  MCR0_PROMISC	0x0020	/* Promiscuous mode */
+#define  MCR0_HASH_EN	0x0100	/* Enable multicast hash table function */
 #define MCR1		0x04	/* Control register 1 */
 #define  MAC_RST	0x0001	/* Reset the MAC */
 #define MBCR		0x08	/* Bus control */
@@ -851,77 +853,92 @@ static void r6040_multicast_list(struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
-	u16 *adrp;
-	u16 reg;
 	unsigned long flags;
 	struct netdev_hw_addr *ha;
 	int i;
+	u16 *adrp;
+	u16 hash_table[4] = { 0 };
+
+	spin_lock_irqsave(&lp->lock, flags);

-	/* MAC Address */
+	/* Keep our MAC Address */
 	adrp = (u16 *)dev->dev_addr;
 	iowrite16(adrp[0], ioaddr + MID_0L);
 	iowrite16(adrp[1], ioaddr + MID_0M);
 	iowrite16(adrp[2], ioaddr + MID_0H);

-	/* Promiscous Mode */
-	spin_lock_irqsave(&lp->lock, flags);
-
 	/* Clear AMCP & PROM bits */
-	reg = ioread16(ioaddr) & ~0x0120;
-	if (dev->flags & IFF_PROMISC) {
-		reg |= 0x0020;
-		lp->mcr0 |= 0x0020;
-	}
-	/* Too many multicast addresses
-	 * accept all traffic */
-	else if ((netdev_mc_count(dev) > MCAST_MAX) ||
-		 (dev->flags & IFF_ALLMULTI))
-		reg |= 0x0020;
+	lp->mcr0 = ioread16(ioaddr + MCR0) & ~(MCR0_PROMISC | MCR0_HASH_EN);

-	iowrite16(reg, ioaddr);
-	spin_unlock_irqrestore(&lp->lock, flags);
+	/* Promiscuous mode */
+	if (dev->flags & IFF_PROMISC)
+		lp->mcr0 |= MCR0_PROMISC;

-	/* Build the hash table */
-	if (netdev_mc_count(dev) > MCAST_MAX) {
-		u16 hash_table[4];
-		u32 crc;
+	/* Enable multicast hash table function to
+	 * receive all multicast packets. */
+	else if (dev->flags & IFF_ALLMULTI) {
+		lp->mcr0 |= MCR0_HASH_EN;

-		for (i = 0; i < 4; i++)
-			hash_table[i] = 0;
+		for (i = 0; i < MCAST_MAX ; i++) {
+			iowrite16(0, ioaddr + MID_1L + 8 * i);
+			iowrite16(0, ioaddr + MID_1M + 8 * i);
+			iowrite16(0, ioaddr + MID_1H + 8 * i);
+		}

+		for (i = 0; i < 4; i++)
+			hash_table[i] = 0xffff;
+	}
+	/* Use internal multicast address registers if the number of
+	 * multicast addresses is not greater than MCAST_MAX. */
+	else if (netdev_mc_count(dev) <= MCAST_MAX) {
+		i = 0;
 		netdev_for_each_mc_addr(ha, dev) {
-			char *addrs = ha->addr;
+			u16 *adrp = (u16 *) ha->addr;
+			iowrite16(adrp[0], ioaddr + MID_1L + 8 * i);
+			iowrite16(adrp[1], ioaddr + MID_1M + 8 * i);
+			iowrite16(adrp[2], ioaddr + MID_1H + 8 * i);
+			i++;
+		}
+		while (i < MCAST_MAX) {
+			iowrite16(0, ioaddr + MID_1L + 8 * i);
+			iowrite16(0, ioaddr + MID_1M + 8 * i);
+			iowrite16(0, ioaddr + MID_1H + 8 * i);
+			i++;
+		}
+	}
+	/* Otherwise, Enable multicast hash table function. */
+	else {
+		u32 crc;

-			if (!(*addrs & 1))
-				continue;
+		lp->mcr0 |= MCR0_HASH_EN;
+
+		for (i = 0; i < MCAST_MAX ; i++) {
+			iowrite16(0, ioaddr + MID_1L + 8 * i);
+			iowrite16(0, ioaddr + MID_1M + 8 * i);
+			iowrite16(0, ioaddr + MID_1H + 8 * i);
+		}

-			crc = ether_crc_le(6, addrs);
+		/* Build multicast hash table */
+		netdev_for_each_mc_addr(ha, dev) {
+			u8 *addrs = ha->addr;
+
+			crc = ether_crc(ETH_ALEN, addrs);
 			crc >>= 26;
-			hash_table[crc >> 4] |= 1 << (15 - (crc & 0xf));
+			hash_table[crc >> 4] |= 1 << (crc & 0xf);
 		}
-		/* Fill the MAC hash tables with their values */
+	}
+
+	iowrite16(lp->mcr0, ioaddr + MCR0);
+
+	/* Fill the MAC hash tables with their values */
+	if (lp->mcr0 && MCR0_HASH_EN) {
 		iowrite16(hash_table[0], ioaddr + MAR0);
 		iowrite16(hash_table[1], ioaddr + MAR1);
 		iowrite16(hash_table[2], ioaddr + MAR2);
 		iowrite16(hash_table[3], ioaddr + MAR3);
 	}
-	/* Multicast Address 1~4 case */
-	i = 0;
-	netdev_for_each_mc_addr(ha, dev) {
-		if (i >= MCAST_MAX)
-			break;
-		adrp = (u16 *) ha->addr;
-		iowrite16(adrp[0], ioaddr + MID_1L + 8 * i);
-		iowrite16(adrp[1], ioaddr + MID_1M + 8 * i);
-		iowrite16(adrp[2], ioaddr + MID_1H + 8 * i);
-		i++;
-	}
-	while (i < MCAST_MAX) {
-		iowrite16(0xffff, ioaddr + MID_1L + 8 * i);
-		iowrite16(0xffff, ioaddr + MID_1M + 8 * i);
-		iowrite16(0xffff, ioaddr + MID_1H + 8 * i);
-		i++;
-	}
+
+	spin_unlock_irqrestore(&lp->lock, flags);
 }

 static void netdev_get_drvinfo(struct net_device *dev,
--
1.7.2.3

