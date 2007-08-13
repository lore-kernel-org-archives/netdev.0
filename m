From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Block device throttling [Re: Distributed storage.]
Date: Sun, 12 Aug 2007 22:22:11 -0700
Message-ID: <200708122222.12189.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <20070807205538.GB5245@kernel.dk> <20070808095448.GA3440@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070808095448.GA3440@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 08 August 2007 02:54, Evgeniy Polyakov wrote:
> On Tue, Aug 07, 2007 at 10:55:38PM +0200, Jens Axboe 
(jens.axboe@oracle.com) wrote:
>
> So, what did we decide? To bloat bio a bit (add a queue pointer) or
> to use physical device limits? The latter requires to replace all
> occurence of bio->bi_bdev = something_new with blk_set_bdev(bio,
> somthing_new), where queue limits will be appropriately charged. So
> far I'm testing second case, but I only changed DST for testing, can
> change all other users if needed though.

Adding a queue pointer to struct bio and using physical device limits as 
in your posted patch both suffer from the same problem: you release the 
throttling on the previous queue when the bio moves to a new one, which 
is a bug because memory consumption on the previous queue then becomes 
unbounded, or limited only by the number of struct requests that can be 
allocated.  In other words, it reverts to the same situation we have 
now as soon as the IO stack has more than one queue.  (Just a shorter 
version of my previous post.)

We can solve this by having the bio only point at the queue to which it 
was originally submitted, since throttling the top level queue 
automatically throttles all queues lower down the stack.  Alternatively 
the bio can point at the block_device or straight at the 
backing_dev_info, which is the per-device structure it actually needs 
to touch.

Note!  There are two more issues I forgot to mention earlier.

1) One throttle count per submitted bio is too crude a measure.  A bio 
can carry as few as one page or as many as 256 pages.  If you take only 
one throttle count per bio and that data will be transferred over the 
network then you have to assume that (a little more than) 256 pages of 
sk_alloc reserve will be needed for every bio, resulting in a grossly 
over-provisioned reserve.  The precise reserve calculation we want to 
do is per-block device, and you will find hooks like this already 
living in backing_dev_info.  We need to place our own fn+data there to 
calculate the throttle draw for each bio.  Unthrottling gets trickier 
with variable size throttle draw.  In ddsnap, we simply write the 
amount we drew from the throttle into (the private data of) bio for use 
later by unthrottle, thus avoiding the issue that the bio fields we 
used to calculate might have changed during the lifetime of the bio.  
This would translate into one more per-bio field.



the throttling performs another function: keeping a reasonable amount of 
IO in flight for the device.  The definition of "reasonable" is 
complex.  For a hard disk it depends on the physical distance between 
sector addresses of the bios in flight.  In ddsnap we make a crude but 
workable approximation that 


 In general, a per block device 

The throttle count needs to cover 

Regards,

Daniel
