From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] net: convert multiple drivers to use
 netdev_for_each_mc_addr, part4
Date: Mon, 22 Feb 2010 20:22:26 +0100
Message-ID: <20100222192225.GD4141@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3439 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752948Ab0BVTW2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2010 14:22:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/davinci_emac.c     |    5 ++---
 drivers/net/e100.c             |   10 +++++++---
 drivers/net/eepro.c            |    8 +++-----
 drivers/net/eexpress.c         |   16 ++++++----------
 drivers/net/ehea/ehea_main.c   |    5 ++---
 drivers/net/enic/enic_main.c   |   10 ++++++----
 drivers/net/epic100.c          |    3 +--
 drivers/net/ethoc.c            |    6 +++---
 drivers/net/ewrk3.c            |    5 ++---
 drivers/net/fealnx.c           |    4 +---
 drivers/net/fec.c              |    6 ++----
 drivers/net/fec_mpc52xx.c      |    5 +----
 drivers/net/forcedeth.c        |    6 ++----
 drivers/net/fs_enet/mac-fcc.c  |    2 +-
 drivers/net/fs_enet/mac-fec.c  |    2 +-
 drivers/net/fs_enet/mac-scc.c  |    2 +-
 drivers/net/gianfar.c          |    2 +-
 drivers/net/hamachi.c          |    7 ++++---
 drivers/net/hp100.c            |    6 +++---
 drivers/net/ibm_newemac/core.c |    2 +-
 drivers/net/ibmlana.c          |    2 +-
 drivers/net/ibmveth.c          |    5 ++---
 drivers/net/igb/igb_main.c     |   12 ++++--------
 drivers/net/igbvf/netdev.c     |   12 +++---------
 drivers/net/ioc3-eth.c         |    6 ++----
 drivers/net/ipg.c              |    3 +--
 drivers/net/isa-skeleton.c     |    2 +-
 drivers/net/iseries_veth.c     |    6 ++----
 drivers/net/ixgb/ixgb_main.c   |    7 +++----
 29 files changed, 69 insertions(+), 98 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index d1e03b5..3f5db83 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -965,10 +965,9 @@ static void emac_dev_mcast_set(struct net_device *ndev)
 			mbp_enable = (mbp_enable | EMAC_MBP_RXMCAST);
 			emac_add_mcast(priv, EMAC_ALL_MULTI_CLR, NULL);
 			/* program multicast address list into EMAC hardware */
-			for (mc_ptr = ndev->mc_list; mc_ptr;
-			     mc_ptr = mc_ptr->next) {
+			netdev_for_each_mc_addr(mc_ptr, ndev) {
 				emac_add_mcast(priv, EMAC_MULTICAST_ADD,
-					       (u8 *)mc_ptr->dmi_addr);
+					       (u8 *) mc_ptr->dmi_addr);
 			}
 		} else {
 			mbp_enable = (mbp_enable & ~EMAC_MBP_RXMCAST);
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index e8c0e82..a26ccab 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1537,14 +1537,18 @@ static int e100_hw_init(struct nic *nic)
 static void e100_multi(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 {
 	struct net_device *netdev = nic->netdev;
-	struct dev_mc_list *list = netdev->mc_list;
+	struct dev_mc_list *list;
 	u16 i, count = min(netdev_mc_count(netdev), E100_MAX_MULTICAST_ADDRS);
 
 	cb->command = cpu_to_le16(cb_multi);
 	cb->u.multi.count = cpu_to_le16(count * ETH_ALEN);
-	for (i = 0; list && i < count; i++, list = list->next)
-		memcpy(&cb->u.multi.addr[i*ETH_ALEN], &list->dmi_addr,
+	i = 0;
+	netdev_for_each_mc_addr(list, netdev) {
+		if (i == count)
+			break;
+		memcpy(&cb->u.multi.addr[i++ * ETH_ALEN], &list->dmi_addr,
 			ETH_ALEN);
+	}
 }
 
 static void e100_set_multicast_list(struct net_device *netdev)
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index 5f73ab2..1b05bdf 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -1287,7 +1287,7 @@ set_multicast_list(struct net_device *dev)
 	struct eepro_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 	unsigned short mode;
-	struct dev_mc_list *dmi=dev->mc_list;
+	struct dev_mc_list *dmi;
 	int mc_count = netdev_mc_count(dev);
 
 	if (dev->flags&(IFF_ALLMULTI|IFF_PROMISC) || mc_count > 63)
@@ -1332,10 +1332,8 @@ set_multicast_list(struct net_device *dev)
 		outw(0, ioaddr + IO_PORT);
 		outw(6 * (mc_count + 1), ioaddr + IO_PORT);
 
-		for (i = 0; i < mc_count; i++)
-		{
-			eaddrs=(unsigned short *)dmi->dmi_addr;
-			dmi=dmi->next;
+		netdev_for_each_mc_addr(dmi, dev) {
+			eaddrs = (unsigned short *) dmi->dmi_addr;
 			outw(*eaddrs++, ioaddr + IO_PORT);
 			outw(*eaddrs++, ioaddr + IO_PORT);
 			outw(*eaddrs++, ioaddr + IO_PORT);
diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index d804ff1..7013dc8 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -1588,23 +1588,19 @@ static void eexp_setup_filter(struct net_device *dev)
 
 	outw(CONF_NR_MULTICAST & ~31, ioaddr+SM_PTR);
 	outw(6*count, ioaddr+SHADOW(CONF_NR_MULTICAST));
-	for (i = 0, dmi = dev->mc_list; i < count; i++, dmi = dmi->next) {
-		unsigned short *data;
-		if (!dmi) {
-			printk(KERN_INFO "%s: too few multicast addresses\n", dev->name);
+	i = 0;
+	netdev_for_each_mc_addr(dmi, dev) {
+		unsigned short *data = (unsigned short *) dmi->dmi_addr;
+
+		if (i == count)
 			break;
-		}
-		if (dmi->dmi_addrlen != ETH_ALEN) {
-			printk(KERN_INFO "%s: invalid multicast address length given.\n", dev->name);
-			continue;
-		}
-		data = (unsigned short *)dmi->dmi_addr;
 		outw((CONF_MULTICAST+(6*i)) & ~31, ioaddr+SM_PTR);
 		outw(data[0], ioaddr+SHADOW(CONF_MULTICAST+(6*i)));
 		outw((CONF_MULTICAST+(6*i)+2) & ~31, ioaddr+SM_PTR);
 		outw(data[1], ioaddr+SHADOW(CONF_MULTICAST+(6*i)+2));
 		outw((CONF_MULTICAST+(6*i)+4) & ~31, ioaddr+SM_PTR);
 		outw(data[2], ioaddr+SHADOW(CONF_MULTICAST+(6*i)+4));
+		i++;
 	}
 }
 
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 99e4f83..b004eab 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -1967,7 +1967,7 @@ static void ehea_set_multicast_list(struct net_device *dev)
 {
 	struct ehea_port *port = netdev_priv(dev);
 	struct dev_mc_list *k_mcl_entry;
-	int ret, i;
+	int ret;
 
 	if (dev->flags & IFF_PROMISC) {
 		ehea_promiscuous(dev, 1);
@@ -1997,8 +1997,7 @@ static void ehea_set_multicast_list(struct net_device *dev)
 			goto out;
 		}
 
-		for (i = 0, k_mcl_entry = dev->mc_list; i < netdev_mc_count(dev); i++,
-			     k_mcl_entry = k_mcl_entry->next)
+		netdev_for_each_mc_addr(k_mcl_entry, dev)
 			ehea_add_multicast_entry(port, k_mcl_entry->dmi_addr);
 
 	}
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 94749eb..cf098bb 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -822,7 +822,7 @@ static int enic_set_mac_addr(struct net_device *netdev, char *addr)
 static void enic_set_multicast_list(struct net_device *netdev)
 {
 	struct enic *enic = netdev_priv(netdev);
-	struct dev_mc_list *list = netdev->mc_list;
+	struct dev_mc_list *list;
 	int directed = 1;
 	int multicast = (netdev->flags & IFF_MULTICAST) ? 1 : 0;
 	int broadcast = (netdev->flags & IFF_BROADCAST) ? 1 : 0;
@@ -851,9 +851,11 @@ static void enic_set_multicast_list(struct net_device *netdev)
 	 * look for changes to add/del.
 	 */
 
-	for (i = 0; list && i < mc_count; i++) {
-		memcpy(mc_addr[i], list->dmi_addr, ETH_ALEN);
-		list = list->next;
+	i = 0;
+	netdev_for_each_mc_addr(list, netdev) {
+		if (i == mc_count)
+			break;
+		memcpy(mc_addr[i++], list->dmi_addr, ETH_ALEN);
 	}
 
 	for (i = 0; i < enic->mc_count; i++) {
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 31a3adb..39c271b 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -1403,8 +1403,7 @@ static void set_rx_mode(struct net_device *dev)
 		struct dev_mc_list *mclist;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
-			 i++, mclist = mclist->next) {
+		netdev_for_each_mc_addr(mclist, dev) {
 			unsigned int bit_nr =
 				ether_crc_le(ETH_ALEN, mclist->dmi_addr) & 0x3f;
 			mc_filter[bit_nr >> 3] |= (1 << bit_nr);
diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index f9d5ca0..2097423 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -755,7 +755,7 @@ static void ethoc_set_multicast_list(struct net_device *dev)
 {
 	struct ethoc *priv = netdev_priv(dev);
 	u32 mode = ethoc_read(priv, MODER);
-	struct dev_mc_list *mc = NULL;
+	struct dev_mc_list *mc;
 	u32 hash[2] = { 0, 0 };
 
 	/* set loopback mode if requested */
@@ -783,8 +783,8 @@ static void ethoc_set_multicast_list(struct net_device *dev)
 		hash[0] = 0xffffffff;
 		hash[1] = 0xffffffff;
 	} else {
-		for (mc = dev->mc_list; mc; mc = mc->next) {
-			u32 crc = ether_crc(mc->dmi_addrlen, mc->dmi_addr);
+		netdev_for_each_mc_addr(mc, dev) {
+			u32 crc = ether_crc(ETH_ALEN, mc->dmi_addr);
 			int bit = (crc >> 26) & 0x3f;
 			hash[bit >> 5] |= 1 << (bit & 0x1f);
 		}
diff --git a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
index 96817a8..91e59f3 100644
--- a/drivers/net/ewrk3.c
+++ b/drivers/net/ewrk3.c
@@ -1169,7 +1169,7 @@ static void set_multicast_list(struct net_device *dev)
 static void SetMulticastFilter(struct net_device *dev)
 {
 	struct ewrk3_private *lp = netdev_priv(dev);
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 	u_long iobase = dev->base_addr;
 	int i;
 	char *addrs, bit, byte;
@@ -1213,9 +1213,8 @@ static void SetMulticastFilter(struct net_device *dev)
 		}
 
 		/* Update table */
-		for (i = 0; i < netdev_mc_count(dev); i++) {	/* for each address in the list */
+		netdev_for_each_mc_addr(dmi, dev) {
 			addrs = dmi->dmi_addr;
-			dmi = dmi->next;
 			if ((*addrs & 0x01) == 1) {	/* multicast address? */
 				crc = ether_crc_le(ETH_ALEN, addrs);
 				hashcode = crc & ((1 << 9) - 1);	/* hashcode is 9 LSb of CRC */
diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index f95b5ff..9d5ad08 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -1793,11 +1793,9 @@ static void __set_rx_mode(struct net_device *dev)
 		rx_mode = CR_W_AB | CR_W_AM;
 	} else {
 		struct dev_mc_list *mclist;
-		int i;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
-		     i++, mclist = mclist->next) {
+		netdev_for_each_mc_addr(mclist, dev) {
 			unsigned int bit;
 			bit = (ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26) ^ 0x3F;
 			mc_filter[bit >> 5] |= (1 << bit);
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index d9d14c8..9f98c1c 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1575,7 +1575,7 @@ static void set_multicast_list(struct net_device *dev)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
 	struct dev_mc_list *dmi;
-	unsigned int i, j, bit, data, crc, tmp;
+	unsigned int i, bit, data, crc, tmp;
 	unsigned char hash;
 
 	if (dev->flags & IFF_PROMISC) {
@@ -1604,9 +1604,7 @@ static void set_multicast_list(struct net_device *dev)
 	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
 	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
 
-	dmi = dev->mc_list;
-
-	for (j = 0; j < netdev_mc_count(dev); j++, dmi = dmi->next) {
+	netdev_for_each_mc_addr(dmi, dev) {
 		/* Only support group multicast for now */
 		if (!(dmi->dmi_addr[0] & 1))
 			continue;
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index 10903b7..0dbd721 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -575,19 +575,16 @@ static void mpc52xx_fec_set_multicast_list(struct net_device *dev)
 			out_be32(&fec->gaddr2, 0xffffffff);
 		} else {
 			u32 crc;
-			int i;
 			struct dev_mc_list *dmi;
 			u32 gaddr1 = 0x00000000;
 			u32 gaddr2 = 0x00000000;
 
-			dmi = dev->mc_list;
-			for (i=0; i<netdev_mc_count(dev); i++) {
+			netdev_for_each_mc_addr(dmi, dev) {
 				crc = ether_crc_le(6, dmi->dmi_addr) >> 26;
 				if (crc >= 32)
 					gaddr1 |= 1 << (crc-32);
 				else
 					gaddr2 |= 1 << crc;
-				dmi = dmi->next;
 			}
 			out_be32(&fec->gaddr1, gaddr1);
 			out_be32(&fec->gaddr2, gaddr2);
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 3eb713b..ca05e56 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -3095,7 +3095,7 @@ static void nv_set_multicast(struct net_device *dev)
 	} else {
 		pff |= NVREG_PFF_MYADDR;
 
-		if (dev->flags & IFF_ALLMULTI || dev->mc_list) {
+		if (dev->flags & IFF_ALLMULTI || !netdev_mc_empty(dev)) {
 			u32 alwaysOff[2];
 			u32 alwaysOn[2];
 
@@ -3105,8 +3105,7 @@ static void nv_set_multicast(struct net_device *dev)
 			} else {
 				struct dev_mc_list *walk;
 
-				walk = dev->mc_list;
-				while (walk != NULL) {
+				netdev_for_each_mc_addr(walk, dev) {
 					u32 a, b;
 					a = le32_to_cpu(*(__le32 *) walk->dmi_addr);
 					b = le16_to_cpu(*(__le16 *) (&walk->dmi_addr[4]));
@@ -3114,7 +3113,6 @@ static void nv_set_multicast(struct net_device *dev)
 					alwaysOff[0] &= ~a;
 					alwaysOn[1] &= b;
 					alwaysOff[1] &= ~b;
-					walk = walk->next;
 				}
 			}
 			addr[0] = alwaysOn[0];
diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
index 482f27d..a761d31 100644
--- a/drivers/net/fs_enet/mac-fcc.c
+++ b/drivers/net/fs_enet/mac-fcc.c
@@ -235,7 +235,7 @@ static void set_multicast_list(struct net_device *dev)
 
 	if ((dev->flags & IFF_PROMISC) == 0) {
 		set_multicast_start(dev);
-		for (pmc = dev->mc_list; pmc != NULL; pmc = pmc->next)
+		netdev_for_each_mc_addr(pmc, dev)
 			set_multicast_one(dev, pmc->dmi_addr);
 		set_multicast_finish(dev);
 	} else
diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
index ddf13ef..ca806d1 100644
--- a/drivers/net/fs_enet/mac-fec.c
+++ b/drivers/net/fs_enet/mac-fec.c
@@ -236,7 +236,7 @@ static void set_multicast_list(struct net_device *dev)
 
 	if ((dev->flags & IFF_PROMISC) == 0) {
 		set_multicast_start(dev);
-		for (pmc = dev->mc_list; pmc != NULL; pmc = pmc->next)
+		netdev_for_each_mc_addr(pmc, dev)
 			set_multicast_one(dev, pmc->dmi_addr);
 		set_multicast_finish(dev);
 	} else
diff --git a/drivers/net/fs_enet/mac-scc.c b/drivers/net/fs_enet/mac-scc.c
index 141dbc9..5bfc99b 100644
--- a/drivers/net/fs_enet/mac-scc.c
+++ b/drivers/net/fs_enet/mac-scc.c
@@ -228,7 +228,7 @@ static void set_multicast_list(struct net_device *dev)
 
 	if ((dev->flags & IFF_PROMISC) == 0) {
 		set_multicast_start(dev);
-		for (pmc = dev->mc_list; pmc != NULL; pmc = pmc->next)
+		netdev_for_each_mc_addr(pmc, dev)
 			set_multicast_one(dev, pmc->dmi_addr);
 		set_multicast_finish(dev);
 	} else
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index c9be090..6aa526e 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2867,7 +2867,7 @@ static void gfar_set_multi(struct net_device *dev)
 			return;
 
 		/* Parse the list, and set the appropriate bits */
-		for(mc_ptr = dev->mc_list; mc_ptr; mc_ptr = mc_ptr->next) {
+		netdev_for_each_mc_addr(mc_ptr, dev) {
 			if (idx < em_num) {
 				gfar_set_mac_for_addr(dev, idx,
 						mc_ptr->dmi_addr);
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index c70b147..373546d 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -1859,12 +1859,13 @@ static void set_rx_mode(struct net_device *dev)
 		writew(0x000B, ioaddr + AddrMode);
 	} else if (!netdev_mc_empty(dev)) { /* Must use the CAM filter. */
 		struct dev_mc_list *mclist;
-		int i;
-		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
-			 i++, mclist = mclist->next) {
+		int i = 0;
+
+		netdev_for_each_mc_addr(mclist, dev) {
 			writel(*(u32*)(mclist->dmi_addr), ioaddr + 0x100 + i*8);
 			writel(0x20000 | (*(u16*)&mclist->dmi_addr[4]),
 				   ioaddr + 0x104 + i*8);
+			i++;
 		}
 		/* Clear remaining entries. */
 		for (; i < 64; i++)
diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index debac1b..b766a69 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -2098,7 +2098,7 @@ static void hp100_set_multicast_list(struct net_device *dev)
 			/* set hash filter to receive all multicast packets */
 			memset(&lp->hash_bytes, 0xff, 8);
 		} else {
-			int i, j, idx;
+			int i, idx;
 			u_char *addrs;
 			struct dev_mc_list *dmi;
 
@@ -2107,14 +2107,14 @@ static void hp100_set_multicast_list(struct net_device *dev)
 			printk("hp100: %s: computing hash filter - mc_count = %i\n",
 			       dev->name, netdev_mc_count(dev));
 #endif
-			for (i = 0, dmi = dev->mc_list; i < netdev_mc_count(dev); i++, dmi = dmi->next) {
+			netdev_for_each_mc_addr(dmi, dev) {
 				addrs = dmi->dmi_addr;
 				if ((*addrs & 0x01) == 0x01) {	/* multicast address? */
 #ifdef HP100_DEBUG
 					printk("hp100: %s: multicast = %pM, ",
 						     dev->name, addrs);
 #endif
-					for (j = idx = 0; j < 6; j++) {
+					for (i = idx = 0; i < 6; i++) {
 						idx ^= *addrs++ & 0x3f;
 						printk(":%02x:", idx);
 					}
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index b75d27e..fb0ac6d 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -395,7 +395,7 @@ static void emac_hash_mc(struct emac_instance *dev)
 
 	memset(gaht_temp, 0, sizeof (gaht_temp));
 
-	for (dmi = dev->ndev->mc_list; dmi; dmi = dmi->next) {
+	netdev_for_each_mc_addr(dmi, dev->ndev) {
 		int slot, reg, mask;
 		DBG2(dev, "mc %pM" NL, dmi->dmi_addr);
 
diff --git a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
index 052c740..b5d0f4e 100644
--- a/drivers/net/ibmlana.c
+++ b/drivers/net/ibmlana.c
@@ -420,7 +420,7 @@ static void InitBoard(struct net_device *dev)
 	/* start putting the multicast addresses into the CAM list.  Stop if
 	   it is full. */
 
-	for (mcptr = dev->mc_list; mcptr != NULL; mcptr = mcptr->next) {
+	netdev_for_each_mc_addr(mcptr, dev) {
 		putcam(cams, &camcnt, mcptr->dmi_addr);
 		if (camcnt == 16)
 			break;
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 41b9c0e..f2b9379 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1072,8 +1072,7 @@ static void ibmveth_set_multicast_list(struct net_device *netdev)
 			ibmveth_error_printk("h_multicast_ctrl rc=%ld when entering promisc mode\n", lpar_rc);
 		}
 	} else {
-		struct dev_mc_list *mclist = netdev->mc_list;
-		int i;
+		struct dev_mc_list *mclist;
 		/* clear the filter table & disable filtering */
 		lpar_rc = h_multicast_ctrl(adapter->vdev->unit_address,
 					   IbmVethMcastEnableRecv |
@@ -1084,7 +1083,7 @@ static void ibmveth_set_multicast_list(struct net_device *netdev)
 			ibmveth_error_printk("h_multicast_ctrl rc=%ld when attempting to clear filter table\n", lpar_rc);
 		}
 		/* add the addresses to the filter table */
-		for(i = 0; i < netdev_mc_count(netdev); ++i, mclist = mclist->next) {
+		netdev_for_each_mc_addr(mclist, netdev) {
 			// add the multicast address to the filter table
 			unsigned long mcast_addr = 0;
 			memcpy(((char *)&mcast_addr)+2, mclist->dmi_addr, 6);
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index f588e49..583a21c 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2877,7 +2877,7 @@ static int igb_write_mc_addr_list(struct net_device *netdev)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	struct dev_mc_list *mc_ptr = netdev->mc_list;
+	struct dev_mc_list *mc_ptr;
 	u8  *mta_list;
 	int i;
 
@@ -2893,14 +2893,10 @@ static int igb_write_mc_addr_list(struct net_device *netdev)
 		return -ENOMEM;
 
 	/* The shared function expects a packed array of only addresses. */
-	mc_ptr = netdev->mc_list;
+	i = 0;
+	netdev_for_each_mc_addr(mc_ptr, netdev)
+		memcpy(mta_list + (i++ * ETH_ALEN), mc_ptr->dmi_addr, ETH_ALEN);
 
-	for (i = 0; i < netdev_mc_count(netdev); i++) {
-		if (!mc_ptr)
-			break;
-		memcpy(mta_list + (i*ETH_ALEN), mc_ptr->dmi_addr, ETH_ALEN);
-		mc_ptr = mc_ptr->next;
-	}
 	igb_update_mc_addr_list(hw, mta_list, i);
 	kfree(mta_list);
 
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 6029c40..a77afd8 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -1413,15 +1413,9 @@ static void igbvf_set_multi(struct net_device *netdev)
 	}
 
 	/* prepare a packed array of only addresses. */
-	mc_ptr = netdev->mc_list;
-
-	for (i = 0; i < netdev_mc_count(netdev); i++) {
-		if (!mc_ptr)
-			break;
-		memcpy(mta_list + (i*ETH_ALEN), mc_ptr->dmi_addr,
-		       ETH_ALEN);
-		mc_ptr = mc_ptr->next;
-	}
+	i = 0;
+	netdev_for_each_mc_addr(mc_ptr, netdev)
+		memcpy(mta_list + (i++ * ETH_ALEN), mc_ptr->dmi_addr, ETH_ALEN);
 
 	hw->mac.ops.update_mc_addr_list(hw, mta_list, i, 0, 0);
 	kfree(mta_list);
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index 0bd5fef..70871b9 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -1664,11 +1664,10 @@ static int ioc3_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 static void ioc3_set_multicast_list(struct net_device *dev)
 {
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 	struct ioc3_private *ip = netdev_priv(dev);
 	struct ioc3 *ioc3 = ip->regs;
 	u64 ehar = 0;
-	int i;
 
 	netif_stop_queue(dev);				/* Lock out others. */
 
@@ -1689,9 +1688,8 @@ static void ioc3_set_multicast_list(struct net_device *dev)
 			ip->ehar_h = 0xffffffff;
 			ip->ehar_l = 0xffffffff;
 		} else {
-			for (i = 0; i < netdev_mc_count(dev); i++) {
+			netdev_for_each_mc_addr(dmi, dev) {
 				char *addr = dmi->dmi_addr;
-				dmi = dmi->next;
 
 				if (!(*addr & 1))
 					continue;
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index 3ca49e3..150415e 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -608,8 +608,7 @@ static void ipg_nic_set_multicast_list(struct net_device *dev)
 	hashtable[1] = 0x00000000;
 
 	/* Cycle through all multicast addresses to filter. */
-	for (mc_list_ptr = dev->mc_list;
-	     mc_list_ptr != NULL; mc_list_ptr = mc_list_ptr->next) {
+	netdev_for_each_mc_addr(mc_list_ptr, dev) {
 		/* Calculate CRC result for each multicast address. */
 		hashindex = crc32_le(0xffffffff, mc_list_ptr->dmi_addr,
 				     ETH_ALEN);
diff --git a/drivers/net/isa-skeleton.c b/drivers/net/isa-skeleton.c
index bb4a3cd..d09e4d3 100644
--- a/drivers/net/isa-skeleton.c
+++ b/drivers/net/isa-skeleton.c
@@ -666,7 +666,7 @@ set_multicast_list(struct net_device *dev)
 	else if (!netdev_mc_empty(dev))
 	{
 		/* Walk the address list, and load the filter */
-		hardware_set_filter(dev->mc_list);
+		hardware_set_filter(dev);
 
 		outw(MULTICAST, ioaddr);
 	}
diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
index ff015e1..966de5d 100644
--- a/drivers/net/iseries_veth.c
+++ b/drivers/net/iseries_veth.c
@@ -961,15 +961,14 @@ static void veth_set_multicast_list(struct net_device *dev)
 			(netdev_mc_count(dev) > VETH_MAX_MCAST)) {
 		port->promiscuous = 1;
 	} else {
-		struct dev_mc_list *dmi = dev->mc_list;
-		int i;
+		struct dev_mc_list *dmi;
 
 		port->promiscuous = 0;
 
 		/* Update table */
 		port->num_mcast = 0;
 
-		for (i = 0; i < netdev_mc_count(dev); i++) {
+		netdev_for_each_mc_addr(dmi, dev) {
 			u8 *addr = dmi->dmi_addr;
 			u64 xaddr = 0;
 
@@ -978,7 +977,6 @@ static void veth_set_multicast_list(struct net_device *dev)
 				port->mcast_addr[port->num_mcast] = xaddr;
 				port->num_mcast++;
 			}
-			dmi = dmi->next;
 		}
 	}
 
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 93d0185..c9fef65 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1088,10 +1088,9 @@ ixgb_set_multi(struct net_device *netdev)
 
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 
-		for (i = 0, mc_ptr = netdev->mc_list;
-		     mc_ptr;
-		     i++, mc_ptr = mc_ptr->next)
-			memcpy(&mta[i * IXGB_ETH_LENGTH_OF_ADDRESS],
+		i = 0;
+		netdev_for_each_mc_addr(mc_ptr, netdev)
+			memcpy(&mta[i++ * IXGB_ETH_LENGTH_OF_ADDRESS],
 			       mc_ptr->dmi_addr, IXGB_ETH_LENGTH_OF_ADDRESS);
 
 		ixgb_mc_addr_list_update(hw, mta, netdev_mc_count(netdev), 0);
-- 
1.6.6

