From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] net/arm: convert to use netdev_for_each_mc_addr
Date: Sat, 20 Feb 2010 10:06:27 +0100
Message-ID: <20100220090626.GA2607@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18582 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754148Ab0BTJGa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Feb 2010 04:06:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/arm/am79c961a.c     |   10 +++++-----
 drivers/net/arm/at91_ether.c    |    7 ++-----
 drivers/net/arm/ixp4xx_eth.c    |   13 ++++++++-----
 drivers/net/arm/ks8695net.c     |   20 +++++++++-----------
 drivers/net/arm/w90p910_ether.c |    8 ++++----
 5 files changed, 28 insertions(+), 30 deletions(-)

diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
index 1c3c1f9..f1f58c5 100644
--- a/drivers/net/arm/am79c961a.c
+++ b/drivers/net/arm/am79c961a.c
@@ -351,13 +351,13 @@ static struct net_device_stats *am79c961_getstats (struct net_device *dev)
 	return &priv->stats;
 }
 
-static void am79c961_mc_hash(struct dev_mc_list *dmi, unsigned short *hash)
+static void am79c961_mc_hash(char *addr, unsigned short *hash)
 {
-	if (dmi->dmi_addrlen == ETH_ALEN && dmi->dmi_addr[0] & 0x01) {
+	if (addr[0] & 0x01) {
 		int idx, bit;
 		u32 crc;
 
-		crc = ether_crc_le(ETH_ALEN, dmi->dmi_addr);
+		crc = ether_crc_le(ETH_ALEN, addr);
 
 		idx = crc >> 30;
 		bit = (crc >> 26) & 15;
@@ -387,8 +387,8 @@ static void am79c961_setmulticastlist (struct net_device *dev)
 
 		memset(multi_hash, 0x00, sizeof(multi_hash));
 
-		for (dmi = dev->mc_list; dmi; dmi = dmi->next)
-			am79c961_mc_hash(dmi, multi_hash);
+		netdev_for_each_mc_addr(dmi, dev)
+			am79c961_mc_hash(dmi->dmi_addr, multi_hash);
 	}
 
 	spin_lock_irqsave(&priv->chip_lock, flags);
diff --git a/drivers/net/arm/at91_ether.c b/drivers/net/arm/at91_ether.c
index 17d85d9..8b23d5a 100644
--- a/drivers/net/arm/at91_ether.c
+++ b/drivers/net/arm/at91_ether.c
@@ -558,14 +558,11 @@ static void at91ether_sethashtable(struct net_device *dev)
 {
 	struct dev_mc_list *curr;
 	unsigned long mc_filter[2];
-	unsigned int i, bitnr;
+	unsigned int bitnr;
 
 	mc_filter[0] = mc_filter[1] = 0;
 
-	curr = dev->mc_list;
-	for (i = 0; i < netdev_mc_count(dev); i++, curr = curr->next) {
-		if (!curr) break;	/* unexpected end of list */
-
+	netdev_for_each_mc_addr(curr, dev) {
 		bitnr = hash_get_index(curr->dmi_addr);
 		mc_filter[bitnr >> 5] |= 1 << (bitnr & 31);
 	}
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index 1a5f78b..6e2ae1d 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -735,22 +735,25 @@ static int eth_xmit(struct sk_buff *skb, struct net_device *dev)
 static void eth_set_mcast_list(struct net_device *dev)
 {
 	struct port *port = netdev_priv(dev);
-	struct dev_mc_list *mclist = dev->mc_list;
+	struct dev_mc_list *mclist;
 	u8 diffs[ETH_ALEN], *addr;
-	int cnt = netdev_mc_count(dev), i;
+	int i;
 
-	if ((dev->flags & IFF_PROMISC) || !mclist || !cnt) {
+	if ((dev->flags & IFF_PROMISC) || netdev_mc_empty(dev)) {
 		__raw_writel(DEFAULT_RX_CNTRL0 & ~RX_CNTRL0_ADDR_FLTR_EN,
 			     &port->regs->rx_control[0]);
 		return;
 	}
 
 	memset(diffs, 0, ETH_ALEN);
-	addr = mclist->dmi_addr; /* first MAC address */
 
-	while (--cnt && (mclist = mclist->next))
+	addr = NULL;
+	netdev_for_each_mc_addr(mclist, dev) {
+		if (!addr)
+			addr = mclist->dmi_addr; /* first MAC address */
 		for (i = 0; i < ETH_ALEN; i++)
 			diffs[i] |= addr[i] ^ mclist->dmi_addr[i];
+	}
 
 	for (i = 0; i < ETH_ALEN; i++) {
 		__raw_writel(addr[i], &port->regs->mcast_addr[i]);
diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
index 1dc181a..2380696 100644
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -327,25 +327,24 @@ ks8695_refill_rxbuffers(struct ks8695_priv *ksp)
  */
 static void
 ks8695_init_partial_multicast(struct ks8695_priv *ksp,
-			      struct dev_mc_list *addr,
-			      int nr_addr)
+			      struct net_device *ndev)
 {
 	u32 low, high;
 	int i;
+	struct dev_mc_list *dmi;
 
-	for (i = 0; i < nr_addr; i++, addr = addr->next) {
-		/* Ran out of addresses? */
-		if (!addr)
-			break;
+	i = 0;
+	netdev_for_each_mc_addr(dmi, ndev) {
 		/* Ran out of space in chip? */
 		BUG_ON(i == KS8695_NR_ADDRESSES);
 
-		low = (addr->dmi_addr[2] << 24) | (addr->dmi_addr[3] << 16) |
-			(addr->dmi_addr[4] << 8) | (addr->dmi_addr[5]);
-		high = (addr->dmi_addr[0] << 8) | (addr->dmi_addr[1]);
+		low = (dmi->dmi_addr[2] << 24) | (dmi->dmi_addr[3] << 16) |
+		      (dmi->dmi_addr[4] << 8) | (dmi->dmi_addr[5]);
+		high = (dmi->dmi_addr[0] << 8) | (dmi->dmi_addr[1]);
 
 		ks8695_writereg(ksp, KS8695_AAL_(i), low);
 		ks8695_writereg(ksp, KS8695_AAH_(i), AAH_E | high);
+		i++;
 	}
 
 	/* Clear the remaining Additional Station Addresses */
@@ -1215,8 +1214,7 @@ ks8695_set_multicast(struct net_device *ndev)
 	} else {
 		/* enable specific multicasts */
 		ctrl &= ~DRXC_RM;
-		ks8695_init_partial_multicast(ksp, ndev->mc_list,
-					      netdev_mc_count(ndev));
+		ks8695_init_partial_multicast(ksp, ndev);
 	}
 
 	ks8695_writereg(ksp, KS8695_DRXC, ctrl);
diff --git a/drivers/net/arm/w90p910_ether.c b/drivers/net/arm/w90p910_ether.c
index b7f3866..febd813 100644
--- a/drivers/net/arm/w90p910_ether.c
+++ b/drivers/net/arm/w90p910_ether.c
@@ -858,10 +858,10 @@ static void w90p910_ether_set_multicast_list(struct net_device *dev)
 
 	if (dev->flags & IFF_PROMISC)
 		rx_mode = CAMCMR_AUP | CAMCMR_AMP | CAMCMR_ABP | CAMCMR_ECMP;
-	else if ((dev->flags & IFF_ALLMULTI) || dev->mc_list)
-			rx_mode = CAMCMR_AMP | CAMCMR_ABP | CAMCMR_ECMP;
-		else
-				rx_mode = CAMCMR_ECMP | CAMCMR_ABP;
+	else if ((dev->flags & IFF_ALLMULTI) || !netdev_mc_empty(dev))
+		rx_mode = CAMCMR_AMP | CAMCMR_ABP | CAMCMR_ECMP;
+	else
+		rx_mode = CAMCMR_ECMP | CAMCMR_ABP;
 	__raw_writel(rx_mode, ether->reg + REG_CAMCMR);
 }
 
-- 
1.6.6

