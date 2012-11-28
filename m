From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH v2 3/3] pppoatm: protect against freeing of vcc
Date: Wed, 28 Nov 2012 10:18:47 -0500
Message-ID: <20121128101847.3722d736@thirdoffive.cmf.nrl.navy.mil>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
	<1350926091-12642-3-git-send-email-krzysiek@podlesie.net>
	<1354036592.2534.6.camel@shinybook.infradead.org>
	<20121127173906.GA11390@shrek.podlesie.net>
	<1354039349.2534.11.camel@shinybook.infradead.org>
	<20121127135434.0728cd4f@thirdoffive.cmf.nrl.navy.mil>
	<AE90C24D6B3A694183C094C60CF0A2F6026B70C9@saturn3.aculab.com>
	<20121128100412.GA6269@shrek.podlesie.net>
	<1354098268.21562.44.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Mazur <krzysiek@podlesie.net>,
	David Laight <David.Laight@ACULAB.COM>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nathan@traverse.com.au
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354098268.21562.44.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 28 Nov 2012 10:24:28 +0000
David Woodhouse <dwmw2@infradead.org> wrote:

> On Wed, 2012-11-28 at 11:04 +0100, Krzysztof Mazur wrote:
> > 
> > The ->close() routine can just abort any pending rx/tx and just wait
> > for completion of currently running rx/tx code. That shouldn't take
> > long.
> 
> If it's been submitted to the hardware for DMA, it can't do that very
> easily.
> 
> And if I can't be bothered to write code to go through the entire damn
> queue and inspect every packet to see if it's a data packet and check
> the VCI/VPI and try to steal it, it can't be done for the software queue
> either :)
> 
> The queue ought to be short; if it isn't, then we already screwed up.
> The close therefore should be quick, and it *doesn't* have to be
> instant.
> 
> If someone wants to return immediately, there's always
> vcc_release_async()...
> 

i dont think that would be quite the right way to do it.
vcc_release_async() just mark's the vcc for deletion--you still need to
go through and close it eventually.  however, nothing would prevent you
from writing a close routine that could just reschedule something
periodically to check to see if the hardware finally finished closing
the vcc and can be reused.  the part that needs fixed for this would be
marking the vcc for reuse.  you would need to keep the vpi.vci marked
as busy so that someone else doesnt try to reuse it while it is
closing.  right now, vcc_destroy_socket() always removes the vcc from
the vcc list -- regardless of whether or not close fully succeeded.
