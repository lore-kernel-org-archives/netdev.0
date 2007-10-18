From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Thu, 18 Oct 2007 08:31:57 +0200
Message-ID: <20071018063157.GA1694@ff.dom.local>
References: <20071015125301.GC3015@ff.dom.local> <Pine.LNX.4.64N.0710151737250.16262@blysk.ds.pg.gda.pl> <20071016062108.GB1000@ff.dom.local> <Pine.LNX.4.64N.0710161759050.22596@blysk.ds.pg.gda.pl> <20071017085809.GA1658@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Maciej W\. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:35508 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756364AbXJRG2w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2007 02:28:52 -0400
Content-Disposition: inline
In-Reply-To: <20071017085809.GA1658@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 17, 2007 at 10:58:09AM +0200, Jarek Poplawski wrote:
...
> 8) phy_stop_interrupts(): I'm not sure this additional call from
> DEBUG_SHIRQ should be so dangerous, eg.:
> 
> 	/*
> 	 * status == PHY_HALTED &&
> 	 * interrupts are stopped after phy_stop()
> 	 */
> 	if (cancel_work_sync(...))
> 		enable_irq();
> 
> 	free_irq(...);
> 	/*
> 	 * possible schedule_work() from DEBUG_SHIRQ only,
> 	 * but proper check for PHY_HALTED is done;
> 	 * so, let's flush after this too:
> 	 */
> 	cancel_work_sync();

After rethinking, it looks like this last cancel should be useless.
So, if phy_interrupt() schedules only if !PHY_HALTED and phy_change()
does enable_irq() with no exeptions, it seems phy_interrupt() even
without lock must see PHY_HALTED state before this free_irq() with
possible DEBUG_SHIRQ call, then maybe only this safety:

	WARN_ON(work_pending(&phydev->phy_queue));


Btw, I've read this was considered and not liked, but IMHO, if this
really has to be like this, creating phy's own workqueue seems to be
resonable, at the very least to reduce latencies to other users of
this irq.

Jarek P.
