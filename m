From: Valerie Henson <val_henson@linux.intel.com>
Subject: Re: PATCHv3 2.6.17-rc5 tulip free_irq() called too late
Date: Wed, 21 Jun 2006 17:43:40 -0700
Message-ID: <20060622004339.GO19196@goober>
References: <20060531195234.GA4967@colo.lackof.org> <44883778.8000209@pobox.com> <20060608170120.GI8246@colo.lackof.org> <20060613235531.GA4191@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:24969 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S932163AbWFVApP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 20:45:15 -0400
To: Grant Grundler <grundler@parisc-linux.org>
Content-Disposition: inline
In-Reply-To: <20060613235531.GA4191@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 13, 2006 at 05:55:31PM -0600, Grant Grundler wrote:
> On Thu, Jun 08, 2006 at 11:01:20AM -0600, Grant Grundler wrote:
> > Here is a new patch that moves free_irq() into tulip_down().
> > The resulting code is structured the same as cp_close().
> 
> Val,
> Two details are wrong in version 2 and are fixed in v3 (appended below):
> 
> o we don't need synchronize_irq() before calling free_irq().
>   (It should be removed from cp_close() too)
>   Thanks to willy for pointing me at kernel/irq/manage.c.
> 
> o tulip_stop_rxtx() has to be called _after_ free_irq().
>   ie. v2 patch didn't fix the original race condition
>   and when under test, dies about as fast as the original code.
> 
> Tested on rx4640 (HP IA64) for several hours.
> Please apply.

Hi folks,

The quick summary of my thoughts on this patch is that it isn't the
ideal patch, but it works and it's well-tested.  Doing my preferred
fix (adding a shutdown flag) would be invasive and take many weeks to
reach the level of stability of Grant's patch.  So I'm taking this
patch but adding a comment describing my preferred fix.

Here's the long version.  The obvious ordering of bringing up the card
is:

request_irq()
setup DMA resources
enable interrupts
start DMA engine

And the obvious ordering of shutting it down is:

stop DMA engine
disable interrupts
remove DMA resources
free_irq()

The problem with the above shutdown order is that we can receive an
interrupt in between stopping DMA and disabling interrupts, and the
tulip irq handler will reenable DMA =><= Boom!  The solution I prefer
is to make the irq handler aware of whether we are shutting down or
not, and not reenable DMA in that case.  However, it is a non-trivial
patch to get right, and I would rather have the bug fixed short-term
with the ordering Grant uses:

disable interrupts
free_irq()
stop rxtx
remove DMA resources

Make sense to everyone?  I'll redo the patch with the comment and get
Grant's sign-off.

-VAL
