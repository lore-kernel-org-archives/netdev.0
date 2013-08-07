From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: low latency/busy poll feedback and bugs
Date: Wed, 7 Aug 2013 22:05:01 +0200
Message-ID: <1375905901.27403.22.camel@deadeye.wl.decadent.org.uk>
References: <20130805212257.GB6904@sbohrermbp13-local.rgmadvisors.com>
	 <5200A8BC.4010402@linux.intel.com>
	 <20130806180806.GA8993@sbohrermbp13-local.rgmadvisors.com>
	 <52013F9A.9020005@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>,
	Amir Vadai <amirv@mellanox.com>, <netdev@vger.kernel.org>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:42217 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932301Ab3HGUFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 16:05:09 -0400
In-Reply-To: <52013F9A.9020005@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-06 at 21:25 +0300, Eliezer Tamir wrote:
> On 06/08/2013 21:08, Shawn Bohrer wrote:
> > On Tue, Aug 06, 2013 at 10:41:48AM +0300, Eliezer Tamir wrote:
> >> For multicast, it is possible that incoming packets to come from more
> >> than one port (and therefore more than one queue).
> >> I'm not sure how we could handle that, but what we have today won't do
> >> well for that use-case.
> >  
> > It is unclear to me exactly what happens in this case.  With my simple
> > patch I'm assuming it will spin on the receive queue that received the
> > last packet for that socket.  What happens when a packet arrives on a
> > different receive queue than the one we were spinning on? I assume it
> > is still delivered but perhaps the spinning process won't get it until
> > the spinning time expires?  I'm just guessing and haven't attempted to
> > figure it out from looking through the code.
> 
> What will happen is that the current code will only busy poll on one
> queue, sometimes on this one, sometimes on that one.
> 
> packets arriving on the other queue will still be serviced but will
> suffer the latency of waiting for NAPI to schedule.
> 
> So your avg will be better, but your std. dev. much worse and it's
> probably not worth it if you really expect two devices to receive
> data at the same time.

It seems like sk_mark_napi_id() should only be called on connected
sockets for now.

At least Solarflare controllers have 'wildcard' filters that can match
destination address (host, l4proto, port) only.  Perhaps ARFS could be
extended to include steering based on destination address when there is
a single unconnected socket bound to that address.  When that is
successful, busy- polling a single NAPI context should work nicely.

Where there are multiple unconnected sockets bound to the same unicast
address, it might make sense for polling on those sockets to prefer the
'local' NAPI context according to CPU topology.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
