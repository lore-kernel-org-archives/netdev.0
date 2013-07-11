From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] gre: Fix MTU sizing check for gretap tunnels
Date: Thu, 11 Jul 2013 15:24:59 -0700
Message-ID: <CALnjE+p3tqNO9Fbn=+LLtL8VvfvSQyOLDZoFRvGFTXgJzHKqhQ@mail.gmail.com>
References: <20130711201152.8775.40579.stgit@ahduyck-hc1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jesse@nicira.com,
	davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog111.obsmtp.com ([74.125.149.205]:34841 "HELO
	na3sys009aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752551Ab3GKWZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 18:25:00 -0400
Received: by mail-qa0-f42.google.com with SMTP id hu16so23124qab.15
        for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 15:24:59 -0700 (PDT)
In-Reply-To: <20130711201152.8775.40579.stgit@ahduyck-hc1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 11, 2013 at 1:12 PM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
> This change fixes an MTU sizing issue seen with gretap tunnels when non-gso
> packets are sent from the interface.
>
> In my case I was able to reproduce the issue by simply sending a ping of
> 1421 bytes with the gretap interface created on a device with a standard
> 1500 mtu.
>
> This fix is based on the fact that the tunnel mtu is already adjusted by
> dev->hard_header_len so it would make sense that any packets being compared
> against that mtu should also be adjusted by hard_header_len and the tunnel
> header instead of just the tunnel header.
>
we can simplify code by not doing dev->hard_header_len adjustment to tunnel-mtu.

And right thing would be adjusting tunnel-mtu according to rt->dst.dev
header-len so that we get mtu for out going path.

> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>
>  net/ipv4/ip_tunnel.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index 945734b..ca1cb2d 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -476,7 +476,7 @@ static int tnl_update_pmtu(struct net_device *dev, struct sk_buff *skb,
>                             struct rtable *rt, __be16 df)
>  {
>         struct ip_tunnel *tunnel = netdev_priv(dev);
> -       int pkt_size = skb->len - tunnel->hlen;
> +       int pkt_size = skb->len - tunnel->hlen - dev->hard_header_len;
>         int mtu;
>
>         if (df)
>
