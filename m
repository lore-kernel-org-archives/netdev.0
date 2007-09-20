From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Thu, 20 Sep 2007 16:53:48 -0700
Message-ID: <20070920165348.0b25be3d.akpm@linux-foundation.org>
References: <Pine.LNX.4.64N.0709171750220.17606@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41639 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751468AbXITXyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 19:54:36 -0400
In-Reply-To: <Pine.LNX.4.64N.0709171750220.17606@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Sep 2007 15:38:19 +0100 (BST)
"Maciej W. Rozycki" <macro@linux-mips.org> wrote:

>  Keep track of disable_irq_nosync() invocations and call enable_irq() the 
> right number of times if work has been cancelled that would include them.
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
> ---
>  Now that the call to flush_work_keventd() (problematic because of 
> rtnl_mutex being held) has been replaced by cancel_work_sync() another 
> issue has arisen and been left unresolved.  As the MDIO bus cannot be 
> accessed from the interrupt context the PHY interrupt handler uses 
> disable_irq_nosync() to prevent from looping and schedules some work to be 
> done as a softirq, which, apart from handling the state change of the 
> originating PHY, is responsible for reenabling the interrupt.  Now if the 
> interrupt line is shared by another device and a call to the softirq 
> handler has been cancelled, that call to enable_irq() never happens and 
> the other device cannot use its interrupt anymore as its stuck disabled.
> 
>  I decided to use a counter rather than a flag because there may be more 
> than one call to phy_change() cancelled in the queue -- a real one and a 
> fake one triggered by free_irq() if DEBUG_SHIRQ is used, if nothing else.  
> Therefore because of its nesting property enable_irq() has to be called 
> the right number of times to match the number disable_irq_nosync() was 
> called and restore the original state.  This DEBUG_SHIRQ feature is also 
> the reason why free_irq() has to be called before cancel_work_sync().
> 
>  While at it I updated the comment about phy_stop_interrupts() being 
> called from `keventd' -- this is no longer relevant as the use of 
> cancel_work_sync() makes such an approach unnecessary.  OTOH a similar 
> comment referring to flush_scheduled_work() in phy_stop() still applies as 
> using cancel_work_sync() there would be dangerous.
> 
>  Checked with checkpatch.pl and at the run time (with and without 
> DEBUG_SHIRQ).

You always put boring, crappy, insufficient text in the for-the-changelog
section and interesting, useful, sufficient text in the not-for-the-changelog
section.

But you can't fool me!  I have an editor and I fix it up.
