From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V2 net-next 09/10] net/mlx4: Refactor QUERY_PORT
Date: Thu, 11 Dec 2014 10:57:59 +0200
Message-ID: <1418288280-334-10-git-send-email-ogerlitz@mellanox.com>
References: <1418288280-334-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40595 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932227AbaLKI7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2014 03:59:51 -0500
In-Reply-To: <1418288280-334-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

Currently QUERY_PORT is done as a part of QUERY_DEV_CAP firmware command.

Since we would like to use it without querying all device capabilities,
extract this part to be a function of its own.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c   |  141 +++++++++++++++++------------
 drivers/net/ethernet/mellanox/mlx4/fw.h   |   37 +++++----
 drivers/net/ethernet/mellanox/mlx4/main.c |   71 ++++++++++-----
 3 files changed, 154 insertions(+), 95 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 622bffa..073b3d1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -886,61 +886,10 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	if (field32 & (1 << 21))
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_80_VFS;
 
-	if (dev->flags & MLX4_FLAG_OLD_PORT_CMDS) {
-		for (i = 1; i <= dev_cap->num_ports; ++i) {
-			MLX4_GET(field, outbox, QUERY_DEV_CAP_VL_PORT_OFFSET);
-			dev_cap->max_vl[i]	   = field >> 4;
-			MLX4_GET(field, outbox, QUERY_DEV_CAP_MTU_WIDTH_OFFSET);
-			dev_cap->ib_mtu[i]	   = field >> 4;
-			dev_cap->max_port_width[i] = field & 0xf;
-			MLX4_GET(field, outbox, QUERY_DEV_CAP_MAX_GID_OFFSET);
-			dev_cap->max_gids[i]	   = 1 << (field & 0xf);
-			MLX4_GET(field, outbox, QUERY_DEV_CAP_MAX_PKEY_OFFSET);
-			dev_cap->max_pkeys[i]	   = 1 << (field & 0xf);
-		}
-	} else {
-#define QUERY_PORT_SUPPORTED_TYPE_OFFSET	0x00
-#define QUERY_PORT_MTU_OFFSET			0x01
-#define QUERY_PORT_ETH_MTU_OFFSET		0x02
-#define QUERY_PORT_WIDTH_OFFSET			0x06
-#define QUERY_PORT_MAX_GID_PKEY_OFFSET		0x07
-#define QUERY_PORT_MAX_MACVLAN_OFFSET		0x0a
-#define QUERY_PORT_MAX_VL_OFFSET		0x0b
-#define QUERY_PORT_MAC_OFFSET			0x10
-#define QUERY_PORT_TRANS_VENDOR_OFFSET		0x18
-#define QUERY_PORT_WAVELENGTH_OFFSET		0x1c
-#define QUERY_PORT_TRANS_CODE_OFFSET		0x20
-
-		for (i = 1; i <= dev_cap->num_ports; ++i) {
-			err = mlx4_cmd_box(dev, 0, mailbox->dma, i, 0, MLX4_CMD_QUERY_PORT,
-					   MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
-			if (err)
-				goto out;
-
-			MLX4_GET(field, outbox, QUERY_PORT_SUPPORTED_TYPE_OFFSET);
-			dev_cap->supported_port_types[i] = field & 3;
-			dev_cap->suggested_type[i] = (field >> 3) & 1;
-			dev_cap->default_sense[i] = (field >> 4) & 1;
-			MLX4_GET(field, outbox, QUERY_PORT_MTU_OFFSET);
-			dev_cap->ib_mtu[i]	   = field & 0xf;
-			MLX4_GET(field, outbox, QUERY_PORT_WIDTH_OFFSET);
-			dev_cap->max_port_width[i] = field & 0xf;
-			MLX4_GET(field, outbox, QUERY_PORT_MAX_GID_PKEY_OFFSET);
-			dev_cap->max_gids[i]	   = 1 << (field >> 4);
-			dev_cap->max_pkeys[i]	   = 1 << (field & 0xf);
-			MLX4_GET(field, outbox, QUERY_PORT_MAX_VL_OFFSET);
-			dev_cap->max_vl[i]	   = field & 0xf;
-			MLX4_GET(field, outbox, QUERY_PORT_MAX_MACVLAN_OFFSET);
-			dev_cap->log_max_macs[i]  = field & 0xf;
-			dev_cap->log_max_vlans[i] = field >> 4;
-			MLX4_GET(dev_cap->eth_mtu[i], outbox, QUERY_PORT_ETH_MTU_OFFSET);
-			MLX4_GET(dev_cap->def_mac[i], outbox, QUERY_PORT_MAC_OFFSET);
-			MLX4_GET(field32, outbox, QUERY_PORT_TRANS_VENDOR_OFFSET);
-			dev_cap->trans_type[i] = field32 >> 24;
-			dev_cap->vendor_oui[i] = field32 & 0xffffff;
-			MLX4_GET(dev_cap->wavelength[i], outbox, QUERY_PORT_WAVELENGTH_OFFSET);
-			MLX4_GET(dev_cap->trans_code[i], outbox, QUERY_PORT_TRANS_CODE_OFFSET);
-		}
+	for (i = 1; i <= dev_cap->num_ports; i++) {
+		err = mlx4_QUERY_PORT(dev, i, dev_cap->port_cap + i);
+		if (err)
+			goto out;
 	}
 
 	mlx4_dbg(dev, "Base MM extensions: flags %08x, rsvd L_Key %08x\n",
@@ -977,8 +926,8 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	mlx4_dbg(dev, "Max CQEs: %d, max WQEs: %d, max SRQ WQEs: %d\n",
 		 dev_cap->max_cq_sz, dev_cap->max_qp_sz, dev_cap->max_srq_sz);
 	mlx4_dbg(dev, "Local CA ACK delay: %d, max MTU: %d, port width cap: %d\n",
-		 dev_cap->local_ca_ack_delay, 128 << dev_cap->ib_mtu[1],
-		 dev_cap->max_port_width[1]);
+		 dev_cap->local_ca_ack_delay, 128 << dev_cap->port_cap[1].ib_mtu,
+		 dev_cap->port_cap[1].max_port_width);
 	mlx4_dbg(dev, "Max SQ desc size: %d, max SQ S/G: %d\n",
 		 dev_cap->max_sq_desc_sz, dev_cap->max_sq_sg);
 	mlx4_dbg(dev, "Max RQ desc size: %d, max RQ S/G: %d\n",
@@ -995,6 +944,84 @@ out:
 	return err;
 }
 
+int mlx4_QUERY_PORT(struct mlx4_dev *dev, int port, struct mlx4_port_cap *port_cap)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	u32 *outbox;
+	u8 field;
+	u32 field32;
+	int err;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+	outbox = mailbox->buf;
+
+	if (dev->flags & MLX4_FLAG_OLD_PORT_CMDS) {
+		err = mlx4_cmd_box(dev, 0, mailbox->dma, 0, 0, MLX4_CMD_QUERY_DEV_CAP,
+				   MLX4_CMD_TIME_CLASS_A,
+				   MLX4_CMD_NATIVE);
+
+		if (err)
+			goto out;
+
+		MLX4_GET(field, outbox, QUERY_DEV_CAP_VL_PORT_OFFSET);
+		port_cap->max_vl	   = field >> 4;
+		MLX4_GET(field, outbox, QUERY_DEV_CAP_MTU_WIDTH_OFFSET);
+		port_cap->ib_mtu	   = field >> 4;
+		port_cap->max_port_width = field & 0xf;
+		MLX4_GET(field, outbox, QUERY_DEV_CAP_MAX_GID_OFFSET);
+		port_cap->max_gids	   = 1 << (field & 0xf);
+		MLX4_GET(field, outbox, QUERY_DEV_CAP_MAX_PKEY_OFFSET);
+		port_cap->max_pkeys	   = 1 << (field & 0xf);
+	} else {
+#define QUERY_PORT_SUPPORTED_TYPE_OFFSET	0x00
+#define QUERY_PORT_MTU_OFFSET			0x01
+#define QUERY_PORT_ETH_MTU_OFFSET		0x02
+#define QUERY_PORT_WIDTH_OFFSET			0x06
+#define QUERY_PORT_MAX_GID_PKEY_OFFSET		0x07
+#define QUERY_PORT_MAX_MACVLAN_OFFSET		0x0a
+#define QUERY_PORT_MAX_VL_OFFSET		0x0b
+#define QUERY_PORT_MAC_OFFSET			0x10
+#define QUERY_PORT_TRANS_VENDOR_OFFSET		0x18
+#define QUERY_PORT_WAVELENGTH_OFFSET		0x1c
+#define QUERY_PORT_TRANS_CODE_OFFSET		0x20
+
+		err = mlx4_cmd_box(dev, 0, mailbox->dma, port, 0, MLX4_CMD_QUERY_PORT,
+				   MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
+		if (err)
+			goto out;
+
+		MLX4_GET(field, outbox, QUERY_PORT_SUPPORTED_TYPE_OFFSET);
+		port_cap->supported_port_types = field & 3;
+		port_cap->suggested_type = (field >> 3) & 1;
+		port_cap->default_sense = (field >> 4) & 1;
+		MLX4_GET(field, outbox, QUERY_PORT_MTU_OFFSET);
+		port_cap->ib_mtu	   = field & 0xf;
+		MLX4_GET(field, outbox, QUERY_PORT_WIDTH_OFFSET);
+		port_cap->max_port_width = field & 0xf;
+		MLX4_GET(field, outbox, QUERY_PORT_MAX_GID_PKEY_OFFSET);
+		port_cap->max_gids	   = 1 << (field >> 4);
+		port_cap->max_pkeys	   = 1 << (field & 0xf);
+		MLX4_GET(field, outbox, QUERY_PORT_MAX_VL_OFFSET);
+		port_cap->max_vl	   = field & 0xf;
+		MLX4_GET(field, outbox, QUERY_PORT_MAX_MACVLAN_OFFSET);
+		port_cap->log_max_macs  = field & 0xf;
+		port_cap->log_max_vlans = field >> 4;
+		MLX4_GET(port_cap->eth_mtu, outbox, QUERY_PORT_ETH_MTU_OFFSET);
+		MLX4_GET(port_cap->def_mac, outbox, QUERY_PORT_MAC_OFFSET);
+		MLX4_GET(field32, outbox, QUERY_PORT_TRANS_VENDOR_OFFSET);
+		port_cap->trans_type = field32 >> 24;
+		port_cap->vendor_oui = field32 & 0xffffff;
+		MLX4_GET(port_cap->wavelength, outbox, QUERY_PORT_WAVELENGTH_OFFSET);
+		MLX4_GET(port_cap->trans_code, outbox, QUERY_PORT_TRANS_CODE_OFFSET);
+	}
+
+out:
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+
 #define DEV_CAP_EXT_2_FLAG_VLAN_CONTROL (1 << 26)
 #define DEV_CAP_EXT_2_FLAG_80_VFS	(1 << 21)
 #define DEV_CAP_EXT_2_FLAG_FSM		(1 << 20)
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index 0e910a4..744398b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -43,6 +43,25 @@ struct mlx4_mod_stat_cfg {
 	u8 log_pg_sz_m;
 };
 
+struct mlx4_port_cap {
+	u8  supported_port_types;
+	u8  suggested_type;
+	u8  default_sense;
+	u8  log_max_macs;
+	u8  log_max_vlans;
+	int ib_mtu;
+	int max_port_width;
+	int max_vl;
+	int max_gids;
+	int max_pkeys;
+	u64 def_mac;
+	u16 eth_mtu;
+	int trans_type;
+	int vendor_oui;
+	u16 wavelength;
+	u64 trans_code;
+};
+
 struct mlx4_dev_cap {
 	int max_srq_sz;
 	int max_qp_sz;
@@ -67,17 +86,6 @@ struct mlx4_dev_cap {
 	int local_ca_ack_delay;
 	int num_ports;
 	u32 max_msg_sz;
-	int ib_mtu[MLX4_MAX_PORTS + 1];
-	int max_port_width[MLX4_MAX_PORTS + 1];
-	int max_vl[MLX4_MAX_PORTS + 1];
-	int max_gids[MLX4_MAX_PORTS + 1];
-	int max_pkeys[MLX4_MAX_PORTS + 1];
-	u64 def_mac[MLX4_MAX_PORTS + 1];
-	u16 eth_mtu[MLX4_MAX_PORTS + 1];
-	int trans_type[MLX4_MAX_PORTS + 1];
-	int vendor_oui[MLX4_MAX_PORTS + 1];
-	u16 wavelength[MLX4_MAX_PORTS + 1];
-	u64 trans_code[MLX4_MAX_PORTS + 1];
 	u16 stat_rate_support;
 	int fs_log_max_ucast_qp_range_size;
 	int fs_max_num_qp_per_entry;
@@ -115,12 +123,8 @@ struct mlx4_dev_cap {
 	u64 max_icm_sz;
 	int max_gso_sz;
 	int max_rss_tbl_sz;
-	u8  supported_port_types[MLX4_MAX_PORTS + 1];
-	u8  suggested_type[MLX4_MAX_PORTS + 1];
-	u8  default_sense[MLX4_MAX_PORTS + 1];
-	u8  log_max_macs[MLX4_MAX_PORTS + 1];
-	u8  log_max_vlans[MLX4_MAX_PORTS + 1];
 	u32 max_counters;
+	struct mlx4_port_cap port_cap[MLX4_MAX_PORTS + 1];
 };
 
 struct mlx4_func_cap {
@@ -217,6 +221,7 @@ struct mlx4_set_ib_param {
 };
 
 int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap);
+int mlx4_QUERY_PORT(struct mlx4_dev *dev, int port, struct mlx4_port_cap *port_cap);
 int mlx4_QUERY_FUNC_CAP(struct mlx4_dev *dev, u8 gen_or_port,
 			struct mlx4_func_cap *func_cap);
 int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 3bfe90b..6173b80 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -254,6 +254,46 @@ static void mlx4_enable_cqe_eqe_stride(struct mlx4_dev *dev)
 	}
 }
 
+static int _mlx4_dev_port(struct mlx4_dev *dev, int port,
+			  struct mlx4_port_cap *port_cap)
+{
+	dev->caps.vl_cap[port]	    = port_cap->max_vl;
+	dev->caps.ib_mtu_cap[port]	    = port_cap->ib_mtu;
+	dev->phys_caps.gid_phys_table_len[port]  = port_cap->max_gids;
+	dev->phys_caps.pkey_phys_table_len[port] = port_cap->max_pkeys;
+	/* set gid and pkey table operating lengths by default
+	 * to non-sriov values
+	 */
+	dev->caps.gid_table_len[port]  = port_cap->max_gids;
+	dev->caps.pkey_table_len[port] = port_cap->max_pkeys;
+	dev->caps.port_width_cap[port] = port_cap->max_port_width;
+	dev->caps.eth_mtu_cap[port]    = port_cap->eth_mtu;
+	dev->caps.def_mac[port]        = port_cap->def_mac;
+	dev->caps.supported_type[port] = port_cap->supported_port_types;
+	dev->caps.suggested_type[port] = port_cap->suggested_type;
+	dev->caps.default_sense[port] = port_cap->default_sense;
+	dev->caps.trans_type[port]	    = port_cap->trans_type;
+	dev->caps.vendor_oui[port]     = port_cap->vendor_oui;
+	dev->caps.wavelength[port]     = port_cap->wavelength;
+	dev->caps.trans_code[port]     = port_cap->trans_code;
+
+	return 0;
+}
+
+static int mlx4_dev_port(struct mlx4_dev *dev, int port,
+			 struct mlx4_port_cap *port_cap)
+{
+	int err = 0;
+
+	err = mlx4_QUERY_PORT(dev, port, port_cap);
+
+	if (err)
+		mlx4_err(dev, "QUERY_PORT command failed.\n");
+
+	return err;
+}
+
+#define MLX4_A0_STEERING_TABLE_SIZE	256
 static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 {
 	int err;
@@ -289,24 +329,11 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 				      dev->caps.num_sys_eqs :
 				      MLX4_MAX_EQ_NUM;
 	for (i = 1; i <= dev->caps.num_ports; ++i) {
-		dev->caps.vl_cap[i]	    = dev_cap->max_vl[i];
-		dev->caps.ib_mtu_cap[i]	    = dev_cap->ib_mtu[i];
-		dev->phys_caps.gid_phys_table_len[i]  = dev_cap->max_gids[i];
-		dev->phys_caps.pkey_phys_table_len[i] = dev_cap->max_pkeys[i];
-		/* set gid and pkey table operating lengths by default
-		 * to non-sriov values */
-		dev->caps.gid_table_len[i]  = dev_cap->max_gids[i];
-		dev->caps.pkey_table_len[i] = dev_cap->max_pkeys[i];
-		dev->caps.port_width_cap[i] = dev_cap->max_port_width[i];
-		dev->caps.eth_mtu_cap[i]    = dev_cap->eth_mtu[i];
-		dev->caps.def_mac[i]        = dev_cap->def_mac[i];
-		dev->caps.supported_type[i] = dev_cap->supported_port_types[i];
-		dev->caps.suggested_type[i] = dev_cap->suggested_type[i];
-		dev->caps.default_sense[i] = dev_cap->default_sense[i];
-		dev->caps.trans_type[i]	    = dev_cap->trans_type[i];
-		dev->caps.vendor_oui[i]     = dev_cap->vendor_oui[i];
-		dev->caps.wavelength[i]     = dev_cap->wavelength[i];
-		dev->caps.trans_code[i]     = dev_cap->trans_code[i];
+		err = _mlx4_dev_port(dev, i, dev_cap->port_cap + i);
+		if (err) {
+			mlx4_err(dev, "QUERY_PORT command failed, aborting\n");
+			return err;
+		}
 	}
 
 	dev->caps.uar_page_size	     = PAGE_SIZE;
@@ -415,13 +442,13 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 			dev->caps.possible_type[i] = dev->caps.port_type[i];
 		}
 
-		if (dev->caps.log_num_macs > dev_cap->log_max_macs[i]) {
-			dev->caps.log_num_macs = dev_cap->log_max_macs[i];
+		if (dev->caps.log_num_macs > dev_cap->port_cap[i].log_max_macs) {
+			dev->caps.log_num_macs = dev_cap->port_cap[i].log_max_macs;
 			mlx4_warn(dev, "Requested number of MACs is too much for port %d, reducing to %d\n",
 				  i, 1 << dev->caps.log_num_macs);
 		}
-		if (dev->caps.log_num_vlans > dev_cap->log_max_vlans[i]) {
-			dev->caps.log_num_vlans = dev_cap->log_max_vlans[i];
+		if (dev->caps.log_num_vlans > dev_cap->port_cap[i].log_max_vlans) {
+			dev->caps.log_num_vlans = dev_cap->port_cap[i].log_max_vlans;
 			mlx4_warn(dev, "Requested number of VLANs is too much for port %d, reducing to %d\n",
 				  i, 1 << dev->caps.log_num_vlans);
 		}
-- 
1.7.1
