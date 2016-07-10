From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v6 02/12] net: add ndo to set xdp prog in adapter rx
Date: Sun, 10 Jul 2016 15:59:00 -0500
Message-ID: <CALx6S36-ccirAZBbHCNO3hHeuW32tSwNPcxz5oevp90fzm+BOg@mail.gmail.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com> <1467944124-14891-3-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34335 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757207AbcGJU7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2016 16:59:01 -0400
Received: by mail-io0-f196.google.com with SMTP id 100so13106152ioh.1
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2016 13:59:00 -0700 (PDT)
In-Reply-To: <1467944124-14891-3-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 7, 2016 at 9:15 PM, Brenden Blanco <bblanco@plumgrid.com> wrote:
> Add two new set/check netdev ops for drivers implementing the
> BPF_PROG_TYPE_XDP filter.
>
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
> ---
>  include/linux/netdevice.h | 14 ++++++++++++++
>  net/core/dev.c            | 30 ++++++++++++++++++++++++++++++
>  2 files changed, 44 insertions(+)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 49736a3..36ae955 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -63,6 +63,7 @@ struct wpan_dev;
>  struct mpls_dev;
>  /* UDP Tunnel offloads */
>  struct udp_tunnel_info;
> +struct bpf_prog;
>
>  void netdev_set_default_ethtool_ops(struct net_device *dev,
>                                     const struct ethtool_ops *ops);
> @@ -1087,6 +1088,15 @@ struct tc_to_netdev {
>   *     appropriate rx headroom value allows avoiding skb head copy on
>   *     forward. Setting a negative value resets the rx headroom to the
>   *     default value.
> + * int (*ndo_xdp_set)(struct net_device *dev, struct bpf_prog *prog);
> + *     This function is used to set or clear a bpf program used in the
> + *     earliest stages of packet rx. The prog will have been loaded as
> + *     BPF_PROG_TYPE_XDP. The callee is responsible for calling bpf_prog_put
> + *     on any old progs that are stored, but not on the passed in prog.
> + * bool (*ndo_xdp_attached)(struct net_device *dev);
> + *     This function is used to check if a bpf program is set on the device.
> + *     The callee should return true if a program is currently attached and
> + *     running.
>   *
>   */
>  struct net_device_ops {
> @@ -1271,6 +1281,9 @@ struct net_device_ops {
>                                                        struct sk_buff *skb);
>         void                    (*ndo_set_rx_headroom)(struct net_device *dev,
>                                                        int needed_headroom);
> +       int                     (*ndo_xdp_set)(struct net_device *dev,
> +                                              struct bpf_prog *prog);
> +       bool                    (*ndo_xdp_attached)(struct net_device *dev);

It might nice if everything could be accomplished with with one ndo
function (just too many ndo's flying around). Also, may want to
consider future like maybe we have an XDP function in output path, or
multiple programs pipelined together somehow.

>  };
>
>  /**
> @@ -3257,6 +3270,7 @@ int dev_get_phys_port_id(struct net_device *dev,
>  int dev_get_phys_port_name(struct net_device *dev,
>                            char *name, size_t len);
>  int dev_change_proto_down(struct net_device *dev, bool proto_down);
> +int dev_change_xdp_fd(struct net_device *dev, int fd);
>  struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev);
>  struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>                                     struct netdev_queue *txq, int *ret);
> diff --git a/net/core/dev.c b/net/core/dev.c
> index b92d63b..154b057 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -94,6 +94,7 @@
>  #include <linux/ethtool.h>
>  #include <linux/notifier.h>
>  #include <linux/skbuff.h>
> +#include <linux/bpf.h>
>  #include <net/net_namespace.h>
>  #include <net/sock.h>
>  #include <net/busy_poll.h>
> @@ -6615,6 +6616,35 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
>  EXPORT_SYMBOL(dev_change_proto_down);
>
>  /**
> + *     dev_change_xdp_fd - set or clear a bpf program for a device rx path
> + *     @dev: device
> + *     @fd: new program fd or negative value to clear
> + *
> + *     Set or clear a bpf program for a device
> + */
> +int dev_change_xdp_fd(struct net_device *dev, int fd)
> +{
> +       const struct net_device_ops *ops = dev->netdev_ops;
> +       struct bpf_prog *prog = NULL;
> +       int err;
> +
> +       if (!ops->ndo_xdp_set)
> +               return -EOPNOTSUPP;
> +       if (fd >= 0) {
> +               prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_XDP);
> +               if (IS_ERR(prog))
> +                       return PTR_ERR(prog);
> +       }
> +
> +       err = ops->ndo_xdp_set(dev, prog);
> +       if (err < 0 && prog)
> +               bpf_prog_put(prog);
> +
> +       return err;
> +}
> +EXPORT_SYMBOL(dev_change_xdp_fd);
> +
> +/**
>   *     dev_new_index   -       allocate an ifindex
>   *     @net: the applicable net namespace
>   *
> --
> 2.8.2
>
