From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] [ver3 PATCH 3/6] virtio_net: virtio_net driver changes
Date: Fri, 18 Nov 2011 17:14:22 +0000
Message-ID: <1321636462.2883.3.camel@bwh-desktop>
References: <20111111130223.9878.59517.sendpatchset@krkumar2.in.ibm.com>
	 <20111111130420.9878.19729.sendpatchset@krkumar2.in.ibm.com>
	 <1321578488.2749.66.camel@bwh-desktop> <1321597481.8010.19.camel@lappy>
	 <1321630839.2885.117.camel@deadeye>  <1321633081.2974.1.camel@sasha>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2@in.ibm.com>, <rusty@rustcorp.com.au>,
	<mst@redhat.com>, <netdev@vger.kernel.org>, <kvm@vger.kernel.org>,
	<davem@davemloft.net>, <virtualization@lists.linux-foundation.org>
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1321633081.2974.1.camel@sasha>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-11-18 at 18:18 +0200, Sasha Levin wrote:
> On Fri, 2011-11-18 at 15:40 +0000, Ben Hutchings wrote:
> > On Fri, 2011-11-18 at 08:24 +0200, Sasha Levin wrote:
> > > On Fri, 2011-11-18 at 01:08 +0000, Ben Hutchings wrote:
> > > > On Fri, 2011-11-11 at 18:34 +0530, Krishna Kumar wrote:
> > > > > Changes for multiqueue virtio_net driver.
> > > > [...]
> > > > > @@ -677,25 +730,35 @@ static struct rtnl_link_stats64 *virtnet
> > > > >  {
> > > > >  	struct virtnet_info *vi = netdev_priv(dev);
> > > > >  	int cpu;
> > > > > -	unsigned int start;
> > > > >  
> > > > >  	for_each_possible_cpu(cpu) {
> > > > > -		struct virtnet_stats __percpu *stats
> > > > > -			= per_cpu_ptr(vi->stats, cpu);
> > > > > -		u64 tpackets, tbytes, rpackets, rbytes;
> > > > > -
> > > > > -		do {
> > > > > -			start = u64_stats_fetch_begin(&stats->syncp);
> > > > > -			tpackets = stats->tx_packets;
> > > > > -			tbytes   = stats->tx_bytes;
> > > > > -			rpackets = stats->rx_packets;
> > > > > -			rbytes   = stats->rx_bytes;
> > > > > -		} while (u64_stats_fetch_retry(&stats->syncp, start));
> > > > > -
> > > > > -		tot->rx_packets += rpackets;
> > > > > -		tot->tx_packets += tpackets;
> > > > > -		tot->rx_bytes   += rbytes;
> > > > > -		tot->tx_bytes   += tbytes;
> > > > > +		int qpair;
> > > > > +
> > > > > +		for (qpair = 0; qpair < vi->num_queue_pairs; qpair++) {
> > > > > +			struct virtnet_send_stats __percpu *tx_stat;
> > > > > +			struct virtnet_recv_stats __percpu *rx_stat;
> > > > 
> > > > While you're at it, you can drop the per-CPU stats and make them only
> > > > per-queue.  There is unlikely to be any benefit in maintaining them
> > > > per-CPU while receive and transmit processing is serialised per-queue.
> > > 
> > > It allows you to update stats without a lock.
> > 
> > But you'll already be holding a lock related to the queue.
> 
> Right, but now you're holding a queue lock just when playing with the
> queue, we don't hold it when we process the data - which is when we
> usually need to update stats.
[...]

The *stack* is holding the appropriate lock when calling the NAPI poll
function or ndo_start_xmit function.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

