From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH] net: veth: use new api ethtool_{get|set}_link_ksettings
Date: Mon, 20 Mar 2017 20:25:28 +0800
Message-ID: <CADvbK_dvNYaZ=qE0xkpxVQvyE3d6m3jgWPHEUW3_6Q1mz8oq3Q@mail.gmail.com>
References: <1489835606-23692-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem <davem@davemloft.net>, jarod@redhat.com,
        Stephen Hemminger <stephen@networkplumber.org>,
        dsa@cumulusnetworks.com, aduyck@mirantis.com,
        network dev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489835606-23692-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 18, 2017 at 7:13 PM, Philippe Reynes <tremyfr@gmail.com> wrote:
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
>
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
>  drivers/net/veth.c |   22 ++++++++++------------
>  1 files changed, 10 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index 8c39d6d..730b133 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -45,18 +45,16 @@ struct veth_priv {
>         { "peer_ifindex" },
>  };
>
> -static int veth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
> +static int veth_get_link_ksettings(struct net_device *dev,
> +                                  struct ethtool_link_ksettings *cmd)
>  {
> -       cmd->supported          = 0;
> -       cmd->advertising        = 0;
> -       ethtool_cmd_speed_set(cmd, SPEED_10000);
> -       cmd->duplex             = DUPLEX_FULL;
> -       cmd->port               = PORT_TP;
> -       cmd->phy_address        = 0;
> -       cmd->transceiver        = XCVR_INTERNAL;
> -       cmd->autoneg            = AUTONEG_DISABLE;
> -       cmd->maxtxpkt           = 0;
> -       cmd->maxrxpkt           = 0;
> +       ethtool_link_ksettings_zero_link_mode(cmd, supported);
> +       ethtool_link_ksettings_zero_link_mode(cmd, advertising);
> +       cmd->base.speed = SPEED_10000;
> +       cmd->base.duplex        = DUPLEX_FULL;
> +       cmd->base.port          = PORT_TP;
> +       cmd->base.phy_address   = 0;
It seem always:
        memset(&link_ksettings, 0, sizeof(link_ksettings));
        err = dev->ethtool_ops->get_link_ksettings(dev, &link_ksettings);

do we really need:
       ethtool_link_ksettings_zero_link_mode(cmd, supported);
       ethtool_link_ksettings_zero_link_mode(cmd, advertising);
       cmd->base.phy_address   = 0;
?

> +       cmd->base.autoneg       = AUTONEG_DISABLE;
>         return 0;
>  }
>
> @@ -95,12 +93,12 @@ static void veth_get_ethtool_stats(struct net_device *dev,
>  }
>
>  static const struct ethtool_ops veth_ethtool_ops = {
> -       .get_settings           = veth_get_settings,
>         .get_drvinfo            = veth_get_drvinfo,
>         .get_link               = ethtool_op_get_link,
>         .get_strings            = veth_get_strings,
>         .get_sset_count         = veth_get_sset_count,
>         .get_ethtool_stats      = veth_get_ethtool_stats,
> +       .get_link_ksettings     = veth_get_link_ksettings,
>  };
>
>  static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
> --
> 1.7.4.4
>
