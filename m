From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio-net: fix a race on 32bit arches
Date: Wed, 6 Jun 2012 17:49:42 +0300
Message-ID: <20120606144941.GA17092@redhat.com>
References: <1338971724.2760.3913.camel@edumazet-glaptop>
	<1338972341.2760.3944.camel@edumazet-glaptop>
	<20120606111357.GA15070@redhat.com>
	<1338988210.2760.4485.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1338988210.2760.4485.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 06, 2012 at 03:10:10PM +0200, Eric Dumazet wrote:
> On Wed, 2012-06-06 at 14:13 +0300, Michael S. Tsirkin wrote:
> 
> > We currently do all stats either on napi callback or from
> > start_xmit callback.
> > This makes them safe, yes?
> 
> Hmm, then _bh() variant is needed in virtnet_stats(), as explained in
> include/linux/u64_stats_sync.h section 6)
> 
>  * 6) If counter might be written by an interrupt, readers should block interrupts.
>  *    (On UP, there is no seqcount_t protection, a reader allowing interrupts could
>  *     read partial values)
> 
> Yes, its tricky...

Sounds good, but I have a question: this realies on counters
being atomic on 64 bit.
Would not it be better to always use a seqlock even on 64 bit?
This way counters would actually be correct and in sync.
As it is if we want e.g. average packet size,
we can not rely e.g. on it being bytes/packets.

> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 5214b1e..705aaa7 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -703,12 +703,12 @@ static struct rtnl_link_stats64 *virtnet_stats(struct net_device *dev,
>  		u64 tpackets, tbytes, rpackets, rbytes;
>  
>  		do {
> -			start = u64_stats_fetch_begin(&stats->syncp);
> +			start = u64_stats_fetch_begin_bh(&stats->syncp);
>  			tpackets = stats->tx_packets;
>  			tbytes   = stats->tx_bytes;
>  			rpackets = stats->rx_packets;
>  			rbytes   = stats->rx_bytes;
> -		} while (u64_stats_fetch_retry(&stats->syncp, start));
> +		} while (u64_stats_fetch_retry_bh(&stats->syncp, start));
>  
>  		tot->rx_packets += rpackets;
>  		tot->tx_packets += tpackets;
> 
