From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH RFC v3] ethtool: implement helper to get flow_type value
Date: Tue, 29 Nov 2016 10:45:28 -0800
Message-ID: <20161129184528.13486-1-jacob.e.keller@intel.com>
Cc: David Miller <davem@davemloft.net>,
        Jakub Kicinski <kubakici@wp.pl>,
        Jacob Keller <jacob.e.keller@intel.com>
To: netdev@vger.kernel.org,
        Intel Wired LAN <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:65342 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753048AbcK2Spc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 13:45:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Often a driver wants to store the flow type and thus it must mask the
extra fields. This is a task that could grow more complex as more flags
are added in the future. Add a helper function that masks the flags for
marking additional fields.

Modify drivers in drivers/net/ethernet that currently check for FLOW_EXT
and FLOW_MAC_EXT to use the helper. Currently this is only the mellanox
drivers.

I chose not to modify other drivers as I'm actually unsure whether we
should always mask the flow type even for drivers which don't recognize
the newer flags. On the one hand, today's drivers (generally)
automatically fail when a new flag is used because they won't mask it
and their checks against flow_type will not match. On the other hand, it
means another place that you have to update when you begin implementing
a flag.

An alternative is to have the driver store a set of flags that it knows
about, and then have ethtool core do the check for us to discard frames.
I haven't implemented this quite yet.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c         | 4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c | 6 +++---
 include/uapi/linux/ethtool.h                            | 5 +++++
 3 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 487a58f9c192..d8f9839ce2a3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1270,7 +1270,7 @@ static int mlx4_en_validate_flow(struct net_device *dev,
 			return -EINVAL;
 	}
 
-	switch (cmd->fs.flow_type & ~(FLOW_EXT | FLOW_MAC_EXT)) {
+	switch (ethtool_get_flow_spec_type(cmd->fs.flow_type)) {
 	case TCP_V4_FLOW:
 	case UDP_V4_FLOW:
 		if (cmd->fs.m_u.tcp_ip4_spec.tos)
@@ -1493,7 +1493,7 @@ static int mlx4_en_ethtool_to_net_trans_rule(struct net_device *dev,
 	if (err)
 		return err;
 
-	switch (cmd->fs.flow_type & ~(FLOW_EXT | FLOW_MAC_EXT)) {
+	switch (ethtool_get_flow_spec_type(cmd->fs.flow_type)) {
 	case ETHER_FLOW:
 		spec_l2 = kzalloc(sizeof(*spec_l2), GFP_KERNEL);
 		if (!spec_l2)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
index 3691451c728c..066e6c5cf38b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
@@ -63,7 +63,7 @@ static struct mlx5e_ethtool_table *get_flow_table(struct mlx5e_priv *priv,
 	int table_size;
 	int prio;
 
-	switch (fs->flow_type & ~(FLOW_EXT | FLOW_MAC_EXT)) {
+	switch (ethtool_get_flow_spec_type(fs->flow_type)) {
 	case TCP_V4_FLOW:
 	case UDP_V4_FLOW:
 		max_tuples = ETHTOOL_NUM_L3_L4_FTS;
@@ -147,7 +147,7 @@ static int set_flow_attrs(u32 *match_c, u32 *match_v,
 					     outer_headers);
 	void *outer_headers_v = MLX5_ADDR_OF(fte_match_param, match_v,
 					     outer_headers);
-	u32 flow_type = fs->flow_type & ~(FLOW_EXT | FLOW_MAC_EXT);
+	u32 flow_type = ethtool_get_flow_spec_type(fs->flow_type);
 	struct ethtool_tcpip4_spec *l4_mask;
 	struct ethtool_tcpip4_spec *l4_val;
 	struct ethtool_usrip4_spec *l3_mask;
@@ -393,7 +393,7 @@ static int validate_flow(struct mlx5e_priv *priv,
 	    fs->ring_cookie != RX_CLS_FLOW_DISC)
 		return -EINVAL;
 
-	switch (fs->flow_type & ~(FLOW_EXT | FLOW_MAC_EXT)) {
+	switch (ethtool_get_flow_spec_type(fs->flow_type)) {
 	case ETHER_FLOW:
 		eth_mask = &fs->m_u.ether_spec;
 		if (!is_zero_ether_addr(eth_mask->h_dest))
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index f0db7788f887..ed650eef9e54 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1583,6 +1583,11 @@ static inline int ethtool_validate_duplex(__u8 duplex)
 #define	FLOW_EXT	0x80000000
 #define	FLOW_MAC_EXT	0x40000000
 
+static inline __u32 ethtool_get_flow_spec_type(__u32 flow_type)
+{
+	return flow_type & ~(FLOW_EXT | FLOW_MAC_EXT);
+}
+
 /* L3-L4 network traffic flow hash options */
 #define	RXH_L2DA	(1 << 1)
 #define	RXH_VLAN	(1 << 2)
-- 
2.11.0.rc2.152.g4d04e67
