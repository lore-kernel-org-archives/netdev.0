From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH net-next-2.6] net: Introduce u64_stats_sync
 infrastructure
Date: Tue, 15 Jun 2010 20:25:41 +1000
Message-ID: <20100615102541.GH6138@laptop>
References: <1276531162.2478.121.camel@edumazet-laptop>
 <20100614.231412.39191304.davem@davemloft.net>
 <1276596856.2541.84.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33675 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752149Ab0FOKZq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 06:25:46 -0400
Content-Disposition: inline
In-Reply-To: <1276596856.2541.84.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 15, 2010 at 12:14:16PM +0200, Eric Dumazet wrote:
> Here is the followup patch to abstract things a bit, before upcoming
> conversions.
> 
> Thanks !
> 
> [PATCH net-next-2.6] net: Introduce u64_stats_sync infrastructure
> 
> To properly implement 64bits network statistics on 32bit or 64bit hosts,
> we provide one new type and four methods, to ease conversions.
> 
> Stats producer should use following template granted it already got an
> exclusive access to counters (a previous lock is taken, or per cpu
> data [used in a non preemptable context])
> 
> Let me repeat : stats producers must be serialized by other means before
> using this template. Preemption must be disabled too.
> 
> u64_stats_update_begin(&stats->syncp);
> stats->bytes += len;
> stats->packets++;
> u64_stats_update_end(&stats->syncp);
> 
> While a consumer should use following template to get consistent
> snapshot :
> 
> u64 tbytes, tpackets;
> unsigned int start;
> 
> do {
> 	start = u64_stats_fetch_begin(&stats->syncp);
> 	tbytes = stats->bytes;
> 	tpackets = stats->packets;
> } while (u64_stats_fetch_retry(&stats->lock, syncp));
> 
> This patch uses this infrastructure in net loopback driver, instead of
> specific one added in commit 6b10de38f0ef (loopback: Implement 64bit
> stats on 32bit arches)
> 
> Suggested by David Miller

Cool, I don't mind this, but perhaps could you add some comments
because it _will_ either be misused or copied and misused elsewhere :)

Callers must:
- write side must ensure mutual exclusion (even if it was previously OK
  to have lost updates on the writer side, the seqlock will explodde if
  it is taken concurrently for write)
- write side must not sleep
- readside and writeside must have local-CPU exclusion from one another;
  preempt, irq, bh as appropriate
- will only protect 64-bit sizes from tearing -- eg updating 2 different
  stats under the same write side will not ensure they are both seen in
  the same read side

But I do like the minimal design.

> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Nick Piggin <npiggin@suse.de>
> ---
>  drivers/net/loopback.c    |   61 ++++++++----------------------------
>  include/linux/netdevice.h |   50 +++++++++++++++++++++++++++++
>  2 files changed, 65 insertions(+), 46 deletions(-)
> 
> diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
> index 09334f8..f20b156 100644
> --- a/drivers/net/loopback.c
> +++ b/drivers/net/loopback.c
> @@ -60,51 +60,12 @@
>  #include <net/net_namespace.h>
>  
>  struct pcpu_lstats {
> -	u64 packets;
> -	u64 bytes;
> -#if BITS_PER_LONG==32 && defined(CONFIG_SMP)
> -	seqcount_t seq;
> -#endif
> -	unsigned long drops;
> +	u64			packets;
> +	u64			bytes;
> +	struct u64_stats_sync	syncp;
> +	unsigned long		drops;
>  };
>  
> -#if BITS_PER_LONG==32 && defined(CONFIG_SMP)
> -static void inline lstats_update_begin(struct pcpu_lstats *lstats)
> -{
> -	write_seqcount_begin(&lstats->seq);
> -}
> -static void inline lstats_update_end(struct pcpu_lstats *lstats)
> -{
> -	write_seqcount_end(&lstats->seq);
> -}
> -static void inline lstats_fetch_and_add(u64 *packets, u64 *bytes, const struct pcpu_lstats *lstats)
> -{
> -	u64 tpackets, tbytes;
> -	unsigned int seq;
> -
> -	do {
> -		seq = read_seqcount_begin(&lstats->seq);
> -		tpackets = lstats->packets;
> -		tbytes = lstats->bytes;
> -	} while (read_seqcount_retry(&lstats->seq, seq));
> -
> -	*packets += tpackets;
> -	*bytes += tbytes;
> -}
> -#else
> -static void inline lstats_update_begin(struct pcpu_lstats *lstats)
> -{
> -}
> -static void inline lstats_update_end(struct pcpu_lstats *lstats)
> -{
> -}
> -static void inline lstats_fetch_and_add(u64 *packets, u64 *bytes, const struct pcpu_lstats *lstats)
> -{
> -	*packets += lstats->packets;
> -	*bytes += lstats->bytes;
> -}
> -#endif
> -
>  /*
>   * The higher levels take care of making this non-reentrant (it's
>   * called with bh's disabled).
> @@ -126,10 +87,10 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
>  
>  	len = skb->len;
>  	if (likely(netif_rx(skb) == NET_RX_SUCCESS)) {
> -		lstats_update_begin(lb_stats);
> +		u64_stats_update_begin(&lb_stats->syncp);
>  		lb_stats->bytes += len;
>  		lb_stats->packets++;
> -		lstats_update_end(lb_stats);
> +		u64_stats_update_end(&lb_stats->syncp);
>  	} else
>  		lb_stats->drops++;
>  
> @@ -148,10 +109,18 @@ static struct rtnl_link_stats64 *loopback_get_stats64(struct net_device *dev)
>  	pcpu_lstats = (void __percpu __force *)dev->ml_priv;
>  	for_each_possible_cpu(i) {
>  		const struct pcpu_lstats *lb_stats;
> +		u64 tbytes, tpackets;
> +		unsigned int start;
>  
>  		lb_stats = per_cpu_ptr(pcpu_lstats, i);
> -		lstats_fetch_and_add(&packets, &bytes, lb_stats);
> +		do {
> +			start = u64_stats_fetch_begin(&lb_stats->syncp);
> +			tbytes = lb_stats->bytes;
> +			tpackets = lb_stats->packets;
> +		} while (u64_stats_fetch_retry(&lb_stats->syncp, start));
>  		drops   += lb_stats->drops;
> +		bytes   += tbytes;
> +		packets += tpackets;
>  	}
>  	stats->rx_packets = packets;
>  	stats->tx_packets = packets;
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 4fbccc5..dd1d93d 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -174,6 +174,56 @@ static inline bool dev_xmit_complete(int rc)
>  #define NET_DEVICE_STATS_DEFINE(name)	unsigned long pad_ ## name, name
>  #endif
>  
> +#if BITS_PER_LONG==32 && defined(CONFIG_SMP)
> +struct u64_stats_sync {
> +	seqcount_t	seq;
> +};
> +
> +static void inline u64_stats_update_begin(struct u64_stats_sync *syncp)
> +{
> +	write_seqcount_begin(&syncp->seq);
> +}
> +
> +static void inline u64_stats_update_end(struct u64_stats_sync *syncp)
> +{
> +	write_seqcount_end(&syncp->seq);
> +}
> +
> +static unsigned int inline u64_stats_fetch_begin(const struct u64_stats_sync *syncp)
> +{
> +	return read_seqcount_begin(&syncp->seq);
> +}
> +
> +static bool inline u64_stats_fetch_retry(const struct u64_stats_sync *syncp,
> +					 unsigned int start)
> +{
> +	return read_seqcount_retry(&syncp->seq, start);
> +}
> +
> +#else
> +struct u64_stats_sync {
> +};
> +
> +static void inline u64_stats_update_begin(struct u64_stats_sync *syncp)
> +{
> +}
> +
> +static void inline u64_stats_update_end(struct u64_stats_sync *syncp)
> +{
> +}
> +
> +static unsigned int inline u64_stats_fetch_begin(const struct u64_stats_sync *syncp)
> +{
> +	return 0;
> +}
> +
> +static bool inline u64_stats_fetch_retry(const struct u64_stats_sync *syncp,
> +					 unsigned int start)
> +{
> +	return false;
> +}
> +#endif
> +
>  struct net_device_stats {
>  	NET_DEVICE_STATS_DEFINE(rx_packets);
>  	NET_DEVICE_STATS_DEFINE(tx_packets);
> 
