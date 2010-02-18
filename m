From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] net: convert multiple drivers to use
 netdev_for_each_mc_addr, part2
Date: Thu, 18 Feb 2010 11:42:54 +0100
Message-ID: <20100218104253.GE2772@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34467 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751912Ab0BRKm7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2010 05:42:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/s2io.c                  |    5 +++--
 drivers/net/sb1250-mac.c            |    6 +++---
 drivers/net/sc92031.c               |    2 +-
 drivers/net/sfc/efx.c               |    6 ++----
 drivers/net/sis190.c                |    4 +---
 drivers/net/sis900.c                |    5 ++---
 drivers/net/skfp/skfddi.c           |   10 +++-------
 drivers/net/skge.c                  |   10 ++++------
 drivers/net/sky2.c                  |    5 ++---
 drivers/net/smsc9420.c              |    5 ++---
 drivers/net/sonic.c                 |    7 ++++---
 drivers/net/spider_net.c            |    2 +-
 drivers/net/starfire.c              |    4 ++--
 drivers/net/stmmac/dwmac100.c       |    4 +---
 drivers/net/stmmac/dwmac1000_core.c |    4 +---
 drivers/net/sun3_82586.c            |    8 +++++---
 drivers/net/sunbmac.c               |    5 ++---
 drivers/net/sundance.c              |    3 +--
 drivers/net/sungem.c                |   10 +++-------
 drivers/net/sunhme.c                |   20 ++++++--------------
 drivers/net/sunlance.c              |    6 ++----
 drivers/net/sunqe.c                 |    9 +++------
 drivers/net/sunvnet.c               |    2 +-
 23 files changed, 55 insertions(+), 87 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 102be16..43bc66a 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -5092,8 +5092,8 @@ static void s2io_set_multicast(struct net_device *dev)
 		}
 
 		/* Create the new Rx filter list and update the same in H/W. */
-		for (i = 0, mclist = dev->mc_list; i < netdev_mc_count(dev);
-		     i++, mclist = mclist->next) {
+		i = 0;
+		netdev_for_each_mc_addr(mclist, dev) {
 			memcpy(sp->usr_addrs[i].addr, mclist->dmi_addr,
 			       ETH_ALEN);
 			mac_addr = 0;
@@ -5121,6 +5121,7 @@ static void s2io_set_multicast(struct net_device *dev)
 					  dev->name);
 				return;
 			}
+			i++;
 		}
 	}
 }
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 564d4d7..9944e5d 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2161,13 +2161,13 @@ static void sbmac_setmulti(struct sbmac_softc *sc)
 	 * XXX if the table overflows */
 
 	idx = 1;		/* skip station address */
-	mclist = dev->mc_list;
-	while (mclist && (idx < MAC_ADDR_COUNT)) {
+	netdev_for_each_mc_addr(mclist, dev) {
+		if (idx == MAC_ADDR_COUNT)
+			break;
 		reg = sbmac_addr2reg(mclist->dmi_addr);
 		port = sc->sbm_base + R_MAC_ADDR_BASE+(idx * sizeof(uint64_t));
 		__raw_writeq(reg, port);
 		idx++;
-		mclist = mclist->next;
 	}
 
 	/*
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index 00ff899..d87c478 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -435,7 +435,7 @@ static void _sc92031_set_mar(struct net_device *dev)
 	else if (dev->flags & IFF_MULTICAST) {
 		struct dev_mc_list *mc_list;
 
-		for (mc_list = dev->mc_list; mc_list; mc_list = mc_list->next) {
+		netdev_for_each_mc_addr(mc_list, dev) {
 			u32 crc;
 			unsigned bit = 0;
 
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index dc58d9f..88f2fb1 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1602,11 +1602,10 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
 static void efx_set_multicast_list(struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	struct dev_mc_list *mc_list = net_dev->mc_list;
+	struct dev_mc_list *mc_list;
 	union efx_multicast_hash *mc_hash = &efx->multicast_hash;
 	u32 crc;
 	int bit;
-	int i;
 
 	efx->promiscuous = !!(net_dev->flags & IFF_PROMISC);
 
@@ -1615,11 +1614,10 @@ static void efx_set_multicast_list(struct net_device *net_dev)
 		memset(mc_hash, 0xff, sizeof(*mc_hash));
 	} else {
 		memset(mc_hash, 0x00, sizeof(*mc_hash));
-		for (i = 0; i < netdev_mc_count(net_dev); i++) {
+		netdev_for_each_mc_addr(mc_list, net_dev) {
 			crc = ether_crc_le(ETH_ALEN, mc_list->dmi_addr);
 			bit = crc & (EFX_MCAST_HASH_ENTRIES - 1);
 			set_bit_le(bit, mc_hash->byte);
-			mc_list = mc_list->next;
 		}
 
 		/* Broadcast packets go through the multicast hash filter.
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index bf2ffbb..ead1d31 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -849,12 +849,10 @@ static void sis190_set_rx_mode(struct net_device *dev)
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
 	} else {
 		struct dev_mc_list *mclist;
-		unsigned int i;
 
 		rx_mode = AcceptBroadcast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0;
-		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
-		     i++, mclist = mclist->next) {
+		netdev_for_each_mc_addr(mclist, dev) {
 			int bit_nr =
 				ether_crc(ETH_ALEN, mclist->dmi_addr) & 0x3f;
 			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index 32ae87c..cc0c731 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -2300,9 +2300,8 @@ static void set_rx_mode(struct net_device *net_dev)
 		 * packets */
 		struct dev_mc_list *mclist;
 		rx_mode = RFAAB;
-		for (i = 0, mclist = net_dev->mc_list;
-			mclist && i < netdev_mc_count(net_dev);
-			i++, mclist = mclist->next) {
+
+		netdev_for_each_mc_addr(mclist, net_dev) {
 			unsigned int bit_nr =
 				sis900_mcast_bitnr(mclist->dmi_addr, sis_priv->chipset_rev);
 			mc_filter[bit_nr >> 4] |= (1 << (bit_nr & 0xf));
diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index 346adfa..1921a54 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -852,8 +852,7 @@ static void skfp_ctl_set_multicast_list(struct net_device *dev)
 static void skfp_ctl_set_multicast_list_wo_lock(struct net_device *dev)
 {
 	struct s_smc *smc = netdev_priv(dev);
-	struct dev_mc_list *dmi;	/* ptr to multicast addr entry */
-	int i;
+	struct dev_mc_list *dmi;
 
 	/* Enable promiscuous mode, if necessary */
 	if (dev->flags & IFF_PROMISC) {
@@ -877,17 +876,14 @@ static void skfp_ctl_set_multicast_list_wo_lock(struct net_device *dev)
 				/* use exact filtering */
 
 				// point to first multicast addr
-				dmi = dev->mc_list;
-
-				for (i = 0; i < netdev_mc_count(dev); i++) {
+				netdev_for_each_mc_addr(dmi, dev) {
 					mac_add_multicast(smc, 
 							  (struct fddi_addr *)dmi->dmi_addr, 
 							  1);
 
 					pr_debug(KERN_INFO "ENABLE MC ADDRESS: %pMF\n",
 						dmi->dmi_addr);
-					dmi = dmi->next;
-				}	// for
+				}
 
 			} else {	// more MC addresses than HW supports
 
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 720af1c..d0058e5 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2917,8 +2917,7 @@ static void genesis_set_multicast(struct net_device *dev)
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
-	int i, count = netdev_mc_count(dev);
-	struct dev_mc_list *list = dev->mc_list;
+	struct dev_mc_list *list;
 	u32 mode;
 	u8 filter[8];
 
@@ -2938,7 +2937,7 @@ static void genesis_set_multicast(struct net_device *dev)
 		    skge->flow_status == FLOW_STAT_SYMMETRIC)
 			genesis_add_filter(filter, pause_mc_addr);
 
-		for (i = 0; list && i < count; i++, list = list->next)
+		netdev_for_each_mc_addr(list, dev)
 			genesis_add_filter(filter, list->dmi_addr);
 	}
 
@@ -2957,7 +2956,7 @@ static void yukon_set_multicast(struct net_device *dev)
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
-	struct dev_mc_list *list = dev->mc_list;
+	struct dev_mc_list *list;
 	int rx_pause = (skge->flow_status == FLOW_STAT_REM_SEND ||
 			skge->flow_status == FLOW_STAT_SYMMETRIC);
 	u16 reg;
@@ -2975,13 +2974,12 @@ static void yukon_set_multicast(struct net_device *dev)
 	else if (netdev_mc_empty(dev) && !rx_pause)/* no multicast */
 		reg &= ~GM_RXCR_MCF_ENA;
 	else {
-		int i;
 		reg |= GM_RXCR_MCF_ENA;
 
 		if (rx_pause)
 			yukon_add_filter(filter, pause_mc_addr);
 
-		for (i = 0; list && i < netdev_mc_count(dev); i++, list = list->next)
+		netdev_for_each_mc_addr(list, dev)
 			yukon_add_filter(filter, list->dmi_addr);
 	}
 
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index d1e98e2..653bdd7 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3621,7 +3621,7 @@ static void sky2_set_multicast(struct net_device *dev)
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
-	struct dev_mc_list *list = dev->mc_list;
+	struct dev_mc_list *list;
 	u16 reg;
 	u8 filter[8];
 	int rx_pause;
@@ -3640,13 +3640,12 @@ static void sky2_set_multicast(struct net_device *dev)
 	else if (netdev_mc_empty(dev) && !rx_pause)
 		reg &= ~GM_RXCR_MCF_ENA;
 	else {
-		int i;
 		reg |= GM_RXCR_MCF_ENA;
 
 		if (rx_pause)
 			sky2_add_filter(filter, pause_mc_addr);
 
-		for (i = 0; list && i < netdev_mc_count(dev); i++, list = list->next)
+		netdev_for_each_mc_addr(list, dev)
 			sky2_add_filter(filter, list->dmi_addr);
 	}
 
diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index 2bd3c98..30110a1 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -1063,11 +1063,11 @@ static void smsc9420_set_multicast_list(struct net_device *dev)
 		mac_cr |= MAC_CR_MCPAS_;
 		mac_cr &= (~MAC_CR_HPFILT_);
 	} else if (!netdev_mc_empty(dev)) {
-		struct dev_mc_list *mc_list = dev->mc_list;
+		struct dev_mc_list *mc_list;
 		u32 hash_lo = 0, hash_hi = 0;
 
 		smsc_dbg(HW, "Multicast filter enabled");
-		while (mc_list) {
+		netdev_for_each_mc_addr(mc_list, dev) {
 			u32 bit_num = smsc9420_hash(mc_list->dmi_addr);
 			u32 mask = 1 << (bit_num & 0x1F);
 
@@ -1076,7 +1076,6 @@ static void smsc9420_set_multicast_list(struct net_device *dev)
 			else
 				hash_lo |= mask;
 
-			mc_list = mc_list->next;
 		}
 		smsc9420_reg_write(pd, HASHH, hash_hi);
 		smsc9420_reg_write(pd, HASHL, hash_lo);
diff --git a/drivers/net/sonic.c b/drivers/net/sonic.c
index bd8bc66..287c251 100644
--- a/drivers/net/sonic.c
+++ b/drivers/net/sonic.c
@@ -531,7 +531,7 @@ static void sonic_multicast_list(struct net_device *dev)
 {
 	struct sonic_local *lp = netdev_priv(dev);
 	unsigned int rcr;
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 	unsigned char *addr;
 	int i;
 
@@ -549,13 +549,14 @@ static void sonic_multicast_list(struct net_device *dev)
 				printk("sonic_multicast_list: mc_count %d\n",
 				       netdev_mc_count(dev));
 			sonic_set_cam_enable(dev, 1);  /* always enable our own address */
-			for (i = 1; i <= netdev_mc_count(dev); i++) {
+			i = 1;
+			netdev_for_each_mc_addr(dmi, dev) {
 				addr = dmi->dmi_addr;
-				dmi = dmi->next;
 				sonic_cda_put(dev, i, SONIC_CD_CAP0, addr[1] << 8 | addr[0]);
 				sonic_cda_put(dev, i, SONIC_CD_CAP1, addr[3] << 8 | addr[2]);
 				sonic_cda_put(dev, i, SONIC_CD_CAP2, addr[5] << 8 | addr[4]);
 				sonic_set_cam_enable(dev, sonic_get_cam_enable(dev) | (1 << i));
+				i++;
 			}
 			SONIC_WRITE(SONIC_CDC, 16);
 			/* issue Load CAM command */
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 1619199..2f8a8c3 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -646,7 +646,7 @@ spider_net_set_multi(struct net_device *netdev)
 	hash = spider_net_get_multicast_hash(netdev, netdev->broadcast); */
 	set_bit(0xfd, bitmask);
 
-	for (mc = netdev->mc_list; mc; mc = mc->next) {
+	netdev_for_each_mc_addr(mc, netdev) {
 		hash = spider_net_get_multicast_hash(netdev, mc->dmi_addr);
 		set_bit(hash, bitmask);
 	}
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 58bc7ac..0f405ef 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1804,14 +1804,14 @@ static void set_rx_mode(struct net_device *dev)
 		/* Use the 16 element perfect filter, skip first two entries. */
 		void __iomem *filter_addr = ioaddr + PerfFilterTable + 2 * 16;
 		__be16 *eaddrs;
-		for (i = 2, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev) + 2;
-		     i++, mclist = mclist->next) {
+		netdev_for_each_mc_addr(mclist, dev) {
 			eaddrs = (__be16 *)mclist->dmi_addr;
 			writew(be16_to_cpu(eaddrs[2]), filter_addr); filter_addr += 4;
 			writew(be16_to_cpu(eaddrs[1]), filter_addr); filter_addr += 4;
 			writew(be16_to_cpu(eaddrs[0]), filter_addr); filter_addr += 8;
 		}
 		eaddrs = (__be16 *)dev->dev_addr;
+		i = netdev_mc_count(dev) + 2;
 		while (i++ < 16) {
 			writew(be16_to_cpu(eaddrs[0]), filter_addr); filter_addr += 4;
 			writew(be16_to_cpu(eaddrs[1]), filter_addr); filter_addr += 4;
diff --git a/drivers/net/stmmac/dwmac100.c b/drivers/net/stmmac/dwmac100.c
index 576b256..803b037 100644
--- a/drivers/net/stmmac/dwmac100.c
+++ b/drivers/net/stmmac/dwmac100.c
@@ -315,7 +315,6 @@ static void dwmac100_set_filter(struct net_device *dev)
 		value &= ~(MAC_CONTROL_PM | MAC_CONTROL_PR | MAC_CONTROL_IF |
 			   MAC_CONTROL_HO | MAC_CONTROL_HP);
 	} else {
-		int i;
 		u32 mc_filter[2];
 		struct dev_mc_list *mclist;
 
@@ -326,8 +325,7 @@ static void dwmac100_set_filter(struct net_device *dev)
 			   MAC_CONTROL_IF | MAC_CONTROL_HO);
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list;
-		     mclist && i < netdev_mc_count(dev); i++, mclist = mclist->next) {
+		netdev_for_each_mc_addr(mclist, dev) {
 			/* The upper 6 bits of the calculated CRC are used to
 			 * index the contens of the hash table */
 			int bit_nr =
diff --git a/drivers/net/stmmac/dwmac1000_core.c b/drivers/net/stmmac/dwmac1000_core.c
index 90dbb4f..a6538ae 100644
--- a/drivers/net/stmmac/dwmac1000_core.c
+++ b/drivers/net/stmmac/dwmac1000_core.c
@@ -93,7 +93,6 @@ static void dwmac1000_set_filter(struct net_device *dev)
 		writel(0xffffffff, ioaddr + GMAC_HASH_HIGH);
 		writel(0xffffffff, ioaddr + GMAC_HASH_LOW);
 	} else if (!netdev_mc_empty(dev)) {
-		int i;
 		u32 mc_filter[2];
 		struct dev_mc_list *mclist;
 
@@ -101,8 +100,7 @@ static void dwmac1000_set_filter(struct net_device *dev)
 		value = GMAC_FRAME_FILTER_HMC;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list;
-		     mclist && i < netdev_mc_count(dev); i++, mclist = mclist->next) {
+		netdev_for_each_mc_addr(mclist, dev) {
 			/* The upper 6 bits of the calculated CRC are used to
 			   index the contens of the hash table */
 			int bit_nr =
diff --git a/drivers/net/sun3_82586.c b/drivers/net/sun3_82586.c
index efedc25..2f6a760 100644
--- a/drivers/net/sun3_82586.c
+++ b/drivers/net/sun3_82586.c
@@ -413,7 +413,7 @@ static int init586(struct net_device *dev)
 	volatile struct iasetup_cmd_struct *ias_cmd;
 	volatile struct tdr_cmd_struct *tdr_cmd;
 	volatile struct mcsetup_cmd_struct *mc_cmd;
-	struct dev_mc_list *dmi=dev->mc_list;
+	struct dev_mc_list *dmi;
 	int num_addrs=netdev_mc_count(dev);
 
 	ptr = (void *) ((char *)p->scb + sizeof(struct scb_struct));
@@ -536,8 +536,10 @@ static int init586(struct net_device *dev)
 		mc_cmd->cmd_link = 0xffff;
 		mc_cmd->mc_cnt = swab16(num_addrs * 6);
 
-		for(i=0;i<num_addrs;i++,dmi=dmi->next)
-			memcpy((char *) mc_cmd->mc_list[i], dmi->dmi_addr,6);
+		i = 0;
+		netdev_for_each_mc_addr(dmi, dev)
+			memcpy((char *) mc_cmd->mc_list[i++],
+			       dmi->dmi_addr, ETH_ALEN);
 
 		p->scb->cbl_offset = make16(mc_cmd);
 		p->scb->cmd_cuc = CUC_START;
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index dfea56f..a0bd361 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -999,7 +999,7 @@ static void bigmac_set_multicast(struct net_device *dev)
 {
 	struct bigmac *bp = netdev_priv(dev);
 	void __iomem *bregs = bp->bregs;
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 	char *addrs;
 	int i;
 	u32 tmp, crc;
@@ -1028,9 +1028,8 @@ static void bigmac_set_multicast(struct net_device *dev)
 		for (i = 0; i < 4; i++)
 			hash_table[i] = 0;
 
-		for (i = 0; i < netdev_mc_count(dev); i++) {
+		netdev_for_each_mc_addr(dmi, dev) {
 			addrs = dmi->dmi_addr;
-			dmi = dmi->next;
 
 			if (!(*addrs & 1))
 				continue;
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 4171259..a855934 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -1528,8 +1528,7 @@ static void set_rx_mode(struct net_device *dev)
 		int index;
 		int crc;
 		memset (mc_filter, 0, sizeof (mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
-		     i++, mclist = mclist->next) {
+		netdev_for_each_mc_addr(mclist, dev) {
 			crc = ether_crc_le (ETH_ALEN, mclist->dmi_addr);
 			for (index=0, bit=0; bit < 6; bit++, crc <<= 1)
 				if (crc & 0x80000000) index |= 1 << bit;
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index d497ec0..4344017 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -1846,17 +1846,13 @@ static u32 gem_setup_multicast(struct gem *gp)
 	} else {
 		u16 hash_table[16];
 		u32 crc;
-		struct dev_mc_list *dmi = gp->dev->mc_list;
+		struct dev_mc_list *dmi;
 		int i;
 
-		for (i = 0; i < 16; i++)
-			hash_table[i] = 0;
-
-		for (i = 0; i < netdev_mc_count(gp->dev); i++) {
+		memset(hash_table, 0, sizeof(hash_table));
+		netdev_for_each_mc_addr(dmi, gp->dev) {
 			char *addrs = dmi->dmi_addr;
 
-			dmi = dmi->next;
-
 			if (!(*addrs & 1))
 				continue;
 
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 905df35..b17dbb1 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -1523,17 +1523,13 @@ static int happy_meal_init(struct happy_meal *hp)
 		hme_write32(hp, bregs + BMAC_HTABLE3, 0xffff);
 	} else if ((hp->dev->flags & IFF_PROMISC) == 0) {
 		u16 hash_table[4];
-		struct dev_mc_list *dmi = hp->dev->mc_list;
+		struct dev_mc_list *dmi;
 		char *addrs;
-		int i;
 		u32 crc;
 
-		for (i = 0; i < 4; i++)
-			hash_table[i] = 0;
-
-		for (i = 0; i < netdev_mc_count(hp->dev); i++) {
+		memset(hash_table, 0, sizeof(hash_table));
+		netdev_for_each_mc_addr(dmi, hp->dev) {
 			addrs = dmi->dmi_addr;
-			dmi = dmi->next;
 
 			if (!(*addrs & 1))
 				continue;
@@ -2366,9 +2362,8 @@ static void happy_meal_set_multicast(struct net_device *dev)
 {
 	struct happy_meal *hp = netdev_priv(dev);
 	void __iomem *bregs = hp->bigmacregs;
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 	char *addrs;
-	int i;
 	u32 crc;
 
 	spin_lock_irq(&hp->happy_lock);
@@ -2384,12 +2379,9 @@ static void happy_meal_set_multicast(struct net_device *dev)
 	} else {
 		u16 hash_table[4];
 
-		for (i = 0; i < 4; i++)
-			hash_table[i] = 0;
-
-		for (i = 0; i < netdev_mc_count(dev); i++) {
+		memset(hash_table, 0, sizeof(hash_table));
+		netdev_for_each_mc_addr(dmi, dev) {
 			addrs = dmi->dmi_addr;
-			dmi = dmi->next;
 
 			if (!(*addrs & 1))
 				continue;
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index cf9d5bb..d7c73f4 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -1170,9 +1170,8 @@ static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 static void lance_load_multicast(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 	char *addrs;
-	int i;
 	u32 crc;
 	u32 val;
 
@@ -1196,9 +1195,8 @@ static void lance_load_multicast(struct net_device *dev)
 		return;
 
 	/* Add addresses */
-	for (i = 0; i < netdev_mc_count(dev); i++) {
+	netdev_for_each_mc_addr(dmi, dev) {
 		addrs = dmi->dmi_addr;
-		dmi   = dmi->next;
 
 		/* multicast address? */
 		if (!(*addrs & 1))
diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index 3bc35d8..be637dc 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -627,7 +627,7 @@ static int qe_start_xmit(struct sk_buff *skb, struct net_device *dev)
 static void qe_set_multicast(struct net_device *dev)
 {
 	struct sunqe *qep = netdev_priv(dev);
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 	u8 new_mconfig = qep->mconfig;
 	char *addrs;
 	int i;
@@ -650,12 +650,9 @@ static void qe_set_multicast(struct net_device *dev)
 		u16 hash_table[4];
 		u8 *hbytes = (unsigned char *) &hash_table[0];
 
-		for (i = 0; i < 4; i++)
-			hash_table[i] = 0;
-
-		for (i = 0; i < netdev_mc_count(dev); i++) {
+		memset(hash_table, 0, sizeof(hash_table));
+		netdev_for_each_mc_addr(dmi, dev) {
 			addrs = dmi->dmi_addr;
-			dmi = dmi->next;
 
 			if (!(*addrs & 1))
 				continue;
diff --git a/drivers/net/sunvnet.c b/drivers/net/sunvnet.c
index d65764e..6b1b7ce 100644
--- a/drivers/net/sunvnet.c
+++ b/drivers/net/sunvnet.c
@@ -765,7 +765,7 @@ static void __update_mc_list(struct vnet *vp, struct net_device *dev)
 {
 	struct dev_addr_list *p;
 
-	for (p = dev->mc_list; p; p = p->next) {
+	netdev_for_each_mc_addr(p, dev) {
 		struct vnet_mcast_entry *m;
 
 		m = __vnet_mc_find(vp, p->dmi_addr);
-- 
1.6.6

