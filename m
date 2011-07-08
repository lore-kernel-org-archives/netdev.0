From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] drivers/net: Omit check for multicast bit in netdev_for_each_mc_addr
Date: Fri,  8 Jul 2011 10:06:26 +0200
Message-ID: <1310112386-13716-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org, Joe Perches <joe@perches.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:46085 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751856Ab1GHIGa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2011 04:06:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to check for the address being a multicast address in
the netdev_for_each_mc_addr loop, so remove it.

There is no need to check for the address being a multicast address in
the netdev_for_each_mc_addr loop, so remove it. This patch covers all
remaining network drivers still containing such a check.

Cc: Joe Perches <joe@perches.com>
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/7990.c       |    9 +--------
 drivers/net/a2065.c      |    9 +--------
 drivers/net/bmac.c       |    8 +-------
 drivers/net/declance.c   |    9 +--------
 drivers/net/ewrk3.c      |   31 ++++++++++++++-----------------
 drivers/net/fec.c        |    4 ----
 drivers/net/hp100.c      |   18 ++++++++----------
 drivers/net/ioc3-eth.c   |    7 +------
 drivers/net/korina.c     |    7 +------
 drivers/net/ks8851_mll.c |    2 --
 drivers/net/ksz884x.c    |    2 --
 drivers/net/pcnet32.c    |    9 +--------
 drivers/net/smc911x.c    |    5 -----
 drivers/net/smc9194.c    |    5 -----
 drivers/net/smc91x.c     |    5 -----
 drivers/net/sunbmac.c    |    8 +-------
 drivers/net/sungem.c     |    7 +------
 drivers/net/sunhme.c     |   16 ++--------------
 drivers/net/sunlance.c   |    8 +-------
 drivers/net/sunqe.c      |    7 +------
 20 files changed, 35 insertions(+), 141 deletions(-)

diff --git a/drivers/net/7990.c b/drivers/net/7990.c
index 903bcb3..60b35fb 100644
--- a/drivers/net/7990.c
+++ b/drivers/net/7990.c
@@ -594,7 +594,6 @@ static void lance_load_multicast (struct net_device *dev)
         volatile struct lance_init_block *ib = lp->init_block;
         volatile u16 *mcast_table = (u16 *)&ib->filter;
 	struct netdev_hw_addr *ha;
-        char *addrs;
         u32 crc;
 
         /* set all multicast bits */
@@ -609,13 +608,7 @@ static void lance_load_multicast (struct net_device *dev)
 
         /* Add addresses */
 	netdev_for_each_mc_addr(ha, dev) {
-		addrs = ha->addr;
-
-                /* multicast address? */
-                if (!(*addrs & 1))
-                        continue;
-
-		crc = ether_crc_le(6, addrs);
+		crc = ether_crc_le(6, ha->addr);
                 crc = crc >> 26;
                 mcast_table [crc >> 4] |= 1 << (crc & 0xf);
         }
diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
index 7d9a1a6..e1e1b07 100644
--- a/drivers/net/a2065.c
+++ b/drivers/net/a2065.c
@@ -587,7 +587,6 @@ static void lance_load_multicast(struct net_device *dev)
 	volatile struct lance_init_block *ib = lp->init_block;
 	volatile u16 *mcast_table = (u16 *)&ib->filter;
 	struct netdev_hw_addr *ha;
-	char *addrs;
 	u32 crc;
 
 	/* set all multicast bits */
@@ -602,13 +601,7 @@ static void lance_load_multicast(struct net_device *dev)
 
 	/* Add addresses */
 	netdev_for_each_mc_addr(ha, dev) {
-		addrs = ha->addr;
-
-		/* multicast address? */
-		if (!(*addrs & 1))
-			continue;
-
-		crc = ether_crc_le(6, addrs);
+		crc = ether_crc_le(6, ha->addr);
 		crc = crc >> 26;
 		mcast_table[crc >> 4] |= 1 << (crc & 0xf);
 	}
diff --git a/drivers/net/bmac.c b/drivers/net/bmac.c
index d2e58e2..45e45e8 100644
--- a/drivers/net/bmac.c
+++ b/drivers/net/bmac.c
@@ -1015,7 +1015,6 @@ static void bmac_set_multicast(struct net_device *dev)
 static void bmac_set_multicast(struct net_device *dev)
 {
 	struct netdev_hw_addr *ha;
-	char *addrs;
 	int i;
 	unsigned short rx_cfg;
 	u32 crc;
@@ -1039,12 +1038,7 @@ static void bmac_set_multicast(struct net_device *dev)
 		for(i = 0; i < 4; i++) hash_table[i] = 0;
 
 		netdev_for_each_mc_addr(ha, dev) {
-			addrs = ha->addr;
-
-			if(!(*addrs & 1))
-				continue;
-
-			crc = ether_crc_le(6, addrs);
+			crc = ether_crc_le(6, ha->addr);
 			crc >>= 26;
 			hash_table[crc >> 4] |= 1 << (crc & 0xf);
 		}
diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index cabd3a5..d5598f6 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -946,7 +946,6 @@ static void lance_load_multicast(struct net_device *dev)
 	struct lance_private *lp = netdev_priv(dev);
 	volatile u16 *ib = (volatile u16 *)dev->mem_start;
 	struct netdev_hw_addr *ha;
-	char *addrs;
 	u32 crc;
 
 	/* set all multicast bits */
@@ -965,13 +964,7 @@ static void lance_load_multicast(struct net_device *dev)
 
 	/* Add addresses */
 	netdev_for_each_mc_addr(ha, dev) {
-		addrs = ha->addr;
-
-		/* multicast address? */
-		if (!(*addrs & 1))
-			continue;
-
-		crc = ether_crc_le(ETH_ALEN, addrs);
+		crc = ether_crc_le(ETH_ALEN, ha->addr);
 		crc = crc >> 26;
 		*lib_ptr(ib, filter[crc >> 4], lp->type) |= 1 << (crc & 0xf);
 	}
diff --git a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
index d1e229f..05a5f71 100644
--- a/drivers/net/ewrk3.c
+++ b/drivers/net/ewrk3.c
@@ -1169,7 +1169,7 @@ static void SetMulticastFilter(struct net_device *dev)
 	struct netdev_hw_addr *ha;
 	u_long iobase = dev->base_addr;
 	int i;
-	char *addrs, bit, byte;
+	char bit, byte;
 	short __iomem *p = lp->mctbl;
 	u16 hashcode;
 	u32 crc;
@@ -1211,25 +1211,22 @@ static void SetMulticastFilter(struct net_device *dev)
 
 		/* Update table */
 		netdev_for_each_mc_addr(ha, dev) {
-			addrs = ha->addr;
-			if ((*addrs & 0x01) == 1) {	/* multicast address? */
-				crc = ether_crc_le(ETH_ALEN, addrs);
-				hashcode = crc & ((1 << 9) - 1);	/* hashcode is 9 LSb of CRC */
+			crc = ether_crc_le(ETH_ALEN, ha->addr);
+			hashcode = crc & ((1 << 9) - 1);	/* hashcode is 9 LSb of CRC */
 
-				byte = hashcode >> 3;	/* bit[3-8] -> byte in filter */
-				bit = 1 << (hashcode & 0x07);	/* bit[0-2] -> bit in byte */
+			byte = hashcode >> 3;	/* bit[3-8] -> byte in filter */
+			bit = 1 << (hashcode & 0x07);	/* bit[0-2] -> bit in byte */
 
-				if (lp->shmem_length == IO_ONLY) {
-					u_char tmp;
+			if (lp->shmem_length == IO_ONLY) {
+				u_char tmp;
 
-					outw(PAGE0_HTE + byte, EWRK3_PIR1);
-					tmp = inb(EWRK3_DATA);
-					tmp |= bit;
-					outw(PAGE0_HTE + byte, EWRK3_PIR1);
-					outb(tmp, EWRK3_DATA);
-				} else {
-					writeb(readb(lp->mctbl + byte) | bit, lp->mctbl + byte);
-				}
+				outw(PAGE0_HTE + byte, EWRK3_PIR1);
+				tmp = inb(EWRK3_DATA);
+				tmp |= bit;
+				outw(PAGE0_HTE + byte, EWRK3_PIR1);
+				outb(tmp, EWRK3_DATA);
+			} else {
+				writeb(readb(lp->mctbl + byte) | bit, lp->mctbl + byte);
 			}
 		}
 	}
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 7ae3f28..5b631fe 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1227,10 +1227,6 @@ static void set_multicast_list(struct net_device *ndev)
 	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
 
 	netdev_for_each_mc_addr(ha, ndev) {
-		/* Only support group multicast for now */
-		if (!(ha->addr[0] & 1))
-			continue;
-
 		/* calculate crc32 value of mac address */
 		crc = 0xffffffff;
 
diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index c3ecb11..b6519c1 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -2103,20 +2103,18 @@ static void hp100_set_multicast_list(struct net_device *dev)
 #endif
 			netdev_for_each_mc_addr(ha, dev) {
 				addrs = ha->addr;
-				if ((*addrs & 0x01) == 0x01) {	/* multicast address? */
 #ifdef HP100_DEBUG
-					printk("hp100: %s: multicast = %pM, ",
-						     dev->name, addrs);
+				printk("hp100: %s: multicast = %pM, ",
+					     dev->name, addrs);
 #endif
-					for (i = idx = 0; i < 6; i++) {
-						idx ^= *addrs++ & 0x3f;
-						printk(":%02x:", idx);
-					}
+				for (i = idx = 0; i < 6; i++) {
+					idx ^= *addrs++ & 0x3f;
+					printk(":%02x:", idx);
+				}
 #ifdef HP100_DEBUG
-					printk("idx = %i\n", idx);
+				printk("idx = %i\n", idx);
 #endif
-					lp->hash_bytes[idx >> 3] |= (1 << (idx & 7));
-				}
+				lp->hash_bytes[idx >> 3] |= (1 << (idx & 7));
 			}
 		}
 #else
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index 318a25a..a234e45 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -1664,12 +1664,7 @@ static void ioc3_set_multicast_list(struct net_device *dev)
 			ip->ehar_l = 0xffffffff;
 		} else {
 			netdev_for_each_mc_addr(ha, dev) {
-				char *addr = ha->addr;
-
-				if (!(*addr & 1))
-					continue;
-
-				ehar |= (1UL << ioc3_hash(addr));
+				ehar |= (1UL << ioc3_hash(ha->addr));
 			}
 			ip->ehar_h = ehar >> 32;
 			ip->ehar_l = ehar & 0xffffffff;
diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index c7a9bef..763844c 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -504,12 +504,7 @@ static void korina_multicast_list(struct net_device *dev)
 			hash_table[i] = 0;
 
 		netdev_for_each_mc_addr(ha, dev) {
-			char *addrs = ha->addr;
-
-			if (!(*addrs & 1))
-				continue;
-
-			crc = ether_crc_le(6, addrs);
+			crc = ether_crc_le(6, ha->addr);
 			crc >>= 26;
 			hash_table[crc >> 4] |= 1 << (15 - (crc & 0xf));
 		}
diff --git a/drivers/net/ks8851_mll.c b/drivers/net/ks8851_mll.c
index a823782..d19c849 100644
--- a/drivers/net/ks8851_mll.c
+++ b/drivers/net/ks8851_mll.c
@@ -1190,8 +1190,6 @@ static void ks_set_rx_mode(struct net_device *netdev)
 			int i = 0;
 
 			netdev_for_each_mc_addr(ha, netdev) {
-				if (!(*ha->addr & 1))
-					continue;
 				if (i >= MAX_MCAST_LST)
 					break;
 				memcpy(ks->mcast_lst[i++], ha->addr, ETH_ALEN);
diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index 2ac6c6c..27418d3 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -5785,8 +5785,6 @@ static void netdev_set_rx_mode(struct net_device *dev)
 		}
 
 		netdev_for_each_mc_addr(ha, dev) {
-			if (!(*ha->addr & 1))
-				continue;
 			if (i >= MAX_MULTICAST_LIST)
 				break;
 			memcpy(hw->multi_list[i++], ha->addr, MAC_ADDR_LEN);
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index b48aba9..8b3090d 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -2570,7 +2570,6 @@ static void pcnet32_load_multicast(struct net_device *dev)
 	volatile __le16 *mcast_table = (__le16 *)ib->filter;
 	struct netdev_hw_addr *ha;
 	unsigned long ioaddr = dev->base_addr;
-	char *addrs;
 	int i;
 	u32 crc;
 
@@ -2590,13 +2589,7 @@ static void pcnet32_load_multicast(struct net_device *dev)
 
 	/* Add addresses */
 	netdev_for_each_mc_addr(ha, dev) {
-		addrs = ha->addr;
-
-		/* multicast address? */
-		if (!(*addrs & 1))
-			continue;
-
-		crc = ether_crc_le(6, addrs);
+		crc = ether_crc_le(6, ha->addr);
 		crc = crc >> 26;
 		mcast_table[crc >> 4] |= cpu_to_le16(1 << (crc & 0xf));
 	}
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 053863a..a91fe17 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -1351,11 +1351,6 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 		netdev_for_each_mc_addr(ha, dev) {
 			u32 position;
 
-			/* make sure this is a multicast address -
-				shouldn't this be a given if we have it here ? */
-			if (!(*ha->addr & 1))
-				continue;
-
 			/* upper 6 bits are used as hash index */
 			position = ether_crc(ETH_ALEN, ha->addr)>>26;
 
diff --git a/drivers/net/smc9194.c b/drivers/net/smc9194.c
index 7486d09..5b65ac4 100644
--- a/drivers/net/smc9194.c
+++ b/drivers/net/smc9194.c
@@ -447,11 +447,6 @@ static void smc_setmulticast(int ioaddr, struct net_device *dev)
 	netdev_for_each_mc_addr(ha, dev) {
 		int position;
 
-		/* make sure this is a multicast address - shouldn't this
-		   be a given if we have it here ? */
-		if (!(*ha->addr & 1))
-			continue;
-
 		/* only use the low order bits */
 		position = ether_crc_le(6, ha->addr) & 0x3f;
 
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index f628574..2b1d254 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -1425,11 +1425,6 @@ static void smc_set_multicast_list(struct net_device *dev)
 		netdev_for_each_mc_addr(ha, dev) {
 			int position;
 
-			/* make sure this is a multicast address -
-		   	   shouldn't this be a given if we have it here ? */
-			if (!(*ha->addr & 1))
-				continue;
-
 			/* only use the low order bits */
 			position = crc32_le(~0, ha->addr, 6) & 0x3f;
 
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index aa47658..297a424 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -998,7 +998,6 @@ static void bigmac_set_multicast(struct net_device *dev)
 	struct bigmac *bp = netdev_priv(dev);
 	void __iomem *bregs = bp->bregs;
 	struct netdev_hw_addr *ha;
-	char *addrs;
 	int i;
 	u32 tmp, crc;
 
@@ -1027,12 +1026,7 @@ static void bigmac_set_multicast(struct net_device *dev)
 			hash_table[i] = 0;
 
 		netdev_for_each_mc_addr(ha, dev) {
-			addrs = ha->addr;
-
-			if (!(*addrs & 1))
-				continue;
-
-			crc = ether_crc_le(6, addrs);
+			crc = ether_crc_le(6, ha->addr);
 			crc >>= 26;
 			hash_table[crc >> 4] |= 1 << (crc & 0xf);
 		}
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 32b11a3..be745ae 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -1801,12 +1801,7 @@ static u32 gem_setup_multicast(struct gem *gp)
 
 		memset(hash_table, 0, sizeof(hash_table));
 		netdev_for_each_mc_addr(ha, gp->dev) {
-			char *addrs = ha->addr;
-
-			if (!(*addrs & 1))
-				continue;
-
- 			crc = ether_crc_le(6, addrs);
+			crc = ether_crc_le(6, ha->addr);
 			crc >>= 24;
 			hash_table[crc >> 4] |= 1 << (15 - (crc & 0xf));
 		}
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 30aad54..856e05b 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -1524,17 +1524,11 @@ static int happy_meal_init(struct happy_meal *hp)
 	} else if ((hp->dev->flags & IFF_PROMISC) == 0) {
 		u16 hash_table[4];
 		struct netdev_hw_addr *ha;
-		char *addrs;
 		u32 crc;
 
 		memset(hash_table, 0, sizeof(hash_table));
 		netdev_for_each_mc_addr(ha, hp->dev) {
-			addrs = ha->addr;
-
-			if (!(*addrs & 1))
-				continue;
-
-			crc = ether_crc_le(6, addrs);
+			crc = ether_crc_le(6, ha->addr);
 			crc >>= 26;
 			hash_table[crc >> 4] |= 1 << (crc & 0xf);
 		}
@@ -2361,7 +2355,6 @@ static void happy_meal_set_multicast(struct net_device *dev)
 	struct happy_meal *hp = netdev_priv(dev);
 	void __iomem *bregs = hp->bigmacregs;
 	struct netdev_hw_addr *ha;
-	char *addrs;
 	u32 crc;
 
 	spin_lock_irq(&hp->happy_lock);
@@ -2379,12 +2372,7 @@ static void happy_meal_set_multicast(struct net_device *dev)
 
 		memset(hash_table, 0, sizeof(hash_table));
 		netdev_for_each_mc_addr(ha, dev) {
-			addrs = ha->addr;
-
-			if (!(*addrs & 1))
-				continue;
-
-			crc = ether_crc_le(6, addrs);
+			crc = ether_crc_le(6, ha->addr);
 			crc >>= 26;
 			hash_table[crc >> 4] |= 1 << (crc & 0xf);
 		}
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index 32a5c7f..06f2d43 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -1170,7 +1170,6 @@ static void lance_load_multicast(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
 	struct netdev_hw_addr *ha;
-	char *addrs;
 	u32 crc;
 	u32 val;
 
@@ -1195,12 +1194,7 @@ static void lance_load_multicast(struct net_device *dev)
 
 	/* Add addresses */
 	netdev_for_each_mc_addr(ha, dev) {
-		addrs = ha->addr;
-
-		/* multicast address? */
-		if (!(*addrs & 1))
-			continue;
-		crc = ether_crc_le(6, addrs);
+		crc = ether_crc_le(6, ha->addr);
 		crc = crc >> 26;
 		if (lp->pio_buffer) {
 			struct lance_init_block __iomem *ib = lp->init_block_iomem;
diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index 18ecdc3..209c7f8 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -628,7 +628,6 @@ static void qe_set_multicast(struct net_device *dev)
 	struct sunqe *qep = netdev_priv(dev);
 	struct netdev_hw_addr *ha;
 	u8 new_mconfig = qep->mconfig;
-	char *addrs;
 	int i;
 	u32 crc;
 
@@ -651,11 +650,7 @@ static void qe_set_multicast(struct net_device *dev)
 
 		memset(hash_table, 0, sizeof(hash_table));
 		netdev_for_each_mc_addr(ha, dev) {
-			addrs = ha->addr;
-
-			if (!(*addrs & 1))
-				continue;
-			crc = ether_crc_le(6, addrs);
+			crc = ether_crc_le(6, ha->addr);
 			crc >>= 26;
 			hash_table[crc >> 4] |= 1 << (crc & 0xf);
 		}
-- 
1.7.5.4

