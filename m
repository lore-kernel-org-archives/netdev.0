From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 9/9] net/mlx4_en: Implement ndo fdb functionality
Date: Tue,  5 Feb 2013 13:28:36 +0200
Message-ID: <1360063716-13415-10-git-send-email-amirv@mellanox.com>
References: <1360063716-13415-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yan Burman <yanb@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:54243 "HELO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751618Ab3BEL3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 06:29:01 -0500
In-Reply-To: <1360063716-13415-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yan Burman <yanb@mellanox.com>

Add support for setting embedded switch fdb in case of SRIOV, by
implementing ndo_fdb_{add, del, dump}. This will allow to use
bridged configuration with multi-function. In order to add VM MAC
to the eSwitch fdb, the following command may be used over the relevant function interface:
bridge fdb add <MAC> permanent self dev <IFACE>

Signed-off-by: Yan Burman <yanb@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   75 ++++++++++++++++++++++++
 1 files changed, 75 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index e5d1d79..3c4aa9e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1909,6 +1909,78 @@ static int mlx4_en_set_features(struct net_device *netdev,
 
 }
 
+static int mlx4_en_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
+			   struct net_device *dev,
+			   const unsigned char *addr, u16 flags)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_dev *mdev = priv->mdev->dev;
+	int err;
+
+	if (!mlx4_is_mfunc(mdev))
+		return -EOPNOTSUPP;
+
+	/* Hardware does not support aging addresses, allow only
+	 * permanent addresses if ndm_state is given
+	 */
+	if (ndm->ndm_state && !(ndm->ndm_state & NUD_PERMANENT)) {
+		en_info(priv, "Add FDB only supports static addresses\n");
+		return -EINVAL;
+	}
+
+	if (is_unicast_ether_addr(addr) || is_link_local_ether_addr(addr))
+		err = dev_uc_add_excl(dev, addr);
+	else if (is_multicast_ether_addr(addr))
+		err = dev_mc_add_excl(dev, addr);
+	else
+		err = -EINVAL;
+
+	/* Only return duplicate errors if NLM_F_EXCL is set */
+	if (err == -EEXIST && !(flags & NLM_F_EXCL))
+		err = 0;
+
+	return err;
+}
+
+static int mlx4_en_fdb_del(struct ndmsg *ndm,
+			   struct net_device *dev,
+			   const unsigned char *addr)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_dev *mdev = priv->mdev->dev;
+	int err;
+
+	if (!mlx4_is_mfunc(mdev))
+		return -EOPNOTSUPP;
+
+	if (ndm->ndm_state && !(ndm->ndm_state & NUD_PERMANENT)) {
+		en_info(priv, "Del FDB only supports static addresses\n");
+		return -EINVAL;
+	}
+
+	if (is_unicast_ether_addr(addr) || is_link_local_ether_addr(addr))
+		err = dev_uc_del(dev, addr);
+	else if (is_multicast_ether_addr(addr))
+		err = dev_mc_del(dev, addr);
+	else
+		err = -EINVAL;
+
+	return err;
+}
+
+static int mlx4_en_fdb_dump(struct sk_buff *skb,
+			    struct netlink_callback *cb,
+			    struct net_device *dev, int idx)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_dev *mdev = priv->mdev->dev;
+
+	if (mlx4_is_mfunc(mdev))
+		idx = ndo_dflt_fdb_dump(skb, cb, dev, idx);
+
+	return idx;
+}
+
 static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_open		= mlx4_en_open,
 	.ndo_stop		= mlx4_en_close,
@@ -1930,6 +2002,9 @@ static const struct net_device_ops mlx4_netdev_ops = {
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	= mlx4_en_filter_rfs,
 #endif
+	.ndo_fdb_add		= mlx4_en_fdb_add,
+	.ndo_fdb_del		= mlx4_en_fdb_del,
+	.ndo_fdb_dump		= mlx4_en_fdb_dump,
 };
 
 int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
-- 
1.7.6.4
