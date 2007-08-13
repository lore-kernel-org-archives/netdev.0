From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Distributed storage.
Date: Mon, 13 Aug 2007 16:27:42 -0700
Message-ID: <200708131627.42859.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708130159.22407.phillips@phunq.net> <20070813091235.GI23758@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070813091235.GI23758@kernel.dk>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 13 August 2007 02:12, Jens Axboe wrote:
> > It is a system wide problem.  Every block device needs throttling,
> > otherwise queues expand without limit.  Currently, block devices
> > that use the standard request library get a slipshod form of
> > throttling for free in the form of limiting in-flight request
> > structs.  Because the amount of IO carried by a single request can
> > vary by two orders of magnitude, the system behavior of this
> > approach is far from predictable.
>
> Is it? Consider just 10 standard sata disks. The next kernel revision
> will have sg chaining support, so that allows 32MiB per request. Even
> if we disregard reads (not so interesting in this discussion) and
> just look at potentially pinned dirty data in a single queue, that
> number comes to 4GiB PER disk. Or 40GiB for 10 disks. Auch.
>
> So I still think that this throttling needs to happen elsewhere, you
> cannot rely the block layer throttling globally or for a single
> device. It just doesn't make sense.

You are right, so long as the unit of throttle accounting remains one 
request.  This is not what we do in ddsnap.  Instead we inc/dec the 
throttle counter by the number of bvecs in each bio, which produces a 
nice steady data flow to the disk under a wide variety of loads, and 
provides the memory resource bound we require.

One throttle count per bvec will not be the right throttling metric for 
every driver.  To customize this accounting metric for a given driver 
we already have the backing_dev_info structure, which provides 
per-device-instance accounting functions and instance data.  Perfect! 
This allows us to factor the throttling mechanism out of the driver, so 
the only thing the driver has to do is define the throttle accounting 
if it needs a custom one.

We can avoid affecting the traditional behavior quite easily, for 
example if backing_dev_info->throttle_fn (new method) is null then 
either not throttle at all (and rely on the struct request in-flight 
limit) or we can move the in-flight request throttling logic into core 
as the default throttling method, simplifying the request library and 
not changing its behavior.

> > These deadlocks are first and foremost, block layer deficiencies. 
> > Even the network becomes part of the problem only because it lies
> > in the block IO path.
>
> The block layer has NEVER guaranteed throttling, so it can - by
> definition - not be a block layer deficiency.

The block layer has always been deficient by not providing accurate 
throttling, or any throttling at all for some devices.  We have 
practical proof that this causes deadlock and a good theoretical basis 
for describing exactly how it happens.

To be sure, vm and net are co-conspirators, however the block layer 
really is the main actor in this little drama.

Regards,

Daniel
