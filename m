From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: New driver "sfc" for Solarstorm SFC4000 controller.
Date: Tue, 6 May 2008 16:04:53 +0100
Message-ID: <20080506150450.GB2217@solarflare.com>
References: <200804301925.m3UJPc72001651@hera.kernel.org> <20080501120858.207b6dd6.akpm@linux-foundation.org> <20080502160530.GN14219@solarflare.com> <20080502110908.93c79d81.akpm@linux-foundation.org> <20080506125008.GA2217@solarflare.com> <20080506072442.82a834c8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:53459 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754250AbYEFPFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 11:05:35 -0400
Content-Disposition: inline
In-Reply-To: <20080506072442.82a834c8.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Tue, 6 May 2008 13:50:09 +0100 Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
> > Andrew Morton wrote:
> > > On Fri, 2 May 2008 17:05:35 +0100 Ben Hutchings <bhutchings@solarflare.com> wrote:
> > > 
> > > > > Oh dear, it found
> > > > > 
> > > > > #5617: FILE: drivers/net/sfc/falcon.c:1877:
> > > > > +               if (*(volatile u32 *)dma_done == FALCON_STATS_DONE)
> > > > > 
> > > > > which was naughty of you.  Perhaps this was already discussed in review
> > > > > with the people who actually know what they're talking about.
> > > > 
> > > > There wasn't any specific discussion of this.  Is it wrong?  We want to
> > > > prevent the compiler from caching *dma_done, which is itself written by DMA.
> > > 
> > > Documentation/volatile-considered-harmful.txt has some dicussion.
> > 
> > Looks like we should be using something like:
> > 
> > 	while (*dma_done != FALCON_STATS_DONE)
> > 		cpu_relax();
> > 
> > But then how do we time-out?
> 
> Dunno, something like
> 
>  	while (*dma_done != FALCON_STATS_DONE) {
> 		if (time_after(jiffies, when_to_timeout))
> 			goto timeout;
>  		cpu_relax();
> 	}
 
This isn't good for short timeouts.

> or
> 
>  	while (*dma_done != FALCON_STATS_DONE) {
> 		udelay(1);
> 		if (++timeout > TIMEOUT)
> 			goto timeout;
> 	}
 
On some architectures udelay() is defined using inline assembly that is not
specified as clobbering memory.  So the compiler need not reload *dma_done
after calling it, and this doesn't work.

> ?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
