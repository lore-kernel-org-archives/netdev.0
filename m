From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net 1/1] driver: veth: Return the actual value instead
 return NETDEV_TX_OK always
Date: Wed, 2 Nov 2016 13:22:49 -0700
Message-ID: <CAM_iQpW4HmtoSAiKSyq9o0MXpL1R8XL2-r3NsPH6xu9Pd4X8XA@mail.gmail.com>
References: <1478080756-16789-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Cong Wang <cwang@twopensource.com>,
        Vijay Pandurangan <vijayp@vijayp.ca>,
        Evan Jones <ej@evanjones.ca>, pabeni@redhat.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:35178 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756309AbcKBUXK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 16:23:10 -0400
Received: by mail-oi0-f66.google.com with SMTP id v84so2820752oie.2
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 13:23:10 -0700 (PDT)
In-Reply-To: <1478080756-16789-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 2, 2016 at 2:59 AM,  <fgao@ikuai8.com> wrote:
> From: Gao Feng <fgao@ikuai8.com>
>
> Current veth_xmit always returns NETDEV_TX_OK whatever if it is really
> sent successfully. Now return the actual value instead of NETDEV_TX_OK
> always.
>
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  drivers/net/veth.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index fbc853e..769a3bd 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -111,15 +111,18 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
>         struct veth_priv *priv = netdev_priv(dev);
>         struct net_device *rcv;
>         int length = skb->len;
> +       int ret = NETDEV_TX_OK;
>
>         rcu_read_lock();
>         rcv = rcu_dereference(priv->peer);
>         if (unlikely(!rcv)) {
>                 kfree_skb(skb);
> +               ret = NET_RX_DROP;


Returning NET_RX_DROP doesn't look correct in a xmit function.


>                 goto drop;
>         }
>
> -       if (likely(dev_forward_skb(rcv, skb) == NET_RX_SUCCESS)) {
> +       ret = dev_forward_skb(rcv, skb);
> +       if (likely(ret == NET_RX_SUCCESS)) {
>                 struct pcpu_vstats *stats = this_cpu_ptr(dev->vstats);
>
>                 u64_stats_update_begin(&stats->syncp);
> @@ -131,7 +134,7 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
>                 atomic64_inc(&priv->dropped);
>         }
>         rcu_read_unlock();
> -       return NETDEV_TX_OK;
> +       return ret;
>  }
>
>  /*
> --
> 1.9.1
>
>
