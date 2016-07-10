From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, do segmentation even for non IPSKB_FORWARDED skbs
Date: Sun, 10 Jul 2016 10:51:20 +0300
Message-ID: <20160710105120.72d80371@pixies>
References: <1467722132-10084-1-git-send-email-shmulik.ladkani@ravellosystems.com>
	<20160705130327.GA10737@breakpoint.cc>
	<20160705170541.3f210675@pixies>
	<20160709090020.GB2067@breakpoint.cc>
	<20160709153017.791f2607@halley>
	<20160709132230.GD2067@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	shmulik.ladkani@gmail.com, netdev@vger.kernel.org,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38766 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbcGJHva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2016 03:51:30 -0400
Received: by mail-wm0-f48.google.com with SMTP id o80so13845910wme.1
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2016 00:51:29 -0700 (PDT)
In-Reply-To: <20160709132230.GD2067@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 9 Jul 2016 15:22:30 +0200, fw@strlen.de wrote:
> Shmulik Ladkani <shmulik.ladkani@ravellosystems.com> wrote:
> > I'd appreciate any suggestion how to determine traffic is local OTHER
> > THAN testing IPSKB_FORWARDED; If we have such a way, there wouldn't be an
> > impact on local traffic.
> > 
> > > What about setting IPCB FORWARD flag in iptunnel_xmit if
> > > skb->skb_iif != 0... instead?
> > 
> > Can you please elaborate?
> 
> diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
> --- a/net/ipv4/ip_tunnel_core.c
> +++ b/net/ipv4/ip_tunnel_core.c
> @@ -65,6 +65,7 @@ void iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
>  	struct net_device *dev = skb->dev;
>  	struct iphdr *iph;
>  	int err;
> +	bool fwd = skb->skb_iif > 0;
>  
>  	skb_scrub_packet(skb, xnet);
>  
> @@ -72,6 +73,9 @@ void iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
>  	skb_dst_set(skb, &rt->dst);
>  	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
>  
> +	if (fwd)
> +		IPCB(skb)->flags = IPSKB_FORWARDED;
> +

Thanks.

OK with the general idea; However I don't want to abuse IPSKB_FORWARDED
as the skb is not really "ip forwarded", and it might have undesirable
affects, such as in 'ip_skb_dst_mtu' which follows.

How about a new IPSKB bit flag, say IPSKB_TUNNEL_FORWARDED, or a
different way of marking?

Regards,
Shmulik
