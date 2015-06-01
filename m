From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ipv4/udp: Verify multicast group is ours in upd_v4_early_demux()
Date: Mon, 01 Jun 2015 23:11:42 +0300
Message-ID: <556CBC7E.2050005@cogentembedded.com>
References: <1432663193.4060.280.camel@edumazet-glaptop2.roam.corp.google.com> <1433176465-22941-1-git-send-email-shawn.bohrer@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>,
	Alexandra.Kossovsky@oktetlabs.ru,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Oliver Graff <oliver.e.graff@gmail.com>, davem@davemloft.net,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Shawn Bohrer <shawn.bohrer@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:36845 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889AbbFAULr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 16:11:47 -0400
Received: by laei3 with SMTP id i3so22271520lae.3
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2015 13:11:45 -0700 (PDT)
In-Reply-To: <1433176465-22941-1-git-send-email-shawn.bohrer@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/01/2015 07:34 PM, Shawn Bohrer wrote:

> From: Shawn Bohrer <sbohrer@rgmadvisors.com>

> 421b3885bf6d56391297844f43fb7154a6396e12 "udp: ipv4: Add udp early
> demux" introduced a regression that allowed sockets bound to INADDR_ANY
> to receive packets from multicast groups that the socket had not joined.
> For example a socket that had joined 224.168.2.9 could also receive
> packets from 225.168.2.9 despite not having joined that group if
> ip_early_demux is enabled.

> Fix this by calling ip_check_mc_rcu() in udp_v4_early_demux() to verify
> that the multicast packet is indeed ours.

> Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
> Reported-by: Yurij M. Plotnikov <Yurij.Plotnikov@oktetlabs.ru>
> ---
>   net/ipv4/udp.c | 18 +++++++++++++-----
>   1 file changed, 13 insertions(+), 5 deletions(-)

> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index d10b7e0..17d31f5 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
[...]
> @@ -1971,10 +1972,17 @@ void udp_v4_early_demux(struct sk_buff *skb)
>   	uh = udp_hdr(skb);
>
>   	if (skb->pkt_type == PACKET_BROADCAST ||
> -	    skb->pkt_type == PACKET_MULTICAST)
> -		sk = __udp4_lib_mcast_demux_lookup(net, uh->dest, iph->daddr,
> -						   uh->source, iph->saddr, dif);
> -	else if (skb->pkt_type == PACKET_HOST)
> +	    skb->pkt_type == PACKET_MULTICAST) {
> +		struct in_device *in_dev = __in_dev_get_rcu(skb->dev);
> +
> +		if (in_dev) {
> +			int our = ip_check_mc_rcu(in_dev, iph->daddr, iph->saddr,
> +						  iph->protocol);
> +			if (our)
> +				sk = __udp4_lib_mcast_demux_lookup(net, uh->dest, iph->daddr,
> +								   uh->source, iph->saddr, dif);
> +		}
> +	} else if (skb->pkt_type == PACKET_HOST)
>   		sk = __udp4_lib_demux_lookup(net, uh->dest, iph->daddr,
>   					     uh->source, iph->saddr, dif);
>   	else

    Must add {} around all branches of the *if* statement if you're adding 
them around just one; see Documentation/CodingStyle.

WBR, Sergei
