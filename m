From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
Subject: [PATCH] greth: some driver cleanups
Date: Fri, 19 Feb 2010 14:14:39 +0300
Message-ID: <20100219111439.GA4046@coldcone>
Reply-To: kirjanov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: kristoffer@gaisler.com, jpirko@redhat.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:39038 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751945Ab0BSLMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 06:12:50 -0500
Received: by fg-out-1718.google.com with SMTP id 22so15729fge.1
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 03:12:48 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some driver cleanups:
* convert to use phy_find_first/phy_direct_connect
* convert to use netdev_mc_* helpers
* fixed missing validate_addr hook
* removed netdev_priv castings

Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>

---
 drivers/net/greth.c |   38 +++++++++++++++-----------------------
 1 files changed, 15 insertions(+), 23 deletions(-)

diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index 457da1c..38620da 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -965,7 +965,7 @@ static int greth_set_mac_add(struct net_device *dev, void *p)
 	struct greth_private *greth;
 	struct greth_regs *regs;
 
-	greth = (struct greth_private *) netdev_priv(dev);
+	greth = netdev_priv(dev);
 	regs = (struct greth_regs *) greth->regs;
 
 	if (!is_valid_ether_addr(addr->sa_data))
@@ -988,16 +988,14 @@ static u32 greth_hash_get_index(__u8 *addr)
 static void greth_set_hash_filter(struct net_device *dev)
 {
 	struct dev_mc_list *curr;
-	struct greth_private *greth = (struct greth_private *) netdev_priv(dev);
+	struct greth_private *greth = netdev_priv(dev);
 	struct greth_regs *regs = (struct greth_regs *) greth->regs;
 	u32 mc_filter[2];
-	unsigned int i, bitnr;
+	unsigned int bitnr;
 
 	mc_filter[0] = mc_filter[1] = 0;
 
-	curr = dev->mc_list;
-
-	for (i = 0; i < dev->mc_count; i++, curr = curr->next) {
+	netdev_for_each_mc_addr(curr, dev) {
 
 		if (!curr)
 			break;	/* unexpected end of list */
@@ -1031,7 +1029,7 @@ static void greth_set_multicast_list(struct net_device *dev)
 			return;
 		}
 
-		if (dev->mc_count == 0) {
+		if (!netdev_mc_count(dev)) {
 			cfg &= ~GRETH_CTRL_MCEN;
 			GRETH_REGSAVE(regs->control, cfg);
 			return;
@@ -1160,6 +1158,7 @@ static struct net_device_ops greth_netdev_ops = {
 	.ndo_stop = greth_close,
 	.ndo_start_xmit = greth_start_xmit,
 	.ndo_set_mac_address = greth_set_mac_add,
+	.ndo_validate_addr 	= eth_validate_addr,
 };
 
 static inline int wait_for_mdio(struct greth_private *greth)
@@ -1275,28 +1274,21 @@ static int greth_mdio_probe(struct net_device *dev)
 {
 	struct greth_private *greth = netdev_priv(dev);
 	struct phy_device *phy = NULL;
-	u32 interface;
-	int i;
+	int ret;
 
 	/* Find the first PHY */
-	for (i = 0; i < PHY_MAX_ADDR; i++) {
-		if (greth->mdio->phy_map[i]) {
-			phy = greth->mdio->phy_map[i];
-			break;
-		}
-	}
+	phy = phy_find_first(greth->mdio);
+
 	if (!phy) {
 		if (netif_msg_probe(greth))
 			dev_err(&dev->dev, "no PHY found\n");
 		return -ENXIO;
 	}
 
-	if (greth->gbit_mac)
-		interface = PHY_INTERFACE_MODE_GMII;
-	else
-		interface = PHY_INTERFACE_MODE_MII;
-
-	phy = phy_connect(dev, dev_name(&phy->dev), &greth_link_change, 0, interface);
+	ret = phy_connect_direct(dev, phy, &greth_link_change,
+			0, greth->gbit_mac ?
+			PHY_INTERFACE_MODE_GMII :
+			PHY_INTERFACE_MODE_MII);
 
 	if (greth->gbit_mac)
 		phy->supported &= PHY_GBIT_FEATURES;
@@ -1305,10 +1297,10 @@ static int greth_mdio_probe(struct net_device *dev)
 
 	phy->advertising = phy->supported;
 
-	if (IS_ERR(phy)) {
+	if (ret) {
 		if (netif_msg_ifup(greth))
 			dev_err(&dev->dev, "could not attach to PHY\n");
-		return PTR_ERR(phy);
+		return ret;
 	}
 
 	greth->link = 0;
