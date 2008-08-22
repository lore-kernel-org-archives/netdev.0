From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [RFC] New Qlogic 10Gb Ethernet driver for 2.6.28
Date: Fri, 22 Aug 2008 10:42:05 -0700
Message-ID: <20080822174205.GA2551@susedev.qlogic.org>
References: <20080821185402.GD31526@susedev.qlogic.org> <48AE8549.6090705@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux-Driver@qlogic.com, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:12726 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264AbYHVRmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 13:42:39 -0400
Content-Disposition: inline
In-Reply-To: <48AE8549.6090705@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2008 at 05:22:17AM -0400, Jeff Garzik wrote:
> Ron Mercer wrote:
> >Hi Jeff,
> >
> >Please find our new 10Gb ethernet driver at the following site:
> >
> >ftp://ftp.qlogic.com/outgoing/linux/network/linux/upstream/qlge
> >
> >There are two files at this location:
> >qlge-aug212008.patch - A full patch that is buildable on the latest 
> >netdev/upstream kernel.
> >qlge-aug212008.tar.bz2 - A zip file of the source code at 
> >drivers/net/qlge/*
> >
> >We are targeting this driver for 2.6.28 release.  We look forward to any 
> >and all comments.
> >
> >Notes:
> >1) The file qlge_mpi.c (Management Port Interface) is mostly stubbed right 
> >now but will have functionality to handle setting up wake-on-lan and 
> >getting/setting link paramters.
> >2) Please ignore "#ifdef PALLADIUM".  It will be removed going forward as 
> >it's currently used for a test platform.
> 
> OK, just skimmed the whole thing (i.e. no in-depth analysis of locking, 
> etc.)
> 
> Initial thoughts...
>
 
> - its a nice clean driver
;)

> - I have not examined the interrupt and completion paths in depth, but 
> they looked unusual enough to warrant additional analysis [on my part]. 

The MSI-X multi-vector path is fairly straightforward.  There are handlers for outbound
completions, inbound completions (RSS) and an auxillary path that handles
chip errors, firmware events, and a queue for broadcast/multicast frames.
The non MSI-X is a little more complicated because it handles more conditions. I
can break this out a little more if it would be cleaner.
 
>  - There are more spinlocks than usual, raising an eyebrow

The NIC function on this ASIC shares a few resources with the firmware.
When you see ql_sem_spinlock/ql_sem_trylock it is causing serial access
to these resources.  They are not used in the critical path.


> - The kmap use is interesting

I think I can get rid of this and if not will change to __pskb_pull_tail per
Dave's suggestion. Basically, it only happens when a JUMBO inbound completion
arrives that is not a TCP/UDP frame.  I have set the driver up to cause the
chip to split headers for jumbo TCP/UDP frames only.  When a large non-TCP/UDP
packet arrives it gets messy. I allocate an skb and copy some or all of the
data from the large buffer (page) to the skb. I wasn't sure if I could
chain a page to an skb that has an empty data buffer. 

> - I also wonder if heavy use of atomic_t might not be more expensive 
> than spinlocking a section, then using normal variables.

Good point.  I will look into this more.

> - want more info on shadow (buffering?) scheme

The shadow scheme is used to reduce PCI reads in rx ring processing. We have the
chip echo the producer index for each ring to a memory location passed
from the driver to the chip. It works as is but I would be happy to
work on cleaning up the implementation.  Right now I grab a page of memory
and then dole out pointers to 32-bit locations for the chip to echo
the index to.
I also use space from this page to hold a pointer to the buffer queues. The
buffer queue pointer that is given to the chip is actually a
pointer to a location that points to a page comprising the buffer queue.
This was done to provide support for buffer queues that span 
non-contiguous pages. This driver uses a single page for the buffer
queues but I still have to use the indirection method to
communicate it to the hardware.
I will think about how to clean this up and comment it better.

> - are hardware docs or more info available?
The spec is still not ready for release.

> - most drivers do not need LICENSE files, is that really necessary?
The license is only for the firmware.  The driver is GPL.

