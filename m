From: David Miller <davem@davemloft.net>
Subject: Re: Very Minor Patch to loopback.c
Date: Thu, 12 Jun 2014 15:22:19 -0700 (PDT)
Message-ID: <20140612.152219.1525707034580179174.davem@davemloft.net>
References: <CAECMkcNrXmuE4saV2==GrCwjwEUzAaGi+NroP5ZXxrRpqr0AwA@mail.gmail.com>
	<CAECMkcMGgCjCF-GVjyywn+B9cgMLwCsPQB3y1R2eMsck-=qv8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zacharyw09264@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54748 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735AbaFLWWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 18:22:22 -0400
In-Reply-To: <CAECMkcMGgCjCF-GVjyywn+B9cgMLwCsPQB3y1R2eMsck-=qv8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zachary <zacharyw09264@gmail.com>
Date: Thu, 12 Jun 2014 16:24:03 -0400

> Updated due to Richard Weinberger's info in linux-kernel
> 
> diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
> index bb96409..fc03883 100644
> --- a/drivers/net/loopback.c
> +++ b/drivers/net/loopback.c
> @@ -72,7 +72,6 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
>                                  struct net_device *dev)
>  {
>         struct pcpu_lstats *lb_stats;
> -       int len;
> 
>         skb_orphan(skb);
> 
> @@ -86,10 +85,9 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
>         /* it's OK to use per_cpu_ptr() because BHs are off */
>         lb_stats = this_cpu_ptr(dev->lstats);
> 
> -       len = skb->len;
>         if (likely(netif_rx(skb) == NET_RX_SUCCESS)) {
>                 u64_stats_update_begin(&lb_stats->syncp);
> -               lb_stats->bytes += len;
> +               lb_stats->bytes += skb->len;
>                 lb_stats->packets++;
>                 u64_stats_update_end(&lb_stats->syncp);
>         }

After 'skb' is passed to netif_rx(), it can no longer be accessed because
that function can free 'skb'.

That is why we load skb->len into a local variable, before calling
netif_rx().
