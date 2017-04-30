From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 06/15] net/mlx5e: Read neigh parameters with proper locking
Date: Sun, 30 Apr 2017 16:20:07 +0300
Message-ID: <20170430132016.27012-7-saeedm@mellanox.com>
References: <20170430132016.27012-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46758 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756811AbdD3NU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 09:20:27 -0400
In-Reply-To: <20170430132016.27012-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

The nud_state and hardware address fields are protected by the neighbour
lock, we should acquire it before accessing those parameters.

Use this lock to avoid inconsistency between the neighbour validity state
and it's hardware address.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 2a9289b8a33b..ae07fe6473bb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -1223,6 +1223,7 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 	struct flowi4 fl4 = {};
 	char *encap_header;
 	int ttl, err;
+	u8 nud_state;
 
 	if (max_encap_size < ipv4_encap_size) {
 		mlx5_core_warn(priv->mdev, "encap size %d too big, max supported is %d\n",
@@ -1252,7 +1253,12 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 	if (err)
 		goto out;
 
-	if (!(n->nud_state & NUD_VALID)) {
+	read_lock_bh(&n->lock);
+	nud_state = n->nud_state;
+	ether_addr_copy(e->h_dest, n->ha);
+	read_unlock_bh(&n->lock);
+
+	if (!(nud_state & NUD_VALID)) {
 		pr_warn("%s: can't offload, neighbour to %pI4 invalid\n", __func__, &fl4.daddr);
 		err = -EOPNOTSUPP;
 		goto out;
@@ -1261,8 +1267,6 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 	e->n = n;
 	e->out_dev = out_dev;
 
-	neigh_ha_snapshot(e->h_dest, n, out_dev);
-
 	switch (e->tunnel_type) {
 	case MLX5_HEADER_TYPE_VXLAN:
 		gen_vxlan_header_ipv4(out_dev, encap_header,
@@ -1297,6 +1301,7 @@ static int mlx5e_create_encap_header_ipv6(struct mlx5e_priv *priv,
 	struct flowi6 fl6 = {};
 	char *encap_header;
 	int err, ttl = 0;
+	u8 nud_state;
 
 	if (max_encap_size < ipv6_encap_size) {
 		mlx5_core_warn(priv->mdev, "encap size %d too big, max supported is %d\n",
@@ -1327,7 +1332,12 @@ static int mlx5e_create_encap_header_ipv6(struct mlx5e_priv *priv,
 	if (err)
 		goto out;
 
-	if (!(n->nud_state & NUD_VALID)) {
+	read_lock_bh(&n->lock);
+	nud_state = n->nud_state;
+	ether_addr_copy(e->h_dest, n->ha);
+	read_unlock_bh(&n->lock);
+
+	if (!(nud_state & NUD_VALID)) {
 		pr_warn("%s: can't offload, neighbour to %pI6 invalid\n", __func__, &fl6.daddr);
 		err = -EOPNOTSUPP;
 		goto out;
@@ -1336,8 +1346,6 @@ static int mlx5e_create_encap_header_ipv6(struct mlx5e_priv *priv,
 	e->n = n;
 	e->out_dev = out_dev;
 
-	neigh_ha_snapshot(e->h_dest, n, out_dev);
-
 	switch (e->tunnel_type) {
 	case MLX5_HEADER_TYPE_VXLAN:
 		gen_vxlan_header_ipv6(out_dev, encap_header,
-- 
2.11.0
