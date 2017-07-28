From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC] switchdev: generate phys_port_name in the core
Date: Fri, 28 Jul 2017 07:35:07 +0200
Message-ID: <20170728053507.GA1857@nanopsycho>
References: <CAJ3xEMhUs0DfMioSU=gqR_hEs=ZFjUM1bA3nA9LwtTgH93ygDQ@mail.gmail.com>
 <20170728023122.1674-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <gerlitz.or@gmail.com>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Michael Chan <michael.chan@broadcom.com>,
        Sathya Perla <sathya.perla@broadcom.com>,
        David Miller <davem@davemloft.net>, simon.horman@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34988 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750888AbdG1FfK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 01:35:10 -0400
Received: by mail-wm0-f66.google.com with SMTP id r77so12951287wmd.2
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 22:35:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170728023122.1674-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jul 28, 2017 at 04:31:22AM CEST, jakub.kicinski@netronome.com wrote:
>On Thu, 27 Jul 2017 13:30:44 +0300, Or Gerlitz wrote:
>> > want to add port splitting support, for example, reporting the name on
>> > physical ports will become more of a necessity.  
>> 
>> > If we adopt Jiri's suggestion of returning structured data it will be
>> > very easy to give user space type and indexes separately, but we should
>> > probably still return the string for backwards compatibility.  
>> 
>> I am not still clear how the structured data would look like
>
>I decided to just quickly write the code, that should be easier to 
>understand.  We can probably leave out the netlink part of the API
>if there is no need for it right now, but that's what I ment by
>returning the information in a more structured way.
>
>Tested-by: nobody :)
>Suggested-by: Jiri (if I understood correctly)

Yes, you did :) Couple of nits inlined.


>---
> drivers/net/ethernet/mellanox/mlx5/core/en_rep.c |  8 ++-
> drivers/net/ethernet/mellanox/mlxsw/switchx2.c   | 10 ++--
> drivers/net/ethernet/netronome/nfp/nfp_port.c    | 26 ++++-----
> drivers/net/ethernet/netronome/nfp/nfp_port.h    |  4 +-
> include/linux/netdevice.h                        | 18 ++++++-
> include/uapi/linux/if_link.h                     | 16 ++++++
> net/core/dev.c                                   | 31 +++++++++--
> net/core/rtnetlink.c                             | 69 ++++++++++++++++++++++++
> 8 files changed, 153 insertions(+), 29 deletions(-)
>
>diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
>index 45e60be9c277..7a71291b8ec3 100644
>--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
>+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
>@@ -637,16 +637,14 @@ static int mlx5e_rep_close(struct net_device *dev)
> }
> 
> static int mlx5e_rep_get_phys_port_name(struct net_device *dev,
>-					char *buf, size_t len)
>+					struct netdev_port_info *info)

Either we rename ndo to something like ndo_get_port_info or you rename
the struct to netdev_port_name_info. These 2 should be in sync


> {
> 	struct mlx5e_priv *priv = netdev_priv(dev);
> 	struct mlx5e_rep_priv *rpriv = priv->ppriv;
> 	struct mlx5_eswitch_rep *rep = rpriv->rep;
>-	int ret;
> 
>-	ret = snprintf(buf, len, "%d", rep->vport - 1);
>-	if (ret >= len)
>-		return -EOPNOTSUPP;
>+	info->type = NETDEV_PORT_PCI_VF;

NETDEV_PORT_TYPE_PCI_VF
or
NETDEV_PORT_NAME_TYPE_PCI_VF
depends on the option you chose above.


>+	info->pci.vf_id = rep->vport - 1;
> 
> 	return 0;
> }
>diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
>index 3b0f72455681..383b8b5f41cf 100644
>--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
>+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
>@@ -413,15 +413,13 @@ mlxsw_sx_port_get_stats64(struct net_device *dev,
> 	stats->tx_dropped	= tx_dropped;
> }
> 
>-static int mlxsw_sx_port_get_phys_port_name(struct net_device *dev, char *name,
>-					    size_t len)
>+static int mlxsw_sx_port_get_phys_port_name(struct net_device *dev,
>+					    struct netdev_port_info *info)
> {
> 	struct mlxsw_sx_port *mlxsw_sx_port = netdev_priv(dev);
>-	int err;
> 
>-	err = snprintf(name, len, "p%d", mlxsw_sx_port->mapping.module + 1);
>-	if (err >= len)
>-		return -EINVAL;
>+	info->type = NETDEV_PORT_EXTERNAL;
>+	info->port.id = mlxsw_sx_port->mapping.module + 1;
> 
> 	return 0;
> }
>diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.c b/drivers/net/ethernet/netronome/nfp/nfp_port.c
>index d16a7b78ba9b..8f5c37b9a79c 100644
>--- a/drivers/net/ethernet/netronome/nfp/nfp_port.c
>+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.c
>@@ -143,11 +143,11 @@ struct nfp_eth_table_port *nfp_port_get_eth_port(struct nfp_port *port)
> }
> 
> int
>-nfp_port_get_phys_port_name(struct net_device *netdev, char *name, size_t len)
>+nfp_port_get_phys_port_name(struct net_device *netdev,
>+			    struct netdev_port_info *info)
> {
> 	struct nfp_eth_table_port *eth_port;
> 	struct nfp_port *port;
>-	int n;
> 
> 	port = nfp_port_from_netdev(netdev);
> 	if (!port)
>@@ -159,25 +159,27 @@ nfp_port_get_phys_port_name(struct net_device *netdev, char *name, size_t len)
> 		if (!eth_port)
> 			return -EOPNOTSUPP;
> 
>-		if (!eth_port->is_split)
>-			n = snprintf(name, len, "p%d", eth_port->label_port);
>-		else
>-			n = snprintf(name, len, "p%ds%d", eth_port->label_port,
>-				     eth_port->label_subport);
>+		info->type = NETDEV_PORT_EXTERNAL;
>+		info->external.id = eth_port->label_port;
>+
>+		if (eth_port->is_split) {
>+			info->type = NETDEV_PORT_EXTERNAL_SPLIT;
>+			info->external.split_id = eth_port->label_subport;
>+		}
> 		break;
> 	case NFP_PORT_PF_PORT:
>-		n = snprintf(name, len, "pf%d", port->pf_id);
>+		info->type = NETDEV_PORT_PCI_PF;
>+		info->pci.pf_id = port->pf_id;
> 		break;
> 	case NFP_PORT_VF_PORT:
>-		n = snprintf(name, len, "pf%dvf%d", port->pf_id, port->vf_id);
>+		info->type = NETDEV_PORT_PCI_VF;
>+		info->pci.pf_id = port->pf_id;
>+		info->pci.vf_id = port->vf_id;
> 		break;
> 	default:
> 		return -EOPNOTSUPP;
> 	}
> 
>-	if (n >= len)
>-		return -EINVAL;
>-
> 	return 0;
> }
> 
>diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.h b/drivers/net/ethernet/netronome/nfp/nfp_port.h
>index 56c76926c82a..03b8746feb29 100644
>--- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
>+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
>@@ -118,8 +118,8 @@ nfp_port_from_id(struct nfp_pf *pf, enum nfp_port_type type, unsigned int id);
> struct nfp_eth_table_port *__nfp_port_get_eth_port(struct nfp_port *port);
> struct nfp_eth_table_port *nfp_port_get_eth_port(struct nfp_port *port);
> 
>-int
>-nfp_port_get_phys_port_name(struct net_device *netdev, char *name, size_t len);
>+int nfp_port_get_phys_port_name(struct net_device *netdev,
>+				struct netdev_port_info *info);
> int nfp_port_configure(struct net_device *netdev, bool configed);
> 
> struct nfp_port *
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index 3a3cdc1b1f31..0a055df701ef 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -845,6 +845,22 @@ struct xfrmdev_ops {
> };
> #endif
> 
>+struct netdev_port_info {
>+	int type;

enum please


>+
>+	union {
>+		struct {
>+			u32 id;
>+			u32 split_id;
>+		} external;
>+
>+		struct {
>+			u32 pf_id;
>+			u32 vf_id;
>+		} pci;
>+	};
>+};
>+
> /*
>  * This structure defines the management hooks for network devices.
>  * The following hooks can be defined; unless noted otherwise, they are
>@@ -1306,7 +1322,7 @@ struct net_device_ops {
> 	int			(*ndo_get_phys_port_id)(struct net_device *dev,
> 							struct netdev_phys_item_id *ppid);
> 	int			(*ndo_get_phys_port_name)(struct net_device *dev,
>-							  char *name, size_t len);
>+							  struct netdev_port_info *info);
> 	void			(*ndo_udp_tunnel_add)(struct net_device *dev,
> 						      struct udp_tunnel_info *ti);
> 	void			(*ndo_udp_tunnel_del)(struct net_device *dev,
>diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>index 8d062c58d5cb..e00ff0333e3f 100644
>--- a/include/uapi/linux/if_link.h
>+++ b/include/uapi/linux/if_link.h
>@@ -158,6 +158,7 @@ enum {
> 	IFLA_PAD,
> 	IFLA_XDP,
> 	IFLA_EVENT,
>+	IFLA_PORT_INFO,
> 	__IFLA_MAX
> };
> 
>@@ -927,4 +928,19 @@ enum {
> 	IFLA_EVENT_BONDING_OPTIONS,	/* change in bonding options */
> };
> 
>+enum {
>+	NETDEV_PORT_EXTERNAL,
>+	NETDEV_PORT_EXTERNAL_SPLIT,
>+	NETDEV_PORT_PCI_PF,

Isn't PF also EXTERNAL? Cant VF be split? What I'm getting at, shoudn't
these be flags?


>+	NETDEV_PORT_PCI_VF,
>+};
>+
