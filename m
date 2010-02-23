From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] net: convert multiple drivers to use
 netdev_for_each_mc_addr, part5
Date: Tue, 23 Feb 2010 20:07:40 +0100
Message-ID: <20100223190739.GC2673@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13064 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753803Ab0BWTHm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2010 14:07:42 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


removed some needless checks and also corrected bug in lp486e (dmi was passed
instead of dmi->dmi_addr)

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/jme.c                  |    6 +-----
 drivers/net/korina.c               |    6 ++----
 drivers/net/ks8851.c               |    5 ++---
 drivers/net/ks8851_mll.c           |    3 ++-
 drivers/net/ksz884x.c              |    4 ++--
 drivers/net/lib82596.c             |    7 ++++---
 drivers/net/lib8390.c              |   15 ++++-----------
 drivers/net/ll_temac_main.c        |    7 ++++---
 drivers/net/lp486e.c               |    4 ++--
 drivers/net/mac89x0.c              |    4 +---
 drivers/net/macb.c                 |    7 ++-----
 drivers/net/mace.c                 |   11 +++++------
 drivers/net/macmace.c              |   12 ++++++------
 drivers/net/mv643xx_eth.c          |    2 +-
 drivers/net/myri10ge/myri10ge.c    |    2 +-
 drivers/net/natsemi.c              |    4 ++--
 drivers/net/netxen/netxen_nic_hw.c |   19 +++++++------------
 drivers/net/ni5010.c               |    3 ++-
 drivers/net/ni52.c                 |    8 ++++----
 drivers/net/niu.c                  |    2 +-
 drivers/net/octeon/octeon_mgmt.c   |    7 +------
 drivers/net/pci-skeleton.c         |    6 +++---
 drivers/net/pcnet32.c              |    5 ++---
 drivers/net/ps3_gelic_net.c        |    2 +-
 drivers/net/qlcnic/qlcnic_hw.c     |    3 +--
 drivers/net/qlge/qlge_main.c       |    6 ++++--
 drivers/net/r6040.c                |   30 +++++++++++++++---------------
 drivers/net/r8169.c                |    4 +---
 28 files changed, 83 insertions(+), 111 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 558b6a0..0f31497 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -1997,7 +1997,6 @@ jme_set_multi(struct net_device *netdev)
 {
 	struct jme_adapter *jme = netdev_priv(netdev);
 	u32 mc_hash[2] = {};
-	int i;
 
 	spin_lock_bh(&jme->rxmcs_lock);
 
@@ -2012,10 +2011,7 @@ jme_set_multi(struct net_device *netdev)
 		int bit_nr;
 
 		jme->reg_rxmcs |= RXMCS_MULFRAME | RXMCS_MULFILTERED;
-		for (i = 0, mclist = netdev->mc_list;
-			mclist && i < netdev_mc_count(netdev);
-			++i, mclist = mclist->next) {
-
+		netdev_for_each_mc_addr(mclist, netdev) {
 			bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) & 0x3F;
 			mc_hash[bit_nr >> 5] |= 1 << (bit_nr & 0x1F);
 		}
diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index af0c764..300c224 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -482,7 +482,7 @@ static void korina_multicast_list(struct net_device *dev)
 {
 	struct korina_private *lp = netdev_priv(dev);
 	unsigned long flags;
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 	u32 recognise = ETH_ARC_AB;	/* always accept broadcasts */
 	int i;
 
@@ -502,11 +502,9 @@ static void korina_multicast_list(struct net_device *dev)
 		for (i = 0; i < 4; i++)
 			hash_table[i] = 0;
 
-		for (i = 0; i < netdev_mc_count(dev); i++) {
+		netdev_for_each_mc_addr(dmi, dev) {
 			char *addrs = dmi->dmi_addr;
 
-			dmi = dmi->next;
-
 			if (!(*addrs & 1))
 				continue;
 
diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
index 9845ab1..b5219cc 100644
--- a/drivers/net/ks8851.c
+++ b/drivers/net/ks8851.c
@@ -966,13 +966,12 @@ static void ks8851_set_rx_mode(struct net_device *dev)
 		rxctrl.rxcr1 = (RXCR1_RXME | RXCR1_RXAE |
 				RXCR1_RXPAFMA | RXCR1_RXMAFMA);
 	} else if (dev->flags & IFF_MULTICAST && !netdev_mc_empty(dev)) {
-		struct dev_mc_list *mcptr = dev->mc_list;
+		struct dev_mc_list *mcptr;
 		u32 crc;
-		int i;
 
 		/* accept some multicast */
 
-		for (i = netdev_mc_count(dev); i > 0; i--) {
+		netdev_for_each_mc_addr(mcptr, dev) {
 			crc = ether_crc(ETH_ALEN, mcptr->dmi_addr);
 			crc >>= (32 - 6);  /* get top six bits */
 
diff --git a/drivers/net/ks8851_mll.c b/drivers/net/ks8851_mll.c
index ffffb38..84b0e15 100644
--- a/drivers/net/ks8851_mll.c
+++ b/drivers/net/ks8851_mll.c
@@ -1196,7 +1196,8 @@ static void ks_set_rx_mode(struct net_device *netdev)
 	if ((netdev->flags & IFF_MULTICAST) && netdev_mc_count(netdev)) {
 		if (netdev_mc_count(netdev) <= MAX_MCAST_LST) {
 			int i = 0;
-			for (ptr = netdev->mc_list; ptr; ptr = ptr->next) {
+
+			netdev_for_each_mc_addr(ptr, netdev) {
 				if (!(*ptr->dmi_addr & 1))
 					continue;
 				if (i >= MAX_MCAST_LST)
diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index 6f187c7..7264a3e 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -5777,7 +5777,7 @@ static void netdev_set_rx_mode(struct net_device *dev)
 	if (hw_priv->hw.dev_count > 1)
 		return;
 
-	if ((dev->flags & IFF_MULTICAST) && dev->mc_count) {
+	if ((dev->flags & IFF_MULTICAST) && !netdev_mc_empty(dev)) {
 		int i = 0;
 
 		/* List too big to support so turn on all multicast mode. */
@@ -5790,7 +5790,7 @@ static void netdev_set_rx_mode(struct net_device *dev)
 			return;
 		}
 
-		for (mc_ptr = dev->mc_list; mc_ptr; mc_ptr = mc_ptr->next) {
+		netdev_for_each_mc_addr(mc_ptr, dev) {
 			if (!(*mc_ptr->dmi_addr & 1))
 				continue;
 			if (i >= MAX_MULTICAST_LIST)
diff --git a/drivers/net/lib82596.c b/drivers/net/lib82596.c
index 371b58b..443c39a 100644
--- a/drivers/net/lib82596.c
+++ b/drivers/net/lib82596.c
@@ -1396,15 +1396,16 @@ static void set_multicast_list(struct net_device *dev)
 		cmd->cmd.command = SWAP16(CmdMulticastList);
 		cmd->mc_cnt = SWAP16(netdev_mc_count(dev) * 6);
 		cp = cmd->mc_addrs;
-		for (dmi = dev->mc_list;
-		     cnt && dmi != NULL;
-		     dmi = dmi->next, cnt--, cp += 6) {
+		netdev_for_each_mc_addr(dmi, dev) {
+			if (!cnt--)
+				break;
 			memcpy(cp, dmi->dmi_addr, 6);
 			if (i596_debug > 1)
 				DEB(DEB_MULTI,
 				    printk(KERN_DEBUG
 					   "%s: Adding address %pM\n",
 					   dev->name, cp));
+			cp += 6;
 		}
 		DMA_WBACK_INV(dev, &dma->mc_cmd, sizeof(struct mc_cmd));
 		i596_add_cmd(dev, &cmd->cmd);
diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index 57f2584..e629233 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -907,15 +907,8 @@ static inline void make_mc_bits(u8 *bits, struct net_device *dev)
 {
 	struct dev_mc_list *dmi;
 
-	for (dmi=dev->mc_list; dmi; dmi=dmi->next)
-	{
-		u32 crc;
-		if (dmi->dmi_addrlen != ETH_ALEN)
-		{
-			printk(KERN_INFO "%s: invalid multicast address length given.\n", dev->name);
-			continue;
-		}
-		crc = ether_crc(ETH_ALEN, dmi->dmi_addr);
+	netdev_for_each_mc_addr(dmi, dev) {
+		u32 crc = ether_crc(ETH_ALEN, dmi->dmi_addr);
 		/*
 		 * The 8390 uses the 6 most significant bits of the
 		 * CRC to index the multicast table.
@@ -941,7 +934,7 @@ static void do_set_multicast_list(struct net_device *dev)
 	if (!(dev->flags&(IFF_PROMISC|IFF_ALLMULTI)))
 	{
 		memset(ei_local->mcfilter, 0, 8);
-		if (dev->mc_list)
+		if (!netdev_mc_empty(dev))
 			make_mc_bits(ei_local->mcfilter, dev);
 	}
 	else
@@ -975,7 +968,7 @@ static void do_set_multicast_list(struct net_device *dev)
 
   	if(dev->flags&IFF_PROMISC)
   		ei_outb_p(E8390_RXCONFIG | 0x18, e8390_base + EN0_RXCR);
-	else if(dev->flags&IFF_ALLMULTI || dev->mc_list)
+	else if (dev->flags & IFF_ALLMULTI || !netdev_mc_addr(dev))
   		ei_outb_p(E8390_RXCONFIG | 0x08, e8390_base + EN0_RXCR);
   	else
   		ei_outb_p(E8390_RXCONFIG, e8390_base + EN0_RXCR);
diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index e534402..a18e348 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -250,9 +250,10 @@ static void temac_set_multicast_list(struct net_device *ndev)
 		temac_indirect_out32(lp, XTE_AFM_OFFSET, XTE_AFM_EPPRM_MASK);
 		dev_info(&ndev->dev, "Promiscuous mode enabled.\n");
 	} else if (!netdev_mc_empty(ndev)) {
-		struct dev_mc_list *mclist = ndev->mc_list;
-		for (i = 0; mclist && i < netdev_mc_count(ndev); i++) {
+		struct dev_mc_list *mclist;
 
+		i = 0;
+		netdev_for_each_mc_addr(mclist, ndev) {
 			if (i >= MULTICAST_CAM_TABLE_NUM)
 				break;
 			multi_addr_msw = ((mclist->dmi_addr[3] << 24) |
@@ -265,7 +266,7 @@ static void temac_set_multicast_list(struct net_device *ndev)
 					  (mclist->dmi_addr[4]) | (i << 16));
 			temac_indirect_out32(lp, XTE_MAW1_OFFSET,
 					     multi_addr_lsw);
-			mclist = mclist->next;
+			i++;
 		}
 	} else {
 		val = temac_indirect_in32(lp, XTE_AFM_OFFSET);
diff --git a/drivers/net/lp486e.c b/drivers/net/lp486e.c
index b1f5d79..3e3cc04 100644
--- a/drivers/net/lp486e.c
+++ b/drivers/net/lp486e.c
@@ -1267,8 +1267,8 @@ static void set_multicast_list(struct net_device *dev) {
 		cmd->command = CmdMulticastList;
 		*((unsigned short *) (cmd + 1)) = netdev_mc_count(dev) * 6;
 		cp = ((char *)(cmd + 1))+2;
-		for (dmi = dev->mc_list; dmi != NULL; dmi = dmi->next) {
-			memcpy(cp, dmi,6);
+		netdev_for_each_mc_addr(dmi, dev) {
+			memcpy(cp, dmi->dmi_addr, 6);
 			cp += 6;
 		}
 		if (i596_debug & LOG_SRCDST)
diff --git a/drivers/net/mac89x0.c b/drivers/net/mac89x0.c
index 23b633e..c292a60 100644
--- a/drivers/net/mac89x0.c
+++ b/drivers/net/mac89x0.c
@@ -568,9 +568,7 @@ static void set_multicast_list(struct net_device *dev)
 	if(dev->flags&IFF_PROMISC)
 	{
 		lp->rx_mode = RX_ALL_ACCEPT;
-	}
-	else if((dev->flags&IFF_ALLMULTI)||dev->mc_list)
-	{
+	} else if ((dev->flags & IFF_ALLMULTI) || !netdev_mc_empty(dev)) {
 		/* The multicast-accept list is initialized to accept-all, and we
 		   rely on higher-level filtering for now. */
 		lp->rx_mode = RX_MULTCAST_ACCEPT;
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 7a5f897..c8a18a6 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -884,15 +884,12 @@ static void macb_sethashtable(struct net_device *dev)
 {
 	struct dev_mc_list *curr;
 	unsigned long mc_filter[2];
-	unsigned int i, bitnr;
+	unsigned int bitnr;
 	struct macb *bp = netdev_priv(dev);
 
 	mc_filter[0] = mc_filter[1] = 0;
 
-	curr = dev->mc_list;
-	for (i = 0; i < netdev_mc_count(dev); i++, curr = curr->next) {
-		if (!curr) break;	/* unexpected end of list */
-
+	netdev_for_each_mc_addr(curr, dev) {
 		bitnr = hash_get_index(curr->dmi_addr);
 		mc_filter[bitnr >> 5] |= 1 << (bitnr & 31);
 	}
diff --git a/drivers/net/mace.c b/drivers/net/mace.c
index fdb0bbd..57534f0 100644
--- a/drivers/net/mace.c
+++ b/drivers/net/mace.c
@@ -588,7 +588,7 @@ static void mace_set_multicast(struct net_device *dev)
 {
     struct mace_data *mp = netdev_priv(dev);
     volatile struct mace __iomem *mb = mp->mace;
-    int i, j;
+    int i;
     u32 crc;
     unsigned long flags;
 
@@ -598,7 +598,7 @@ static void mace_set_multicast(struct net_device *dev)
 	mp->maccc |= PROM;
     } else {
 	unsigned char multicast_filter[8];
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 
 	if (dev->flags & IFF_ALLMULTI) {
 	    for (i = 0; i < 8; i++)
@@ -606,11 +606,10 @@ static void mace_set_multicast(struct net_device *dev)
 	} else {
 	    for (i = 0; i < 8; i++)
 		multicast_filter[i] = 0;
-	    for (i = 0; i < netdev_mc_count(dev); i++) {
+	    netdev_for_each_mc_addr(dmi, dev) {
 	        crc = ether_crc_le(6, dmi->dmi_addr);
-		j = crc >> 26;	/* bit number in multicast_filter */
-		multicast_filter[j >> 3] |= 1 << (j & 7);
-		dmi = dmi->next;
+		i = crc >> 26;	/* bit number in multicast_filter */
+		multicast_filter[i >> 3] |= 1 << (i & 7);
 	    }
 	}
 #if 0
diff --git a/drivers/net/macmace.c b/drivers/net/macmace.c
index 740accb..4e4eac0 100644
--- a/drivers/net/macmace.c
+++ b/drivers/net/macmace.c
@@ -496,7 +496,7 @@ static void mace_set_multicast(struct net_device *dev)
 {
 	struct mace_data *mp = netdev_priv(dev);
 	volatile struct mace *mb = mp->mace;
-	int i, j;
+	int i;
 	u32 crc;
 	u8 maccc;
 	unsigned long flags;
@@ -509,7 +509,7 @@ static void mace_set_multicast(struct net_device *dev)
 		mb->maccc |= PROM;
 	} else {
 		unsigned char multicast_filter[8];
-		struct dev_mc_list *dmi = dev->mc_list;
+		struct dev_mc_list *dmi;
 
 		if (dev->flags & IFF_ALLMULTI) {
 			for (i = 0; i < 8; i++) {
@@ -518,11 +518,11 @@ static void mace_set_multicast(struct net_device *dev)
 		} else {
 			for (i = 0; i < 8; i++)
 				multicast_filter[i] = 0;
-			for (i = 0; i < netdev_mc_count(dev); i++) {
+			netdev_for_each_mc_addr(dmi, dev) {
 				crc = ether_crc_le(6, dmi->dmi_addr);
-				j = crc >> 26;	/* bit number in multicast_filter */
-				multicast_filter[j >> 3] |= 1 << (j & 7);
-				dmi = dmi->next;
+				/* bit number in multicast_filter */
+				i = crc >> 26;
+				multicast_filter[i >> 3] |= 1 << (i & 7);
 			}
 		}
 
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 2733b0a..c97b6e4 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1794,7 +1794,7 @@ oom:
 	memset(mc_spec, 0, 0x100);
 	memset(mc_other, 0, 0x100);
 
-	for (addr = dev->mc_list; addr != NULL; addr = addr->next) {
+	netdev_for_each_mc_addr(addr, dev) {
 		u8 *a = addr->da_addr;
 		u32 *table;
 		int entry;
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index c0884a9..e06fbd9 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -3065,7 +3065,7 @@ static void myri10ge_set_multicast_list(struct net_device *dev)
 	}
 
 	/* Walk the multicast list, and add each address */
-	for (mc_list = dev->mc_list; mc_list != NULL; mc_list = mc_list->next) {
+	netdev_for_each_mc_addr(mc_list, dev) {
 		memcpy(data, &mc_list->dmi_addr, 6);
 		cmd.data0 = ntohl(data[0]);
 		cmd.data1 = ntohl(data[1]);
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index c64e5b0..e520387 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -2495,9 +2495,9 @@ static void __set_rx_mode(struct net_device *dev)
 	} else {
 		struct dev_mc_list *mclist;
 		int i;
+
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
-			 i++, mclist = mclist->next) {
+		netdev_for_each_mc_addr(mclist, dev) {
 			int b = (ether_crc(ETH_ALEN, mclist->dmi_addr) >> 23) & 0x1ff;
 			mc_filter[b/8] |= (1 << (b & 0x07));
 		}
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 25f4414..a945591 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -539,7 +539,7 @@ void netxen_p2_nic_set_multi(struct net_device *netdev)
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 	struct dev_mc_list *mc_ptr;
 	u8 null_addr[6];
-	int index = 0;
+	int i;
 
 	memset(null_addr, 0, 6);
 
@@ -570,16 +570,13 @@ void netxen_p2_nic_set_multi(struct net_device *netdev)
 
 	netxen_nic_enable_mcast_filter(adapter);
 
-	for (mc_ptr = netdev->mc_list; mc_ptr; mc_ptr = mc_ptr->next, index++)
-		netxen_nic_set_mcast_addr(adapter, index, mc_ptr->dmi_addr);
-
-	if (index != netdev_mc_count(netdev))
-		printk(KERN_WARNING "%s: %s multicast address count mismatch\n",
-			netxen_nic_driver_name, netdev->name);
+	i = 0;
+	netdev_for_each_mc_addr(mc_ptr, netdev)
+		netxen_nic_set_mcast_addr(adapter, i++, mc_ptr->dmi_addr);
 
 	/* Clear out remaining addresses */
-	for (; index < adapter->max_mc_count; index++)
-		netxen_nic_set_mcast_addr(adapter, index, null_addr);
+	while (i < adapter->max_mc_count)
+		netxen_nic_set_mcast_addr(adapter, i++, null_addr);
 }
 
 static int
@@ -710,10 +707,8 @@ void netxen_p3_nic_set_multi(struct net_device *netdev)
 	}
 
 	if (!netdev_mc_empty(netdev)) {
-		for (mc_ptr = netdev->mc_list; mc_ptr;
-		     mc_ptr = mc_ptr->next) {
+		netdev_for_each_mc_addr(mc_ptr, netdev)
 			nx_p3_nic_add_mac(adapter, mc_ptr->dmi_addr, &del_list);
-		}
 	}
 
 send_fw_cmd:
diff --git a/drivers/net/ni5010.c b/drivers/net/ni5010.c
index 6a87d81..c16cbfb 100644
--- a/drivers/net/ni5010.c
+++ b/drivers/net/ni5010.c
@@ -651,7 +651,8 @@ static void ni5010_set_multicast_list(struct net_device *dev)
 
 	PRINTK2((KERN_DEBUG "%s: entering set_multicast_list\n", dev->name));
 
-	if (dev->flags&IFF_PROMISC || dev->flags&IFF_ALLMULTI || dev->mc_list) {
+	if (dev->flags & IFF_PROMISC || dev->flags & IFF_ALLMULTI ||
+	    !netdev_mc_empty(dev)) {
 		outb(RMD_PROMISC, EDLC_RMODE); /* Enable promiscuous mode */
 		PRINTK((KERN_DEBUG "%s: Entering promiscuous mode\n", dev->name));
 	} else {
diff --git a/drivers/net/ni52.c b/drivers/net/ni52.c
index 497c6d5..05c29c2 100644
--- a/drivers/net/ni52.c
+++ b/drivers/net/ni52.c
@@ -596,7 +596,7 @@ static int init586(struct net_device *dev)
 	struct iasetup_cmd_struct __iomem *ias_cmd;
 	struct tdr_cmd_struct __iomem *tdr_cmd;
 	struct mcsetup_cmd_struct __iomem *mc_cmd;
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 	int num_addrs = netdev_mc_count(dev);
 
 	ptr = p->scb + 1;
@@ -724,9 +724,9 @@ static int init586(struct net_device *dev)
 		writew(0xffff, &mc_cmd->cmd_link);
 		writew(num_addrs * 6, &mc_cmd->mc_cnt);
 
-		for (i = 0; i < num_addrs; i++, dmi = dmi->next)
-			memcpy_toio(mc_cmd->mc_list[i],
-							dmi->dmi_addr, 6);
+		i = 0;
+		netdev_for_each_mc_addr(dmi, dev)
+			memcpy_toio(mc_cmd->mc_list[i++], dmi->dmi_addr, 6);
 
 		writew(make16(mc_cmd), &p->scb->cbl_offset);
 		writeb(CUC_START, &p->scb->cmd_cuc);
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 5e604e3..0678f31 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6365,7 +6365,7 @@ static void niu_set_rx_mode(struct net_device *dev)
 		for (i = 0; i < 16; i++)
 			hash[i] = 0xffff;
 	} else if (!netdev_mc_empty(dev)) {
-		for (addr = dev->mc_list; addr; addr = addr->next) {
+		netdev_for_each_mc_addr(addr, dev) {
 			u32 crc = ether_crc_le(ETH_ALEN, addr->da_addr);
 
 			crc >>= 24;
diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/octeon/octeon_mgmt.c
index 3a0f910..be368e5 100644
--- a/drivers/net/octeon/octeon_mgmt.c
+++ b/drivers/net/octeon/octeon_mgmt.c
@@ -467,7 +467,6 @@ static void octeon_mgmt_set_rx_filtering(struct net_device *netdev)
 {
 	struct octeon_mgmt *p = netdev_priv(netdev);
 	int port = p->port;
-	int i;
 	union cvmx_agl_gmx_rxx_adr_ctl adr_ctl;
 	union cvmx_agl_gmx_prtx_cfg agl_gmx_prtx;
 	unsigned long flags;
@@ -511,12 +510,8 @@ static void octeon_mgmt_set_rx_filtering(struct net_device *netdev)
 		}
 	}
 	if (multicast_mode == 0) {
-		i = netdev_mc_count(netdev);
-		list = netdev->mc_list;
-		while (i--) {
+		netdev_for_each_mc_addr(list, netdev)
 			octeon_mgmt_cam_state_add(&cam_state, list->da_addr);
-			list = list->next;
-		}
 	}
 
 
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index 11d4398..3678585 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -1793,7 +1793,7 @@ static void netdrv_set_rx_mode(struct net_device *dev)
 	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	u32 mc_filter[2];	/* Multicast hash filter */
-	int i, rx_mode;
+	int rx_mode;
 	u32 tmp;
 
 	DPRINTK("ENTER\n");
@@ -1814,10 +1814,10 @@ static void netdrv_set_rx_mode(struct net_device *dev)
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
 	} else {
 		struct dev_mc_list *mclist;
+
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0;
-		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
-		     i++, mclist = mclist->next) {
+		netdev_for_each_mc_addr(mclist, dev) {
 			int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
 
 			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 63e0315..084d78d 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -2590,7 +2590,7 @@ static void pcnet32_load_multicast(struct net_device *dev)
 	struct pcnet32_private *lp = netdev_priv(dev);
 	volatile struct pcnet32_init_block *ib = lp->init_block;
 	volatile __le16 *mcast_table = (__le16 *)ib->filter;
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 	unsigned long ioaddr = dev->base_addr;
 	char *addrs;
 	int i;
@@ -2611,9 +2611,8 @@ static void pcnet32_load_multicast(struct net_device *dev)
 	ib->filter[1] = 0;
 
 	/* Add addresses */
-	for (i = 0; i < netdev_mc_count(dev); i++) {
+	netdev_for_each_mc_addr(dmi, dev) {
 		addrs = dmi->dmi_addr;
-		dmi = dmi->next;
 
 		/* multicast address? */
 		if (!(*addrs & 1))
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index c19dd4a..a849f6f 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -580,7 +580,7 @@ void gelic_net_set_multi(struct net_device *netdev)
 	}
 
 	/* set multicast addresses */
-	for (mc = netdev->mc_list; mc; mc = mc->next) {
+	netdev_for_each_mc_addr(mc, netdev) {
 		addr = 0;
 		p = mc->dmi_addr;
 		for (i = 0; i < ETH_ALEN; i++) {
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 8ea7f86..99a4d13 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -453,8 +453,7 @@ void qlcnic_set_multi(struct net_device *netdev)
 	}
 
 	if (!netdev_mc_empty(netdev)) {
-		for (mc_ptr = netdev->mc_list; mc_ptr;
-				     mc_ptr = mc_ptr->next) {
+		netdev_for_each_mc_addr(mc_ptr, netdev) {
 			qlcnic_nic_add_mac(adapter, mc_ptr->dmi_addr,
 							&del_list);
 		}
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index c170349..c26ec5d 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -4270,8 +4270,8 @@ static void qlge_set_multicast_list(struct net_device *ndev)
 		status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
 		if (status)
 			goto exit;
-		for (i = 0, mc_ptr = ndev->mc_list; mc_ptr;
-		     i++, mc_ptr = mc_ptr->next)
+		i = 0;
+		netdev_for_each_mc_addr(mc_ptr, ndev) {
 			if (ql_set_mac_addr_reg(qdev, (u8 *) mc_ptr->dmi_addr,
 						MAC_ADDR_TYPE_MULTI_MAC, i)) {
 				netif_err(qdev, hw, qdev->ndev,
@@ -4279,6 +4279,8 @@ static void qlge_set_multicast_list(struct net_device *ndev)
 				ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 				goto exit;
 			}
+			i++;
+		}
 		ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 		if (ql_set_routing_reg
 		    (qdev, RT_IDX_MCAST_MATCH_SLOT, RT_IDX_MCAST_MATCH, 1)) {
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index b810342..15d5373 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -938,7 +938,7 @@ static void r6040_multicast_list(struct net_device *dev)
 	u16 *adrp;
 	u16 reg;
 	unsigned long flags;
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 	int i;
 
 	/* MAC Address */
@@ -973,11 +973,9 @@ static void r6040_multicast_list(struct net_device *dev)
 		for (i = 0; i < 4; i++)
 			hash_table[i] = 0;
 
-		for (i = 0; i < netdev_mc_count(dev); i++) {
+		netdev_for_each_mc_addr(dmi, dev) {
 			char *addrs = dmi->dmi_addr;
 
-			dmi = dmi->next;
-
 			if (!(*addrs & 1))
 				continue;
 
@@ -995,17 +993,19 @@ static void r6040_multicast_list(struct net_device *dev)
 		iowrite16(hash_table[3], ioaddr + MAR3);
 	}
 	/* Multicast Address 1~4 case */
-	for (i = 0, dmi; (i < netdev_mc_count(dev)) && (i < MCAST_MAX); i++) {
-		adrp = (u16 *)dmi->dmi_addr;
-		iowrite16(adrp[0], ioaddr + MID_1L + 8*i);
-		iowrite16(adrp[1], ioaddr + MID_1M + 8*i);
-		iowrite16(adrp[2], ioaddr + MID_1H + 8*i);
-		dmi = dmi->next;
-	}
-	for (i = netdev_mc_count(dev); i < MCAST_MAX; i++) {
-		iowrite16(0xffff, ioaddr + MID_0L + 8*i);
-		iowrite16(0xffff, ioaddr + MID_0M + 8*i);
-		iowrite16(0xffff, ioaddr + MID_0H + 8*i);
+	i = 0;
+	netdev_for_each_mc_addr(dmi, dev) {
+		if (i < MCAST_MAX) {
+			adrp = (u16 *) dmi->dmi_addr;
+			iowrite16(adrp[0], ioaddr + MID_1L + 8 * i);
+			iowrite16(adrp[1], ioaddr + MID_1M + 8 * i);
+			iowrite16(adrp[2], ioaddr + MID_1H + 8 * i);
+		} else {
+			iowrite16(0xffff, ioaddr + MID_0L + 8 * i);
+			iowrite16(0xffff, ioaddr + MID_0M + 8 * i);
+			iowrite16(0xffff, ioaddr + MID_0H + 8 * i);
+		}
+		i++;
 	}
 }
 
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 83965ee..dfc3573 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4732,12 +4732,10 @@ static void rtl_set_rx_mode(struct net_device *dev)
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
 	} else {
 		struct dev_mc_list *mclist;
-		unsigned int i;
 
 		rx_mode = AcceptBroadcast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0;
-		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
-		     i++, mclist = mclist->next) {
+		netdev_for_each_mc_addr(mclist, dev) {
 			int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
 			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
 			rx_mode |= AcceptMulticast;
-- 
1.6.6

