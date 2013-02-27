From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH 3/3] mlx4: Use default fdb handlers when not multifunction.
Date: Wed, 27 Feb 2013 12:46:04 -0500
Message-ID: <1361987164-15280-4-git-send-email-vyasevic@redhat.com>
References: <1361987164-15280-1-git-send-email-vyasevic@redhat.com>
Cc: john.r.fastabend@intel.com, davem@davemloft.net,
	Vlad Yasevich <vyasevic@redhat.com>,
	Amir Vadai <amirv@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46794 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932182Ab3B0RqR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2013 12:46:17 -0500
In-Reply-To: <1361987164-15280-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the use of ndo_dflt_fdb_<add|del|dump> when the
adapter is not configured with virtual functins (!mlx4_is_mfunc())
This allows proper IFF_UNICAST_FLT support and allows for
additional handling by the driver if needed.

CC: Amir Vadai <amirv@mellanox.com>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 5385474..5732025 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1934,7 +1934,7 @@ static int mlx4_en_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	int err;
 
 	if (!mlx4_is_mfunc(mdev))
-		return -EOPNOTSUPP;
+		return ndo_dflt_fdb_add(ndm, tb, dev, addr, flags);
 
 	/* Hardware does not support aging addresses, allow only
 	 * permanent addresses if ndm_state is given
@@ -1968,7 +1968,7 @@ static int mlx4_en_fdb_del(struct ndmsg *ndm,
 	int err;
 
 	if (!mlx4_is_mfunc(mdev))
-		return -EOPNOTSUPP;
+		return ndo_dflt_fdb_del(ndm, tb, dev, addr);
 
 	if (ndm->ndm_state && !(ndm->ndm_state & NUD_PERMANENT)) {
 		en_info(priv, "Del FDB only supports static addresses\n");
@@ -1989,13 +1989,7 @@ static int mlx4_en_fdb_dump(struct sk_buff *skb,
 			    struct netlink_callback *cb,
 			    struct net_device *dev, int idx)
 {
-	struct mlx4_en_priv *priv = netdev_priv(dev);
-	struct mlx4_dev *mdev = priv->mdev->dev;
-
-	if (mlx4_is_mfunc(mdev))
-		idx = ndo_dflt_fdb_dump(skb, cb, dev, idx);
-
-	return idx;
+	return ndo_dflt_fdb_dump(skb, cb, dev, idx);
 }
 
 static const struct net_device_ops mlx4_netdev_ops = {
-- 
1.7.7.6
