From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fix the use of pcpu_tstats in ip6_tunnel
Date: Wed, 01 Jan 2014 22:50:33 -0500 (EST)
Message-ID: <20140101.225033.1351962333260167430.davem@davemloft.net>
References: <1388623780-1484-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46228 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbaABDue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 22:50:34 -0500
In-Reply-To: <1388623780-1484-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu,  2 Jan 2014 08:49:40 +0800

> Eric Dumazet <edumazet@google.com>

What is this?

> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
 ...
>  {
> -	struct pcpu_tstats sum = { 0 };
> +	struct pcpu_tstats tmp, sum = { 0 };
>  	int i;
>  
> -	for_each_possible_cpu(i) {
> -		const struct pcpu_tstats *tstats = per_cpu_ptr(dev->tstats, i);
> +	BUILD_BUG_ON(offsetof(typeof(tmp), syncp) !=
> +		     sizeof(tmp) - sizeof(tmp.syncp));
>  
> -		sum.rx_packets += tstats->rx_packets;
> -		sum.rx_bytes   += tstats->rx_bytes;
> -		sum.tx_packets += tstats->tx_packets;
> -		sum.tx_bytes   += tstats->tx_bytes;
> +	for_each_possible_cpu(i) {
> +		unsigned int start;
> +		const struct pcpu_tstats *stat = per_cpu_ptr(dev->tstats, i);
> +
> +		do {
> +			start = u64_stats_fetch_begin_bh(&stat->syncp);
> +			memcpy(&tmp, stat, sizeof(tmp) - sizeof(stat->syncp));
> +		} while (u64_stats_fetch_retry_bh(&stat->syncp, start));

It's entirely wasteful and non-canonical to use an on-stack copy for this,
just surround the entire set of statistic increments within the u64 stats
updata sequence.  Then you don't need the on-stack thing.
