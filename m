From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] jme: Fix DMA unmap warning
Date: Wed, 7 May 2014 16:33:17 -0400
Message-ID: <20140507203317.GC8786@hmsreliant.think-freely.org>
References: <1399315907-27148-1-git-send-email-nhorman@tuxdriver.com>
 <20140507.155613.630399521517455317.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cooldavid@cooldavid.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47143 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963AbaEGUdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 16:33:23 -0400
Content-Disposition: inline
In-Reply-To: <20140507.155613.630399521517455317.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 07, 2014 at 03:56:13PM -0400, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Mon,  5 May 2014 14:51:47 -0400
> 
> > The jme driver forgot to check the return status from pci_map_page in its tx
> > path, causing a dma api warning on unmap.  Easy fix, just do the check and
> > augment the tx path to tell the stack that the driver is busy so we re-queue the
> > frame.
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> Applied thanks Neil.
> 
No problem.

> Probably we should eventually come up with a perhaps more suitable recovery
> scheme in the generic netdev queuing layer for these situations.
> 
> If a mapping fails, usually it's because of resource exhaustion and that's
> a "wait and try again" type situation in hoping that whatever releases
> are keeping the allocation from happening will get released.
> 
> But that's not exactly what we do right now when NETDEV_TX_BUSY is
> signalled.  We'll just loop over and over in the TX software interrupt
> handler for the qdisc.
> 
> Perhaps an hrtimer or similar would be more appropriate.
> 
Hm, timers seem like they might be a bit too 'dead reckoned' I think.  I.e.
theres no correlation or interlock between how long we set the timer to expire,
and the likelyhood that the resource limitation is cleared (or was cleared and
recurred from a subsequent glut of traffic).  

Perhaps a solution is a signalling mechanism tied to completion interrupts?
I.e. a mapping failure gets reported to the stack, which causes the
correspondnig queue to be stopped, until such time a the driver signals a safe
restart by the reception of a tx completion interrupt?  I'm actually tinkering
right now with a mechanism that provides guidance to the stack as to how many
dma descriptors are available in a given net_device that might come in handy
here
Neil
