From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/42] net: add dev arg to ndo_neigh_construct/destroy
Date: Fri,  1 Jul 2016 16:04:29 +0200
Message-ID: <1467381910-3445-2-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33730 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151AbcGAOSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:18:51 -0400
Received: by mail-wm0-f65.google.com with SMTP id r201so5668461wme.0
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:18:51 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

As the following patch will allow upper devices to follow the call down
lower devices, we need to add dev here and not rely on n->dev.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker_main.c | 3 ++-
 include/linux/netdevice.h                 | 6 ++++--
 net/atm/clip.c                            | 2 +-
 net/core/neighbour.c                      | 4 ++--
 net/ieee802154/6lowpan/core.c             | 2 +-
 5 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 28b775e..f0b09b0 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1996,7 +1996,8 @@ static int rocker_port_change_proto_down(struct net_device *dev,
 	return 0;
 }
 
-static void rocker_port_neigh_destroy(struct neighbour *n)
+static void rocker_port_neigh_destroy(struct net_device *dev,
+				      struct neighbour *n)
 {
 	struct rocker_port *rocker_port = netdev_priv(n->dev);
 	int err;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e84d9d2..f126119 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1209,8 +1209,10 @@ struct net_device_ops {
 						    netdev_features_t features);
 	int			(*ndo_set_features)(struct net_device *dev,
 						    netdev_features_t features);
-	int			(*ndo_neigh_construct)(struct neighbour *n);
-	void			(*ndo_neigh_destroy)(struct neighbour *n);
+	int			(*ndo_neigh_construct)(struct net_device *dev,
+						       struct neighbour *n);
+	void			(*ndo_neigh_destroy)(struct net_device *dev,
+						     struct neighbour *n);
 
 	int			(*ndo_fdb_add)(struct ndmsg *ndm,
 					       struct nlattr *tb[],
diff --git a/net/atm/clip.c b/net/atm/clip.c
index e07f551..53b4ac0 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -286,7 +286,7 @@ static const struct neigh_ops clip_neigh_ops = {
 	.connected_output =	neigh_direct_output,
 };
 
-static int clip_constructor(struct neighbour *neigh)
+static int clip_constructor(struct net_device *dev, struct neighbour *neigh)
 {
 	struct atmarp_entry *entry = neighbour_priv(neigh);
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 510cd62..952aabb 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -473,7 +473,7 @@ struct neighbour *__neigh_create(struct neigh_table *tbl, const void *pkey,
 	}
 
 	if (dev->netdev_ops->ndo_neigh_construct) {
-		error = dev->netdev_ops->ndo_neigh_construct(n);
+		error = dev->netdev_ops->ndo_neigh_construct(dev, n);
 		if (error < 0) {
 			rc = ERR_PTR(error);
 			goto out_neigh_release;
@@ -701,7 +701,7 @@ void neigh_destroy(struct neighbour *neigh)
 	neigh->arp_queue_len_bytes = 0;
 
 	if (dev->netdev_ops->ndo_neigh_destroy)
-		dev->netdev_ops->ndo_neigh_destroy(neigh);
+		dev->netdev_ops->ndo_neigh_destroy(dev, neigh);
 
 	dev_put(dev);
 	neigh_parms_put(neigh->parms);
diff --git a/net/ieee802154/6lowpan/core.c b/net/ieee802154/6lowpan/core.c
index 8c004a0..935ab93 100644
--- a/net/ieee802154/6lowpan/core.c
+++ b/net/ieee802154/6lowpan/core.c
@@ -81,7 +81,7 @@ static int lowpan_stop(struct net_device *dev)
 	return 0;
 }
 
-static int lowpan_neigh_construct(struct neighbour *n)
+static int lowpan_neigh_construct(struct net_device *dev, struct neighbour *n)
 {
 	struct lowpan_802154_neigh *neigh = lowpan_802154_neigh(neighbour_priv(n));
 
-- 
2.5.5
