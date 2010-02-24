From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] net: convert multiple drivers to use
 netdev_for_each_mc_addr, part6
Date: Wed, 24 Feb 2010 10:17:07 +0100
Message-ID: <20100224091707.GB2663@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60847 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755316Ab0BXJRK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2010 04:17:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[net-next-2.6 PATCH] net: convert multiple drivers to use netdev_for_each_mc_addr, part6

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/smc911x.c             |    4 +---
 drivers/net/smc9194.c             |   10 +++++-----
 drivers/net/smc91x.c              |    7 +------
 drivers/net/starfire.c            |    3 +--
 drivers/net/tc35815.c             |    8 ++++----
 drivers/net/tehuti.c              |    4 +---
 drivers/net/tg3.c                 |    5 +----
 drivers/net/tlan.c                |    7 ++++---
 drivers/net/tsi108_eth.c          |   20 +++++---------------
 drivers/net/typhoon.c             |    5 +----
 drivers/net/ucc_geth.c            |    7 +------
 drivers/net/via-rhine.c           |    6 ++----
 drivers/net/via-velocity.c        |    6 +++---
 drivers/net/virtio_net.c          |    5 +++--
 drivers/net/vmxnet3/vmxnet3_drv.c |   11 ++++-------
 drivers/net/vxge/vxge-main.c      |    4 +---
 drivers/net/yellowfin.c           |    4 ++--
 drivers/net/znet.c                |    3 ++-
 18 files changed, 42 insertions(+), 77 deletions(-)

diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index ef9674c..9871a2b 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -1341,7 +1341,6 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 	 * within that register.
 	 */
 	else if (!netdev_mc_empty(dev)) {
-		int i;
 		struct dev_mc_list *cur_addr;
 
 		/* Set the Hash perfec mode */
@@ -1350,8 +1349,7 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 		/* start with a table of all zeros: reject all */
 		memset(multicast_table, 0, sizeof(multicast_table));
 
-		cur_addr = dev->mc_list;
-		for (i = 0; i < netdev_mc_count(dev); i++, cur_addr = cur_addr->next) {
+		netdev_for_each_mc_addr(cur_addr, dev) {
 			u32 position;
 
 			/* do we have a pointer here? */
diff --git a/drivers/net/smc9194.c b/drivers/net/smc9194.c
index 41c3ddd..f9a960e 100644
--- a/drivers/net/smc9194.c
+++ b/drivers/net/smc9194.c
@@ -434,18 +434,18 @@ static void smc_shutdown( int ioaddr )
 */
 
 
-static void smc_setmulticast( int ioaddr, int count, struct dev_mc_list * addrs ) {
+static void smc_setmulticast(int ioaddr, struct net_device *dev)
+{
 	int			i;
 	unsigned char		multicast_table[ 8 ];
-	struct dev_mc_list	* cur_addr;
+	struct dev_mc_list *cur_addr;
 	/* table for flipping the order of 3 bits */
 	unsigned char invert3[] = { 0, 4, 2, 6, 1, 5, 3, 7 };
 
 	/* start with a table of all zeros: reject all */
 	memset( multicast_table, 0, sizeof( multicast_table ) );
 
-	cur_addr = addrs;
-	for ( i = 0; i < count ; i ++, cur_addr = cur_addr->next  ) {
+	netdev_for_each_mc_addr(cur_addr, dev) {
 		int position;
 
 		/* do we have a pointer here? */
@@ -1550,7 +1550,7 @@ static void smc_set_multicast_list(struct net_device *dev)
 			ioaddr + RCR );
 		/* NOTE: this has to set the bank, so make sure it is the
 		   last thing called.  The bank is set to zero at the top */
-		smc_setmulticast(ioaddr, netdev_mc_count(dev), dev->mc_list);
+		smc_setmulticast(ioaddr, dev);
 	}
 	else  {
 		outw( inw( ioaddr + RCR ) & ~(RCR_PROMISC | RCR_ALMUL),
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 6645012..fc1b5a1 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -1413,7 +1413,6 @@ static void smc_set_multicast_list(struct net_device *dev)
 	 * within that register.
 	 */
 	else if (!netdev_mc_empty(dev)) {
-		int i;
 		struct dev_mc_list *cur_addr;
 
 		/* table for flipping the order of 3 bits */
@@ -1422,13 +1421,9 @@ static void smc_set_multicast_list(struct net_device *dev)
 		/* start with a table of all zeros: reject all */
 		memset(multicast_table, 0, sizeof(multicast_table));
 
-		cur_addr = dev->mc_list;
-		for (i = 0; i < netdev_mc_count(dev); i++, cur_addr = cur_addr->next) {
+		netdev_for_each_mc_addr(cur_addr, dev) {
 			int position;
 
-			/* do we have a pointer here? */
-			if (!cur_addr)
-				break;
 			/* make sure this is a multicast address -
 		   	   shouldn't this be a given if we have it here ? */
 			if (!(*cur_addr->dmi_addr & 1))
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 0f405ef..6dfa698 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1825,8 +1825,7 @@ static void set_rx_mode(struct net_device *dev)
 		__le16 mc_filter[32] __attribute__ ((aligned(sizeof(long))));	/* Multicast hash filter */
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
-		     i++, mclist = mclist->next) {
+		netdev_for_each_mc_addr(mclist, dev) {
 			/* The chip uses the upper 9 CRC bits
 			   as index into the hash table */
 			int bit_nr = ether_crc_le(ETH_ALEN, mclist->dmi_addr) >> 23;
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index d838d40..093cc15 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1946,18 +1946,18 @@ tc35815_set_multicast_list(struct net_device *dev)
 		/* Disable promiscuous mode, use normal mode. */
 		tc_writel(CAM_CompEn | CAM_BroadAcc | CAM_GroupAcc, &tr->CAM_Ctl);
 	} else if (!netdev_mc_empty(dev)) {
-		struct dev_mc_list *cur_addr = dev->mc_list;
+		struct dev_mc_list *cur_addr;
 		int i;
 		int ena_bits = CAM_Ena_Bit(CAM_ENTRY_SOURCE);
 
 		tc_writel(0, &tr->CAM_Ctl);
 		/* Walk the address list, and load the filter */
-		for (i = 0; i < netdev_mc_count(dev); i++, cur_addr = cur_addr->next) {
-			if (!cur_addr)
-				break;
+		i = 0;
+		netdev_for_each_mc_addr(cur_addr, dev) {
 			/* entry 0,1 is reserved. */
 			tc35815_set_cam_entry(dev, i + 2, cur_addr->dmi_addr);
 			ena_bits |= CAM_Ena_Bit(i + 2);
+			i++;
 		}
 		tc_writel(ena_bits, &tr->CAM_Ena);
 		tc_writel(CAM_CompEn | CAM_BroadAcc, &tr->CAM_Ctl);
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 2517cc0..0c97802 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -824,10 +824,8 @@ static void bdx_setmulti(struct net_device *ndev)
 		/* TBD: sort addreses and write them in ascending order
 		 * into RX_MAC_MCST regs. we skip this phase now and accept ALL
 		 * multicast frames throu IMF */
-		mclist = ndev->mc_list;
-
 		/* accept the rest of addresses throu IMF */
-		for (; mclist; mclist = mclist->next) {
+		netdev_for_each_mc_addr(mclist, ndev) {
 			hash = 0;
 			for (i = 0; i < ETH_ALEN; i++)
 				hash ^= mclist->dmi_addr[i];
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index f204f73..0d06e40 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9458,15 +9458,12 @@ static void __tg3_set_rx_mode(struct net_device *dev)
 	} else {
 		/* Accept one or more multicast(s). */
 		struct dev_mc_list *mclist;
-		unsigned int i;
 		u32 mc_filter[4] = { 0, };
 		u32 regidx;
 		u32 bit;
 		u32 crc;
 
-		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
-		     i++, mclist = mclist->next) {
-
+		netdev_for_each_mc_addr(mclist, dev) {
 			crc = calc_crc (mclist->dmi_addr, ETH_ALEN);
 			bit = ~crc & 0x7f;
 			regidx = (bit & 0x60) >> 5;
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index e44d5a0..390540c 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -1314,7 +1314,7 @@ static struct net_device_stats *TLan_GetStats( struct net_device *dev )
 
 static void TLan_SetMulticastList( struct net_device *dev )
 {
-	struct dev_mc_list	*dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 	u32			hash1 = 0;
 	u32			hash2 = 0;
 	int			i;
@@ -1335,7 +1335,8 @@ static void TLan_SetMulticastList( struct net_device *dev )
 			TLan_DioWrite32( dev->base_addr, TLAN_HASH_1, 0xFFFFFFFF );
 			TLan_DioWrite32( dev->base_addr, TLAN_HASH_2, 0xFFFFFFFF );
 		} else {
-			for ( i = 0; i < netdev_mc_count(dev); i++ ) {
+			i = 0;
+			netdev_for_each_mc_addr(dmi, dev) {
 				if ( i < 3 ) {
 					TLan_SetMac( dev, i + 1,
 						     (char *) &dmi->dmi_addr );
@@ -1346,7 +1347,7 @@ static void TLan_SetMulticastList( struct net_device *dev )
 					else
 						hash2 |= ( 1 << ( offset - 32 ) );
 				}
-				dmi = dmi->next;
+				i++;
 			}
 			for ( ; i < 3; i++ )
 				TLan_SetMac( dev, i + 1, NULL );
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index f4b30c4..647cdd1 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -1186,27 +1186,17 @@ static void tsi108_set_rx_mode(struct net_device *dev)
 
 	if (dev->flags & IFF_ALLMULTI || !netdev_mc_empty(dev)) {
 		int i;
-		struct dev_mc_list *mc = dev->mc_list;
+		struct dev_mc_list *mc;
 		rxcfg |= TSI108_EC_RXCFG_MFE | TSI108_EC_RXCFG_MC_HASH;
 
 		memset(data->mc_hash, 0, sizeof(data->mc_hash));
 
-		while (mc) {
+		netdev_for_each_mc_addr(mc, dev) {
 			u32 hash, crc;
 
-			if (mc->dmi_addrlen == 6) {
-				crc = ether_crc(6, mc->dmi_addr);
-				hash = crc >> 23;
-
-				__set_bit(hash, &data->mc_hash[0]);
-			} else {
-				printk(KERN_ERR
-		"%s: got multicast address of length %d instead of 6.\n",
-				       dev->name,
-				       mc->dmi_addrlen);
-			}
-
-			mc = mc->next;
+			crc = ether_crc(6, mc->dmi_addr);
+			hash = crc >> 23;
+			__set_bit(hash, &data->mc_hash[0]);
 		}
 
 		TSI_WRITE(TSI108_EC_HASHADDR,
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 38c2161..e3ddcb8 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -922,12 +922,9 @@ typhoon_set_rx_mode(struct net_device *dev)
 		filter |= TYPHOON_RX_FILTER_ALL_MCAST;
 	} else if (!netdev_mc_empty(dev)) {
 		struct dev_mc_list *mclist;
-		int i;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list;
-		     mclist && i < netdev_mc_count(dev);
-		     i++, mclist = mclist->next) {
+		netdev_for_each_mc_addr(mclist, dev) {
 			int bit = ether_crc(ETH_ALEN, mclist->dmi_addr) & 0x3f;
 			mc_filter[bit >> 5] |= 1 << (bit & 0x1f);
 		}
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index a057202..23a9751 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2002,7 +2002,6 @@ static void ucc_geth_set_multi(struct net_device *dev)
 	struct dev_mc_list *dmi;
 	struct ucc_fast __iomem *uf_regs;
 	struct ucc_geth_82xx_address_filtering_pram __iomem *p_82xx_addr_filt;
-	int i;
 
 	ugeth = netdev_priv(dev);
 
@@ -2029,11 +2028,7 @@ static void ucc_geth_set_multi(struct net_device *dev)
 			out_be32(&p_82xx_addr_filt->gaddr_h, 0x0);
 			out_be32(&p_82xx_addr_filt->gaddr_l, 0x0);
 
-			dmi = dev->mc_list;
-
-			for (i = 0; i < netdev_mc_count(dev);
-			     i++, dmi = dmi->next) {
-
+			netdev_for_each_mc_addr(dmi, dev) {
 				/* Only support group multicast for now.
 				 */
 				if (!(dmi->dmi_addr[0] & 1))
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 85df7ac..50f881a 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -1705,11 +1705,9 @@ static void rhine_set_rx_mode(struct net_device *dev)
 		rx_mode = 0x0C;
 	} else {
 		struct dev_mc_list *mclist;
-		int i;
+
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list;
-		     mclist && i < netdev_mc_count(dev);
-		     i++, mclist = mclist->next) {
+		netdev_for_each_mc_addr(mclist, dev) {
 			int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
 
 			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 4e47f26..3a486f3 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1141,11 +1141,11 @@ static void velocity_set_multi(struct net_device *dev)
 		int offset = MCAM_SIZE - vptr->multicast_limit;
 		mac_get_cam_mask(regs, vptr->mCAMmask);
 
-		for (i = 0, mclist = dev->mc_list;
-		     mclist && i < netdev_mc_count(dev);
-		     i++, mclist = mclist->next) {
+		i = 0;
+		netdev_for_each_mc_addr(mclist, dev) {
 			mac_set_cam(regs, i + offset, mclist->dmi_addr);
 			vptr->mCAMmask[(offset + i) / 8] |= 1 << ((offset + i) & 7);
+			i++;
 		}
 
 		mac_set_cam_mask(regs, vptr->mCAMmask);
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index ce35b42..e6095f3 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -776,8 +776,9 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 
 	mac_data->entries = mc_count;
 	addr = dev->mc_list;
-	for (i = 0; i < mc_count; i++, addr = addr->next)
-		memcpy(&mac_data->macs[i][0], addr->da_addr, ETH_ALEN);
+	i = 0;
+	netdev_for_each_mc_addr(addr, dev)
+		memcpy(&mac_data->macs[i++][0], addr->da_addr, ETH_ALEN);
 
 	sg_set_buf(&sg[1], mac_data,
 		   sizeof(mac_data->entries) + (mc_count * ETH_ALEN));
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index ee1b397..cff3485 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1675,15 +1675,12 @@ vmxnet3_copy_mc(struct net_device *netdev)
 		/* We may be called with BH disabled */
 		buf = kmalloc(sz, GFP_ATOMIC);
 		if (buf) {
-			int i;
-			struct dev_mc_list *mc = netdev->mc_list;
+			struct dev_mc_list *mc;
+			int i = 0;
 
-			for (i = 0; i < netdev_mc_count(netdev); i++) {
-				BUG_ON(!mc);
-				memcpy(buf + i * ETH_ALEN, mc->dmi_addr,
+			netdev_for_each_mc_addr(mc, netdev)
+				memcpy(buf + i++ * ETH_ALEN, mc->dmi_addr,
 				       ETH_ALEN);
-				mc = mc->next;
-			}
 		}
 	}
 	return buf;
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index c248b01..46a7c9e 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -1217,9 +1217,7 @@ static void vxge_set_multicast(struct net_device *dev)
 		}
 
 		/* Add new ones */
-		for (i = 0, mclist = dev->mc_list; i < netdev_mc_count(dev);
-			i++, mclist = mclist->next) {
-
+		netdev_for_each_mc_addr(mclist, dev) {
 			memcpy(mac_info.macaddr, mclist->dmi_addr, ETH_ALEN);
 			for (vpath_idx = 0; vpath_idx < vdev->no_of_vpath;
 					vpath_idx++) {
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index e4aab4d..7d4107f 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -1303,9 +1303,9 @@ static void set_rx_mode(struct net_device *dev)
 		struct dev_mc_list *mclist;
 		u16 hash_table[4];
 		int i;
+
 		memset(hash_table, 0, sizeof(hash_table));
-		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
-			 i++, mclist = mclist->next) {
+		netdev_for_each_mc_addr(mclist, dev) {
 			unsigned int bit;
 
 			/* Due to a bug in the early chip versions, multiple filter
diff --git a/drivers/net/znet.c b/drivers/net/znet.c
index bc5ae0f..def49d2 100644
--- a/drivers/net/znet.c
+++ b/drivers/net/znet.c
@@ -313,7 +313,8 @@ static void znet_set_multicast_list (struct net_device *dev)
 	/* Byte D */
 	cfblk->dummy_1 = 1; 	/* set to 1 */
 	cfblk->tx_ifs_retrig = 3; /* Hmm... Disabled */
-	cfblk->mc_all = (dev->mc_list || (dev->flags&IFF_ALLMULTI));/* multicast all mode */
+	cfblk->mc_all = (!netdev_mc_empty(dev) ||
+			(dev->flags & IFF_ALLMULTI)); /* multicast all mode */
 	cfblk->rcv_mon = 0;	/* Monitor mode disabled */
 	cfblk->frag_acpt = 0;	/* Do not accept fragments */
 	cfblk->tstrttrs = 0;	/* No start transmission threshold */
-- 
1.6.6

