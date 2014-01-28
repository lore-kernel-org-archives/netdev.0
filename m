From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH v2] net: gre: use icmp_hdr() to get inner ip header
Date: Mon, 27 Jan 2014 21:35:40 -0800
Message-ID: <CALnjE+oK_v0CuUvP4aGHo00KvwYR2RnP0W+stBffKAH+4WYx_w@mail.gmail.com>
References: <52E728D7.70506@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:48859 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750793AbaA1Ffl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 00:35:41 -0500
Received: by mail-ve0-f179.google.com with SMTP id jx11so4146626veb.10
        for <netdev@vger.kernel.org>; Mon, 27 Jan 2014 21:35:40 -0800 (PST)
In-Reply-To: <52E728D7.70506@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 27, 2014 at 7:49 PM, Duan Jiong <duanj.fnst@cn.fujitsu.com> wrote:
>
> When dealing with icmp messages, the skb->data points the
> ip header that triggered the sending of the icmp message.
>
> In gre_cisco_err(), the parse_gre_header() is called, and the
> iptunnel_pull_header() is called to pull the skb at the end of
> the parse_gre_header(), so the skb->data doesn't point the
> inner ip header.
>
> Unfortunately, the ipgre_err still needs those ip addresses in
> inner ip header to look up tunnel by ip_tunnel_lookup().
>
> So just use icmp_hdr() to get inner ip header instead of skb->data.
>
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> ---
>
> v2: use icmp_hdr() instead of conditional pulling of headers
>
>  net/ipv4/ip_gre.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index e7a92fd..ec4f762 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -178,7 +178,7 @@ static int ipgre_err(struct sk_buff *skb, u32 info,
>         else
>                 itn = net_generic(net, ipgre_net_id);
>
> -       iph = (const struct iphdr *)skb->data;
> +       iph = (const struct iphdr *)(icmp_hdr(skb) + 1);
>         t = ip_tunnel_lookup(itn, skb->dev->ifindex, tpi->flags,
>                              iph->daddr, iph->saddr, tpi->key);
>

Don't we need to pull inner ip header first?

> --
> 1.8.3.1
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
