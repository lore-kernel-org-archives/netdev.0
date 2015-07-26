From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next 4/4] mlxsw: Introduce Mellanox SwitchX-2 ASIC support
Date: Sat, 25 Jul 2015 19:45:07 -0700
Message-ID: <CAE4R7bAk_nUCuqcJxuAAr6pOqNX7zXWv1zFZDVGwBi7_nk8=kQ@mail.gmail.com>
References: <1437666216-3149-1-git-send-email-jiri@resnulli.us> <1437666216-3149-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, idosch@mellanox.com,
	eladr@mellanox.com,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	john fastabend <john.fastabend@gmail.com>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	John Linville <linville@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:34463 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964853AbbGZCp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2015 22:45:27 -0400
Received: by obre1 with SMTP id e1so38633058obr.1
        for <netdev@vger.kernel.org>; Sat, 25 Jul 2015 19:45:26 -0700 (PDT)
In-Reply-To: <1437666216-3149-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 23, 2015 at 8:43 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Benefit from the previously introduced Mellanox Switch infrastructure and
> add driver for SwitchX-2 ASIC. Note that this driver is very simple now.
> It implements bare minimum for getting device to work on slow-path.
> Fast-path offload functionality is going to be added soon.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Elad Raz <eladr@mellanox.com>

[cut]

> +static netdev_tx_t mlxsw_sx_port_xmit(struct sk_buff *skb,
> +                                     struct net_device *dev)
> +{
> +       struct mlxsw_sx_port *mlxsw_sx_port = netdev_priv(dev);
> +       struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
> +       struct mlxsw_sx_port_pcpu_stats *pcpu_stats;
> +       const struct mlxsw_tx_info tx_info = {
> +               .local_port = mlxsw_sx_port->local_port,
> +               .is_emad = false,
> +       };
> +       int err;
> +
> +       if (unlikely(skb_headroom(skb) < MLXSW_TXHDR_LEN)) {

Does this happen at all since dev->hard_header_len was set in probe to
add MLXSW_TXHDR_LEN?

> +               struct sk_buff *skb_new;
> +
> +               skb_new = skb_realloc_headroom(skb, MLXSW_TXHDR_LEN);
> +               dev_kfree_skb_any(skb);
> +               if (!skb_new) {
> +                       this_cpu_inc(mlxsw_sx_port->pcpu_stats->tx_dropped);
> +                       return NETDEV_TX_OK;
> +               }
> +               skb = skb_new;
> +       }
> +       mlxsw_sx_txhdr_construct(skb, &tx_info);
> +       err = mlxsw_core_skb_transmit(mlxsw_sx, skb, &tx_info);
> +       if (err == -EAGAIN)
> +               return NETDEV_TX_BUSY;

I think there is a problem here when returning NETDEV_TX_BUSY when
original skb might have been freed above in the headroom check. (ref
Documentation/networking/driver.txt).

[cut]

> +static int mlxsw_sx_port_dev_addr_get(struct mlxsw_sx_port *mlxsw_sx_port)
> +{
> +       struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
> +       struct net_device *dev = mlxsw_sx_port->dev;
> +       char ppad_pl[MLXSW_REG_PPAD_LEN];
> +       int err;
> +
> +       mlxsw_reg_ppad_pack(ppad_pl, false, 0);
> +       err = mlxsw_reg_query(mlxsw_sx->core, MLXSW_REG(ppad), ppad_pl);
> +       if (err)
> +               return err;
> +       mlxsw_reg_ppad_mac_memcpy_from(ppad_pl, dev->dev_addr);
> +       /* The last byte in base mac address is always 0 */
> +       dev->dev_addr[ETH_ALEN - 1] += mlxsw_sx_port->local_port;

If MLXSW_PORT_MAX_PORTS > 256, you'll wrap this.  Is dev_addr[ETH_ALEN
- 2] available to carry into?

> +       return 0;
> +}
> +

[cut]

> +static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port)
> +{
> +       struct mlxsw_sx_port *mlxsw_sx_port;
> +       struct net_device *dev;
> +       bool usable;
> +       int err;
> +
> +       dev = alloc_etherdev(sizeof(struct mlxsw_sx_port));
> +       if (!dev)
> +               return -ENOMEM;
> +       mlxsw_sx_port = netdev_priv(dev);
> +       mlxsw_sx_port->dev = dev;
> +       mlxsw_sx_port->mlxsw_sx = mlxsw_sx;
> +       mlxsw_sx_port->local_port = local_port;
> +
> +       mlxsw_sx_port->pcpu_stats =
> +               netdev_alloc_pcpu_stats(struct mlxsw_sx_port_pcpu_stats);
> +       if (!mlxsw_sx_port->pcpu_stats) {
> +               err = -ENOMEM;
> +               goto err_alloc_stats;
> +       }
> +
> +       dev->netdev_ops = &mlxsw_sx_port_netdev_ops;
> +       dev->ethtool_ops = &mlxsw_sx_port_ethtool_ops;
> +       dev->switchdev_ops = &mlxsw_sx_port_switchdev_ops;
> +
> +       err = mlxsw_sx_port_dev_addr_get(mlxsw_sx_port);
> +       if (err) {
> +               dev_err(mlxsw_sx->bus_info->dev, "Port %d: Unable to get port mac address\n",
> +                       mlxsw_sx_port->local_port);
> +               goto err_dev_addr_get;
> +       }
> +
> +       netif_carrier_off(dev);
> +
> +       dev->features |= NETIF_F_NETNS_LOCAL | NETIF_F_LLTX |

Not supposed to use LLTX in new drivers, according to
include/linux/netdev_features.h.
