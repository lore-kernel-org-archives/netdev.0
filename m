From: Shawn Lin <shawn@dmp.com.tw>
Subject: Re: [PATCH 1/2] r6040: fix multicast operations
Date: Thu, 11 Nov 2010 16:39:47 +0800
Message-ID: <1289464787.2169.107.camel@shawn-desktop>
References: <201010202309.43812.florian@openwrt.org>
	 <1288788689.1837.141.camel@shawn-desktop>
	 <201011041104.24681.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Marc Leclerc <marc-leclerc@signaturealpha.com>,
	Albert Chen <albert.chen@rdc.com.tw>,
	David Miller <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 59-120-27-67.HINET-IP.hinet.net ([59.120.27.67]:3312 "EHLO
	www.dmp.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932367Ab0KKIj4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Nov 2010 03:39:56 -0500
Received: from [59.120.27.68] by www.dmp.com.tw (GMS
 15.00.3626/AB6032.00.96a8e532) with ESMTP id ezbrcbaa for
 netdev@vger.kernel.org; Thu, 11 Nov 2010 16:39:50 +0800
In-Reply-To: <201011041104.24681.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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


The version is for net-next-2.6:

Reported-by: Marc Leclerc <marc-leclerc@signaturealpha.com>
Tested-by: Marc Leclerc <marc-leclerc@signaturealpha.com>
Signed-off-by: Shawn Lin <shawn@dmp.com.tw>
Signed-off-by: Albert Chen <albert.chen@rdc.com.tw>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 0b014c8..e88e171 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -69,6 +69,8 @@
 
 /* MAC registers */
 #define MCR0           0x00    /* Control register 0 */
+#define  PROMISC       0x0020  /* Promiscuous mode */
+#define  HASH_EN       0x0100  /* Enable multicast hash table function
*/
 #define MCR1           0x04    /* Control register 1 */
 #define  MAC_RST       0x0001  /* Reset the MAC */
 #define MBCR           0x08    /* Bus control */
@@ -851,77 +853,84 @@ static void r6040_multicast_list(struct net_device
*dev)
 {
        struct r6040_private *lp = netdev_priv(dev);
        void __iomem *ioaddr = lp->base;
-       u16 *adrp;
-       u16 reg;
        unsigned long flags;
        struct netdev_hw_addr *ha;
        int i;
+       u16 hash_table[4] = { 0, };
 
-       /* MAC Address */
-       adrp = (u16 *)dev->dev_addr;
-       iowrite16(adrp[0], ioaddr + MID_0L);
-       iowrite16(adrp[1], ioaddr + MID_0M);
-       iowrite16(adrp[2], ioaddr + MID_0H);
-
-       /* Promiscous Mode */
        spin_lock_irqsave(&lp->lock, flags);
 
        /* Clear AMCP & PROM bits */
-       reg = ioread16(ioaddr) & ~0x0120;
+       lp->mcr0 = ioread16(ioaddr + MCR0) & ~(PROMISC | HASH_EN);
+
+       /* Promiscuous Mode */
        if (dev->flags & IFF_PROMISC) {
-               reg |= 0x0020;
-               lp->mcr0 |= 0x0020;
+               lp->mcr0 |= PROMISC;
        }
-       /* Too many multicast addresses
-        * accept all traffic */
-       else if ((netdev_mc_count(dev) > MCAST_MAX) ||
-                (dev->flags & IFF_ALLMULTI))
-               reg |= 0x0020;
-
-       iowrite16(reg, ioaddr);
-       spin_unlock_irqrestore(&lp->lock, flags);
+       /* Enable multicast hash table function to
+        * receive all multicast packets. */
+       else if (dev->flags & IFF_ALLMULTI) {
+               lp->mcr0 |= HASH_EN;
+
+               for (i = 0; i < MCAST_MAX ; i++) {
+                       iowrite16(0, ioaddr + MID_1L + 8 * i);
+                       iowrite16(0, ioaddr + MID_1M + 8 * i);
+                       iowrite16(0, ioaddr + MID_1H + 8 * i);
+               }
 
-       /* Build the hash table */
-       if (netdev_mc_count(dev) > MCAST_MAX) {
-               u16 hash_table[4];
+               for (i = 0; i < 4; i++)
+                       hash_table[i] = 0xffff;
+       }
+       /* Use internal multicast address registers if the number of
+        * multicast addresses is not greater than MCAST_MAX. */
+       else if (netdev_mc_count(dev) <= MCAST_MAX) {
+               i = 0;
+               netdev_for_each_mc_addr(ha, dev) {
+                       u16 *adrp = (u16 *) ha->addr;
+                       iowrite16(adrp[0], ioaddr + MID_1L + 8 * i);
+                       iowrite16(adrp[1], ioaddr + MID_1M + 8 * i);
+                       iowrite16(adrp[2], ioaddr + MID_1H + 8 * i);
+                       i++;
+               }
+               while (i < MCAST_MAX) {
+                       iowrite16(0, ioaddr + MID_1L + 8 * i);
+                       iowrite16(0, ioaddr + MID_1M + 8 * i);
+                       iowrite16(0, ioaddr + MID_1H + 8 * i);
+                       i++;
+               }
+       }
+       /* Otherwise, Enable multicast hash table function. */
+       else {
                u32 crc;
 
-               for (i = 0; i < 4; i++)
-                       hash_table[i] = 0;
+               lp->mcr0 |= HASH_EN;
 
-               netdev_for_each_mc_addr(ha, dev) {
-                       char *addrs = ha->addr;
+               for (i = 0; i < MCAST_MAX ; i++) {
+                       iowrite16(0, ioaddr + MID_1L + 8 * i);
+                       iowrite16(0, ioaddr + MID_1M + 8 * i);
+                       iowrite16(0, ioaddr + MID_1H + 8 * i);
+               }
 
-                       if (!(*addrs & 1))
-                               continue;
+               /* Build multicast hash table */
+               netdev_for_each_mc_addr(ha, dev) {
+                       u8 *addrs = ha->addr;
 
-                       crc = ether_crc_le(6, addrs);
+                       crc = ether_crc(ETH_ALEN, addrs);
                        crc >>= 26;
-                       hash_table[crc >> 4] |= 1 << (15 - (crc & 0xf));
+                       hash_table[crc >> 4] |= 1 << (crc & 0xf);
                }
-               /* Fill the MAC hash tables with their values */
+       }
+       iowrite16(lp->mcr0, ioaddr + MCR0);
+
+       /* Fill the MAC hash tables with their values */
+       if (lp->mcr0 && HASH_EN) {
                iowrite16(hash_table[0], ioaddr + MAR0);
                iowrite16(hash_table[1], ioaddr + MAR1);
                iowrite16(hash_table[2], ioaddr + MAR2);
                iowrite16(hash_table[3], ioaddr + MAR3);
        }
-       /* Multicast Address 1~4 case */
-       i = 0;
-       netdev_for_each_mc_addr(ha, dev) {
-               if (i >= MCAST_MAX)
-                       break;
-               adrp = (u16 *) ha->addr;
-               iowrite16(adrp[0], ioaddr + MID_1L + 8 * i);
-               iowrite16(adrp[1], ioaddr + MID_1M + 8 * i);
-               iowrite16(adrp[2], ioaddr + MID_1H + 8 * i);
-               i++;
-       }
-       while (i < MCAST_MAX) {
-               iowrite16(0xffff, ioaddr + MID_1L + 8 * i);
-               iowrite16(0xffff, ioaddr + MID_1M + 8 * i);
-               iowrite16(0xffff, ioaddr + MID_1H + 8 * i);
-               i++;
-       }
+
+       spin_unlock_irqrestore(&lp->lock, flags);
 }
 
 static void netdev_get_drvinfo(struct net_device *dev,
---


The version is for 2.6.32.y and 2.6.27.y:

Reported-by: Marc Leclerc <marc-leclerc@signaturealpha.com>
Tested-by: Marc Leclerc <marc-leclerc@signaturealpha.com>
Signed-off-by: Shawn Lin <shawn@dmp.com.tw>
Signed-off-by: Albert Chen <albert.chen@rdc.com.tw>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 9ee9f01..f9af419 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -69,6 +69,8 @@
 
 /* MAC registers */
 #define MCR0           0x00    /* Control register 0 */
+#define  PROMISC       0x0020  /* Promiscuous mode */
+#define  HASH_EN       0x0100  /* Enable multicast hash table function
*/
 #define MCR1           0x04    /* Control register 1 */
 #define  MAC_RST       0x0001  /* Reset the MAC */
 #define MBCR           0x08    /* Bus control */
@@ -935,76 +937,88 @@ static void r6040_multicast_list(struct net_device
*dev)
 {
        struct r6040_private *lp = netdev_priv(dev);
        void __iomem *ioaddr = lp->base;
-       u16 *adrp;
-       u16 reg;
        unsigned long flags;
        struct dev_mc_list *dmi = dev->mc_list;
        int i;
+       u16 hash_table[4] = { 0, };
 
-       /* MAC Address */
-       adrp = (u16 *)dev->dev_addr;
-       iowrite16(adrp[0], ioaddr + MID_0L);
-       iowrite16(adrp[1], ioaddr + MID_0M);
-       iowrite16(adrp[2], ioaddr + MID_0H);
-
-       /* Promiscous Mode */
        spin_lock_irqsave(&lp->lock, flags);
 
        /* Clear AMCP & PROM bits */
-       reg = ioread16(ioaddr) & ~0x0120;
+       lp->mcr0 = ioread16(ioaddr + MCR0) & ~(PROMISC | HASH_EN);
+
+       /* Promiscuous Mode */
        if (dev->flags & IFF_PROMISC) {
-               reg |= 0x0020;
-               lp->mcr0 |= 0x0020;
+               lp->mcr0 |= PROMISC;
        }
-       /* Too many multicast addresses
-        * accept all traffic */
-       else if ((dev->mc_count > MCAST_MAX)
-               || (dev->flags & IFF_ALLMULTI))
-               reg |= 0x0020;
+       /* Enable multicast hash table function to
+        * receive all multicast packets. */
+       else if (dev->flags & IFF_ALLMULTI) {
+               lp->mcr0 |= HASH_EN;
+
+               for (i = 0; i < MCAST_MAX ; i++) {
+                       iowrite16(0, ioaddr + MID_1L + 8 * i);
+                       iowrite16(0, ioaddr + MID_1M + 8 * i);
+                       iowrite16(0, ioaddr + MID_1H + 8 * i);
+               }
 
-       iowrite16(reg, ioaddr);
-       spin_unlock_irqrestore(&lp->lock, flags);
+               for (i = 0; i < 4; i++)
+                       hash_table[i] = 0xffff;
+       }
+       /* Use internal multicast address registers if the number of
+        * multicast addresses is not greater than MCAST_MAX. */
+       else if (dev->mc_count <= MCAST_MAX) {
+               i = 0;
+               while (i < dev->mc_count) {
+                       u16 *adrp = (u16 *) dmi->dmi_addr;
+                       dmi = dmi->next;
 
-       /* Build the hash table */
-       if (dev->mc_count > MCAST_MAX) {
-               u16 hash_table[4];
+                       iowrite16(adrp[0], ioaddr + MID_1L + 8 * i);
+                       iowrite16(adrp[1], ioaddr + MID_1M + 8 * i);
+                       iowrite16(adrp[2], ioaddr + MID_1H + 8 * i);
+                       i++;
+               }
+               while (i < MCAST_MAX) {
+                       iowrite16(0, ioaddr + MID_1L + 8 * i);
+                       iowrite16(0, ioaddr + MID_1M + 8 * i);
+                       iowrite16(0, ioaddr + MID_1H + 8 * i);
+                       i++;
+               }
+       }
+       /* Otherwise, Enable multicast hash table function. */
+       else {
                u32 crc;
 
-               for (i = 0; i < 4; i++)
-                       hash_table[i] = 0;
+               lp->mcr0 |= HASH_EN;
 
-               for (i = 0; i < dev->mc_count; i++) {
-                       char *addrs = dmi->dmi_addr;
+               for (i = 0; i < MCAST_MAX ; i++) {
+                       iowrite16(0, ioaddr + MID_1L + 8 * i);
+                       iowrite16(0, ioaddr + MID_1M + 8 * i);
+                       iowrite16(0, ioaddr + MID_1H + 8 * i);
+               }
 
+               /* Build multicast hash table */
+               for (i = 0; i < dev->mc_count; i++) {
+                       u8 *addrs = dmi->dmi_addr;
                        dmi = dmi->next;
 
-                       if (!(*addrs & 1))
-                               continue;
-
-                       crc = ether_crc_le(6, addrs);
+                       crc = ether_crc(ETH_ALEN, addrs);
                        crc >>= 26;
-                       hash_table[crc >> 4] |= 1 << (15 - (crc & 0xf));
+                       hash_table[crc >> 4] |= 1 << (crc & 0xf);
                }
-               /* Fill the MAC hash tables with their values */
+
+       }
+       iowrite16(lp->mcr0, ioaddr + MCR0);
+
+       /* Fill the MAC hash tables with their values */
+       if (lp->mcr0 && HASH_EN) {
                iowrite16(hash_table[0], ioaddr + MAR0);
                iowrite16(hash_table[1], ioaddr + MAR1);
                iowrite16(hash_table[2], ioaddr + MAR2);
                iowrite16(hash_table[3], ioaddr + MAR3);
        }
-       /* Multicast Address 1~4 case */
-       dmi = dev->mc_list;
-       for (i = 0, dmi; (i < dev->mc_count) && (i < MCAST_MAX); i++) {
-               adrp = (u16 *)dmi->dmi_addr;
-               iowrite16(adrp[0], ioaddr + MID_1L + 8*i);
-               iowrite16(adrp[1], ioaddr + MID_1M + 8*i);
-               iowrite16(adrp[2], ioaddr + MID_1H + 8*i);
-               dmi = dmi->next;
-       }
-       for (i = dev->mc_count; i < MCAST_MAX; i++) {
-               iowrite16(0xffff, ioaddr + MID_1L + 8*i);
-               iowrite16(0xffff, ioaddr + MID_1M + 8*i);
-               iowrite16(0xffff, ioaddr + MID_1H + 8*i);
-       }
+
+       spin_unlock_irqrestore(&lp->lock, flags);
 }
 
 static void netdev_get_drvinfo(struct net_device *dev,
---



===========================================================================================
The privileged confidential information contained in this email is intended for use only by the addressees as indicated by the original sender of this email. 
If you are not the addressee indicated in this email or are not responsible for delivery of the email to such a person, please kindly reply to the sender indicating this fact and delete all copies of it from your computer and network server immediately. 
Your cooperation is highly appreciated. It is advised that any unauthorized use of confidential information of DM&P Group is strictly prohibited; and any information in this email irrelevant to the official business of DM&P Group shall be deemed as neither given nor endorsed by DM&P Group.

===========================================================================================
