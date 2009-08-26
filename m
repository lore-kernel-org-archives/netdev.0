From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Wed, 26 Aug 2009 15:11:06 -0700
Message-ID: <1251324666.10599.72.camel@w-sridhar.beaverton.ibm.com>
References: <OFB18AD855.24C5AC71-ON8825761D.00687D5E-8825761D.0068BB9C@us.ibm.com>
	 <alpine.DEB.1.10.0908251514190.17963@gentwo.org>
	 <1251239734.3169.65.camel@w-sridhar.beaverton.ibm.com>
	 <alpine.DEB.1.10.0908261223210.9933@gentwo.org>
	 <1251309040.10599.34.camel@w-sridhar.beaverton.ibm.com>
	 <alpine.DEB.1.10.0908261506590.9933@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	niv@linux.vnet.ibm.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:49336 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753931AbZHZWLH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 18:11:07 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7QM2s6s027054
	for <netdev@vger.kernel.org>; Wed, 26 Aug 2009 18:02:54 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7QMB8ib254260
	for <netdev@vger.kernel.org>; Wed, 26 Aug 2009 18:11:08 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7QMB7Qp008150
	for <netdev@vger.kernel.org>; Wed, 26 Aug 2009 18:11:08 -0400
In-Reply-To: <alpine.DEB.1.10.0908261506590.9933@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-08-26 at 15:09 -0400, Christoph Lameter wrote:
> On Wed, 26 Aug 2009, Sridhar Samudrala wrote:
> 
> > >  They are reported for IP and UDP.
> > Not clear what you meant by this.
> 
> The SNMP and UDP statistics show the loss. qdisc level does not show the
> loss.
> > > root@rd-strategy3-deb64:/home/clameter#tc -s qdisc show
> > > qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1
> > > 1 1 1 1
> > >  Sent 6208 bytes 64 pkt (dropped 0, overlimits 0 requeues 0)
> > >  rate 0bit 0pps backlog 0b 0p requeues 0
> >
> > Even the Sent count seems to be too low. Are you looking at the right
> > device?
> 
> I would think that tc displays all queues? It says eth0 and eth0 is the
> device that we sent the data out on.


> 
> > So based on the current analysis, the packets are getting dropped after
> > the call to ip_local_out() in ip_push_pending_frames(). ip_local_out()
> > is failing with NET_XMIT_DROP. But we are not sure where they are
> > getting dropped. Is that right?
> 
> ip_local_out is returning ENOBUFS. Something at the qdisc layer is
> dropping the packet and not incrementing counters.

Is the ENOBUFS return with your/Eric's patch? I thought you were
were seeing NET_XMIT_DROP without any patches.

> 
> > I think we need to figure out where they are getting dropped and then
> > decide on the appropriate counter to be incremented.
> 
> Right. Where in the qdisc layer do drops occur?

The normal path where the packets are dropped when the tx qlen is exceeded is
  pfifo_fast_enqueue() -> qdisc_drop()
In this path, drops are counted.
The other place is in dev_queue_xmit(), but you are not hitting that case too.

So it looks like there is another place where they are getting dropped.

Thanks
Sridhar





