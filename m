From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] staging: convert to use netdev_for_each_mc_addr
Date: Thu, 18 Feb 2010 16:10:14 +0100
Message-ID: <20100218151014.GJ2772@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54539 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758221Ab0BRPKT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2010 10:10:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

removed needless checks in arlan-main.c and slicoss.c
fixed bug in et131x_netdev.c to actually fill addresses in.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/staging/arlan/arlan-main.c     |   25 ++++++++++---------------
 drivers/staging/et131x/et131x_netdev.c |   15 ++++++++-------
 drivers/staging/octeon/ethernet.c      |    2 +-
 drivers/staging/slicoss/slicoss.c      |   16 ++++------------
 drivers/staging/vt6655/device_main.c   |    6 ++----
 drivers/staging/vt6656/main_usb.c      |    5 ++---
 drivers/staging/wavelan/wavelan.c      |    6 +++---
 drivers/staging/wavelan/wavelan_cs.c   |    9 ++++-----
 drivers/staging/wlags49_h2/wl_netdev.c |   16 ++++++----------
 9 files changed, 40 insertions(+), 60 deletions(-)

diff --git a/drivers/staging/arlan/arlan-main.c b/drivers/staging/arlan/arlan-main.c
index 921a082..88fdd53 100644
--- a/drivers/staging/arlan/arlan-main.c
+++ b/drivers/staging/arlan/arlan-main.c
@@ -1455,10 +1455,10 @@ static void arlan_rx_interrupt(struct net_device *dev, u_char rxStatus, u_short
 #ifdef ARLAN_MULTICAST
 			if (!(dev->flags & IFF_ALLMULTI) &&
 				!(dev->flags & IFF_PROMISC) &&
-				dev->mc_list)
+				!netdev_mc_empty(dev))
 			{
 				char hw_dst_addr[6];
-				struct dev_mc_list *dmi = dev->mc_list;
+				struct dev_mc_list *dmi;
 				int i;
 
 				memcpy_fromio(hw_dst_addr, arlan->ultimateDestAddress, 6);
@@ -1469,20 +1469,15 @@ static void arlan_rx_interrupt(struct net_device *dev, u_char rxStatus, u_short
 							printk(KERN_ERR "%s mcast 0x0100 \n", dev->name);
 						else if (hw_dst_addr[1] == 0x40)
 							printk(KERN_ERR "%s m/bcast 0x0140 \n", dev->name);
-					while (dmi)
-					{
-						if (dmi->dmi_addrlen == 6) {
-							if (arlan_debug & ARLAN_DEBUG_HEADER_DUMP)
-								printk(KERN_ERR "%s mcl %pM\n",
-								       dev->name, dmi->dmi_addr);
-							for (i = 0; i < 6; i++)
-								if (dmi->dmi_addr[i] != hw_dst_addr[i])
-									break;
-							if (i == 6)
+					netdev_for_each_mc_entry(dmi, dev) {
+						if (arlan_debug & ARLAN_DEBUG_HEADER_DUMP)
+							printk(KERN_ERR "%s mcl %pM\n",
+							       dev->name, dmi->dmi_addr);
+						for (i = 0; i < 6; i++)
+							if (dmi->dmi_addr[i] != hw_dst_addr[i])
 								break;
-						} else
-							printk(KERN_ERR "%s: invalid multicast address length given.\n", dev->name);
-						dmi = dmi->next;
+						if (i == 6)
+							break;
 					}
 					/* we reach here if multicast filtering is on and packet 
 					 * is multicast and not for receive */
diff --git a/drivers/staging/et131x/et131x_netdev.c b/drivers/staging/et131x/et131x_netdev.c
index bc1fad2..edb78ae 100644
--- a/drivers/staging/et131x/et131x_netdev.c
+++ b/drivers/staging/et131x/et131x_netdev.c
@@ -411,9 +411,9 @@ void et131x_multicast(struct net_device *netdev)
 {
 	struct et131x_adapter *adapter = netdev_priv(netdev);
 	uint32_t PacketFilter = 0;
-	uint32_t count;
 	unsigned long flags;
-	struct dev_mc_list *mclist = netdev->mc_list;
+	struct dev_mc_list *mclist;
+	int i;
 
 	spin_lock_irqsave(&adapter->Lock, flags);
 
@@ -456,12 +456,13 @@ void et131x_multicast(struct net_device *netdev)
 	}
 
 	/* Set values in the private adapter struct */
-	adapter->MCAddressCount = netdev_mc_count(netdev);
-
-	if (!netdev_mc_empty(netdev)) {
-		count = netdev_mc_count(netdev) - 1;
-		memcpy(adapter->MCList[count], mclist->dmi_addr, ETH_ALEN);
+	i = 0;
+	netdev_for_each_mc_addr(mclist, netdev) {
+		if (i == NIC_MAX_MCAST_LIST)
+			break;
+		memcpy(adapter->MCList[i++], mclist->dmi_addr, ETH_ALEN);
 	}
+	adapter->MCAddressCount = i;
 
 	/* Are the new flags different from the previous ones? If not, then no
 	 * action is required
diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
index 4cfd4b1..220de13 100644
--- a/drivers/staging/octeon/ethernet.c
+++ b/drivers/staging/octeon/ethernet.c
@@ -382,7 +382,7 @@ static void cvm_oct_common_set_multicast_list(struct net_device *dev)
 		control.u64 = 0;
 		control.s.bcst = 1;	/* Allow broadcast MAC addresses */
 
-		if (dev->mc_list || (dev->flags & IFF_ALLMULTI) ||
+		if (!netdev_mc_empty(dev) || (dev->flags & IFF_ALLMULTI) ||
 		    (dev->flags & IFF_PROMISC))
 			/* Force accept multicast packets */
 			control.s.mcst = 2;
diff --git a/drivers/staging/slicoss/slicoss.c b/drivers/staging/slicoss/slicoss.c
index 8c9d5e5..f5cc01b 100644
--- a/drivers/staging/slicoss/slicoss.c
+++ b/drivers/staging/slicoss/slicoss.c
@@ -1362,25 +1362,17 @@ static void slic_mcast_set_list(struct net_device *dev)
 {
 	struct adapter *adapter = (struct adapter *)netdev_priv(dev);
 	int status = STATUS_SUCCESS;
-	int i;
 	char *addresses;
-	struct dev_mc_list *mc_list = dev->mc_list;
-	int mc_count = netdev_mc_count(dev);
+	struct dev_mc_list *mc_list;
 
 	ASSERT(adapter);
 
-	for (i = 1; i <= mc_count; i++) {
+	netdev_for_each_mc_addr(mc_list, dev) {
 		addresses = (char *) &mc_list->dmi_addr;
-		if (mc_list->dmi_addrlen == 6) {
-			status = slic_mcast_add_list(adapter, addresses);
-			if (status != STATUS_SUCCESS)
-				break;
-		} else {
-			status = -EINVAL;
+		status = slic_mcast_add_list(adapter, addresses);
+		if (status != STATUS_SUCCESS)
 			break;
-		}
 		slic_mcast_set_bit(adapter, addresses);
-		mc_list = mc_list->next;
 	}
 
 	if (adapter->devflags_prev != dev->flags) {
diff --git a/drivers/staging/vt6655/device_main.c b/drivers/staging/vt6655/device_main.c
index 82b3a6e..0dadb76 100644
--- a/drivers/staging/vt6655/device_main.c
+++ b/drivers/staging/vt6655/device_main.c
@@ -3082,8 +3082,7 @@ static void device_set_multi(struct net_device *dev) {
 
     PSMgmtObject     pMgmt = pDevice->pMgmt;
     u32              mc_filter[2];
-    int              i;
-    struct dev_mc_list  *mclist;
+    struct dev_mc_list *mclist;
 
 
     VNSvInPortB(pDevice->PortOffset + MAC_REG_RCR, &(pDevice->byRxMode));
@@ -3103,8 +3102,7 @@ static void device_set_multi(struct net_device *dev) {
     }
     else {
         memset(mc_filter, 0, sizeof(mc_filter));
-        for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
-             i++, mclist = mclist->next) {
+	netdev_for_each_mc_addr(mclist, dev) {
             int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
             mc_filter[bit_nr >> 5] |= cpu_to_le32(1 << (bit_nr & 31));
         }
diff --git a/drivers/staging/vt6656/main_usb.c b/drivers/staging/vt6656/main_usb.c
index 2c6a535..a8e1adb 100644
--- a/drivers/staging/vt6656/main_usb.c
+++ b/drivers/staging/vt6656/main_usb.c
@@ -1596,7 +1596,7 @@ static void device_set_multi(struct net_device *dev) {
     PSMgmtObject     pMgmt = &(pDevice->sMgmtObj);
     u32              mc_filter[2];
     int              ii;
-    struct dev_mc_list  *mclist;
+    struct dev_mc_list *mclist;
     BYTE             pbyData[8] = {0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff};
     BYTE             byTmpMode = 0;
     int              rc;
@@ -1632,8 +1632,7 @@ static void device_set_multi(struct net_device *dev) {
     }
     else {
         memset(mc_filter, 0, sizeof(mc_filter));
-        for (ii = 0, mclist = dev->mc_list; mclist && ii < netdev_mc_count(dev);
-             ii++, mclist = mclist->next) {
+	netdev_for_each_mc_addr(mclist, dev) {
             int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
             mc_filter[bit_nr >> 5] |= cpu_to_le32(1 << (bit_nr & 31));
         }
diff --git a/drivers/staging/wavelan/wavelan.c b/drivers/staging/wavelan/wavelan.c
index 961f141..54ca631 100644
--- a/drivers/staging/wavelan/wavelan.c
+++ b/drivers/staging/wavelan/wavelan.c
@@ -1387,7 +1387,7 @@ static void wavelan_set_multicast_list(struct net_device * dev)
 		}
 	} else
 		/* Are there multicast addresses to send? */
-	if (dev->mc_list != (struct dev_mc_list *) NULL) {
+	if (!netdev_mc_empty(dev)) {
 		/*
 		 * Disable promiscuous mode, but receive all packets
 		 * in multicast list
@@ -3531,7 +3531,7 @@ static void wv_82586_config(struct net_device * dev)
 
 	/* Any address to set? */
 	if (lp->mc_count) {
-		for (dmi = dev->mc_list; dmi; dmi = dmi->next)
+		netdev_for_each_mc_addr(dmi, dev)
 			outsw(PIOP1(ioaddr), (u16 *) dmi->dmi_addr,
 			      WAVELAN_ADDR_SIZE >> 1);
 
@@ -3539,7 +3539,7 @@ static void wv_82586_config(struct net_device * dev)
 		printk(KERN_DEBUG
 		       "%s: wv_82586_config(): set %d multicast addresses:\n",
 		       dev->name, lp->mc_count);
-		for (dmi = dev->mc_list; dmi; dmi = dmi->next)
+		netdev_for_each_mc_addr(dmi, dev)
 			printk(KERN_DEBUG " %pM\n", dmi->dmi_addr);
 #endif
 	}
diff --git a/drivers/staging/wavelan/wavelan_cs.c b/drivers/staging/wavelan/wavelan_cs.c
index 08fcb22..04f691d 100644
--- a/drivers/staging/wavelan/wavelan_cs.c
+++ b/drivers/staging/wavelan/wavelan_cs.c
@@ -1410,8 +1410,7 @@ wavelan_set_multicast_list(struct net_device *	dev)
       }
     else
       /* If there is some multicast addresses to send */
-      if(dev->mc_list != (struct dev_mc_list *) NULL)
-	{
+      if (!netdev_mc_empty(dev)) {
 	  /*
 	   * Disable promiscuous mode, but receive all packets
 	   * in multicast list
@@ -3598,13 +3597,13 @@ wv_82593_config(struct net_device *	dev)
   /* If any multicast address to set */
   if(lp->mc_count)
     {
-      struct dev_mc_list *	dmi;
+      struct dev_mc_list *dmi;
       int			addrs_len = WAVELAN_ADDR_SIZE * lp->mc_count;
 
 #ifdef DEBUG_CONFIG_INFO
       printk(KERN_DEBUG "%s: wv_hw_config(): set %d multicast addresses:\n",
 	     dev->name, lp->mc_count);
-      for(dmi=dev->mc_list; dmi; dmi=dmi->next)
+      netdev_for_each_mc_addr(dmi, dev)
 	printk(KERN_DEBUG " %pM\n", dmi->dmi_addr);
 #endif
 
@@ -3613,7 +3612,7 @@ wv_82593_config(struct net_device *	dev)
       outb(((TX_BASE >> 8) & PIORH_MASK) | PIORH_SEL_TX, PIORH(base));
       outb(addrs_len & 0xff, PIOP(base));	/* byte count lsb */
       outb((addrs_len >> 8), PIOP(base));	/* byte count msb */
-      for(dmi=dev->mc_list; dmi; dmi=dmi->next)
+      netdev_for_each_mc_addr(dmi, dev)
 	outsb(PIOP(base), dmi->dmi_addr, dmi->dmi_addrlen);
 
       /* reset transmit DMA pointer */
diff --git a/drivers/staging/wlags49_h2/wl_netdev.c b/drivers/staging/wlags49_h2/wl_netdev.c
index a95ebf8..c33e225 100644
--- a/drivers/staging/wlags49_h2/wl_netdev.c
+++ b/drivers/staging/wlags49_h2/wl_netdev.c
@@ -1049,7 +1049,7 @@ void wl_multicast( struct net_device *dev )
 //;?seems reasonable that even an AP-only driver could afford this small additional footprint
 
     int                 x;
-    struct dev_mc_list  *mclist;
+    struct dev_mc_list *mclist;
     struct wl_private   *lp = wl_priv(dev);
     unsigned long       flags;
     /*------------------------------------------------------------------------*/
@@ -1072,11 +1072,9 @@ void wl_multicast( struct net_device *dev )
 
         DBG_PRINT( "  mc_count: %d\n", netdev_mc_count(dev));
 
-        for( x = 0, mclist = dev->mc_list; mclist && x < netdev_mc_count(dev);
-             x++, mclist = mclist->next ) {
+	netdev_for_each_mc_addr(mclist, dev)
             DBG_PRINT( "    %s (%d)\n", DbgHwAddr(mclist->dmi_addr),
                        mclist->dmi_addrlen );
-        }
     }
 #endif /* DBG */
 
@@ -1120,12 +1118,10 @@ void wl_multicast( struct net_device *dev )
                 lp->ltvRecord.len = ( netdev_mc_count(dev) * 3 ) + 1;
                 lp->ltvRecord.typ = CFG_GROUP_ADDR;
 
-                for( x = 0, mclist = dev->mc_list;
-                ( x < netdev_mc_count(dev)) && ( mclist != NULL );
-                    x++, mclist = mclist->next ) {
-                    memcpy( &( lp->ltvRecord.u.u8[x * ETH_ALEN] ),
-                            mclist->dmi_addr, ETH_ALEN );
-                }
+		x = 0;
+		netdev_for_each_mc_addr(mclist, dev)
+                    memcpy(&(lp->ltvRecord.u.u8[x++ * ETH_ALEN]),
+                           mclist->dmi_addr, ETH_ALEN);
                 DBG_PRINT( "Setting multicast list\n" );
                 hcf_put_info( &( lp->hcfCtx ), (LTVP)&( lp->ltvRecord ));
             } else {
-- 
1.6.6

