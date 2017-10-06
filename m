From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC 2/3] tun: expand ethtool stats with zerocopy
Date: Fri, 6 Oct 2017 18:32:45 -0400
Message-ID: <CAF=yD-+shuwJVLvxr3omjoib_WO2ZQ9fZut1oaH=t3v-Tqw8jg@mail.gmail.com>
References: <20171006222516.90654-1-willemdebruijn.kernel@gmail.com> <20171006222516.90654-3-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:50463 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752458AbdJFWd1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 18:33:27 -0400
Received: by mail-oi0-f68.google.com with SMTP id q4so14262675oic.7
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 15:33:27 -0700 (PDT)
In-Reply-To: <20171006222516.90654-3-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 6, 2017 at 6:25 PM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> Add two counters to tun ethool stats to count zerocopy completions.
> - tx_zerocopy counts completions that succeeded without copy.
> - tx_zerocopy_err counts those that triggered a copy.
>
> Tun intercepts completions by replacing the zerocopy completion
> handler (ubuf_info) prepared by the packet source (vhost-net)
> with its own.
>
> To avoid adding another ubuf_info alloc/free in the datapath, only
> enter this mode if the packet source passed an array of two ubuf_info
> to the tun device.
>
> Pass msg_controllen to tun_get_user to detect this.
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  drivers/net/tun.c | 79 ++++++++++++++++++++++++++++++++++++++++++++++++-------
>  1 file changed, 69 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index df6ef9670d05..286787d8e875 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -149,6 +149,8 @@ struct tun_pcpu_stats {
>         u32 rx_dropped;
>         u32 tx_dropped;
>         u32 rx_frame_errors;
> +       u64 tx_zerocopy;
> +       u64 tx_zerocopy_err;
>  };
>
>  /* A tun_file connects an open character device to a tuntap netdevice. It
> @@ -201,6 +203,8 @@ static const struct {
>         { "tx_packets" },
>         { "rx_bytes" },
>         { "tx_bytes" },
> +       { "tx_zerocopy" },
> +       { "tx_zerocopy_err" },
>  };
>
>  /* Since the socket were moved to tun_file, to preserve the behavior of persist
> @@ -1082,8 +1086,9 @@ static void tun_set_headroom(struct net_device *dev, int new_hr)
>         tun->align = new_hr;
>  }
>
> -static void
> -tun_net_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
> +static void __tun_net_get_stats64(struct net_device *dev,
> +                                 struct rtnl_link_stats64 *stats,
> +                                 u64 *ethtool_stats)
>  {
>         u32 rx_dropped = 0, tx_dropped = 0, rx_frame_errors = 0;
>         struct tun_struct *tun = netdev_priv(dev);
> @@ -1103,6 +1108,16 @@ tun_net_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
>                         txbytes         = p->tx_bytes;
>                 } while (u64_stats_fetch_retry(&p->syncp, start));
>
> +               if (ethtool_stats) {
> +                       ethtool_stats[0] += rxpackets;
> +                       ethtool_stats[1] += txpackets;
> +                       ethtool_stats[2] += rxbytes;
> +                       ethtool_stats[3] += txbytes;
> +                       ethtool_stats[4] += p->tx_zerocopy;
> +                       ethtool_stats[5] += p->tx_zerocopy_err;
> +                       continue;
> +               }
> +
>                 stats->rx_packets       += rxpackets;
>                 stats->rx_bytes         += rxbytes;
>                 stats->tx_packets       += txpackets;
> @@ -1113,11 +1128,21 @@ tun_net_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
>                 rx_frame_errors += p->rx_frame_errors;
>                 tx_dropped      += p->tx_dropped;
>         }
> +
> +       if (ethtool_stats)
> +               return;
> +
>         stats->rx_dropped  = rx_dropped;
>         stats->rx_frame_errors = rx_frame_errors;
>         stats->tx_dropped = tx_dropped;
>  }
>
> +static void tun_net_get_stats64(struct net_device *dev,
> +                               struct rtnl_link_stats64 *stats)
> +{
> +       __tun_net_get_stats64(dev, stats, NULL);
> +}
> +
>  static int tun_xdp_set(struct net_device *dev, struct bpf_prog *prog,
>                        struct netlink_ext_ack *extack)
>  {
> @@ -1537,10 +1562,44 @@ static struct sk_buff *tun_build_skb(struct tun_struct *tun,
>         return NULL;
>  }
>
> +static void tun_zerocopy_callback(struct ubuf_info *ubuf, bool success)
> +{
> +       struct tun_struct *tun = ubuf->ctx;

This might need an explicit reference to avoid the tun device going
away. Noticed that too late.. need to take a closer look.
