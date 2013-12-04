From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Tue, 3 Dec 2013 16:26:28 -0800
Message-ID: <CAMEtUuzEM957fRjsb5aSG7xHWKp13fy59QxWpsU_=d+-6ydazg@mail.gmail.com>
References: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
	<1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com>
	<20131203.165034.1085515763685633822.davem@davemloft.net>
	<1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com>
	<1386115199.30495.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	David Miller <davem@davemloft.net>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Jerry Chu <hkchu@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f182.google.com ([74.125.82.182]:44415 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206Ab3LDA03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 19:26:29 -0500
Received: by mail-we0-f182.google.com with SMTP id q59so14599077wes.27
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 16:26:28 -0800 (PST)
In-Reply-To: <1386115199.30495.44.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 3, 2013 at 3:59 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> +#define SKB_CONSUMED_MAGIC ((void *)0xDEAD0001)
> +static inline void dev_consume_skb_any(struct sk_buff *skb)
> +{
> +       skb->dev = SKB_CONSUMED_MAGIC;
> +       dev_kfree_skb_any(skb);
> +}
> +
>  int netif_rx(struct sk_buff *skb);
>  int netif_rx_ni(struct sk_buff *skb);
>  int netif_receive_skb(struct sk_buff *skb);
> diff --git a/net/core/dev.c b/net/core/dev.c
> index ba3b7ea5ebb3..b2b0e5776ce9 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3306,7 +3306,10 @@ static void net_tx_action(struct softirq_action *h)
>                         clist = clist->next;
>
>                         WARN_ON(atomic_read(&skb->users));
> -                       trace_kfree_skb(skb, net_tx_action);
> +                       if (likely(skb->dev == SKB_CONSUMED_MAGIC))
> +                               trace_consume_skb(skb);
> +                       else
> +                               trace_kfree_skb(skb, net_tx_action);

Could you use some other way to mark skb ?
In tracing we might want to examine skb more carefully and not being
able to see the device
will limit the usability of this tracepoint.
