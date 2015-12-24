From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2] ip_tunnel: Move stats update to
 iptunnel_xmit()
Date: Thu, 24 Dec 2015 10:14:02 +0100
Message-ID: <567BB75A.5040408@6wind.com>
References: <1450914723-16452-1-git-send-email-pshelar@nicira.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Pravin B Shelar <pshelar@nicira.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35277 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753914AbbLXJOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 04:14:05 -0500
Received: by mail-wm0-f50.google.com with SMTP id l126so175618231wml.0
        for <netdev@vger.kernel.org>; Thu, 24 Dec 2015 01:14:04 -0800 (PST)
In-Reply-To: <1450914723-16452-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/12/2015 00:52, Pravin B Shelar a =C3=A9crit :
[snip]
> @@ -83,22 +84,12 @@ int ip6_tnl_get_iflink(const struct net_device *d=
ev);
>   static inline void ip6tunnel_xmit(struct sock *sk, struct sk_buff *=
skb,
>   				  struct net_device *dev)
>   {
> -	struct net_device_stats *stats =3D &dev->stats;
>   	int pkt_len, err;
>
>   	pkt_len =3D skb->len - skb_inner_network_offset(skb);
>   	err =3D ip6_local_out(dev_net(skb_dst(skb)->dev), sk, skb);
> -
> -	if (net_xmit_eval(err) =3D=3D 0) {
> -		struct pcpu_sw_netstats *tstats =3D get_cpu_ptr(dev->tstats);
> -		u64_stats_update_begin(&tstats->syncp);
> -		tstats->tx_bytes +=3D pkt_len;
> -		tstats->tx_packets++;
> -		u64_stats_update_end(&tstats->syncp);
> -		put_cpu_ptr(tstats);
> -	} else {
> -		stats->tx_errors++;
> -		stats->tx_aborted_errors++;
> -	}
> +	if (likely(!net_xmit_eval(err)))
> +		err =3D pkt_len;
> +	iptunnel_xmit_stats(dev, err);
I don't think this is an equivalent change.
=46or example, if err =3D=3D NET_XMIT_DROP, then '!net_xmit_eval(err)' =
is false and
iptunnel_xmit_stats() is called with err set to a positive value (NET_X=
MIT_DROP
value is 0x01), ie not an error.
