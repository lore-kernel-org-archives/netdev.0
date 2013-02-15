From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] v4 GRE: Add TCP segmentation offload for
 GRE
Date: Fri, 15 Feb 2013 06:41:00 -0800
Message-ID: <1360939260.19353.2.camel@edumazet-glaptop>
References: <1360886561-1630-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jesse@nicira.com,
	bhutchings@solarflare.com, mirqus@gmail.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:47462 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932237Ab3BOOlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 09:41:04 -0500
Received: by mail-pa0-f48.google.com with SMTP id hz10so1790910pad.7
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 06:41:03 -0800 (PST)
In-Reply-To: <1360886561-1630-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-14 at 16:02 -0800, Pravin B Shelar wrote:

> +	err = ip_local_out(skb);
> +	if (likely(net_xmit_eval(err) == 0)) {
> +		int pkt_len = skb->len - skb_transport_offset(skb);
> +		u64_stats_update_begin(&tstats->syncp);
> +		tstats->tx_bytes += pkt_len;
> +		tstats->tx_packets++;
> +		u64_stats_update_end(&tstats->syncp);
> +	} else {
> +		dev->stats.tx_errors++;
> +		dev->stats.tx_aborted_errors++;
> +	}
>  	return NETDEV_TX_OK;

Once given to ip_local_out(), you cant reference the skb anymore,
therefore you must evaluate pkt_len before :

pkt_len = skb->len - skb_transport_offset(skb);
err = ip_local_out(skb);
if (likely(net_xmit_eval(err) == 0)) {
    ...
