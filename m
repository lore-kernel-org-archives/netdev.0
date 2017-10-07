From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: make ->ndo_get_phys_port_name accept 32-bit len
Date: Sun, 8 Oct 2017 01:19:17 +0300
Message-ID: <20171007221917.GA2467@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com,
        saeedm@mellanox.com, simon.horman@netronome.com, jiri@mellanox.com,
        ecree@solarflare.com, vivien.didelot@savoirfairelinux.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35255 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751940AbdJGWTW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 18:19:22 -0400
Received: by mail-wm0-f68.google.com with SMTP id b189so15519752wmd.2
        for <netdev@vger.kernel.org>; Sat, 07 Oct 2017 15:19:21 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Buffer length passed into this hook is always IFNAMSIZ which is 16.

Code savings on x86_64:

	add/remove: 0/0 grow/shrink: 1/9 up/down: 2/-45 (-43)
	function                                     old     new   delta
	rocker_cmd_get_port_settings_phys_name_proc     179     181      +2
	rocker_port_get_phys_port_name                62      61      -1
	mlxsw_sx_port_get_phys_port_name              54      50      -4
	mlx5e_rep_get_phys_port_name                  61      57      -4
	efx_get_phys_port_name                        50      46      -4
	dsa_slave_get_phys_port_name                  54      50      -4
	bnxt_vf_rep_get_phys_port_name                69      65      -4
	bnxt_get_phys_port_name                       70      65      -5
	mlxsw_sp_port_get_phys_port_name             116     107      -9
	nfp_port_get_phys_port_name                  180     170     -10

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/ethernet/broadcom/bnxt/bnxt.c        |    2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c    |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c |    2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c   |    2 +-
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c   |    2 +-
 drivers/net/ethernet/netronome/nfp/nfp_port.c    |    4 ++--
 drivers/net/ethernet/netronome/nfp/nfp_port.h    |    3 +--
 drivers/net/ethernet/rocker/rocker_main.c        |    8 ++++----
 drivers/net/ethernet/sfc/efx.c                   |    2 +-
 include/linux/netdevice.h                        |    4 ++--
 net/core/dev.c                                   |    2 +-
 net/dsa/slave.c                                  |    2 +-
 12 files changed, 17 insertions(+), 18 deletions(-)

--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7619,7 +7619,7 @@ static int bnxt_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh,
 }
 
 static int bnxt_get_phys_port_name(struct net_device *dev, char *buf,
-				   size_t len)
+				   unsigned int len)
 {
 	struct bnxt *bp = netdev_priv(dev);
 	int rc;
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
@@ -155,7 +155,7 @@ void bnxt_vf_rep_rx(struct bnxt *bp, struct sk_buff *skb)
 }
 
 static int bnxt_vf_rep_get_phys_port_name(struct net_device *dev, char *buf,
-					  size_t len)
+					  unsigned int len)
 {
 	struct bnxt_vf_rep *vf_rep = netdev_priv(dev);
 	struct pci_dev *pf_pdev = vf_rep->bp->pdev;
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -643,7 +643,7 @@ static int mlx5e_rep_close(struct net_device *dev)
 }
 
 static int mlx5e_rep_get_phys_port_name(struct net_device *dev,
-					char *buf, size_t len)
+					char *buf, unsigned int len)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	struct mlx5e_rep_priv *rpriv = priv->ppriv;
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1498,7 +1498,7 @@ static int mlxsw_sp_port_kill_vid(struct net_device *dev,
 }
 
 static int mlxsw_sp_port_get_phys_port_name(struct net_device *dev, char *name,
-					    size_t len)
+					    unsigned int len)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	u8 module = mlxsw_sp_port->mapping.module;
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -414,7 +414,7 @@ mlxsw_sx_port_get_stats64(struct net_device *dev,
 }
 
 static int mlxsw_sx_port_get_phys_port_name(struct net_device *dev, char *name,
-					    size_t len)
+					    unsigned int len)
 {
 	struct mlxsw_sx_port *mlxsw_sx_port = netdev_priv(dev);
 	int err;
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.c
@@ -139,8 +139,8 @@ struct nfp_eth_table_port *nfp_port_get_eth_port(struct nfp_port *port)
 	return __nfp_port_get_eth_port(port);
 }
 
-int
-nfp_port_get_phys_port_name(struct net_device *netdev, char *name, size_t len)
+int nfp_port_get_phys_port_name(struct net_device *netdev,
+				char *name, unsigned int len)
 {
 	struct nfp_eth_table_port *eth_port;
 	struct nfp_port *port;
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
@@ -127,8 +127,7 @@ nfp_port_from_id(struct nfp_pf *pf, enum nfp_port_type type, unsigned int id);
 struct nfp_eth_table_port *__nfp_port_get_eth_port(struct nfp_port *port);
 struct nfp_eth_table_port *nfp_port_get_eth_port(struct nfp_port *port);
 
-int
-nfp_port_get_phys_port_name(struct net_device *netdev, char *name, size_t len);
+int nfp_port_get_phys_port_name(struct net_device *netdev, char *name, unsigned int len);
 int nfp_port_configure(struct net_device *netdev, bool configed);
 
 struct nfp_port *
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1204,7 +1204,7 @@ rocker_cmd_get_port_settings_mode_proc(const struct rocker_port *rocker_port,
 
 struct port_name {
 	char *buf;
-	size_t len;
+	unsigned int len;
 };
 
 static int
@@ -1216,7 +1216,7 @@ rocker_cmd_get_port_settings_phys_name_proc(const struct rocker_port *rocker_por
 	const struct rocker_tlv *attrs[ROCKER_TLV_CMD_MAX + 1];
 	struct port_name *name = priv;
 	const struct rocker_tlv *attr;
-	size_t i, j, len;
+	unsigned int i, j, len;
 	const char *str;
 
 	rocker_tlv_parse_desc(attrs, ROCKER_TLV_CMD_MAX, desc_info);
@@ -1229,7 +1229,7 @@ rocker_cmd_get_port_settings_phys_name_proc(const struct rocker_port *rocker_por
 	if (!attr)
 		return -EIO;
 
-	len = min_t(size_t, rocker_tlv_len(attr), name->len);
+	len = min_t(unsigned int, rocker_tlv_len(attr), name->len);
 	str = rocker_tlv_data(attr);
 
 	/* make sure name only contains alphanumeric characters */
@@ -1986,7 +1986,7 @@ static int rocker_port_change_mtu(struct net_device *dev, int new_mtu)
 }
 
 static int rocker_port_get_phys_port_name(struct net_device *dev,
-					  char *buf, size_t len)
+					  char *buf, unsigned int len)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	struct port_name name = { .buf = buf, .len = len };
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2340,7 +2340,7 @@ static int efx_get_phys_port_id(struct net_device *net_dev,
 }
 
 static int efx_get_phys_port_name(struct net_device *net_dev,
-				  char *name, size_t len)
+				  char *name, unsigned int len)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1292,7 +1292,7 @@ struct net_device_ops {
 	int			(*ndo_get_phys_port_id)(struct net_device *dev,
 							struct netdev_phys_item_id *ppid);
 	int			(*ndo_get_phys_port_name)(struct net_device *dev,
-							  char *name, size_t len);
+							  char *name, unsigned int len);
 	void			(*ndo_udp_tunnel_add)(struct net_device *dev,
 						      struct udp_tunnel_info *ti);
 	void			(*ndo_udp_tunnel_del)(struct net_device *dev,
@@ -3299,7 +3299,7 @@ int dev_change_carrier(struct net_device *, bool new_carrier);
 int dev_get_phys_port_id(struct net_device *dev,
 			 struct netdev_phys_item_id *ppid);
 int dev_get_phys_port_name(struct net_device *dev,
-			   char *name, size_t len);
+			   char *name, unsigned int len);
 int dev_change_proto_down(struct net_device *dev, bool proto_down);
 struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev);
 struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7031,7 +7031,7 @@ EXPORT_SYMBOL(dev_get_phys_port_id);
  *	Get device physical port name
  */
 int dev_get_phys_port_name(struct net_device *dev,
-			   char *name, size_t len)
+			   char *name, unsigned int len)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -674,7 +674,7 @@ static void dsa_slave_poll_controller(struct net_device *dev)
 #endif
 
 static int dsa_slave_get_phys_port_name(struct net_device *dev,
-					char *name, size_t len)
+					char *name, unsigned int len)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 
