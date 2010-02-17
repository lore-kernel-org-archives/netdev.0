From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] cxgb3: convert to use netdev_for_each_addr
Date: Wed, 17 Feb 2010 23:27:14 +0100
Message-ID: <20100217222714.GF2635@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, divy@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24515 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757320Ab0BQW1U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 17:27:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed whole t3_rx_mode structure and appropriate helpers cause they are no
longer needed.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/cxgb3/common.h     |   28 +---------------------------
 drivers/net/cxgb3/cxgb3_main.c |    8 ++------
 drivers/net/cxgb3/xgmac.c      |   15 ++++++++-------
 3 files changed, 11 insertions(+), 40 deletions(-)

diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 6ff356d..fe08a00 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -67,32 +67,6 @@
 /* Additional NETIF_MSG_* categories */
 #define NETIF_MSG_MMIO 0x8000000
 
-struct t3_rx_mode {
-	struct net_device *dev;
-	struct dev_mc_list *mclist;
-	unsigned int idx;
-};
-
-static inline void init_rx_mode(struct t3_rx_mode *p, struct net_device *dev,
-				struct dev_mc_list *mclist)
-{
-	p->dev = dev;
-	p->mclist = mclist;
-	p->idx = 0;
-}
-
-static inline u8 *t3_get_next_mcaddr(struct t3_rx_mode *rm)
-{
-	u8 *addr = NULL;
-
-	if (rm->mclist && rm->idx < rm->dev->mc_count) {
-		addr = rm->mclist->dmi_addr;
-		rm->mclist = rm->mclist->next;
-		rm->idx++;
-	}
-	return addr;
-}
-
 enum {
 	MAX_NPORTS = 2,		/* max # of ports */
 	MAX_FRAME_SIZE = 10240,	/* max MAC frame size, including header + FCS */
@@ -746,7 +720,7 @@ void t3_mac_enable_exact_filters(struct cmac *mac);
 int t3_mac_enable(struct cmac *mac, int which);
 int t3_mac_disable(struct cmac *mac, int which);
 int t3_mac_set_mtu(struct cmac *mac, unsigned int mtu);
-int t3_mac_set_rx_mode(struct cmac *mac, struct t3_rx_mode *rm);
+int t3_mac_set_rx_mode(struct cmac *mac, struct net_device *dev);
 int t3_mac_set_address(struct cmac *mac, unsigned int idx, u8 addr[6]);
 int t3_mac_set_num_ucast(struct cmac *mac, int n);
 const struct mac_stats *t3_mac_update_stats(struct cmac *mac);
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 73622f5..6fd968a 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -324,11 +324,9 @@ void t3_os_phymod_changed(struct adapter *adap, int port_id)
 
 static void cxgb_set_rxmode(struct net_device *dev)
 {
-	struct t3_rx_mode rm;
 	struct port_info *pi = netdev_priv(dev);
 
-	init_rx_mode(&rm, dev, dev->mc_list);
-	t3_mac_set_rx_mode(&pi->mac, &rm);
+	t3_mac_set_rx_mode(&pi->mac, dev);
 }
 
 /**
@@ -339,17 +337,15 @@ static void cxgb_set_rxmode(struct net_device *dev)
  */
 static void link_start(struct net_device *dev)
 {
-	struct t3_rx_mode rm;
 	struct port_info *pi = netdev_priv(dev);
 	struct cmac *mac = &pi->mac;
 
-	init_rx_mode(&rm, dev, dev->mc_list);
 	t3_mac_reset(mac);
 	t3_mac_set_num_ucast(mac, MAX_MAC_IDX);
 	t3_mac_set_mtu(mac, dev->mtu);
 	t3_mac_set_address(mac, LAN_MAC_IDX, dev->dev_addr);
 	t3_mac_set_address(mac, SAN_MAC_IDX, pi->iscsic.mac_addr);
-	t3_mac_set_rx_mode(mac, &rm);
+	t3_mac_set_rx_mode(mac, dev);
 	t3_link_start(&pi->phy, mac, &pi->link_config);
 	t3_mac_enable(mac, MAC_DIRECTION_RX | MAC_DIRECTION_TX);
 }
diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index 0c08de5..c142a21 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -297,29 +297,30 @@ static int hash_hw_addr(const u8 * addr)
 	return hash;
 }
 
-int t3_mac_set_rx_mode(struct cmac *mac, struct t3_rx_mode *rm)
+int t3_mac_set_rx_mode(struct cmac *mac, struct net_device *dev)
 {
 	u32 val, hash_lo, hash_hi;
 	struct adapter *adap = mac->adapter;
 	unsigned int oft = mac->offset;
 
 	val = t3_read_reg(adap, A_XGM_RX_CFG + oft) & ~F_COPYALLFRAMES;
-	if (rm->dev->flags & IFF_PROMISC)
+	if (dev->flags & IFF_PROMISC)
 		val |= F_COPYALLFRAMES;
 	t3_write_reg(adap, A_XGM_RX_CFG + oft, val);
 
-	if (rm->dev->flags & IFF_ALLMULTI)
+	if (dev->flags & IFF_ALLMULTI)
 		hash_lo = hash_hi = 0xffffffff;
 	else {
-		u8 *addr;
+		struct dev_mc_list *dmi;
 		int exact_addr_idx = mac->nucast;
 
 		hash_lo = hash_hi = 0;
-		while ((addr = t3_get_next_mcaddr(rm)))
+		netdev_for_each_mc_addr(dmi, dev)
 			if (exact_addr_idx < EXACT_ADDR_FILTERS)
-				set_addr_filter(mac, exact_addr_idx++, addr);
+				set_addr_filter(mac, exact_addr_idx++,
+						dmi->dmi_addr);
 			else {
-				int hash = hash_hw_addr(addr);
+				int hash = hash_hw_addr(dmi->dmi_addr);
 
 				if (hash < 32)
 					hash_lo |= (1 << hash);
-- 
1.6.6

