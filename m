From: Bill Fink <billfink@mindspring.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Wed, 2 Sep 2009 11:38:39 -0400
Message-ID: <20090902113839.277d8b3b.billfink@mindspring.com>
References: <20090820035044.9b70fca6.billfink@mindspring.com>
	<20090820201919.GA20750@localhost.localdomain>
	<20090821001421.214a560b.billfink@mindspring.com>
	<20090821152341.GA2998@localhost.localdomain>
	<20090826031057.375303c9.billfink@mindspring.com>
	<20090826110013.GA10816@hmsreliant.think-freely.org>
	<20090826180811.GB10816@hmsreliant.think-freely.org>
	<20090827134429.ca1ba6bd.billfink@mindspring.com>
	<20090827175151.GC4762@hmsreliant.think-freely.org>
	<20090902011143.89359828.billfink@mindspring.com>
	<20090902104915.GA402@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>, brice@myri.com,
	gallatin@myri.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:46357 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752797AbZIBPik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 11:38:40 -0400
In-Reply-To: <20090902104915.GA402@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Sep 2009, Neil Horman wrote:

> On Wed, Sep 02, 2009 at 01:11:43AM -0400, Bill Fink wrote:
> > On Thu, 27 Aug 2009, Neil Horman wrote:
> > 
> > > On Thu, Aug 27, 2009 at 01:44:29PM -0400, Bill Fink wrote:
> > > > On Wed, 26 Aug 2009, Neil Horman wrote:
> > > > 
> > > > > Here  you go, I think this will fix your oops.
> > > > > 
> > > > > 
> > > > >     Fix NULL pointer deref in skb sources ftracer
> > > > >     
> > > > >     Its possible that skb->sk will be null in this path, so we shouldn't just assume
> > > > >     we can pass it to sock_net
> > > > >     
> > > > >     Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > > > > 
> > > > >  trace_skb_sources.c |    6 ++++--
> > > > >  1 file changed, 4 insertions(+), 2 deletions(-)
> > > > > 
> > > > > diff --git a/kernel/trace/trace_skb_sources.c b/kernel/trace/trace_skb_sources.c
> > > > > index 40eb071..8bf518f 100644
> > > > > --- a/kernel/trace/trace_skb_sources.c
> > > > > +++ b/kernel/trace/trace_skb_sources.c
> > > > > @@ -29,7 +29,7 @@ static void probe_skb_dequeue(const struct sk_buff *skb, int len)
> > > > >  	struct ring_buffer_event *event;
> > > > >  	struct trace_skb_event *entry;
> > > > >  	struct trace_array *tr = skb_trace;
> > > > > -	struct net_device *dev;
> > > > > +	struct net_device *dev = NULL;
> > > > >  
> > > > >  	if (!trace_skb_source_enabled)
> > > > >  		return;
> > > > > @@ -50,7 +50,9 @@ static void probe_skb_dequeue(const struct sk_buff *skb, int len)
> > > > >  	entry->event_data.rx_queue = skb->queue_mapping;
> > > > >  	entry->event_data.ccpu = smp_processor_id();
> > > > >  
> > > > > -	dev = dev_get_by_index(sock_net(skb->sk), skb->iif);
> > > > > +	if (skb->sk)
> > > > > +		dev = dev_get_by_index(sock_net(skb->sk), skb->iif);
> > > > > +
> > > > >  	if (dev) {
> > > > >  		memcpy(entry->event_data.ifname, dev->name, IFNAMSIZ);
> > > > >  		dev_put(dev);
> > > > 
> > > > 
> > > > 
> > > > On the positive side, it did fix the oops.  But the results of the
> > > > skb_sources tracing was not that useful.
> > > > 
> > > > [root@xeontest1 tracing]# numactl --membind=1 nuttcp -In2 -xc4/0 192.168.1.10 & ps ax | grep nuttcp
> > > >  5521 ttyS0    S      0:00 nuttcp -In2 -xc4/0 192.168.1.10
> > > > n2: 11819.0786 MB /  10.01 sec = 9905.6427 Mbps 26 %TX 37 %RX 0 retrans 0.18 msRTT
> > > > 
> > > > First off, only 10 trace entries were made:
> > > > 
> > > > [root@xeontest1 tracing]# wc trace
> > > > 14 90 334 trace
> > > > 
> > > > And here they are:
> > > > 
> > > > [root@xeontest1 tracing]# cat trace
> > > > # tracer: skb_sources
> > > > #
> > > > #       PID     ANID    CNID    IFC     RXQ     CCPU    LEN
> > > > #        |       |       |       |       |       |       |
> > > >         5521    0       0       Unknown 0       3       888
> > > >         5521    0       0       Unknown 0       3       896
> > > >         5521    0       0       Unknown 0       3       20
> > > >         5521    0       0       Unknown 0       3       888
> > > >         5521    0       0       Unknown 0       3       896
> > > >         5521    0       0       Unknown 0       3       20
> > > >         5521    1       1       Unknown 0       4       20
> > > >         5521    1       1       Unknown 0       4       11
> > > >         5521    1       1       Unknown 0       4       540
> > > >         5521    1       1       Unknown 0       4       0
> > > > 
> > > > Even for these 10 entries, why is the IFC Unknown, and the LENs
> > > > seem to be wrong too.
> > > > 
> > > > 						-Bill
> > > > 
> > > I'm not sure why you're getting Unknown Interface names.  Nominally that
> > > indicates that the skb->iif value in the skb was incorrect or otherwise not set,
> > > which shouldn't be the case.  As for the lengths that just seems wrong.  That
> > > length value is taken directly from skb->len, so if its not right, it seems like
> > > its not getting set correctly someplace.
> > > 
> > > As you may have seen we're removing the ftrace module, and replacing it with the
> > > use of raw trace events.  When I have that working, I'll see if I get simmilar
> > > results.  I never did in my local testing of the ftrace module, but perhaps its
> > > related to load or something.
> > 
> > IIUC I should keep the first of your original three ftrace patches,
> > revert all the rest, and then apply your very latest patch that
> > augments the skb_copy_datagram_iovec TRACE_EVENT.  Do I have that
> > basically correct?
> > 
> Thats exactly correct, yes.
> 
> > Then I just need to ask how do I use this new method?
> > 
> It works in basically the same way.  Except instead of doing this:
> echo skb_ftracer > /sys/kernel/debug/tracing/current_tracer
> you do this:
> echo 1 > /sys/kernel/debug/tracing/events/skb/skb_copy_datagram_iovec/enable
> Then the events should should up in /sys/kernel/debug/tracing/trace[_pipe]

Thanks!  I'll probably give this a try later today and report back.

						-Bill
