From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH V6 net-next 2/5] xen-netback: Add support for multiple
 queues
Date: Tue, 18 Mar 2014 10:56:40 +0000
Message-ID: <1395140200.12847.33.camel@kazak.uk.xensource.com>
References: <1393847269-6981-1-git-send-email-andrew.bennieston@citrix.com>
		 <1393847269-6981-3-git-send-email-andrew.bennieston@citrix.com>
	 <1394813004.6442.133.camel@kazak.uk.xensource.com>
	 <5328246C.6060502@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <wei.liu2@citrix.com>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<david.vrabel@citrix.com>
To: Andrew Bennieston <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:7244 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755120AbaCRK46 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 06:56:58 -0400
In-Reply-To: <5328246C.6060502@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-18 at 10:48 +0000, Andrew Bennieston wrote:
[snip... queeues...]

All sounds fine, thanks for the explanations.

> >>   	xen_net_read_rate(dev, &credit_bytes, &credit_usec);
> >>   	read_xenbus_vif_flags(be);
> >>
> >> -	be->vif->num_queues = 1;
> >> +	/* Use the number of queues requested by the frontend */
> >> +	be->vif->num_queues = requested_num_queues;
> >>   	be->vif->queues = vzalloc(be->vif->num_queues *
> >>   			sizeof(struct xenvif_queue));
> >> +	rtnl_lock();
> >> +	netif_set_real_num_tx_queues(be->vif->dev, be->vif->num_queues);
> >> +	rtnl_unlock();
> >
> > I'm always a bit suspicious of this construct -- it makes me thing the
> > call is happening from the wrong context and that the right context
> > would naturally hold the lock already.
> 
> netif_set_real_num_tx_queues() must be called either with this lock
> held, or before the netdev is registered. The netdev is registered early
> so that it can be plugged into a bridge or whatever other network
> configuration has to happen. The point at which we know the correct
> number of tx queues happens in response to the frontend changing
> Xenstore entries, so the rtnl lock is not naturally held here.
> xenvif_carrier_on() and xenvif_carrier_off() also take this lock, but
> they are not the appropriate place to set the number of queues.

Great, just wanted to be sure it had been thought about and not just
"slap a lock around it to make it stop complaining" :-)

> >>   	for (queue_index = 0; queue_index < be->vif->num_queues; ++queue_index) {
> >>   		queue = &be->vif->queues[queue_index];
> >> @@ -547,29 +575,52 @@ static int connect_rings(struct backend_info *be, struct xenvif_queue *queue)
> >>   	unsigned long tx_ring_ref, rx_ring_ref;
> >>   	unsigned int tx_evtchn, rx_evtchn;
> >>   	int err;
> >> +	char *xspath;
> >> +	size_t xspathsize;
> >> +	const size_t xenstore_path_ext_size = 11; /* sufficient for "/queue-NNN" */
> >> +
> >> +	/* If the frontend requested 1 queue, or we have fallen back
> >> +	 * to single queue due to lack of frontend support for multi-
> >> +	 * queue, expect the remaining XenStore keys in the toplevel
> >> +	 * directory. Otherwise, expect them in a subdirectory called
> >> +	 * queue-N.
> >> +	 */
> >> +	if (queue->vif->num_queues == 1) {
> >> +		xspath = (char *)dev->otherend;
> >
> > Casting away a const is naughty. Either make xspath const or if that
> > isn't possible make it dynamic in all cases with a strcpy in this
> > degenerate case.
> >
> 
> Ok, I can change this. I was trying to avoid the strcpy.

Thanks.

Ian.
