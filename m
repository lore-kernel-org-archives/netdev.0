From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/2] r6040: fix multicast operations
Date: Wed, 20 Oct 2010 23:09:41 +0200
Message-ID: <201010202309.43812.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Shawn Lin <shawn@dmp.com.tw>,
	Marc Leclerc <marc-leclerc@signaturealpha.com>,
	Albert Chen <albert.chen@rdc.com.tw>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47998 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753249Ab0JTVHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 17:07:47 -0400
Received: by wwf26 with SMTP id 26so1654574wwf.1
        for <netdev@vger.kernel.org>; Wed, 20 Oct 2010 14:07:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following issues with the r6040 NIC operating in
multicast:

1) When the IFF_ALLMULTI flag is set, we should write 0xffff to the NIC hash
   table registers to make it process multicast traffic
2) When the number of multicast address to handle is smaller than MCAST_MAX
   we should use the NIC multicast registers MID1_{L,M,H}.
3) The hashing of the address was not correct, due to an invalid substraction
   (15 - (crc & 0x0f)) instead of (crc & 0x0f)

Reported-by: Marc Leclerc <marc-leclerc@signaturealpha.com>
Tested-by: Marc Leclerc <marc-leclerc@signaturealpha.com>
Signed-off-by: Shawn Lin <shawn@dmp.com.tw>
Signed-off-by: Albert Chen <albert.chen@rdc.com.tw>
Signed-off-by: Florian Fainelli <florian@openwrt.org>
CC: stable@kernel.org
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 68a8419..3843363 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -852,74 +852,90 @@ static void r6040_multicast_list(struct net_device *dev)
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
 	u16 *adrp;
-	u16 reg;
 	unsigned long flags;
 	struct netdev_hw_addr *ha;
 	int i;
 
-	/* MAC Address */
-	adrp = (u16 *)dev->dev_addr;
-	iowrite16(adrp[0], ioaddr + MID_0L);
-	iowrite16(adrp[1], ioaddr + MID_0M);
-	iowrite16(adrp[2], ioaddr + MID_0H);
-
-	/* Promiscous Mode */
 	spin_lock_irqsave(&lp->lock, flags);
 
 	/* Clear AMCP & PROM bits */
-	reg = ioread16(ioaddr) & ~0x0120;
-	if (dev->flags & IFF_PROMISC) {
-		reg |= 0x0020;
+	lp->mcr0 = ioread16(ioaddr) & ~0x0120;
+
+	/* Promiscuous Mode */
+	if (dev->flags & IFF_PROMISC)
 		lp->mcr0 |= 0x0020;
-	}
-	/* Too many multicast addresses
-	 * accept all traffic */
-	else if ((netdev_mc_count(dev) > MCAST_MAX) ||
-		 (dev->flags & IFF_ALLMULTI))
-		reg |= 0x0020;
 
-	iowrite16(reg, ioaddr);
-	spin_unlock_irqrestore(&lp->lock, flags);
+	/* Enable multicast hash table function to
+	 * receive all multicast packets.
+	 */
+	else if (dev->flags & IFF_ALLMULTI) {
+		lp->mcr0 |= 0x0100;
 
-	/* Build the hash table */
-	if (netdev_mc_count(dev) > MCAST_MAX) {
-		u16 hash_table[4];
+		for (i = 0; i < MCAST_MAX ; i++) {
+			iowrite16(0, ioaddr + MID_1L + 8 * i);
+			iowrite16(0, ioaddr + MID_1M + 8 * i);
+			iowrite16(0, ioaddr + MID_1H + 8 * i);
+		}
+
+		iowrite16(0xffff, ioaddr + MAR0);
+		iowrite16(0xffff, ioaddr + MAR1);
+		iowrite16(0xffff, ioaddr + MAR2);
+		iowrite16(0xffff, ioaddr + MAR3);
+	}
+
+	/* Use internal multicast address registers
+	 * if the number of multicast addresses is not greater than MCAST_MAX.
+	 */
+	else if (netdev_mc_empty(dev)) {
+		for (i = 0; i < MCAST_MAX ; i++) {
+			iowrite16(0, ioaddr + MID_1L + 8 * i);
+			iowrite16(0, ioaddr + MID_1M + 8 * i);
+			iowrite16(0, ioaddr + MID_1H + 8 * i);
+		}
+	} else if (netdev_mc_count(dev) <= MCAST_MAX) {
+		i = 0;
+		netdev_for_each_mc_addr(ha, dev) {
+			adrp = (u16 *) ha->addr;
+			iowrite16(adrp[0], ioaddr + MID_1L + 8 * i);
+			iowrite16(adrp[1], ioaddr + MID_1M + 8 * i);
+			iowrite16(adrp[2], ioaddr + MID_1H + 8 * i);
+			i++;
+		}
+	}
+	/* Otherwise, Enable multicast hash table function. */
+	else {
+		u16 hash_table[4] = { 0, };
 		u32 crc;
 
-		for (i = 0; i < 4; i++)
-			hash_table[i] = 0;
+		lp->mcr0 |= 0x0100;
 
+		for (i = 0; i < MCAST_MAX ; i++) {
+			iowrite16(0, ioaddr + MID_1L + 8 * i);
+			iowrite16(0, ioaddr + MID_1M + 8 * i);
+			iowrite16(0, ioaddr + MID_1H + 8 * i);
+		}
+
+		/* Build multicast hash table */
 		netdev_for_each_mc_addr(ha, dev) {
 			char *addrs = ha->addr;
 
 			if (!(*addrs & 1))
 				continue;
 
-			crc = ether_crc_le(6, addrs);
+			crc = ether_crc(ETH_ALEN, addrs);
 			crc >>= 26;
-			hash_table[crc >> 4] |= 1 << (15 - (crc & 0xf));
+			hash_table[crc >> 4] |= 1 << (crc & 0xf);
 		}
+
 		/* Fill the MAC hash tables with their values */
 		iowrite16(hash_table[0], ioaddr + MAR0);
 		iowrite16(hash_table[1], ioaddr + MAR1);
 		iowrite16(hash_table[2], ioaddr + MAR2);
 		iowrite16(hash_table[3], ioaddr + MAR3);
 	}
-	/* Multicast Address 1~4 case */
-	i = 0;
-	netdev_for_each_mc_addr(ha, dev) {
-		if (i < MCAST_MAX) {
-			adrp = (u16 *) ha->addr;
-			iowrite16(adrp[0], ioaddr + MID_1L + 8 * i);
-			iowrite16(adrp[1], ioaddr + MID_1M + 8 * i);
-			iowrite16(adrp[2], ioaddr + MID_1H + 8 * i);
-		} else {
-			iowrite16(0xffff, ioaddr + MID_1L + 8 * i);
-			iowrite16(0xffff, ioaddr + MID_1M + 8 * i);
-			iowrite16(0xffff, ioaddr + MID_1H + 8 * i);
-		}
-		i++;
-	}
+	iowrite16(lp->mcr0, ioaddr);
+
+	spin_unlock_irqrestore(&lp->lock, flags);
 }
 
 static void netdev_get_drvinfo(struct net_device *dev,
