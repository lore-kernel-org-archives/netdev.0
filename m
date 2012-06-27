From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH v2] l2tp: use per-cpu variables for u64_stats updates
Date: Wed, 27 Jun 2012 14:31:37 -0700
Message-ID: <4FEB7BB9.1080905@candelatech.com>
References: <1340798457-28270-1-git-send-email-tparkin@katalix.com>  <1340823810.26242.81.camel@edumazet-glaptop> <4FEB6B64.5060708@hp.com>  <1340829541.26242.90.camel@edumazet-glaptop>  <20120627135034.7db7d0eb@nehalam.linuxnetplumber.net>  <4FEB73EF.9090702@candelatech.com> <1340832022.26242.131.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Rick Jones <rick.jones2@hp.com>,
	Tom Parkin <tparkin@katalix.com>, netdev@vger.kernel.org,
	David.Laight@ACULAB.COM, James Chapman <jchapman@katalix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52053 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581Ab2F0Vbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 17:31:47 -0400
In-Reply-To: <1340832022.26242.131.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/27/2012 02:20 PM, Eric Dumazet wrote:
> On Wed, 2012-06-27 at 13:58 -0700, Ben Greear wrote:
>
>> It's worse than that:  Even on 64-bit kernels, counters that are returned by
>> netlink and /proc/net/dev as 64-bit may still wrap themselves at 32-bit
>> intervals.
>
> Really ?
>
> Thats incredible you dont send a bug report then.

I bitched and moaned a while back...didn't get a lot
of positive feedback :)

For an example, see the VLAN code. rx-errors and tx-dropped are only 32-bit
counters.  Now, in the real world, we wouldn't expect those counters to
increase at high rates, but they are still 32-bit counters masquerading
as 64, and they could wrap after a while, so any code that expected a wrap
to mean a 64-bit wrap would be wrong.

At the time I was last complaining, there were lots more cases
of this that I was fighting with, but I don't recall exactly what they
were.  Once my user-space code got paranoid enough, it was able to
at least mostly deal with 32 and 64 wraps.

static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
{

	if (vlan_dev_priv(dev)->vlan_pcpu_stats) {
		struct vlan_pcpu_stats *p;
		u32 rx_errors = 0, tx_dropped = 0, collisions = 0;
		int i;

		for_each_possible_cpu(i) {
			u64 rxpackets, rxbytes, rxmulticast, txpackets, txbytes;
			unsigned int start;

			p = per_cpu_ptr(vlan_dev_priv(dev)->vlan_pcpu_stats, i);
			do {
				start = u64_stats_fetch_begin_bh(&p->syncp);
				rxpackets	= p->rx_packets;
				rxbytes		= p->rx_bytes;
				rxmulticast	= p->rx_multicast;
				txpackets	= p->tx_packets;
				txbytes		= p->tx_bytes;
			} while (u64_stats_fetch_retry_bh(&p->syncp, start));

			stats->rx_packets	+= rxpackets;
			stats->rx_bytes		+= rxbytes;
			stats->multicast	+= rxmulticast;
			stats->tx_packets	+= txpackets;
			stats->tx_bytes		+= txbytes;
			/* rx_errors & tx_dropped are u32 */
			rx_errors	+= p->rx_errors;
			tx_dropped	+= p->tx_dropped;
			collisions	+= p->collisions;
		}
		stats->rx_errors  = rx_errors;
		stats->tx_dropped = tx_dropped;
		stats->collisions = collisions;
	}
	return stats;
}

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
