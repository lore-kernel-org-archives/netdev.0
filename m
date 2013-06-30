From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: ip_tunnel mtu calculation
Date: Sat, 29 Jun 2013 21:36:39 -0700
Message-ID: <CALnjE+pTXGwhePigZRyfVORkgbpwRDF1hTBRnR24fcsqvsP9ug@mail.gmail.com>
References: <20130629175701.73c17a16@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:60647 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750737Ab3F3Egk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jun 2013 00:36:40 -0400
Received: by mail-qc0-f172.google.com with SMTP id j10so2229251qcx.17
        for <netdev@vger.kernel.org>; Sat, 29 Jun 2013 21:36:39 -0700 (PDT)
In-Reply-To: <20130629175701.73c17a16@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 29, 2013 at 7:57 AM, Timo Teras <timo.teras@iki.fi> wrote:
> Hi,
>
> I'm reviewing changes since 3.9 to net-next and observed that, the
> tunnel refactoring had the following change in ip_gre xmit path.
>
> In ip_tunnel_xmit() mtu is now calculated as:
>         if (df)
>                 mtu = dst_mtu(&rt->dst) - dev->hard_header_len
>                                         - sizeof(struct iphdr);
>         else
>                 mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) : dev->mtu;
>
> And it used to be in ip_gre.c: ipgre_tunnel_xmit():
>         if (df)
>                 mtu = dst_mtu(&rt->dst) - dev->hard_header_len - tunnel->hlen;
>         else
>                 mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) : dev->mtu;
>
> I notice that tunnel->hlen is replaced with sizeof(struct iphdr), but
> in case of GRE those are not the same thing. And the refactored
> ip_gre.c does not set hard_header_len either. So it would like the mtu
> is now miscalculated (planning to give a full test-spin for net-next
> next week).
>
> It seems the tunnel->hlen used to be the full length, including
> sizeof(struct iphdr).
>
> But the new, refactored code seems exclude sizeof(struct iphdr) from
> the tunnel->hlen. So would the following be appropriate?
>
This is ip-tunnel layer, skb has gre header pushed. so mtu does not
need to account gre header when compared to skb->len.
But I missed one comparison for mtu check where iph->tot-len is used
rather that skb-len, which is correct length.

gre module is using iph->tot_len for pmtu check which is wrong for
gre-tap device. This bug is there even before restructuring.
I will send out patch for ip-tunnels code for now.

Thanks.
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index 394cebc..ac3a9a1 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -564,7 +564,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
>
>         if (df)
>                 mtu = dst_mtu(&rt->dst) - dev->hard_header_len
> -                                       - sizeof(struct iphdr);
> +                       - tunnel->hlen - sizeof(struct iphdr);
>         else
>                 mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) : dev->mtu;
>
