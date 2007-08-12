From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [1/1] Block device throttling [Re: Distributed storage.]
Date: Sun, 12 Aug 2007 16:16:10 -0700
Message-ID: <200708121616.10670.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <20070808095448.GA3440@2ka.mipt.ru> <20070808101708.GA23815@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070808101708.GA23815@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Evgeniy,

Sorry for not getting back to you right away, I was on the road with 
limited email access.  Incidentally, the reason my mails to you keep 
bouncing is, your MTA is picky about my mailer's IP reversing to a real 
hostname.  I will take care of that pretty soon, but for now my direct 
mail to you is going to bounce and you will only see the lkml copy.

On Wednesday 08 August 2007 03:17, Evgeniy Polyakov wrote:
> This throttling mechanism allows to limit maximum amount of queued
> bios per physical device. By default it is turned off and old block
> layer behaviour with unlimited number of bios is used. When turned on
> (queue limit is set to something different than -1U via
> blk_set_queue_limit()), generic_make_request() will sleep until there
> is room in the queue. number of bios is increased in
> generic_make_request() and reduced either in bio_endio(), when bio is
> completely processed (bi_size is zero), and recharged from original
> queue when new device is assigned to bio via blk_set_bdev(). All
> oerations are not atomic, since we do not care about precise number
> of bios, but a fact, that we are close or close enough to the limit.
>
> Tested on distributed storage device - with limit of 2 bios it works
> slow :)

it seems to me you need:

-               if (q) {
+               if (q && q->bio_limit != -1) {

This patch is short and simple, and will throttle more accurately than 
the current simplistic per-request allocation limit.  However, it fails 
to throttle device mapper devices.  This is because no request is 
allocated by the device mapper queue method, instead the mapping call 
goes straight through to the mapping function.  If the mapping function 
allocates memory (typically the case) then this resource usage evades 
throttling and deadlock becomes a risk.

There are three obvious fixes:

   1) Implement bio throttling in each virtual block device
   2) Implement bio throttling generically in device mapper
   3) Implement bio throttling for all block devices

Number 1 is the approach we currently use in ddsnap, but it is ugly and 
repetitious.  Number 2 is a possibility, but I favor number 3 because 
it is a system-wide solution to a system-wide problem, does not need to 
be repeated for every block device that lacks a queue, heads in the 
direction of code subtraction, and allows system-wide reserve 
accounting. 

Your patch is close to the truth, but it needs to throttle at the top 
(virtual) end of each block device stack instead of the bottom 
(physical) end.  It does head in the direction of eliminating your own 
deadlock risk indeed, however there are block devices it does not 
cover.

Regards,

Daniel
