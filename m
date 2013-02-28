From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next 3/4] mlx4: Remove driver specific fdb handlers.
Date: Thu, 28 Feb 2013 18:13:02 -0500
Message-ID: <1362093183-5938-4-git-send-email-vyasevic@redhat.com>
References: <1362093183-5938-1-git-send-email-vyasevic@redhat.com>
Cc: john.r.fastabend@intel.com, Vlad Yasevich <vyasevic@redhat.com>,
	Amir Vadai <amirv@mellanox.com>, Yan Burman <yanb@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44301 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752906Ab3B1XOf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2013 18:14:35 -0500
In-Reply-To: <1362093183-5938-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove driver specific fdb hadlers since they are the same as
the default ones.

CC: Amir Vadai <amirv@mellanox.com>
CC: Yan Burman <yanb@mellanox.com>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   76 ------------------------
 1 files changed, 0 insertions(+), 76 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 5385474..5c1bb44 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1925,79 +1925,6 @@ static int mlx4_en_set_features(struct net_device *netdev,
 
 }
 
-static int mlx4_en_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
-			   struct net_device *dev,
-			   const unsigned char *addr, u16 flags)
-{
-	struct mlx4_en_priv *priv = netdev_priv(dev);
-	struct mlx4_dev *mdev = priv->mdev->dev;
-	int err;
-
-	if (!mlx4_is_mfunc(mdev))
-		return -EOPNOTSUPP;
-
-	/* Hardware does not support aging addresses, allow only
-	 * permanent addresses if ndm_state is given
-	 */
-	if (ndm->ndm_state && !(ndm->ndm_state & NUD_PERMANENT)) {
-		en_info(priv, "Add FDB only supports static addresses\n");
-		return -EINVAL;
-	}
-
-	if (is_unicast_ether_addr(addr) || is_link_local_ether_addr(addr))
-		err = dev_uc_add_excl(dev, addr);
-	else if (is_multicast_ether_addr(addr))
-		err = dev_mc_add_excl(dev, addr);
-	else
-		err = -EINVAL;
-
-	/* Only return duplicate errors if NLM_F_EXCL is set */
-	if (err == -EEXIST && !(flags & NLM_F_EXCL))
-		err = 0;
-
-	return err;
-}
-
-static int mlx4_en_fdb_del(struct ndmsg *ndm,
-			   struct nlattr *tb[],
-			   struct net_device *dev,
-			   const unsigned char *addr)
-{
-	struct mlx4_en_priv *priv = netdev_priv(dev);
-	struct mlx4_dev *mdev = priv->mdev->dev;
-	int err;
-
-	if (!mlx4_is_mfunc(mdev))
-		return -EOPNOTSUPP;
-
-	if (ndm->ndm_state && !(ndm->ndm_state & NUD_PERMANENT)) {
-		en_info(priv, "Del FDB only supports static addresses\n");
-		return -EINVAL;
-	}
-
-	if (is_unicast_ether_addr(addr) || is_link_local_ether_addr(addr))
-		err = dev_uc_del(dev, addr);
-	else if (is_multicast_ether_addr(addr))
-		err = dev_mc_del(dev, addr);
-	else
-		err = -EINVAL;
-
-	return err;
-}
-
-static int mlx4_en_fdb_dump(struct sk_buff *skb,
-			    struct netlink_callback *cb,
-			    struct net_device *dev, int idx)
-{
-	struct mlx4_en_priv *priv = netdev_priv(dev);
-	struct mlx4_dev *mdev = priv->mdev->dev;
-
-	if (mlx4_is_mfunc(mdev))
-		idx = ndo_dflt_fdb_dump(skb, cb, dev, idx);
-
-	return idx;
-}
-
 static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_open		= mlx4_en_open,
 	.ndo_stop		= mlx4_en_close,
@@ -2019,9 +1946,6 @@ static const struct net_device_ops mlx4_netdev_ops = {
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	= mlx4_en_filter_rfs,
 #endif
-	.ndo_fdb_add		= mlx4_en_fdb_add,
-	.ndo_fdb_del		= mlx4_en_fdb_del,
-	.ndo_fdb_dump		= mlx4_en_fdb_dump,
 };
 
 int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
-- 
1.7.7.6
