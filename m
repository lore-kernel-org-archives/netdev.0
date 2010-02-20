From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] net: convert multiple drivers to use
 netdev_for_each_mc_addr, part3
Date: Sat, 20 Feb 2010 11:13:58 +0100
Message-ID: <20100220101356.GA10116@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43423 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752442Ab0BTKOB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Feb 2010 05:14:01 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/7990.c             |    6 ++----
 drivers/net/82596.c            |    9 ++++++---
 drivers/net/a2065.c            |    6 ++----
 drivers/net/amd8111e.c         |   11 ++++-------
 drivers/net/amd8111e.h         |    1 -
 drivers/net/appletalk/ltpc.c   |    1 -
 drivers/net/at1700.c           |    4 +---
 drivers/net/atl1c/atl1c_main.c |    2 +-
 drivers/net/atl1e/atl1e_main.c |    2 +-
 drivers/net/atlx/atl2.c        |    2 +-
 drivers/net/atlx/atlx.c        |    2 +-
 drivers/net/atp.c              |    4 +---
 drivers/net/au1000_eth.c       |    5 +----
 drivers/net/b44.c              |    8 +++++---
 drivers/net/bcm63xx_enet.c     |   13 +++++--------
 drivers/net/benet/be_cmds.c    |   10 +++++-----
 drivers/net/benet/be_cmds.h    |    3 +--
 drivers/net/benet/be_main.c    |    6 +++---
 drivers/net/bfin_mac.c         |    6 ++----
 drivers/net/bmac.c             |    7 +++----
 drivers/net/bnx2.c             |    4 +---
 drivers/net/bnx2x_main.c       |   12 ++++--------
 22 files changed, 50 insertions(+), 74 deletions(-)

diff --git a/drivers/net/7990.c b/drivers/net/7990.c
index 079d0be..4e9a5a2 100644
--- a/drivers/net/7990.c
+++ b/drivers/net/7990.c
@@ -595,9 +595,8 @@ static void lance_load_multicast (struct net_device *dev)
         struct lance_private *lp = netdev_priv(dev);
         volatile struct lance_init_block *ib = lp->init_block;
         volatile u16 *mcast_table = (u16 *)&ib->filter;
-        struct dev_mc_list *dmi=dev->mc_list;
+	struct dev_mc_list *dmi;
         char *addrs;
-        int i;
         u32 crc;
 
         /* set all multicast bits */
@@ -611,9 +610,8 @@ static void lance_load_multicast (struct net_device *dev)
         ib->filter [1] = 0;
 
         /* Add addresses */
-        for (i = 0; i < netdev_mc_count(dev); i++){
+	netdev_for_each_mc_addr(dmi, dev) {
                 addrs = dmi->dmi_addr;
-                dmi   = dmi->next;
 
                 /* multicast address? */
                 if (!(*addrs & 1))
diff --git a/drivers/net/82596.c b/drivers/net/82596.c
index 638ce3b..f94d17d 100644
--- a/drivers/net/82596.c
+++ b/drivers/net/82596.c
@@ -1550,13 +1550,16 @@ static void set_multicast_list(struct net_device *dev)
 			return;
 		cmd = &lp->mc_cmd;
 		cmd->cmd.command = CmdMulticastList;
-		cmd->mc_cnt = netdev_mc_count(dev) * 6;
+		cmd->mc_cnt = cnt * ETH_ALEN;
 		cp = cmd->mc_addrs;
-		for (dmi = dev->mc_list; cnt && dmi != NULL; dmi = dmi->next, cnt--, cp += 6) {
-			memcpy(cp, dmi->dmi_addr, 6);
+		netdev_for_each_mc_addr(dmi, dev) {
+			if (!cnt--)
+				break;
+			memcpy(cp, dmi->dmi_addr, ETH_ALEN);
 			if (i596_debug > 1)
 				DEB(DEB_MULTI,printk(KERN_INFO "%s: Adding address %pM\n",
 						dev->name, cp));
+			cp += ETH_ALEN;
 		}
 		i596_add_cmd(dev, &cmd->cmd);
 	}
diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
index 6a65f66..bd4d829 100644
--- a/drivers/net/a2065.c
+++ b/drivers/net/a2065.c
@@ -603,9 +603,8 @@ static void lance_load_multicast (struct net_device *dev)
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
 	volatile u16 *mcast_table = (u16 *)&ib->filter;
-	struct dev_mc_list *dmi=dev->mc_list;
+	struct dev_mc_list *dmi;
 	char *addrs;
-	int i;
 	u32 crc;
 
 	/* set all multicast bits */
@@ -619,9 +618,8 @@ static void lance_load_multicast (struct net_device *dev)
 	ib->filter [1] = 0;
 
 	/* Add addresses */
-	for (i = 0; i < netdev_mc_count(dev); i++){
+	netdev_for_each_mc_addr(dmi, dev) {
 		addrs = dmi->dmi_addr;
-		dmi   = dmi->next;
 
 		/* multicast address? */
 		if (!(*addrs & 1))
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index bdffdfb..b8a59d2 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -1377,10 +1377,11 @@ list to the device.
 */
 static void amd8111e_set_multicast_list(struct net_device *dev)
 {
-	struct dev_mc_list* mc_ptr;
+	struct dev_mc_list *mc_ptr;
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	u32 mc_filter[2] ;
-	int i,bit_num;
+	int bit_num;
+
 	if(dev->flags & IFF_PROMISC){
 		writel( VAL2 | PROM, lp->mmio + CMD2);
 		return;
@@ -1391,7 +1392,6 @@ static void amd8111e_set_multicast_list(struct net_device *dev)
 	    netdev_mc_count(dev) > MAX_FILTER_SIZE) {
 		/* get all multicast packet */
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
-		lp->mc_list = dev->mc_list;
 		lp->options |= OPTION_MULTICAST_ENABLE;
 		amd8111e_writeq(*(u64*)mc_filter,lp->mmio + LADRF);
 		return;
@@ -1399,7 +1399,6 @@ static void amd8111e_set_multicast_list(struct net_device *dev)
 	if (netdev_mc_empty(dev)) {
 		/* get only own packets */
 		mc_filter[1] = mc_filter[0] = 0;
-		lp->mc_list = NULL;
 		lp->options &= ~OPTION_MULTICAST_ENABLE;
 		amd8111e_writeq(*(u64*)mc_filter,lp->mmio + LADRF);
 		/* disable promiscous mode */
@@ -1408,10 +1407,8 @@ static void amd8111e_set_multicast_list(struct net_device *dev)
 	}
 	/* load all the multicast addresses in the logic filter */
 	lp->options |= OPTION_MULTICAST_ENABLE;
-	lp->mc_list = dev->mc_list;
 	mc_filter[1] = mc_filter[0] = 0;
-	for (i = 0, mc_ptr = dev->mc_list; mc_ptr && i < netdev_mc_count(dev);
-		     i++, mc_ptr = mc_ptr->next) {
+	netdev_for_each_mc_addr(mc_ptr, dev) {
 		bit_num = (ether_crc_le(ETH_ALEN, mc_ptr->dmi_addr) >> 26) & 0x3f;
 		mc_filter[bit_num >> 5] |= 1 << (bit_num & 31);
 	}
diff --git a/drivers/net/amd8111e.h b/drivers/net/amd8111e.h
index 28c60a7..ac36eb6 100644
--- a/drivers/net/amd8111e.h
+++ b/drivers/net/amd8111e.h
@@ -789,7 +789,6 @@ struct amd8111e_priv{
 	char opened;
 	struct net_device_stats stats;
 	unsigned int drv_rx_errors;
-	struct dev_mc_list* mc_list;
 	struct amd8111e_coalesce_conf coal_conf;
 
 	struct ipg_info  ipg_data;
diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
index dbfbd3b..8ea4ec7 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -1125,7 +1125,6 @@ struct net_device * __init ltpc_probe(void)
 		printk(KERN_INFO "Apple/Farallon LocalTalk-PC card at %03x, DMA%d.  Using polled mode.\n",io,dma);
 
 	dev->netdev_ops = &ltpc_netdev;
-	dev->mc_list = NULL;
 	dev->base_addr = io;
 	dev->irq = irq;
 	dev->dma = dma;
diff --git a/drivers/net/at1700.c b/drivers/net/at1700.c
index fe60cd0..309843a 100644
--- a/drivers/net/at1700.c
+++ b/drivers/net/at1700.c
@@ -849,11 +849,9 @@ set_rx_mode(struct net_device *dev)
 		outb(1, ioaddr + RX_MODE);	/* Ignore almost all multicasts. */
 	} else {
 		struct dev_mc_list *mclist;
-		int i;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
-			 i++, mclist = mclist->next) {
+		netdev_for_each_mc_addr(mclist, dev) {
 			unsigned int bit =
 				ether_crc_le(ETH_ALEN, mclist->dmi_addr) >> 26;
 			mc_filter[bit >> 3] |= (1 << bit);
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index 3d4c0a5..50dc531 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -377,7 +377,7 @@ static void atl1c_set_multi(struct net_device *netdev)
 	AT_WRITE_REG_ARRAY(hw, REG_RX_HASH_TABLE, 1, 0);
 
 	/* comoute mc addresses' hash value ,and put it into hash table */
-	for (mc_ptr = netdev->mc_list; mc_ptr; mc_ptr = mc_ptr->next) {
+	netdev_for_each_mc_addr(mc_ptr, netdev) {
 		hash_value = atl1c_hash_mc_addr(hw, mc_ptr->dmi_addr);
 		atl1c_hash_set(hw, hash_value);
 	}
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 7d8de10..73302ae 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -307,7 +307,7 @@ static void atl1e_set_multi(struct net_device *netdev)
 	AT_WRITE_REG_ARRAY(hw, REG_RX_HASH_TABLE, 1, 0);
 
 	/* comoute mc addresses' hash value ,and put it into hash table */
-	for (mc_ptr = netdev->mc_list; mc_ptr; mc_ptr = mc_ptr->next) {
+	netdev_for_each_mc_addr(mc_ptr, netdev) {
 		hash_value = atl1e_hash_mc_addr(hw, mc_ptr->dmi_addr);
 		atl1e_hash_set(hw, hash_value);
 	}
diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index 40cf9e5..7061d71 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -157,7 +157,7 @@ static void atl2_set_multi(struct net_device *netdev)
 	ATL2_WRITE_REG_ARRAY(hw, REG_RX_HASH_TABLE, 1, 0);
 
 	/* comoute mc addresses' hash value ,and put it into hash table */
-	for (mc_ptr = netdev->mc_list; mc_ptr; mc_ptr = mc_ptr->next) {
+	netdev_for_each_mc_addr(mc_ptr, netdev) {
 		hash_value = atl2_hash_mc_addr(hw, mc_ptr->dmi_addr);
 		atl2_hash_set(hw, hash_value);
 	}
diff --git a/drivers/net/atlx/atlx.c b/drivers/net/atlx/atlx.c
index 3dc0142..72f3306 100644
--- a/drivers/net/atlx/atlx.c
+++ b/drivers/net/atlx/atlx.c
@@ -144,7 +144,7 @@ static void atlx_set_multi(struct net_device *netdev)
 	iowrite32(0, (hw->hw_addr + REG_RX_HASH_TABLE) + (1 << 2));
 
 	/* compute mc addresses' hash value ,and put it into hash table */
-	for (mc_ptr = netdev->mc_list; mc_ptr; mc_ptr = mc_ptr->next) {
+	netdev_for_each_mc_addr(mc_ptr, netdev) {
 		hash_value = atlx_hash_mc_addr(hw, mc_ptr->dmi_addr);
 		atlx_hash_set(hw, hash_value);
 	}
diff --git a/drivers/net/atp.c b/drivers/net/atp.c
index a841feb..6ad1620 100644
--- a/drivers/net/atp.c
+++ b/drivers/net/atp.c
@@ -886,9 +886,7 @@ static void set_rx_mode_8012(struct net_device *dev)
 		struct dev_mc_list *mclist;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
-			 i++, mclist = mclist->next)
-		{
+		netdev_for_each_mc_addr(mclist, dev) {
 			int filterbit = ether_crc_le(ETH_ALEN, mclist->dmi_addr) & 0x3f;
 			mc_filter[filterbit >> 5] |= 1 << (filterbit & 31);
 		}
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 9337d02..a66b06a 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -1018,16 +1018,13 @@ static void au1000_multicast_list(struct net_device *dev)
 		aup->mac->control &= ~MAC_PROMISCUOUS;
 		printk(KERN_INFO "%s: Pass all multicast\n", dev->name);
 	} else {
-		int i;
 		struct dev_mc_list *mclist;
 		u32 mc_filter[2];	/* Multicast hash filter */
 
 		mc_filter[1] = mc_filter[0] = 0;
-		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
-			 i++, mclist = mclist->next) {
+		netdev_for_each_mc_addr(mclist, dev)
 			set_bit(ether_crc(ETH_ALEN, mclist->dmi_addr)>>26,
 					(long *)mc_filter);
-		}
 		aup->mac->multi_hash_high = mc_filter[1];
 		aup->mac->multi_hash_low = mc_filter[0];
 		aup->mac->control &= ~MAC_PROMISCUOUS;
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 180510e..6e7decd 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1684,9 +1684,11 @@ static int __b44_load_mcast(struct b44 *bp, struct net_device *dev)
 	int i, num_ents;
 
 	num_ents = min_t(int, netdev_mc_count(dev), B44_MCAST_TABLE_SIZE);
-	mclist = dev->mc_list;
-	for (i = 0; mclist && i < num_ents; i++, mclist = mclist->next) {
-		__b44_cam_write(bp, mclist->dmi_addr, i + 1);
+	i = 0;
+	netdev_for_each_mc_addr(mclist, dev) {
+		if (i == num_ents)
+			break;
+		__b44_cam_write(bp, mclist->dmi_addr, i++ + 1);
 	}
 	return i+1;
 }
diff --git a/drivers/net/bcm63xx_enet.c b/drivers/net/bcm63xx_enet.c
index 0927ffa..8cdcab7 100644
--- a/drivers/net/bcm63xx_enet.c
+++ b/drivers/net/bcm63xx_enet.c
@@ -631,16 +631,13 @@ static void bcm_enet_set_multicast_list(struct net_device *dev)
 		return;
 	}
 
-	for (i = 0, mc_list = dev->mc_list;
-	     (mc_list != NULL) && (i < netdev_mc_count(dev)) && (i < 3);
-	     i++, mc_list = mc_list->next) {
+	i = 0;
+	netdev_for_each_mc_addr(mc_list, dev) {
 		u8 *dmi_addr;
 		u32 tmp;
 
-		/* filter non ethernet address */
-		if (mc_list->dmi_addrlen != 6)
-			continue;
-
+		if (i == 3)
+			break;
 		/* update perfect match registers */
 		dmi_addr = mc_list->dmi_addr;
 		tmp = (dmi_addr[2] << 24) | (dmi_addr[3] << 16) |
@@ -649,7 +646,7 @@ static void bcm_enet_set_multicast_list(struct net_device *dev)
 
 		tmp = (dmi_addr[0] << 8 | dmi_addr[1]);
 		tmp |= ENET_PMH_DATAVALID_MASK;
-		enet_writel(priv, tmp, ENET_PMH_REG(i + 1));
+		enet_writel(priv, tmp, ENET_PMH_REG(i++ + 1));
 	}
 
 	for (; i < 3; i++) {
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index ee16b37..c8a2bac 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1134,8 +1134,7 @@ err:
  * (mc == NULL) => multicast promiscous
  */
 int be_cmd_multicast_set(struct be_adapter *adapter, u32 if_id,
-		struct dev_mc_list *mc_list, u32 mc_count,
-		struct be_dma_mem *mem)
+		struct net_device *netdev, struct be_dma_mem *mem)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_mcast_mac_config *req = mem->va;
@@ -1162,13 +1161,14 @@ int be_cmd_multicast_set(struct be_adapter *adapter, u32 if_id,
 		OPCODE_COMMON_NTWK_MULTICAST_SET, sizeof(*req));
 
 	req->interface_id = if_id;
-	if (mc_list) {
+	if (netdev) {
 		int i;
 		struct dev_mc_list *mc;
 
-		req->num_mac = cpu_to_le16(mc_count);
+		req->num_mac = cpu_to_le16(netdev_mc_count(netdev));
 
-		for (mc = mc_list, i = 0; mc; mc = mc->next, i++)
+		i = 0;
+		netdev_for_each_mc_addr(mc, netdev)
 			memcpy(req->mac[i].byte, mc->dmi_addr, ETH_ALEN);
 	} else {
 		req->promiscuous = 1;
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 3464924..728b0d7 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -912,8 +912,7 @@ extern int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id,
 extern int be_cmd_promiscuous_config(struct be_adapter *adapter,
 			u8 port_num, bool en);
 extern int be_cmd_multicast_set(struct be_adapter *adapter, u32 if_id,
-			struct dev_mc_list *mc_list, u32 mc_count,
-			struct be_dma_mem *mem);
+			struct net_device *netdev, struct be_dma_mem *mem);
 extern int be_cmd_set_flow_control(struct be_adapter *adapter,
 			u32 tx_fc, u32 rx_fc);
 extern int be_cmd_get_flow_control(struct be_adapter *adapter,
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index de0830e..27ccdd8 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -577,13 +577,13 @@ static void be_set_multicast_list(struct net_device *netdev)
 	/* Enable multicast promisc if num configured exceeds what we support */
 	if (netdev->flags & IFF_ALLMULTI ||
 	    netdev_mc_count(netdev) > BE_MAX_MC) {
-		be_cmd_multicast_set(adapter, adapter->if_handle, NULL, 0,
+		be_cmd_multicast_set(adapter, adapter->if_handle, NULL,
 				&adapter->mc_cmd_mem);
 		goto done;
 	}
 
-	be_cmd_multicast_set(adapter, adapter->if_handle, netdev->mc_list,
-		netdev_mc_count(netdev), &adapter->mc_cmd_mem);
+	be_cmd_multicast_set(adapter, adapter->if_handle, netdev,
+			&adapter->mc_cmd_mem);
 done:
 	return;
 }
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index ef7f771..587f93c 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -812,16 +812,14 @@ static void bfin_mac_timeout(struct net_device *dev)
 static void bfin_mac_multicast_hash(struct net_device *dev)
 {
 	u32 emac_hashhi, emac_hashlo;
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 	char *addrs;
-	int i;
 	u32 crc;
 
 	emac_hashhi = emac_hashlo = 0;
 
-	for (i = 0; i < netdev_mc_count(dev); i++) {
+	netdev_for_each_mc_addr(dmi, dev) {
 		addrs = dmi->dmi_addr;
-		dmi = dmi->next;
 
 		/* skip non-multicast addresses */
 		if (!(*addrs & 1))
diff --git a/drivers/net/bmac.c b/drivers/net/bmac.c
index 189fa69..119468e 100644
--- a/drivers/net/bmac.c
+++ b/drivers/net/bmac.c
@@ -1000,7 +1000,7 @@ static void bmac_set_multicast(struct net_device *dev)
 			rx_cfg = bmac_rx_on(dev, 0, 0);
 			XXDEBUG(("bmac: multi disabled, rx_cfg=%#08x\n", rx_cfg));
 		} else {
-			for (dmi=dev->mc_list; dmi!=NULL; dmi=dmi->next)
+			netdev_for_each_mc_addr(dmi, dev)
 				bmac_addhash(bp, dmi->dmi_addr);
 			bmac_update_hash_table_mask(dev, bp);
 			rx_cfg = bmac_rx_on(dev, 1, 0);
@@ -1015,7 +1015,7 @@ static void bmac_set_multicast(struct net_device *dev)
 
 static void bmac_set_multicast(struct net_device *dev)
 {
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 	char *addrs;
 	int i;
 	unsigned short rx_cfg;
@@ -1039,9 +1039,8 @@ static void bmac_set_multicast(struct net_device *dev)
 
 		for(i = 0; i < 4; i++) hash_table[i] = 0;
 
-		for(i = 0; i < netdev_mc_count(dev); i++) {
+		netdev_for_each_mc_addr(dmi, dev) {
 			addrs = dmi->dmi_addr;
-			dmi = dmi->next;
 
 			if(!(*addrs & 1))
 				continue;
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index a6cc9d0..d3f739a 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3552,9 +3552,7 @@ bnx2_set_rx_mode(struct net_device *dev)
 
 		memset(mc_filter, 0, 4 * NUM_MC_HASH_REGISTERS);
 
-		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
-		     i++, mclist = mclist->next) {
-
+		netdev_for_each_mc_addr(mclist, dev) {
 			crc = ether_crc_le(ETH_ALEN, mclist->dmi_addr);
 			bit = crc & 0xff;
 			regidx = (bit & 0xe0) >> 5;
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 7f9db47..5adf2a0 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -11483,10 +11483,8 @@ static void bnx2x_set_rx_mode(struct net_device *dev)
 			struct mac_configuration_cmd *config =
 						bnx2x_sp(bp, mcast_config);
 
-			for (i = 0, mclist = dev->mc_list;
-			     mclist && (i < netdev_mc_count(dev));
-			     i++, mclist = mclist->next) {
-
+			i = 0;
+			netdev_for_each_mc_addr(mclist, dev) {
 				config->config_table[i].
 					cam_entry.msb_mac_addr =
 					swab16(*(u16 *)&mclist->dmi_addr[0]);
@@ -11514,6 +11512,7 @@ static void bnx2x_set_rx_mode(struct net_device *dev)
 						cam_entry.middle_mac_addr,
 				   config->config_table[i].
 						cam_entry.lsb_mac_addr);
+				i++;
 			}
 			old = config->hdr.length;
 			if (old > i) {
@@ -11555,10 +11554,7 @@ static void bnx2x_set_rx_mode(struct net_device *dev)
 
 			memset(mc_filter, 0, 4 * MC_HASH_SIZE);
 
-			for (i = 0, mclist = dev->mc_list;
-			     mclist && (i < netdev_mc_count(dev));
-			     i++, mclist = mclist->next) {
-
+			netdev_for_each_mc_addr(mclist, dev) {
 				DP(NETIF_MSG_IFUP, "Adding mcast MAC: %pM\n",
 				   mclist->dmi_addr);
 
-- 
1.6.6

