From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Block device throttling [Re: Distributed storage.]
Date: Tue, 14 Aug 2007 05:32:29 -0700
Message-ID: <200708140532.31378.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708140435.44979.phillips@phunq.net> <20070814115037.GA2958@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070814115037.GA2958@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 14 August 2007 04:50, Evgeniy Polyakov wrote:
> On Tue, Aug 14, 2007 at 04:35:43AM -0700, Daniel Phillips 
(phillips@phunq.net) wrote:
> > On Tuesday 14 August 2007 04:30, Evgeniy Polyakov wrote:
> > > > And it will not solve the deadlock problem in general.  (Maybe
> > > > it works for your virtual device, but I wonder...)  If the
> > > > virtual device allocates memory during generic_make_request
> > > > then the memory needs to be throttled.
> > >
> > > Daniel, if device process bio by itself, it has a limit and thus
> > > it will wait in generic_make_request()
> >
> > What will make it wait?
>
> gneric_make_request() for given block device.

Not good enough, that only makes one thread wait.  Look here:

    http://lkml.org/lkml/2007/8/13/788

An unlimited number of threads can come in, each consuming resources of 
the virtual device, and violating the throttling rules.

The throttling of the virtual device must begin in generic_make_request 
and last to ->endio.  You release the throttle of the virtual device at 
the point you remap the bio to an underlying device, which you have 
convinced yourself is ok, but it is not.  You seem to miss the fact 
that whatever resources the virtual device has allocated are no longer 
protected by the throttle count *of the virtual device*, or you do not 
see why that is a bad thing.  It is a very bad thing, roughly like 
leaving some shared data outside a spin_lock/unlock.

Regards,

Daniel
