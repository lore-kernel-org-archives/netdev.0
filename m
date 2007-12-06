From: Peter Tyser <ptyser@xes-inc.com>
Subject: Re: [PATCH] sky2: RX lockup fix
Date: Wed, 05 Dec 2007 18:18:46 -0600
Message-ID: <1196900326.21996.1.camel@localhost.localdomain>
References: <1196880663.2816.149.camel@localhost.localdomain>
	 <20071205164058.157275a9@shemminger-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xes-mad.com ([216.165.139.214]:42671 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751160AbXLFAVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 19:21:22 -0500
In-Reply-To: <20071205164058.157275a9@shemminger-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2007-12-05 at 16:40 -0500, Stephen Hemminger wrote:
> > I looked over Marvell's most recent sk98lin driver and it looks like
> > they had a "workaround" for the Yukon XL that the sky2 doesn't have yet.
> > The sk98lin driver disables the RX MAC FIFO flush feature for all
> > revisions of the Yukon XL.
> > 
> > According to skgeinit.c of the sk98lin driver, "Flushing must be enabled
> > (needed for ASF see dev. #4.29), but the flushing mask should be
> > disabled (see dev. #4.115)".  Nice.   I implemented this same change in
> > the sky2 driver and verified that the RX lockup I was seeing was
> > resolved.
> > 
> 
> 
> Without the flush, does flow control still work? My concern is that
> integrating this would cause pause packets (and over/under length packets)
> to not be handled correctly.

My understanding is that "bad" packets should still be filtered in
sky2_receive() when a packet's status is compared against
GMR_FS_ANY_ERR.  This comparison should prevent over/under length
packets from making their way up the stack.  This comparison also uses
the same value that was previous programmed to the RX MAC FIFO Flush
Mask, so there shouldn't be any change in the types of bad packets that
are discarded.

I don't believe that disabling RX filtering should affect the handling
of flow control packets specifically either.  The comparison in
sky2_receive() to GMR_FS_ANY_ERR does allow valid flow control packets
to be received. (I'm not intimately familiar with sky2/Linux's handling
of flow control packets, so take the above with a grain of salt)

As I understand it, the only real downside of disabling RX filtering at
the hardware level is that the CPU has to investigate every incoming
packet's status, even the ones that it is going to drop due to length,
crc, etc.  This adds some overhead, but I don't believe it should affect
the driver's operation.

