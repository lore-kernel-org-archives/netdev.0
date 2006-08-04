From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Fri, 04 Aug 2006 16:31:11 -0700 (PDT)
Message-ID: <20060804.163111.85390037.davem@davemloft.net>
References: <20060804101017.GA17393@gondor.apana.org.au>
	<1154712532.3117.43.camel@rh4>
	<20060804110829.62136ebb@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, herbert@gondor.apana.org.au, hadi@cyberus.ca,
	jesse.brandeburg@intel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:13026
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161578AbWHDXbF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 19:31:05 -0400
To: shemminger@osdl.org
In-Reply-To: <20060804110829.62136ebb@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 4 Aug 2006 11:08:29 -0700

> On Fri, 04 Aug 2006 10:28:52 -0700
> "Michael Chan" <mchan@broadcom.com> wrote:
> 
> > May be David can explain why it is undesirable to wake up the queue when
> > it is full?

Why does Michael ask all the difficult questions? :-)

> Because it means that there was a race hole in the normal sleep/wakeup code.
> Some drivers just spin (see acenic.c) but that's ugly.
> 
> The real risk is that the transmit routine will decide it's busy, but
> at the same time an IRQ on another CPU will clean up the whole ring
> and make the queue available again. Then the transmit routine exits and
> says its busy, and the higher level will decide it is permanently stopped.

Yes, it's meant to catch unintented races.

The queueing layer that calls ->hard_start_xmit() technically has no
need to support NETDEV_TX_BUSY as a return value, since the device
is able to prevent this.

If we could avoid NETDEV_TX_BUSY et al. from happening, the idea is
that we could eliminate all of the requeueing logic in the packet
scheduler layer.  It is a pipe dream from many years ago.

But this may never be realized because now we have things like LLTX
which can return NETDEV_TX_LOCKED which also requires a requeue.
Also, several specialized devices can return NETDEV_TX_BUSY in ways
which are hard to prevent.  I'll reproduce Alexey's comments from
qdisc_restart():

		/* Device kicked us out :(
		   This is possible in three cases:

		   0. driver is locked
		   1. fastroute is enabled
		   2. device cannot determine busy state
		      before start of transmission (f.e. dialout)
		   3. device is buggy (ppp)
		 */

Hmmm, another remnant reference to fastroute which we should delete :-)
