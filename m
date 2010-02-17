From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] net: convert multiple drivers to use
 netdev_for_each_mc_addr
Date: Wed, 17 Feb 2010 22:09:31 +0100
Message-ID: <20100217210931.GC2635@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756468Ab0BQVJf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 16:09:35 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/cpmac.c        |    4 +---
 drivers/net/cris/eth_v10.c |    6 ++----
 drivers/net/cs89x0.c       |    2 +-
 drivers/net/declance.c     |    6 ++----
 drivers/net/defxx.c        |   11 +++++------
 drivers/net/depca.c        |    3 +--
 drivers/net/dl2k.c         |    5 +----
 drivers/net/dm9000.c       |    5 ++---
 8 files changed, 15 insertions(+), 27 deletions(-)

diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index c9c537b..0074f3b 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -320,7 +320,6 @@ static int cpmac_config(struct net_device *dev, struct ifmap *map)
 static void cpmac_set_multicast_list(struct net_device *dev)
 {
 	struct dev_mc_list *iter;
-	int i;
 	u8 tmp;
 	u32 mbp, bit, hash[2] = { 0, };
 	struct cpmac_priv *priv = netdev_priv(dev);
@@ -340,8 +339,7 @@ static void cpmac_set_multicast_list(struct net_device *dev)
 			 * cpmac uses some strange mac address hashing
 			 * (not crc32)
 			 */
-			for (i = 0, iter = dev->mc_list; i < netdev_mc_count(dev);
-			     i++, iter = iter->next) {
+			netdev_for_each_mc_addr(iter, dev) {
 				bit = 0;
 				tmp = iter->dmi_addr[0];
 				bit  ^= (tmp >> 2) ^ (tmp << 4);
diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index c9309ea..dd24aad 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -1596,13 +1596,12 @@ set_multicast_list(struct net_device *dev)
 	} else {
 		/* MC mode, receive normal and MC packets */
 		char hash_ix;
-		struct dev_mc_list *dmi = dev->mc_list;
-		int i;
+		struct dev_mc_list *dmi;
 		char *baddr;
 
 		lo_bits = 0x00000000ul;
 		hi_bits = 0x00000000ul;
-		for (i = 0; i < num_addr; i++) {
+		netdev_for_each_mc_addr(dmi, dev) {
 			/* Calculate the hash index for the GA registers */
 
 			hash_ix = 0;
@@ -1632,7 +1631,6 @@ set_multicast_list(struct net_device *dev)
 			} else {
 				lo_bits |= (1 << hash_ix);
 			}
-			dmi = dmi->next;
 		}
 		/* Disable individual receive */
 		SETS(network_rec_config_shadow, R_NETWORK_REC_CONFIG, individual, discard);
diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index 0e79cef..1462401 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -1785,7 +1785,7 @@ static void set_multicast_list(struct net_device *dev)
 	{
 		lp->rx_mode = RX_ALL_ACCEPT;
 	}
-	else if((dev->flags&IFF_ALLMULTI)||dev->mc_list)
+	else if ((dev->flags & IFF_ALLMULTI) || !netdev_mc_empty(dev))
 	{
 		/* The multicast-accept list is initialized to accept-all, and we
 		   rely on higher-level filtering for now. */
diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index 76e0de6..8cf3cc6 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -940,9 +940,8 @@ static void lance_load_multicast(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
 	volatile u16 *ib = (volatile u16 *)dev->mem_start;
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 	char *addrs;
-	int i;
 	u32 crc;
 
 	/* set all multicast bits */
@@ -960,9 +959,8 @@ static void lance_load_multicast(struct net_device *dev)
 	*lib_ptr(ib, filter[3], lp->type) = 0;
 
 	/* Add addresses */
-	for (i = 0; i < netdev_mc_count(dev); i++) {
+	netdev_for_each_mc_addr(dmi, dev) {
 		addrs = dmi->dmi_addr;
-		dmi = dmi->next;
 
 		/* multicast address? */
 		if (!(*addrs & 1))
diff --git a/drivers/net/defxx.c b/drivers/net/defxx.c
index 5adb1e0..ed53a8d 100644
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -2240,12 +2240,11 @@ static void dfx_ctl_set_multicast_list(struct net_device *dev)
 
 		/* Copy addresses to multicast address table, then update adapter CAM */
 
-		dmi = dev->mc_list;				/* point to first multicast addr */
-		for (i=0; i < bp->mc_count; i++)
-			{
-			memcpy(&bp->mc_table[i*FDDI_K_ALEN], dmi->dmi_addr, FDDI_K_ALEN);
-			dmi = dmi->next;			/* point to next multicast addr */
-			}
+		i = 0;
+		netdev_for_each_mc_addr(dmi, dev)
+			memcpy(&bp->mc_table[i++ * FDDI_K_ALEN],
+			       dmi->dmi_addr, FDDI_K_ALEN);
+
 		if (dfx_ctl_update_cam(bp) != DFX_K_SUCCESS)
 			{
 			DBG_printk("%s: Could not update multicast address table!\n", dev->name);
diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index 314bc96..64a569b 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -1287,9 +1287,8 @@ static void SetMulticastFilter(struct net_device *dev)
 			lp->init_block.mcast_table[i] = 0;
 		}
 		/* Add multicast addresses */
-		for (i = 0; i < netdev_mc_count(dev); i++) {	/* for each address in the list */
+		netdev_for_each_mc_addr(dmi, dev) {
 			addrs = dmi->dmi_addr;
-			dmi = dmi->next;
 			if ((*addrs & 0x01) == 1) {	/* multicast address? */
 				crc = ether_crc(ETH_ALEN, addrs);
 				hashcode = (crc & 1);	/* hashcode is 6 LSb of CRC ... */
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index dea4095..b05bad8 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -1132,15 +1132,12 @@ set_multicast (struct net_device *dev)
 		/* Receive broadcast and multicast frames */
 		rx_mode = ReceiveBroadcast | ReceiveMulticast | ReceiveUnicast;
 	} else if (!netdev_mc_empty(dev)) {
-		int i;
 		struct dev_mc_list *mclist;
 		/* Receive broadcast frames and multicast frames filtering
 		   by Hashtable */
 		rx_mode =
 		    ReceiveBroadcast | ReceiveMulticastHash | ReceiveUnicast;
-		for (i=0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
-				i++, mclist=mclist->next)
-		{
+		netdev_for_each_mc_addr(mclist, dev) {
 			int bit, index = 0;
 			int crc = ether_crc_le (ETH_ALEN, mclist->dmi_addr);
 			/* The inverted high significant 6 bits of CRC are
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index da0985a..1c67f11 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -724,8 +724,7 @@ static void
 dm9000_hash_table(struct net_device *dev)
 {
 	board_info_t *db = netdev_priv(dev);
-	struct dev_mc_list *mcptr = dev->mc_list;
-	int mc_cnt = netdev_mc_count(dev);
+	struct dev_mc_list *mcptr;
 	int i, oft;
 	u32 hash_val;
 	u16 hash_table[4];
@@ -753,7 +752,7 @@ dm9000_hash_table(struct net_device *dev)
 		rcr |= RCR_ALL;
 
 	/* the multicast address in Hash Table : 64 bits */
-	for (i = 0; i < mc_cnt; i++, mcptr = mcptr->next) {
+	netdev_for_each_mc_addr(mcptr, dev) {
 		hash_val = ether_crc_le(6, mcptr->dmi_addr) & 0x3f;
 		hash_table[hash_val / 16] |= (u16) 1 << (hash_val % 16);
 	}
-- 
1.6.6

