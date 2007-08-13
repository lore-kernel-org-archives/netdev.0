From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Block device throttling [Re: Distributed storage.]
Date: Mon, 13 Aug 2007 16:18:02 +0400
Message-ID: <20070813121802.GB5992@2ka.mipt.ru>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708122236.24096.phillips@phunq.net> <20070813082326.GC30089@2ka.mipt.ru> <200708130418.03667.phillips@phunq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Daniel Phillips <phillips@phunq.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200708130418.03667.phillips@phunq.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 13, 2007 at 04:18:03AM -0700, Daniel Phillips (phillips@phunq.net) wrote:
> > No. Since all requests for virtual device end up in physical devices,
> > which have limits, this mechanism works. Virtual device will
> > essentially call either generic_make_request() for new physical
> > device (and thus will sleep is limit is over), or will process bios
> > directly, but in that case it will sleep in generic_make_request()
> > for virutal device.
> 
> What can happen is, as soon as you unthrottle the previous queue, 
> another thread can come in and put another request on it.  Sure, that 
> thread will likely block on the physical throttle and so will the rest 
> of the incoming threads, but it still allows the higher level queue to 
> grow past any given limit, with the help of lots of threads.  JVM for 
> example?

No. You get one slot, and one thread will not be blocked, all others
will. If lucky thread wants to put two requests it will be blocked on
second request, since underlying physical device does not accept requests
anymore an thus caller will sleep.

> Say you have a device mapper device with some physical device sitting 
> underneath, the classic use case for this throttle code.  Say 8,000 
> threads each submit an IO in parallel.  The device mapper mapping 
> function will be called 8,000 times with associated resource 
> allocations, regardless of any throttling on the physical device queue.

Each thread will sleep in generic_make_request(), if limit is specified
correctly, then allocated number of bios will be enough to have a
progress.

Here is an example:

let's say system has 20.000 pages in RAM and 20.000 in swap,
we have 8.000 threads, each one allocates a page, then next page and so
on. System has one virtual device with two physical devices under it,
each device gets half of requests.

We set limit to 4.000 per physical device.

All threads allocate a page and queue it to devices, so all threads
succeeded in its first allocation, and each device has its queue full.
Virtual device does not have a limit (or have it 4.000 too, but since it
was each time recharged, it has zero blocks in-flight).

New thread tries to allocate a page, it is allocated and queued to one
of the devices, but since its queue is full, thread sleeps. So will do
each other.

Thus we ended up allocated 8.000 requests queued, and 8.000 in-flight,
totally 16.000 which is smaller than amount of pages in RAM, so we are
happy.

Consider above as a special kind calculation i.e. number of 
_allocated_ pages is always number of physical device multiplied by each
one's in-flight limit. By adjusting in-flight limit and knowing number
of device it is completely possible to eliminate vm deadlock.

If you do not like such calculation, solution is trivial:
we can sleep _after_ ->make_request_fn() in
generic_make_request() until number of in-flight bios is reduced by
bio_endio().

-- 
	Evgeniy Polyakov
