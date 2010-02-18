From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] tulip: convert to use netdev_for_each_mc_addr
Date: Thu, 18 Feb 2010 14:34:54 +0100
Message-ID: <20100218133453.GH2772@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, grundler@parisc-linux.org, kyle@mcmartin.ca
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55846 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754386Ab0BRNfO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2010 08:35:14 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

also bug in de2104x.c was corrected:
for (i = 0; i < 32; i++) loop should be outside mc_list iteration.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/tulip/de2104x.c     |   19 ++++++++-----------
 drivers/net/tulip/de4x5.c       |   14 ++++++--------
 drivers/net/tulip/dmfe.c        |   27 +++++++++++++--------------
 drivers/net/tulip/tulip_core.c  |   15 ++++-----------
 drivers/net/tulip/uli526x.c     |    4 ++--
 drivers/net/tulip/winbond-840.c |    6 ++----
 6 files changed, 35 insertions(+), 50 deletions(-)

diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index a4cff23..cb42972 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -677,18 +677,17 @@ static void build_setup_frame_hash(u16 *setup_frm, struct net_device *dev)
 	memset(hash_table, 0, sizeof(hash_table));
 	set_bit_le(255, hash_table); 			/* Broadcast entry */
 	/* This should work on big-endian machines as well. */
-	for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
-	     i++, mclist = mclist->next) {
+	netdev_for_each_mc_addr(mclist, dev) {
 		int index = ether_crc_le(ETH_ALEN, mclist->dmi_addr) & 0x1ff;
 
 		set_bit_le(index, hash_table);
+	}
 
-		for (i = 0; i < 32; i++) {
-			*setup_frm++ = hash_table[i];
-			*setup_frm++ = hash_table[i];
-		}
-		setup_frm = &de->setup_frame[13*6];
+	for (i = 0; i < 32; i++) {
+		*setup_frm++ = hash_table[i];
+		*setup_frm++ = hash_table[i];
 	}
+	setup_frm = &de->setup_frame[13*6];
 
 	/* Fill the final entry with our physical address. */
 	eaddrs = (u16 *)dev->dev_addr;
@@ -701,20 +700,18 @@ static void build_setup_frame_perfect(u16 *setup_frm, struct net_device *dev)
 {
 	struct de_private *de = netdev_priv(dev);
 	struct dev_mc_list *mclist;
-	int i;
 	u16 *eaddrs;
 
 	/* We have <= 14 addresses so we can use the wonderful
 	   16 address perfect filtering of the Tulip. */
-	for (i = 0, mclist = dev->mc_list; i < netdev_mc_count(dev);
-	     i++, mclist = mclist->next) {
+	netdev_for_each_mc_addr(mclist, dev) {
 		eaddrs = (u16 *)mclist->dmi_addr;
 		*setup_frm++ = *eaddrs; *setup_frm++ = *eaddrs++;
 		*setup_frm++ = *eaddrs; *setup_frm++ = *eaddrs++;
 		*setup_frm++ = *eaddrs; *setup_frm++ = *eaddrs++;
 	}
 	/* Fill the unused entries with the broadcast address. */
-	memset(setup_frm, 0xff, (15-i)*12);
+	memset(setup_frm, 0xff, (15 - netdev_mc_count(dev)) * 12);
 	setup_frm = &de->setup_frame[15*6];
 
 	/* Fill the final entry with our physical address. */
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index 0b6a973..c4ecb9a 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -1951,9 +1951,9 @@ static void
 SetMulticastFilter(struct net_device *dev)
 {
     struct de4x5_private *lp = netdev_priv(dev);
-    struct dev_mc_list *dmi=dev->mc_list;
+    struct dev_mc_list *dmi;
     u_long iobase = dev->base_addr;
-    int i, j, bit, byte;
+    int i, bit, byte;
     u16 hashcode;
     u32 omr, crc;
     char *pa;
@@ -1966,9 +1966,8 @@ SetMulticastFilter(struct net_device *dev)
     if ((dev->flags & IFF_ALLMULTI) || (netdev_mc_count(dev) > 14)) {
 	omr |= OMR_PM;                       /* Pass all multicasts */
     } else if (lp->setup_f == HASH_PERF) {   /* Hash Filtering */
-	for (i = 0; i < netdev_mc_count(dev) ;i++) {
-	    addrs=dmi->dmi_addr;
-	    dmi=dmi->next;
+	netdev_for_each_mc_addr(dmi, dev) {
+	    addrs = dmi->dmi_addr;
 	    if ((*addrs & 0x01) == 1) {      /* multicast address? */
 		crc = ether_crc_le(ETH_ALEN, addrs);
 		hashcode = crc & HASH_BITS;  /* hashcode is 9 LSb of CRC */
@@ -1984,9 +1983,8 @@ SetMulticastFilter(struct net_device *dev)
 	    }
 	}
     } else {                                 /* Perfect filtering */
-	for (j=0; j<netdev_mc_count(dev); j++) {
-	    addrs=dmi->dmi_addr;
-	    dmi=dmi->next;
+	netdev_for_each_mc_addr(dmi, dev) {
+	    addrs = dmi->dmi_addr;
 	    for (i=0; i<ETH_ALEN; i++) {
 		*(pa + (i&1)) = *addrs++;
 		if (i & 0x01) pa += 4;
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 534afbd..95b38d8 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -330,8 +330,8 @@ static void poll_dmfe (struct net_device *dev);
 static void dmfe_descriptor_init(struct dmfe_board_info *, unsigned long);
 static void allocate_rx_buffer(struct dmfe_board_info *);
 static void update_cr6(u32, unsigned long);
-static void send_filter_frame(struct DEVICE * ,int);
-static void dm9132_id_table(struct DEVICE * ,int);
+static void send_filter_frame(struct DEVICE *);
+static void dm9132_id_table(struct DEVICE *);
 static u16 phy_read(unsigned long, u8, u8, u32);
 static void phy_write(unsigned long, u8, u8, u16, u32);
 static void phy_write_1bit(unsigned long, u32);
@@ -658,9 +658,9 @@ static void dmfe_init_dm910x(struct DEVICE *dev)
 
 	/* Send setup frame */
 	if (db->chip_id == PCI_DM9132_ID)
-		dm9132_id_table(dev, netdev_mc_count(dev));	/* DM9132 */
+		dm9132_id_table(dev);	/* DM9132 */
 	else
-		send_filter_frame(dev, netdev_mc_count(dev));	/* DM9102/DM9102A */
+		send_filter_frame(dev);	/* DM9102/DM9102A */
 
 	/* Init CR7, interrupt active bit */
 	db->cr7_data = CR7_DEFAULT;
@@ -1075,9 +1075,9 @@ static void dmfe_set_filter_mode(struct DEVICE * dev)
 
 	DMFE_DBUG(0, "Set multicast address", mc_count);
 	if (db->chip_id == PCI_DM9132_ID)
-		dm9132_id_table(dev, mc_count);		/* DM9132 */
+		dm9132_id_table(dev);	/* DM9132 */
 	else
-		send_filter_frame(dev, mc_count);	/* DM9102/DM9102A */
+		send_filter_frame(dev);	/* DM9102/DM9102A */
 	spin_unlock_irqrestore(&db->lock, flags);
 }
 
@@ -1452,7 +1452,7 @@ static void update_cr6(u32 cr6_data, unsigned long ioaddr)
  *	This setup frame initilize DM910X address filter mode
 */
 
-static void dm9132_id_table(struct DEVICE *dev, int mc_cnt)
+static void dm9132_id_table(struct DEVICE *dev)
 {
 	struct dev_mc_list *mcptr;
 	u16 * addrptr;
@@ -1472,15 +1472,14 @@ static void dm9132_id_table(struct DEVICE *dev, int mc_cnt)
 	ioaddr += 4;
 
 	/* Clear Hash Table */
-	for (i = 0; i < 4; i++)
-		hash_table[i] = 0x0;
+	memset(hash_table, 0, sizeof(hash_table));
 
 	/* broadcast address */
 	hash_table[3] = 0x8000;
 
 	/* the multicast address in Hash Table : 64 bits */
-	for (mcptr = dev->mc_list, i = 0; i < mc_cnt; i++, mcptr = mcptr->next) {
-		hash_val = cal_CRC( (char *) mcptr->dmi_addr, 6, 0) & 0x3f;
+	netdev_for_each_mc_addr(mcptr, dev) {
+		hash_val = cal_CRC((char *) mcptr->dmi_addr, 6, 0) & 0x3f;
 		hash_table[hash_val / 16] |= (u16) 1 << (hash_val % 16);
 	}
 
@@ -1495,7 +1494,7 @@ static void dm9132_id_table(struct DEVICE *dev, int mc_cnt)
  *	This setup frame initilize DM910X address filter mode
  */
 
-static void send_filter_frame(struct DEVICE *dev, int mc_cnt)
+static void send_filter_frame(struct DEVICE *dev)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
 	struct dev_mc_list *mcptr;
@@ -1521,14 +1520,14 @@ static void send_filter_frame(struct DEVICE *dev, int mc_cnt)
 	*suptr++ = 0xffff;
 
 	/* fit the multicast address */
-	for (mcptr = dev->mc_list, i = 0; i < mc_cnt; i++, mcptr = mcptr->next) {
+	netdev_for_each_mc_addr(mcptr, dev) {
 		addrptr = (u16 *) mcptr->dmi_addr;
 		*suptr++ = addrptr[0];
 		*suptr++ = addrptr[1];
 		*suptr++ = addrptr[2];
 	}
 
-	for (; i<14; i++) {
+	for (i = netdev_mc_count(dev); i < 14; i++) {
 		*suptr++ = 0xffff;
 		*suptr++ = 0xffff;
 		*suptr++ = 0xffff;
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index cce2ada..7f544ef 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -997,12 +997,10 @@ static void build_setup_frame_hash(u16 *setup_frm, struct net_device *dev)
 	memset(hash_table, 0, sizeof(hash_table));
 	set_bit_le(255, hash_table); 			/* Broadcast entry */
 	/* This should work on big-endian machines as well. */
-	for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
-	     i++, mclist = mclist->next) {
+	netdev_for_each_mc_addr(mclist, dev) {
 		int index = ether_crc_le(ETH_ALEN, mclist->dmi_addr) & 0x1ff;
 
 		set_bit_le(index, hash_table);
-
 	}
 	for (i = 0; i < 32; i++) {
 		*setup_frm++ = hash_table[i];
@@ -1021,20 +1019,18 @@ static void build_setup_frame_perfect(u16 *setup_frm, struct net_device *dev)
 {
 	struct tulip_private *tp = netdev_priv(dev);
 	struct dev_mc_list *mclist;
-	int i;
 	u16 *eaddrs;
 
 	/* We have <= 14 addresses so we can use the wonderful
 	   16 address perfect filtering of the Tulip. */
-	for (i = 0, mclist = dev->mc_list; i < netdev_mc_count(dev);
-	     i++, mclist = mclist->next) {
+	netdev_for_each_mc_addr(mclist, dev) {
 		eaddrs = (u16 *)mclist->dmi_addr;
 		*setup_frm++ = *eaddrs; *setup_frm++ = *eaddrs++;
 		*setup_frm++ = *eaddrs; *setup_frm++ = *eaddrs++;
 		*setup_frm++ = *eaddrs; *setup_frm++ = *eaddrs++;
 	}
 	/* Fill the unused entries with the broadcast address. */
-	memset(setup_frm, 0xff, (15-i)*12);
+	memset(setup_frm, 0xff, (15 - netdev_mc_count(dev)) * 12);
 	setup_frm = &tp->setup_frame[15*6];
 
 	/* Fill the final entry with our physical address. */
@@ -1066,7 +1062,6 @@ static void set_rx_mode(struct net_device *dev)
 		/* Some work-alikes have only a 64-entry hash filter table. */
 		/* Should verify correctness on big-endian/__powerpc__ */
 		struct dev_mc_list *mclist;
-		int i;
 		if (netdev_mc_count(dev) > 64) {
 			/* Arbitrary non-effective limit. */
 			tp->csr6 |= AcceptAllMulticast;
@@ -1074,9 +1069,7 @@ static void set_rx_mode(struct net_device *dev)
 		} else {
 			u32 mc_filter[2] = {0, 0};		 /* Multicast hash filter */
 			int filterbit;
-			for (i = 0, mclist = dev->mc_list;
-			     mclist && i < netdev_mc_count(dev);
-			     i++, mclist = mclist->next) {
+			netdev_for_each_mc_addr(mclist, dev) {
 				if (tp->flags & COMET_MAC_ADDR)
 					filterbit = ether_crc_le(ETH_ALEN, mclist->dmi_addr);
 				else
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index 216ceb3..0ab05af 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -1415,14 +1415,14 @@ static void send_filter_frame(struct net_device *dev, int mc_cnt)
 	*suptr++ = 0xffff << FLT_SHIFT;
 
 	/* fit the multicast address */
-	for (mcptr = dev->mc_list, i = 0; i < mc_cnt; i++, mcptr = mcptr->next) {
+	netdev_for_each_mc_addr(mcptr, dev) {
 		addrptr = (u16 *) mcptr->dmi_addr;
 		*suptr++ = addrptr[0] << FLT_SHIFT;
 		*suptr++ = addrptr[1] << FLT_SHIFT;
 		*suptr++ = addrptr[2] << FLT_SHIFT;
 	}
 
-	for (; i<14; i++) {
+	for (i = netdev_mc_count(dev); i < 14; i++) {
 		*suptr++ = 0xffff << FLT_SHIFT;
 		*suptr++ = 0xffff << FLT_SHIFT;
 		*suptr++ = 0xffff << FLT_SHIFT;
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 98711a9..304f438 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -1368,11 +1368,9 @@ static u32 __set_rx_mode(struct net_device *dev)
 		rx_mode = RxAcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 	} else {
 		struct dev_mc_list *mclist;
-		int i;
+
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list;
-		     mclist && i < netdev_mc_count(dev);
-		     i++, mclist = mclist->next) {
+		netdev_for_each_mc_addr(mclist, dev) {
 			int filterbit = (ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26) ^ 0x3F;
 			filterbit &= 0x3f;
 			mc_filter[filterbit >> 5] |= 1 << (filterbit & 31);
-- 
1.6.6

