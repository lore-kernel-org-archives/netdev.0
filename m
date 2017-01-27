From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH 1/3] net: bgmac: allocate struct bgmac just once & don't copy it
Date: Fri, 27 Jan 2017 10:20:41 +0100
Message-ID: <20170127092043.17413-2-zajec5@gmail.com>
References: <20170127092043.17413-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jon Mason <jon.mason@broadcom.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Felix Fietkau <nbd@openwrt.org>, netdev@vger.kernel.org,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35480 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754418AbdA0JVQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 04:21:16 -0500
Received: by mail-lf0-f68.google.com with SMTP id v186so25555141lfa.2
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 01:21:04 -0800 (PST)
In-Reply-To: <20170127092043.17413-1-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafał Miłecki <rafal@milecki.pl>

To share as much code as possible in bgmac we call alloc_etherdev from
bgmac.c which is used by both: platform and bcma code. The easiest
solution was to use it for allocating whole struct bgmac but it doesn't
work well as we already get early-filled struct bgmac as an argument.

So far we were solving this by copying received struct into newly
allocated one. The problem is it means storing 2 allocated structs,
using only 1 of them and non-shared code not having access to it.

This patch solves it by using alloc_etherdev to allocate *pointer* for
the already allocated struct. The only downside of this is we have to be
careful when using netdev_priv.

Another solution was to call alloc_etherdev in platform/bcma specific
code but Jon advised against it due to sharing less code that way.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
---
 drivers/net/ethernet/broadcom/bgmac-platform.c |  2 +-
 drivers/net/ethernet/broadcom/bgmac.c          | 24 +++++++++++-------------
 2 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac-platform.c b/drivers/net/ethernet/broadcom/bgmac-platform.c
index 6f736c19872f..4fefd1a74fcb 100644
--- a/drivers/net/ethernet/broadcom/bgmac-platform.c
+++ b/drivers/net/ethernet/broadcom/bgmac-platform.c
@@ -98,7 +98,7 @@ static void platform_bgmac_cmn_maskset32(struct bgmac *bgmac, u16 offset,
 
 static void bgmac_nicpm_speed_set(struct net_device *net_dev)
 {
-	struct bgmac *bgmac = netdev_priv(net_dev);
+	struct bgmac *bgmac = *(struct bgmac **)netdev_priv(net_dev);
 	u32 val;
 
 	if (!bgmac->plat.nicpm_base)
diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 0e066dc6b8cc..73d679337903 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -777,7 +777,7 @@ static void bgmac_write_mac_address(struct bgmac *bgmac, u8 *addr)
 
 static void bgmac_set_rx_mode(struct net_device *net_dev)
 {
-	struct bgmac *bgmac = netdev_priv(net_dev);
+	struct bgmac *bgmac = *(struct bgmac **)netdev_priv(net_dev);
 
 	if (net_dev->flags & IFF_PROMISC)
 		bgmac_cmdcfg_maskset(bgmac, ~0, BGMAC_CMDCFG_PROM, true);
@@ -1112,7 +1112,7 @@ static void bgmac_chip_init(struct bgmac *bgmac)
 
 static irqreturn_t bgmac_interrupt(int irq, void *dev_id)
 {
-	struct bgmac *bgmac = netdev_priv(dev_id);
+	struct bgmac *bgmac = *(struct bgmac **)netdev_priv(dev_id);
 
 	u32 int_status = bgmac_read(bgmac, BGMAC_INT_STATUS);
 	int_status &= bgmac->int_mask;
@@ -1161,7 +1161,7 @@ static int bgmac_poll(struct napi_struct *napi, int weight)
 
 static int bgmac_open(struct net_device *net_dev)
 {
-	struct bgmac *bgmac = netdev_priv(net_dev);
+	struct bgmac *bgmac = *(struct bgmac **)netdev_priv(net_dev);
 	int err = 0;
 
 	bgmac_chip_reset(bgmac);
@@ -1191,7 +1191,7 @@ static int bgmac_open(struct net_device *net_dev)
 
 static int bgmac_stop(struct net_device *net_dev)
 {
-	struct bgmac *bgmac = netdev_priv(net_dev);
+	struct bgmac *bgmac = *(struct bgmac **)netdev_priv(net_dev);
 
 	netif_carrier_off(net_dev);
 
@@ -1210,7 +1210,7 @@ static int bgmac_stop(struct net_device *net_dev)
 static netdev_tx_t bgmac_start_xmit(struct sk_buff *skb,
 				    struct net_device *net_dev)
 {
-	struct bgmac *bgmac = netdev_priv(net_dev);
+	struct bgmac *bgmac = *(struct bgmac **)netdev_priv(net_dev);
 	struct bgmac_dma_ring *ring;
 
 	/* No QOS support yet */
@@ -1220,7 +1220,7 @@ static netdev_tx_t bgmac_start_xmit(struct sk_buff *skb,
 
 static int bgmac_set_mac_address(struct net_device *net_dev, void *addr)
 {
-	struct bgmac *bgmac = netdev_priv(net_dev);
+	struct bgmac *bgmac = *(struct bgmac **)netdev_priv(net_dev);
 	int ret;
 
 	ret = eth_prepare_mac_addr_change(net_dev, addr);
@@ -1356,7 +1356,7 @@ static void bgmac_get_strings(struct net_device *dev, u32 stringset,
 static void bgmac_get_ethtool_stats(struct net_device *dev,
 				    struct ethtool_stats *ss, uint64_t *data)
 {
-	struct bgmac *bgmac = netdev_priv(dev);
+	struct bgmac *bgmac = *(struct bgmac **)netdev_priv(dev);
 	const struct bgmac_stat *s;
 	unsigned int i;
 	u64 val;
@@ -1396,7 +1396,7 @@ static const struct ethtool_ops bgmac_ethtool_ops = {
 
 void bgmac_adjust_link(struct net_device *net_dev)
 {
-	struct bgmac *bgmac = netdev_priv(net_dev);
+	struct bgmac *bgmac = *(struct bgmac **)netdev_priv(net_dev);
 	struct phy_device *phy_dev = net_dev->phydev;
 	bool update = false;
 
@@ -1446,21 +1446,19 @@ int bgmac_phy_connect_direct(struct bgmac *bgmac)
 }
 EXPORT_SYMBOL_GPL(bgmac_phy_connect_direct);
 
-int bgmac_enet_probe(struct bgmac *info)
+int bgmac_enet_probe(struct bgmac *bgmac)
 {
 	struct net_device *net_dev;
-	struct bgmac *bgmac;
 	int err;
 
 	/* Allocation and references */
-	net_dev = alloc_etherdev(sizeof(*bgmac));
+	net_dev = alloc_etherdev(sizeof(struct bgmac **));
 	if (!net_dev)
 		return -ENOMEM;
 
 	net_dev->netdev_ops = &bgmac_netdev_ops;
 	net_dev->ethtool_ops = &bgmac_ethtool_ops;
-	bgmac = netdev_priv(net_dev);
-	memcpy(bgmac, info, sizeof(*bgmac));
+	*(struct bgmac **)netdev_priv(net_dev) = bgmac;
 	bgmac->net_dev = net_dev;
 	net_dev->irq = bgmac->irq;
 	SET_NETDEV_DEV(net_dev, bgmac->dev);
-- 
2.11.0
