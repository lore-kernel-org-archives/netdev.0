From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next 2.6 PATCH] net/pcmcia: convert to use
 netdev_for_each_mc_addr
Date: Fri, 19 Feb 2010 19:48:47 +0100
Message-ID: <20100219184847.GG6598@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62438 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752193Ab0BSSsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2010 13:48:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

removed fill_multicast_tbl function in smc91c92_cs and do the work inline

rewritten set_addresses function in xirc2ps_cs. This was kinda headache.
Simulated the original and new functions and they bahave the same.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/pcmcia/axnet_cs.c    |    7 +--
 drivers/net/pcmcia/fmvj18x_cs.c  |    6 +--
 drivers/net/pcmcia/nmclan_cs.c   |    6 +--
 drivers/net/pcmcia/smc91c92_cs.c |   33 +++++----------
 drivers/net/pcmcia/xirc2ps_cs.c  |   84 ++++++++++++++++++++++---------------
 5 files changed, 67 insertions(+), 69 deletions(-)

diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 2ee57bd..d90e0fc 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -1625,8 +1625,7 @@ static inline void make_mc_bits(u8 *bits, struct net_device *dev)
 	struct dev_mc_list *dmi;
 	u32 crc;
 
-	for (dmi=dev->mc_list; dmi; dmi=dmi->next) {
-		
+	netdev_for_each_mc_addr(dmi, dev) {
 		crc = ether_crc(ETH_ALEN, dmi->dmi_addr);
 		/* 
 		 * The 8390 uses the 6 most significant bits of the
@@ -1652,7 +1651,7 @@ static void do_set_multicast_list(struct net_device *dev)
 
 	if (!(dev->flags&(IFF_PROMISC|IFF_ALLMULTI))) {
 		memset(ei_local->mcfilter, 0, 8);
-		if (dev->mc_list)
+		if (!netdev_mc_empty(dev))
 			make_mc_bits(ei_local->mcfilter, dev);
 	} else {
 		/* set to accept-all */
@@ -1668,7 +1667,7 @@ static void do_set_multicast_list(struct net_device *dev)
 
   	if(dev->flags&IFF_PROMISC)
   		outb_p(E8390_RXCONFIG | 0x58, e8390_base + EN0_RXCR);
-	else if(dev->flags&IFF_ALLMULTI || dev->mc_list)
+	else if (dev->flags & IFF_ALLMULTI || !netdev_mc_empty(dev))
   		outb_p(E8390_RXCONFIG | 0x48, e8390_base + EN0_RXCR);
   	else
   		outb_p(E8390_RXCONFIG | 0x40, e8390_base + EN0_RXCR);
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 3d573ed..b9dc80b 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -1199,10 +1199,8 @@ static void set_rx_mode(struct net_device *dev)
 	struct dev_mc_list *mclist;
 
 	memset(mc_filter, 0, sizeof(mc_filter));
-	for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
-	     i++, mclist = mclist->next) {
-	    unsigned int bit =
-	    	ether_crc_le(ETH_ALEN, mclist->dmi_addr) >> 26;
+	netdev_for_each_mc_addr(mclist, dev) {
+	    unsigned int bit = ether_crc_le(ETH_ALEN, mclist->dmi_addr) >> 26;
 	    mc_filter[bit >> 3] |= (1 << (bit & 7));
 	}
 	outb(2, ioaddr + RX_MODE);	/* Use normal mode. */
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index c42a31a..c717b14 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -1475,8 +1475,7 @@ static void set_multicast_list(struct net_device *dev)
 {
   mace_private *lp = netdev_priv(dev);
   int adr[ETHER_ADDR_LEN] = {0}; /* Ethernet address */
-  int i;
-  struct dev_mc_list *dmi = dev->mc_list;
+  struct dev_mc_list *dmi;
 
 #ifdef PCMCIA_DEBUG
   {
@@ -1496,9 +1495,8 @@ static void set_multicast_list(struct net_device *dev)
   if (num_addrs > 0) {
     /* Calculate multicast logical address filter */
     memset(lp->multicast_ladrf, 0, MACE_LADRF_LEN);
-    for (i = 0; i < netdev_mc_count(dev); i++) {
+    netdev_for_each_mc_addr(dmi, dev) {
       memcpy(adr, dmi->dmi_addr, ETHER_ADDR_LEN);
-      dmi = dmi->next;
       BuildLAF(lp->multicast_ladrf, adr);
     }
   }
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index d2e86b8..d29c22a 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -1595,27 +1595,6 @@ static void smc_rx(struct net_device *dev)
 
 /*======================================================================
 
-    Calculate values for the hardware multicast filter hash table.
-
-======================================================================*/
-
-static void fill_multicast_tbl(int count, struct dev_mc_list *addrs,
-			       u_char *multicast_table)
-{
-    struct dev_mc_list	*mc_addr;
-
-    for (mc_addr = addrs;  mc_addr && count-- > 0;  mc_addr = mc_addr->next) {
-	u_int position = ether_crc(6, mc_addr->dmi_addr);
-#ifndef final_version		/* Verify multicast address. */
-	if ((mc_addr->dmi_addr[0] & 1) == 0)
-	    continue;
-#endif
-	multicast_table[position >> 29] |= 1 << ((position >> 26) & 7);
-    }
-}
-
-/*======================================================================
-
     Set the receive mode.
 
     This routine is used by both the protocol level to notify us of
@@ -1639,8 +1618,16 @@ static void set_rx_mode(struct net_device *dev)
 	rx_cfg_setting = RxStripCRC | RxEnable | RxAllMulti;
     else {
 	if (!netdev_mc_empty(dev)) {
-	    fill_multicast_tbl(netdev_mc_count(dev), dev->mc_list,
-			       (u_char *)multicast_table);
+	    struct dev_mc_list *mc_addr;
+
+	    netdev_for_each_mc_addr(mc_addr, dev) {
+		u_int position = ether_crc(6, mc_addr->dmi_addr);
+#ifndef final_version		/* Verify multicast address. */
+		if ((mc_addr->dmi_addr[0] & 1) == 0)
+		    continue;
+#endif
+		multicast_table[position >> 29] |= 1 << ((position >> 26) & 7);
+	    }
 	}
 	rx_cfg_setting = RxStripCRC | RxEnable;
     }
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 4ace18a..4d1802e 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -1364,47 +1364,63 @@ do_start_xmit(struct sk_buff *skb, struct net_device *dev)
     return NETDEV_TX_OK;
 }
 
+struct set_address_info {
+	int reg_nr;
+	int page_nr;
+	int mohawk;
+	unsigned int ioaddr;
+};
+
+static void set_address(struct set_address_info *sa_info, char *addr)
+{
+	unsigned int ioaddr = sa_info->ioaddr;
+	int i;
+
+	for (i = 0; i < 6; i++) {
+		if (sa_info->reg_nr > 15) {
+			sa_info->reg_nr = 8;
+			sa_info->page_nr++;
+			SelectPage(sa_info->page_nr);
+		}
+		if (sa_info->mohawk)
+			PutByte(sa_info->reg_nr++, addr[5 - i]);
+		else
+			PutByte(sa_info->reg_nr++, addr[i]);
+	}
+}
+
 /****************
  * Set all addresses: This first one is the individual address,
  * the next 9 addresses are taken from the multicast list and
  * the rest is filled with the individual address.
  */
-static void
-set_addresses(struct net_device *dev)
+static void set_addresses(struct net_device *dev)
 {
-    unsigned int ioaddr = dev->base_addr;
-    local_info_t *lp = netdev_priv(dev);
-    struct dev_mc_list *dmi = dev->mc_list;
-    unsigned char *addr;
-    int i,j,k,n;
-
-    SelectPage(k=0x50);
-    for (i=0,j=8,n=0; ; i++, j++) {
-	if (i > 5) {
-	    if (++n > 9)
-		break;
-	    i = 0;
-	    if (n > 1 && n <= netdev_mc_count(dev) && dmi) {
-	   	 dmi = dmi->next;
-	    }
-	}
-	if (j > 15) {
-	    j = 8;
-	    k++;
-	    SelectPage(k);
-	}
-
-	if (n && n <= netdev_mc_count(dev) && dmi)
-	    addr = dmi->dmi_addr;
-	else
-	    addr = dev->dev_addr;
+	unsigned int ioaddr = dev->base_addr;
+	local_info_t *lp = netdev_priv(dev);
+	struct dev_mc_list *dmi;
+	struct set_address_info sa_info;
+	int i;
 
-	if (lp->mohawk)
-	    PutByte(j, addr[5-i]);
-	else
-	    PutByte(j, addr[i]);
-    }
-    SelectPage(0);
+	/*
+	 * Setup the info structure so that by first set_address call it will do
+	 * SelectPage with the right page number. Hence these ones here.
+	 */
+	sa_info.reg_nr = 15 + 1;
+	sa_info.page_nr = 0x50 - 1;
+	sa_info.mohawk = lp->mohawk;
+	sa_info.ioaddr = ioaddr;
+
+	set_address(&sa_info, dev->dev_addr);
+	i = 0;
+	netdev_for_each_mc_addr(dmi, dev) {
+		if (i++ == 9)
+			break;
+		set_address(&sa_info, dmi->dmi_addr);
+	}
+	while (i++ < 9)
+		set_address(&sa_info, dev->dev_addr);
+	SelectPage(0);
 }
 
 /****************
-- 
1.6.6

