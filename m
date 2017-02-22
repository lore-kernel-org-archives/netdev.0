From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v4 4/7] gtp: consolidate gtp socket rx path
Date: Wed, 22 Feb 2017 09:41:17 -0800
Message-ID: <CALx6S34-H9rzbJjJRGkRqswnOFK7pKg0gMU+JkgK=Nh77dWoiQ@mail.gmail.com>
References: <20170221101855.23940-1-aschultz@tpip.net> <20170221101855.23940-5-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira <pablo@netfilter.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Harald Welte <laforge@gnumonks.org>,
        osmocom-net-gprs@lists.osmocom.org
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:35500 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932223AbdBVRlT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 12:41:19 -0500
Received: by mail-qt0-f196.google.com with SMTP id b16so1286686qte.2
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 09:41:18 -0800 (PST)
In-Reply-To: <20170221101855.23940-5-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 2:18 AM, Andreas Schultz <aschultz@tpip.net> wrote:
> Add network device to gtp context in preparation for splitting
> the TEID from the network device.
>
> Use this to rework the socker rx path. Move the common RX part
> of v0 and v1 into a helper. Also move the final rx part into
> that helper as well.
>
Andeas,

How are these GTP kernel patches being tested? Is it possible to
create some sort of GTP network device that separates out just the
datapath for development in the same way that VXLAN did this?

Tom

> Signed-off-by: Andreas Schultz <aschultz@tpip.net>
> ---
>  drivers/net/gtp.c | 80 ++++++++++++++++++++++++++++++-------------------------
>  1 file changed, 44 insertions(+), 36 deletions(-)
>
> diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
> index 961fb3c..fc0fff5 100644
> --- a/drivers/net/gtp.c
> +++ b/drivers/net/gtp.c
> @@ -58,6 +58,8 @@ struct pdp_ctx {
>         struct in_addr          ms_addr_ip4;
>         struct in_addr          sgsn_addr_ip4;
>
> +       struct net_device       *dev;
> +
>         atomic_t                tx_seq;
>         struct rcu_head         rcu_head;
>  };
> @@ -175,6 +177,40 @@ static bool gtp_check_src_ms(struct sk_buff *skb, struct pdp_ctx *pctx,
>         return false;
>  }
>
> +static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb, unsigned int hdrlen,
> +                 bool xnet)
> +{
> +       struct pcpu_sw_netstats *stats;
> +
> +       if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
> +               netdev_dbg(pctx->dev, "No PDP ctx for this MS\n");
> +               return 1;
> +       }
> +
> +       /* Get rid of the GTP + UDP headers. */
> +       if (iptunnel_pull_header(skb, hdrlen, skb->protocol, xnet))
> +               return -1;
> +
> +       netdev_dbg(pctx->dev, "forwarding packet from GGSN to uplink\n");
> +
> +       /* Now that the UDP and the GTP header have been removed, set up the
> +        * new network header. This is required by the upper layer to
> +        * calculate the transport header.
> +        */
> +       skb_reset_network_header(skb);
> +
> +       skb->dev = pctx->dev;
> +
> +       stats = this_cpu_ptr(pctx->dev->tstats);
> +       u64_stats_update_begin(&stats->syncp);
> +       stats->rx_packets++;
> +       stats->rx_bytes += skb->len;
> +       u64_stats_update_end(&stats->syncp);
> +
> +       netif_rx(skb);
> +       return 0;
> +}
> +
>  /* 1 means pass up to the stack, -1 means drop and 0 means decapsulated. */
>  static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
>                                bool xnet)
> @@ -201,13 +237,7 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
>                 return 1;
>         }
>
> -       if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
> -               netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
> -               return 1;
> -       }
> -
> -       /* Get rid of the GTP + UDP headers. */
> -       return iptunnel_pull_header(skb, hdrlen, skb->protocol, xnet);
> +       return gtp_rx(pctx, skb, hdrlen, xnet);
>  }
>
>  static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
> @@ -250,13 +280,7 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
>                 return 1;
>         }
>
> -       if (!gtp_check_src_ms(skb, pctx, hdrlen)) {
> -               netdev_dbg(gtp->dev, "No PDP ctx for this MS\n");
> -               return 1;
> -       }
> -
> -       /* Get rid of the GTP + UDP headers. */
> -       return iptunnel_pull_header(skb, hdrlen, skb->protocol, xnet);
> +       return gtp_rx(pctx, skb, hdrlen, xnet);
>  }
>
>  static void gtp_encap_destroy(struct sock *sk)
> @@ -290,10 +314,9 @@ static void gtp_encap_disable(struct gtp_dev *gtp)
>   */
>  static int gtp_encap_recv(struct sock *sk, struct sk_buff *skb)
>  {
> -       struct pcpu_sw_netstats *stats;
>         struct gtp_dev *gtp;
> +       int ret = 0;
>         bool xnet;
> -       int ret;
>
>         gtp = rcu_dereference_sk_user_data(sk);
>         if (!gtp)
> @@ -319,33 +342,17 @@ static int gtp_encap_recv(struct sock *sk, struct sk_buff *skb)
>         switch (ret) {
>         case 1:
>                 netdev_dbg(gtp->dev, "pass up to the process\n");
> -               return 1;
> +               break;
>         case 0:
> -               netdev_dbg(gtp->dev, "forwarding packet from GGSN to uplink\n");
>                 break;
>         case -1:
>                 netdev_dbg(gtp->dev, "GTP packet has been dropped\n");
>                 kfree_skb(skb);
> -               return 0;
> +               ret = 0;
> +               break;
>         }
>
> -       /* Now that the UDP and the GTP header have been removed, set up the
> -        * new network header. This is required by the upper layer to
> -        * calculate the transport header.
> -        */
> -       skb_reset_network_header(skb);
> -
> -       skb->dev = gtp->dev;
> -
> -       stats = this_cpu_ptr(gtp->dev->tstats);
> -       u64_stats_update_begin(&stats->syncp);
> -       stats->rx_packets++;
> -       stats->rx_bytes += skb->len;
> -       u64_stats_update_end(&stats->syncp);
> -
> -       netif_rx(skb);
> -
> -       return 0;
> +       return ret;
>  }
>
>  static int gtp_dev_init(struct net_device *dev)
> @@ -951,6 +958,7 @@ static int ipv4_pdp_add(struct gtp_dev *gtp, struct genl_info *info)
>         if (pctx == NULL)
>                 return -ENOMEM;
>
> +       pctx->dev = gtp->dev;
>         ipv4_pdp_fill(pctx, info);
>         atomic_set(&pctx->tx_seq, 0);
>
> --
> 2.10.2
>
