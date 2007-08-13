From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Block device throttling [Re: Distributed storage.]
Date: Mon, 13 Aug 2007 06:04:06 -0700
Message-ID: <200708130604.07154.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708130418.03667.phillips@phunq.net> <20070813121802.GB5992@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070813121802.GB5992@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 13 August 2007 05:18, Evgeniy Polyakov wrote:
> > Say you have a device mapper device with some physical device
> > sitting underneath, the classic use case for this throttle code. 
> > Say 8,000 threads each submit an IO in parallel.  The device mapper
> > mapping function will be called 8,000 times with associated
> > resource allocations, regardless of any throttling on the physical
> > device queue.
>
> Each thread will sleep in generic_make_request(), if limit is
> specified correctly, then allocated number of bios will be enough to
> have a progress.

The problem is, the sleep does not occur before the virtual device 
mapping function is called.  Let's consider two devices, a physical 
device named pdev and a virtual device sitting on top of it called 
vdev.   vdev's throttle limit is just one element, but we will see that 
in spite of this, two bios can be handled by the vdev's mapping method 
before any IO completes, which violates the throttling rules. According 
to your patch it works like this:

                     Thread 1                                Thread  2

	<no wait because vdev->bio_queued is zero>

	vdev->q->bio_queued++

	<enter devmapper map method>

	blk_set_bdev(bio, pdev)
	     vdev->bio_queued--
	   
					<no wait because vdev->bio_queued is zero>

					vdev->q->bio_queued++

					<enter devmapper map method>

					whoops!  Our virtual device mapping
					function has now allocated resources
					for two in-flight bios in spite of having its
					throttle limit set to 1.

Perhaps you never worried about the resources that the device mapper 
mapping function allocates to handle each bio and so did not consider 
this hole significant.  These resources can be significant, as is the 
case with ddsnap.  It is essential to close that window through with 
the virtual device's queue limit may be violated.  Not doing so will 
allow deadlock.

Regards,

Daniel
