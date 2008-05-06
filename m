From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: New driver "sfc" for Solarstorm SFC4000 controller.
Date: Tue, 6 May 2008 07:24:42 -0700
Message-ID: <20080506072442.82a834c8.akpm@linux-foundation.org>
References: <200804301925.m3UJPc72001651@hera.kernel.org>
	<20080501120858.207b6dd6.akpm@linux-foundation.org>
	<20080502160530.GN14219@solarflare.com>
	<20080502110908.93c79d81.akpm@linux-foundation.org>
	<20080506125008.GA2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50343 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751123AbYEFOZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 10:25:15 -0400
In-Reply-To: <20080506125008.GA2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 May 2008 13:50:09 +0100 Ben Hutchings <bhutchings@solarflare.com> wrote:

> Andrew Morton wrote:
> > On Fri, 2 May 2008 17:05:35 +0100 Ben Hutchings <bhutchings@solarflare.com> wrote:
> > 
> > > > Oh dear, it found
> > > > 
> > > > #5617: FILE: drivers/net/sfc/falcon.c:1877:
> > > > +               if (*(volatile u32 *)dma_done == FALCON_STATS_DONE)
> > > > 
> > > > which was naughty of you.  Perhaps this was already discussed in review
> > > > with the people who actually know what they're talking about.
> > > 
> > > There wasn't any specific discussion of this.  Is it wrong?  We want to
> > > prevent the compiler from caching *dma_done, which is itself written by DMA.
> > 
> > Documentation/volatile-considered-harmful.txt has some dicussion.
> 
> Looks like we should be using something like:
> 
> 	while (*dma_done != FALCON_STATS_DONE)
> 		cpu_relax();
> 
> But then how do we time-out?

Dunno, something like

 	while (*dma_done != FALCON_STATS_DONE) {
		if (time_after(jiffies, when_to_timeout))
			goto timeout;
 		cpu_relax();
	}

or

 	while (*dma_done != FALCON_STATS_DONE) {
		udelay(1);
		if (++timeout > TIMEOUT)
			goto timeout;
	}

?
