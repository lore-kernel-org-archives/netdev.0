From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Block device throttling [Re: Distributed storage.]
Date: Tue, 14 Aug 2007 16:46:56 +0400
Message-ID: <20070814124656.GB10446@2ka.mipt.ru>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708140435.44979.phillips@phunq.net> <20070814115037.GA2958@2ka.mipt.ru> <200708140532.31378.phillips@phunq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Daniel Phillips <phillips@phunq.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:39295 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752337AbXHNMs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 08:48:27 -0400
Content-Disposition: inline
In-Reply-To: <200708140532.31378.phillips@phunq.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 14, 2007 at 05:32:29AM -0700, Daniel Phillips (phillips@phunq.net) wrote:
> On Tuesday 14 August 2007 04:50, Evgeniy Polyakov wrote:
> > On Tue, Aug 14, 2007 at 04:35:43AM -0700, Daniel Phillips 
> (phillips@phunq.net) wrote:
> > > On Tuesday 14 August 2007 04:30, Evgeniy Polyakov wrote:
> > > > > And it will not solve the deadlock problem in general.  (Maybe
> > > > > it works for your virtual device, but I wonder...)  If the
> > > > > virtual device allocates memory during generic_make_request
> > > > > then the memory needs to be throttled.
> > > >
> > > > Daniel, if device process bio by itself, it has a limit and thus
> > > > it will wait in generic_make_request()
> > >
> > > What will make it wait?
> >
> > gneric_make_request() for given block device.
> 
> Not good enough, that only makes one thread wait.  Look here:
> 
>     http://lkml.org/lkml/2007/8/13/788
> 
> An unlimited number of threads can come in, each consuming resources of 
> the virtual device, and violating the throttling rules.
> 
> The throttling of the virtual device must begin in generic_make_request 
> and last to ->endio.  You release the throttle of the virtual device at 
> the point you remap the bio to an underlying device, which you have 
> convinced yourself is ok, but it is not.  You seem to miss the fact 
> that whatever resources the virtual device has allocated are no longer 
> protected by the throttle count *of the virtual device*, or you do not 

Because it is charged to another device. No matter how many of them are
chained, limit is applied to the last device being used.
So, if you have unlimited number of threads, each one allocates a
request, forward it down to low-level devices, each one will eventually
sleep, but yes, each one _can_ allocate _one_ request before it goes
sleeping. It is done to allow fain-grained limits, since some devices
(like locally attached disks) do not require throttling.

Here is an example with threads you mentioned:
http://article.gmane.org/gmane.linux.file-systems/17644

-- 
	Evgeniy Polyakov
