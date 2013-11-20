From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: [PATCH] usb: xhci: Link TRB must not occur with a USB payload
 burst.
Date: Wed, 20 Nov 2013 08:50:41 -0800
Message-ID: <20131120165028.GC9611@xanatos>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B740B@saturn3.aculab.com>
 <Pine.LNX.4.44L0.1311131113090.1424-100000@iolanthe.rowland.org>
 <AE90C24D6B3A694183C094C60CF0A2F6026B741A@saturn3.aculab.com>
 <1384565904.29151.66.camel@bwh-desktop.uk.level5networks.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7428@saturn3.aculab.com>
 <1384787003.10077.34.camel@deadeye.wl.decadent.org.uk>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7430@saturn3.aculab.com>
 <20131119225822.GA9611@xanatos>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7438@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10071 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754248Ab3KTQvV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Nov 2013 11:51:21 -0500
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7438@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 20, 2013 at 09:46:08AM -0000, David Laight wrote:
> > From: Sarah Sharp
> ...
> > (Also, usb-storage aligns the block sizes to 512K, which explains why
> > we've never had an issue with TD fragments with that driver.)
> 
> What is a 'block' in that context?
> 512K sounds more like the value that very long transfers get chopped
> up into. With 4k pages that might be 128 fragments.

Sorry, I meant 512-byte boundaries.  See Alan's comment in
drivers/usb/storage/scsiglue.c:

        /* USB has unusual DMA-alignment requirements: Although the
         * starting address of each scatter-gather element doesn't matter,
         * the length of each element except the last must be divisible
         * by the Bulk maxpacket value.  There's currently no way to
         * express this by block-layer constraints, so we'll cop out
         * and simply require addresses to be aligned at 512-byte
         * boundaries.  This is okay since most block I/O involves
         * hardware sectors that are multiples of 512 bytes in length,
         * and since host controllers up through USB 2.0 have maxpacket
         * values no larger than 512.
         *
         * But it doesn't suffice for Wireless USB, where Bulk maxpacket
         * values can be as large as 2048.  To make that work properly
         * will require changes to the block layer.
         */
        blk_queue_update_dma_alignment(sdev->request_queue, (512 - 1));

> I'd have thought that the SG list would normally contain references
> to a number of memory pages - so each would be 4k (on x86) aligned.
> My suspicion is that the xhci controller will generate correct USB3
> data provided the link TRB is on a 1k boundary - so such data won't
> be a problem.

If the max burst size is less than four, and the scsi layer hands down
4k chunks, then the driver would still work without any modification for
TD fragments, since MBP would be 4k and there would never be a link TRB
in the middle of an MBP.

However, the driver could be in violation of the spec if the burst size
was greater than 4.  I suspect what would happen is the host controller
would read the TD, and do a shorter burst of 4 max-packet-sized 1k
chunks, and then end the burst early.  But I'm not a hardware engineer,
and we can't count on how they designed it.  I'm just trying to figure
out why usb-storage worked for so many years without running into this
issue.

> If a user program does a direct transfer from the block device
> (and that is done by locking down the user pages) then the buffer
> could have an arbitrary alignment.

Sure.  In that case though, limiting the sg_tablesize so that TDs fit
into one ring segment isn't going to help, because the block layer won't
use it.  I guess the transfers will just fail, until we can get a better
fix in.

Sarah Sharp
