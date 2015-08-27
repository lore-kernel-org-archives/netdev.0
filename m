From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v5 net-next 5/8] geneve: Add support to collect tunnel
 metadata.
Date: Thu, 27 Aug 2015 11:18:54 +0200
Message-ID: <20150827091854.GD18481@pox.localdomain>
References: <1440658015-13028-1-git-send-email-pshelar@nicira.com>
 <1440658015-13028-6-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:36133 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457AbbH0JS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 05:18:56 -0400
Received: by wicgk12 with SMTP id gk12so2102853wic.1
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 02:18:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1440658015-13028-6-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/15 at 11:46pm, Pravin B Shelar wrote:
> +	if (ip_tunnel_collect_metadata() || geneve->collect_md) {
> +		__be16 flags;
> +		void *opts;
> +
> +		flags = TUNNEL_KEY | TUNNEL_GENEVE_OPT |
> +			(gnvh->oam ? TUNNEL_OAM : 0) |
> +			(gnvh->critical ? TUNNEL_CRIT_OPT : 0);
> +
> +		tun_dst = udp_tun_rx_dst(skb, AF_INET, flags,
> +					 vni_to_tunnel_id(gnvh->vni),
> +					 gnvh->opt_len * 4);
> +		if (!tun_dst)
> +			goto drop;
> +
> +		/* Update tunnel dst according to Geneve options. */
> +		opts = ip_tunnel_info_opts(&tun_dst->u.tun_info,
> +					   gnvh->opt_len * 4);
> +		memcpy(opts, gnvh->options, gnvh->opt_len * 4);
> +	} else {
> +		/* Drop packets w/ critical options,
> +		 * since we don't support any...
> +		 */
> +		if (gnvh->critical)
> +			goto drop;
> +	}
>  
>  	skb_reset_mac_header(skb);
>  	skb_scrub_packet(skb, !net_eq(geneve->net, dev_net(geneve->dev)));
>  	skb->protocol = eth_type_trans(skb, geneve->dev);
>  	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
>  
> +	if (tun_dst)
> +		skb_dst_set(skb, &tun_dst->dst);

It is slightly non obvious that introducing an error condition above
this and before udp_tun_rx_dst() would introduce a memory leak. Other
than this looks great now.

Acked-by: Thomas Graf <tgraf@suug.ch>
