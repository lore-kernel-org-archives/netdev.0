From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] Block device throttling [Re: Distributed storage.]
Date: Wed, 29 Aug 2007 12:53:31 +0400
Message-ID: <20070829085331.GA16607@2ka.mipt.ru>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708281027.59528.phillips@phunq.net> <20070828175403.GA28440@2ka.mipt.ru> <200708281408.06618.phillips@phunq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Daniel Phillips <phillips@phunq.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200708281408.06618.phillips@phunq.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 28, 2007 at 02:08:04PM -0700, Daniel Phillips (phillips@phunq.net) wrote:
> On Tuesday 28 August 2007 10:54, Evgeniy Polyakov wrote:
> > On Tue, Aug 28, 2007 at 10:27:59AM -0700, Daniel Phillips (phillips@phunq.net) wrote:
> > > > We do not care about one cpu being able to increase its counter
> > > > higher than the limit, such inaccuracy (maximum bios in flight
> > > > thus can be more than limit, difference is equal to the number of
> > > > CPUs - 1) is a price for removing atomic operation. I thought I
> > > > pointed it in the original description, but might forget, that if
> > > > it will be an issue, that atomic operations can be introduced
> > > > there. Any uber-precise measurements in the case when we are
> > > > close to the edge will not give us any benefit at all, since were
> > > > are already in the grey area.
> > >
> > > This is not just inaccurate, it is suicide.  Keep leaking throttle
> > > counts and eventually all of them will be gone.  No more IO
> > > on that block device!
> >
> > First, because number of increased and decreased operations are the
> > same, so it will dance around limit in both directions.
> 
> No.  Please go and read it the description of the race again.  A count
> gets irretrievably lost because the write operation of the first
> decrement is overwritten by the second. Data gets lost.  Atomic 
> operations exist to prevent that sort of thing.  You either need to use 
> them or have a deep understanding of SMP read and write ordering in 
> order to preserve data integrity by some equivalent algorithm.

I think you should complete your emotional email with decription of how
atomic types are operated and how processors access data. Just to give a
lesson to those who never knew how SMP works, but create patches and
have the conscience to send them and even discuss.
Then, if of course you will want, which I doubt, you can reread previous 
mails and find that it was pointed to that race and possibilities to 
solve it way too long ago. 
Anyway, I prefer to look like I do not know how SMP and atomic operation
work and thus stay away from this discussion.

> --- 2.6.22.clean/block/ll_rw_blk.c	2007-07-08 16:32:17.000000000 -0700
> +++ 2.6.22/block/ll_rw_blk.c	2007-08-24 12:07:16.000000000 -0700
> @@ -3237,6 +3237,15 @@ end_io:
>   */
>  void generic_make_request(struct bio *bio)
>  {
> +	struct request_queue *q = bdev_get_queue(bio->bi_bdev);
> +
> +	if (q && q->metric) {
> +		int need = bio->bi_reserved = q->metric(bio);
> +		bio->queue = q;

In case you have stacked device, this entry will be rewritten and you
will lost all your account data.

> +		wait_event_interruptible(q->throttle_wait, atomic_read(&q->available) >= need);
> +		atomic_sub(&q->available, need);
> +	}

-- 
	Evgeniy Polyakov
