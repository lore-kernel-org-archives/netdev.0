From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH net-next 1/1] driver: veth: Refine the statistics codes of
 veth driver
Date: Thu, 3 Nov 2016 20:56:59 +0800
Message-ID: <CA+6hz4qdRXGgDeWWoypS=Ju0qwyVi3WrZRecUnfxAe83mSZfiw@mail.gmail.com>
References: <1478177414-8034-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Feng Gao <gfree.wind@gmail.com>, Gao Feng <fgao@ikuai8.com>
To: "David S. Miller" <davem@davemloft.net>,
        Cong Wang <cwang@twopensource.com>,
        Vijay Pandurangan <vijayp@vijayp.ca>,
        Evan Jones <ej@evanjones.ca>, pabeni@redhat.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:33708 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932467AbcKCM5B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 08:57:01 -0400
Received: by mail-ua0-f193.google.com with SMTP id 20so1856379uak.0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 05:57:00 -0700 (PDT)
In-Reply-To: <1478177414-8034-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is deprecated.

On Thu, Nov 3, 2016 at 8:50 PM,  <fgao@ikuai8.com> wrote:
> From: Gao Feng <fgao@ikuai8.com>
>
> The dropped count of veth is located in struct veth_priv, but other
> statistics like packets and bytes are in another struct pcpu_vstats.
> Now keep these three counters in the same struct.
>
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  drivers/net/veth.c | 32 ++++++++++++++++++--------------
>  1 file changed, 18 insertions(+), 14 deletions(-)
>
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index 0520952a..3d8326f 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -26,12 +26,12 @@
>  struct pcpu_vstats {
>         u64                     packets;
>         u64                     bytes;
> +       u64                     dropped;
>         struct u64_stats_sync   syncp;
>  };
>
>  struct veth_priv {
>         struct net_device __rcu *peer;
> -       atomic64_t              dropped;
>         unsigned                requested_headroom;
>  };
>
> @@ -108,6 +108,8 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
>         struct veth_priv *priv = netdev_priv(dev);
>         struct net_device *rcv;
>         int length = skb->len;
> +       struct pcpu_vstats *stats = this_cpu_ptr(dev->vstats);
> +       int ret = NET_RX_DROP;
>
>         rcu_read_lock();
>         rcv = rcu_dereference(priv->peer);
> @@ -116,17 +118,16 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
>                 goto drop;
>         }
>
> -       if (likely(dev_forward_skb(rcv, skb) == NET_RX_SUCCESS)) {
> -               struct pcpu_vstats *stats = this_cpu_ptr(dev->vstats);
> -
> -               u64_stats_update_begin(&stats->syncp);
> +       ret = dev_forward_skb(rcv, skb);
> +drop:
> +       u64_stats_update_begin(&stats->syncp);
> +       if (likely(ret == NET_RX_SUCCESS)) {
>                 stats->bytes += length;
>                 stats->packets++;
> -               u64_stats_update_end(&stats->syncp);
>         } else {
> -drop:
> -               atomic64_inc(&priv->dropped);
> +               stats->dropped++;
>         }
> +       u64_stats_update_end(&stats->syncp);
>         rcu_read_unlock();
>         return NETDEV_TX_OK;
>  }
> @@ -135,27 +136,28 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
>   * general routines
>   */
>
> -static u64 veth_stats_one(struct pcpu_vstats *result, struct net_device *dev)
> +static void veth_stats_one(struct pcpu_vstats *result, struct net_device *dev)
>  {
> -       struct veth_priv *priv = netdev_priv(dev);
>         int cpu;
>
>         result->packets = 0;
>         result->bytes = 0;
> +       result->dropped = 0;
>         for_each_possible_cpu(cpu) {
>                 struct pcpu_vstats *stats = per_cpu_ptr(dev->vstats, cpu);
> -               u64 packets, bytes;
> +               u64 packets, bytes, dropped;
>                 unsigned int start;
>
>                 do {
>                         start = u64_stats_fetch_begin_irq(&stats->syncp);
>                         packets = stats->packets;
>                         bytes = stats->bytes;
> +                       dropped = stats->dropped;
>                 } while (u64_stats_fetch_retry_irq(&stats->syncp, start));
>                 result->packets += packets;
>                 result->bytes += bytes;
> +               result->dropped += dropped;
>         }
> -       return atomic64_read(&priv->dropped);
>  }
>
>  static struct rtnl_link_stats64 *veth_get_stats64(struct net_device *dev,
> @@ -165,16 +167,18 @@ static struct rtnl_link_stats64 *veth_get_stats64(struct net_device *dev,
>         struct net_device *peer;
>         struct pcpu_vstats one;
>
> -       tot->tx_dropped = veth_stats_one(&one, dev);
> +       veth_stats_one(&one, dev);
>         tot->tx_bytes = one.bytes;
>         tot->tx_packets = one.packets;
> +       tot->tx_dropped = one.dropped;
>
>         rcu_read_lock();
>         peer = rcu_dereference(priv->peer);
>         if (peer) {
> -               tot->rx_dropped = veth_stats_one(&one, peer);
> +               veth_stats_one(&one, dev);

I find there is one issue. It should be peer, not dev.

>                 tot->rx_bytes = one.bytes;
>                 tot->rx_packets = one.packets;
> +               tot->rx_dropped = one.dropped;
>         }
>         rcu_read_unlock();
>
> --
> 1.9.1
>
>

I find this patch contains one error, so please ignore it.

Regards
Feng
