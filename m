From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC] switchdev: generate phys_port_name in the core
Date: Thu, 27 Jul 2017 19:31:22 -0700
Message-ID: <20170728023122.1674-1-jakub.kicinski@netronome.com>
References: <CAJ3xEMhUs0DfMioSU=gqR_hEs=ZFjUM1bA3nA9LwtTgH93ygDQ@mail.gmail.com>
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Michael Chan <michael.chan@broadcom.com>,
        Sathya Perla <sathya.perla@broadcom.com>,
        David Miller <davem@davemloft.net>, simon.horman@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:33133 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751735AbdG1Cbx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 22:31:53 -0400
Received: by mail-pg0-f48.google.com with SMTP id c14so12636348pgn.0
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 19:31:53 -0700 (PDT)
In-Reply-To: <CAJ3xEMhUs0DfMioSU=gqR_hEs=ZFjUM1bA3nA9LwtTgH93ygDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Jul 2017 13:30:44 +0300, Or Gerlitz wrote:
> > want to add port splitting support, for example, reporting the name on
> > physical ports will become more of a necessity.  
> 
> > If we adopt Jiri's suggestion of returning structured data it will be
> > very easy to give user space type and indexes separately, but we should
> > probably still return the string for backwards compatibility.  
> 
> I am not still clear how the structured data would look like

I decided to just quickly write the code, that should be easier to 
understand.  We can probably leave out the netlink part of the API
if there is no need for it right now, but that's what I ment by
returning the information in a more structured way.

Tested-by: nobody :)
Suggested-by: Jiri (if I understood correctly)
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c |  8 ++-
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c   | 10 ++--
 drivers/net/ethernet/netronome/nfp/nfp_port.c    | 26 ++++-----
 drivers/net/ethernet/netronome/nfp/nfp_port.h    |  4 +-
 include/linux/netdevice.h                        | 18 ++++++-
 include/uapi/linux/if_link.h                     | 16 ++++++
 net/core/dev.c                                   | 31 +++++++++--
 net/core/rtnetlink.c                             | 69 ++++++++++++++++++++++++
 8 files changed, 153 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 45e60be9c277..7a71291b8ec3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -637,16 +637,14 @@ static int mlx5e_rep_close(struct net_device *dev)
 }
 
 static int mlx5e_rep_get_phys_port_name(struct net_device *dev,
-					char *buf, size_t len)
+					struct netdev_port_info *info)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	struct mlx5e_rep_priv *rpriv = priv->ppriv;
 	struct mlx5_eswitch_rep *rep = rpriv->rep;
-	int ret;
 
-	ret = snprintf(buf, len, "%d", rep->vport - 1);
-	if (ret >= len)
-		return -EOPNOTSUPP;
+	info->type = NETDEV_PORT_PCI_VF;
+	info->pci.vf_id = rep->vport - 1;
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 3b0f72455681..383b8b5f41cf 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -413,15 +413,13 @@ mlxsw_sx_port_get_stats64(struct net_device *dev,
 	stats->tx_dropped	= tx_dropped;
 }
 
-static int mlxsw_sx_port_get_phys_port_name(struct net_device *dev, char *name,
-					    size_t len)
+static int mlxsw_sx_port_get_phys_port_name(struct net_device *dev,
+					    struct netdev_port_info *info)
 {
 	struct mlxsw_sx_port *mlxsw_sx_port = netdev_priv(dev);
-	int err;
 
-	err = snprintf(name, len, "p%d", mlxsw_sx_port->mapping.module + 1);
-	if (err >= len)
-		return -EINVAL;
+	info->type = NETDEV_PORT_EXTERNAL;
+	info->port.id = mlxsw_sx_port->mapping.module + 1;
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.c b/drivers/net/ethernet/netronome/nfp/nfp_port.c
index d16a7b78ba9b..8f5c37b9a79c 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.c
@@ -143,11 +143,11 @@ struct nfp_eth_table_port *nfp_port_get_eth_port(struct nfp_port *port)
 }
 
 int
-nfp_port_get_phys_port_name(struct net_device *netdev, char *name, size_t len)
+nfp_port_get_phys_port_name(struct net_device *netdev,
+			    struct netdev_port_info *info)
 {
 	struct nfp_eth_table_port *eth_port;
 	struct nfp_port *port;
-	int n;
 
 	port = nfp_port_from_netdev(netdev);
 	if (!port)
@@ -159,25 +159,27 @@ nfp_port_get_phys_port_name(struct net_device *netdev, char *name, size_t len)
 		if (!eth_port)
 			return -EOPNOTSUPP;
 
-		if (!eth_port->is_split)
-			n = snprintf(name, len, "p%d", eth_port->label_port);
-		else
-			n = snprintf(name, len, "p%ds%d", eth_port->label_port,
-				     eth_port->label_subport);
+		info->type = NETDEV_PORT_EXTERNAL;
+		info->external.id = eth_port->label_port;
+
+		if (eth_port->is_split) {
+			info->type = NETDEV_PORT_EXTERNAL_SPLIT;
+			info->external.split_id = eth_port->label_subport;
+		}
 		break;
 	case NFP_PORT_PF_PORT:
-		n = snprintf(name, len, "pf%d", port->pf_id);
+		info->type = NETDEV_PORT_PCI_PF;
+		info->pci.pf_id = port->pf_id;
 		break;
 	case NFP_PORT_VF_PORT:
-		n = snprintf(name, len, "pf%dvf%d", port->pf_id, port->vf_id);
+		info->type = NETDEV_PORT_PCI_VF;
+		info->pci.pf_id = port->pf_id;
+		info->pci.vf_id = port->vf_id;
 		break;
 	default:
 		return -EOPNOTSUPP;
 	}
 
-	if (n >= len)
-		return -EINVAL;
-
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.h b/drivers/net/ethernet/netronome/nfp/nfp_port.h
index 56c76926c82a..03b8746feb29 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
@@ -118,8 +118,8 @@ nfp_port_from_id(struct nfp_pf *pf, enum nfp_port_type type, unsigned int id);
 struct nfp_eth_table_port *__nfp_port_get_eth_port(struct nfp_port *port);
 struct nfp_eth_table_port *nfp_port_get_eth_port(struct nfp_port *port);
 
-int
-nfp_port_get_phys_port_name(struct net_device *netdev, char *name, size_t len);
+int nfp_port_get_phys_port_name(struct net_device *netdev,
+				struct netdev_port_info *info);
 int nfp_port_configure(struct net_device *netdev, bool configed);
 
 struct nfp_port *
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3a3cdc1b1f31..0a055df701ef 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -845,6 +845,22 @@ struct xfrmdev_ops {
 };
 #endif
 
+struct netdev_port_info {
+	int type;
+
+	union {
+		struct {
+			u32 id;
+			u32 split_id;
+		} external;
+
+		struct {
+			u32 pf_id;
+			u32 vf_id;
+		} pci;
+	};
+};
+
 /*
  * This structure defines the management hooks for network devices.
  * The following hooks can be defined; unless noted otherwise, they are
@@ -1306,7 +1322,7 @@ struct net_device_ops {
 	int			(*ndo_get_phys_port_id)(struct net_device *dev,
 							struct netdev_phys_item_id *ppid);
 	int			(*ndo_get_phys_port_name)(struct net_device *dev,
-							  char *name, size_t len);
+							  struct netdev_port_info *info);
 	void			(*ndo_udp_tunnel_add)(struct net_device *dev,
 						      struct udp_tunnel_info *ti);
 	void			(*ndo_udp_tunnel_del)(struct net_device *dev,
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 8d062c58d5cb..e00ff0333e3f 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -158,6 +158,7 @@ enum {
 	IFLA_PAD,
 	IFLA_XDP,
 	IFLA_EVENT,
+	IFLA_PORT_INFO,
 	__IFLA_MAX
 };
 
@@ -927,4 +928,19 @@ enum {
 	IFLA_EVENT_BONDING_OPTIONS,	/* change in bonding options */
 };
 
+enum {
+	NETDEV_PORT_EXTERNAL,
+	NETDEV_PORT_EXTERNAL_SPLIT,
+	NETDEV_PORT_PCI_PF,
+	NETDEV_PORT_PCI_VF,
+};
+
+enum {
+	IFLA_PORT_INFO_TYPE,
+	IFLA_PORT_INFO_EXTERNAL_ID,
+	IFLA_PORT_INFO_EXTERNAL_SPLIT_ID,
+	IFLA_PORT_INFO_PCI_PF_ID,
+	IFLA_PORT_INFO_PCI_VF_ID,
+};
+
 #endif /* _UAPI_LINUX_IF_LINK_H */
diff --git a/net/core/dev.c b/net/core/dev.c
index 8ea6b4b42611..8fe3f697234e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6947,14 +6947,39 @@ EXPORT_SYMBOL(dev_get_phys_port_id);
  *
  *	Get device physical port name
  */
-int dev_get_phys_port_name(struct net_device *dev,
-			   char *name, size_t len)
+int dev_get_phys_port_name(struct net_device *dev, char *name, size_t len)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
+	struct netdev_port_info info = {};
+	int ret;
 
 	if (!ops->ndo_get_phys_port_name)
 		return -EOPNOTSUPP;
-	return ops->ndo_get_phys_port_name(dev, name, len);
+	ret = ops->ndo_get_phys_port_name(dev, &info);
+	if (ret)
+		return ret;
+
+	switch (info.type) {
+	case NETDEV_PORT_EXTERNAL:
+		ret = snprintf(name, len, "p%d", info.external.id);
+		break;
+	case NETDEV_PORT_EXTERNAL_SPLIT:
+		ret = snprintf(name, len, "p%ds%d",
+			       info.external.id, info.external.split_id);
+		break;
+	case NETDEV_PORT_PCI_PF:
+		ret = snprintf(name, len, "pf%d", info.pci.pf_id);
+		break;
+	case NETDEV_PORT_PCI_VF:
+		ret = snprintf(name, len, "pf%dvf%d",
+			       info.pci.pf_id, info.pci.vf_id);
+		break;
+	}
+
+	if (ret > len)
+		return -EINVAL;
+
+	return 0;
 }
 EXPORT_SYMBOL(dev_get_phys_port_name);
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9201e3621351..1eb181ef705f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -907,6 +907,15 @@ static size_t rtnl_xdp_size(void)
 	return xdp_size;
 }
 
+static size_t rtnl_port_info_size(void)
+{
+	size_t port_info_size = nla_total_size(0) + /* nest IFLA_PORT_INFO */
+				nla_total_size(4) + /* EXTERNAL_ID or PF_ID */
+				nla_total_size(4);  /* SPLIT_ID or VF_ID*/
+
+	return port_info_size;
+}
+
 static noinline size_t if_nlmsg_size(const struct net_device *dev,
 				     u32 ext_filter_mask)
 {
@@ -946,6 +955,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(IFNAMSIZ) /* IFLA_PHYS_PORT_NAME */
 	       + rtnl_xdp_size() /* IFLA_XDP */
 	       + nla_total_size(4)  /* IFLA_EVENT */
+	       + rtnl_port_info_size() /* IFLA_PORT_INFO */
 	       + nla_total_size(1); /* IFLA_PROTO_DOWN */
 
 }
@@ -1330,6 +1340,62 @@ static u32 rtnl_get_event(unsigned long event)
 	return rtnl_event_type;
 }
 
+static int rtnl_port_info_fill(struct sk_buff *skb, struct net_device *dev)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	struct netdev_port_info info = {};
+	struct nlattr *port_info;
+	int err;
+
+	if (!ops->ndo_get_phys_port_name)
+		return 0;
+
+	port_info = nla_nest_start(skb, IFLA_PORT_INFO);
+	if (!port_info)
+		return -EMSGSIZE;
+
+	err = ops->ndo_get_phys_port_name(dev, &info);
+	if (err)
+		goto err_cancel;
+
+	err = nla_put_u32(skb, IFLA_PORT_INFO_TYPE, info.type);
+	if (err)
+		goto err_cancel;
+
+	switch (info.type) {
+	case NETDEV_PORT_EXTERNAL_SPLIT:
+		err = nla_put_u32(skb, IFLA_PORT_INFO_EXTERNAL_SPLIT_ID,
+				  info.external.split_id);
+		if (err)
+			goto err_cancel;
+		/* fall through */
+	case NETDEV_PORT_EXTERNAL:
+		err = nla_put_u32(skb, IFLA_PORT_INFO_EXTERNAL_ID,
+				  info.external.id);
+		if (err)
+			goto err_cancel;
+		break;
+	case NETDEV_PORT_PCI_VF:
+		err = nla_put_u32(skb, IFLA_PORT_INFO_PCI_VF_ID,
+				  info.pci.vf_id);
+		if (err)
+			goto err_cancel;
+		/* fall through */
+	case NETDEV_PORT_PCI_PF:
+		err = nla_put_u32(skb, IFLA_PORT_INFO_PCI_PF_ID,
+				  info.pci.pf_id);
+		if (err)
+			goto err_cancel;
+		break;
+	}
+
+	return 0;
+
+err_cancel:
+	nla_nest_cancel(skb, port_info);
+	return err;
+}
+
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
 			    unsigned int flags, u32 ext_filter_mask,
@@ -1435,6 +1501,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (rtnl_xdp_fill(skb, dev))
 		goto nla_put_failure;
 
+	if (rtnl_port_info_fill(skb, dev))
+		goto nla_put_failure;
+
 	if (dev->rtnl_link_ops || rtnl_have_link_slave_info(dev)) {
 		if (rtnl_link_fill(skb, dev) < 0)
 			goto nla_put_failure;
-- 
2.11.0
