From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] ipv6: fix the use of pcpu_tstats in ip6_tunnel
Date: Thu, 2 Jan 2014 14:53:24 +0000
Message-ID: <1388674404.1607.4.camel@bwh-desktop.uk.level5networks.com>
References: <1388623780-1484-1-git-send-email-roy.qing.li@gmail.com>
	 <20140101.225033.1351962333260167430.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <roy.qing.li@gmail.com>, <netdev@vger.kernel.org>,
	<edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17864 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbaABOx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 09:53:28 -0500
In-Reply-To: <20140101.225033.1351962333260167430.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-01 at 22:50 -0500, David Miller wrote:
> From: roy.qing.li@gmail.com
> Date: Thu,  2 Jan 2014 08:49:40 +0800
> 
> > Eric Dumazet <edumazet@google.com>
> 
> What is this?
> 
> > Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>  ...
> >  {
> > -	struct pcpu_tstats sum = { 0 };
> > +	struct pcpu_tstats tmp, sum = { 0 };
> >  	int i;
> >  
> > -	for_each_possible_cpu(i) {
> > -		const struct pcpu_tstats *tstats = per_cpu_ptr(dev->tstats, i);
> > +	BUILD_BUG_ON(offsetof(typeof(tmp), syncp) !=
> > +		     sizeof(tmp) - sizeof(tmp.syncp));
> >  
> > -		sum.rx_packets += tstats->rx_packets;
> > -		sum.rx_bytes   += tstats->rx_bytes;
> > -		sum.tx_packets += tstats->tx_packets;
> > -		sum.tx_bytes   += tstats->tx_bytes;
> > +	for_each_possible_cpu(i) {
> > +		unsigned int start;
> > +		const struct pcpu_tstats *stat = per_cpu_ptr(dev->tstats, i);
> > +
> > +		do {
> > +			start = u64_stats_fetch_begin_bh(&stat->syncp);
> > +			memcpy(&tmp, stat, sizeof(tmp) - sizeof(stat->syncp));
> > +		} while (u64_stats_fetch_retry_bh(&stat->syncp, start));
> 
> It's entirely wasteful and non-canonical to use an on-stack copy for this,
> just surround the entire set of statistic increments within the u64 stats
> updata sequence.  Then you don't need the on-stack thing.

Then you add them to the sum repeatedly in case of a retry...

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
