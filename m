From: Tony Lindgren <tony@atomide.com>
Subject: Re: am335x: cpsw: interrupt failure
Date: Mon, 29 Dec 2014 08:51:04 -0800
Message-ID: <20141229165103.GB2411@atomide.com>
References: <CAGm1_ksNuO75QfgaDUpOe525xDkPhby-z8T=MX3DHdB-LVcR8g@mail.gmail.com>
 <20141210171724.GI4602@saruman>
 <CAGm1_ksziwSjQnV1rDYsAv2QQCvhnZPOimowmsW5Cib7C01aqA@mail.gmail.com>
 <20141210210234.GN4602@saruman>
 <CAGm1_ktYg4iDgK7jyi5etSVup61LdookkV+SaQZOpLb6M=y7hA@mail.gmail.com>
 <CAGm1_kuaqXrU4zhNUZeY85+OeXHApSUDjJdsXcyBdvHTNhLCmQ@mail.gmail.com>
 <20141212173210.GI7549@saruman>
 <CAGm1_kuYrGsfjRO6TVr554yS8dcD4_Z9-j9KL0xpD=X+31OkXQ@mail.gmail.com>
 <CAGm1_kudtF9O4QChrKX1q=c9KwHEFZet=z7j=-_iCRE914X83Q@mail.gmail.com>
 <20141229155029.GA29379@saruman>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yegor Yefremov <yegorslists@googlemail.com>,
	netdev <netdev@vger.kernel.org>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-03-ewr.mailhop.org ([204.13.248.66]:26957 "EHLO
	mho-01-ewr.mailhop.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750977AbaL2Qya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 11:54:30 -0500
Content-Disposition: inline
In-Reply-To: <20141229155029.GA29379@saruman>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Felipe Balbi <balbi@ti.com> [141229 07:53]:
> On Mon, Dec 29, 2014 at 10:33:26AM +0100, Yegor Yefremov wrote:
> > On Fri, Dec 12, 2014 at 8:19 PM, Yegor Yefremov
> > <yegorslists@googlemail.com> wrote:
> > > On Fri, Dec 12, 2014 at 6:32 PM, Felipe Balbi <balbi@ti.com> wrote:
> > >> Hi,
> > >>
> > >> On Fri, Dec 12, 2014 at 01:00:51PM +0100, Yegor Yefremov wrote:
> > >>> U-Boot version: 2014.07
> > >>> Kernel config is omap2plus with enabled USB
> > >>>
> > >>> # cat /proc/version
> > >>> Linux version 3.18.0 (user@user-VirtualBox) (gcc version 4.8.3
> > >>> 20140320 (prerelease) (Sourcery CodeBench Lite 2014.05-29) ) #6 SMP
> > >>> Mon Dec 8 22:47:43 CET 2014
> > >>
> > >> Wasn't GCC 4.8.x total crap for building ARM kernels ? IIRC it was even
> > >> blacklisted. Can you try with 4.9.x just to make sure ?
> > >
> > > Will do.
> > 
> > Adding linux-omap. Beginning of this discussion:
> > http://comments.gmane.org/gmane.linux.network/341427
> > 
> > Quick summary: starting with kernel 3.18 or commit
> > 55601c9f24670ba926ebdd4d712ac3b177232330 am335x (at least BBB and some
> > custom boards) stalls at high network load. Reproducible via nuttcp
> > within some minutes
> > 
> > nuttcp -S (on BBB)
> > nuttcp -t -N 4 -T30m 192.168.1.235 (on host)
> > 
> > As Felipe Balbi suggested, I tried both 4.8.3 and 4.9.2 toolchains,
> > but both show the same behavior.
> > 
> > Linux version 3.18.0 (user@user-VirtualBox) (gcc version 4.8.3
> > 20140320 (prerelease) (Sourcery CodeBench Lite 2014.05-29) ) #6 SMP
> > Mon Dec 8 22:47:43 CET 2014
> > Linux version 3.18.1 (user@user-VirtualBox) (gcc version 4.9.2
> > (Buildroot 2015.02-git-00582-g10b9761) ) #1 SMP Mon Dec 29 09:22:29
> > CET 2014
> > 
> > Let me know, if you can reproduce this issue.
> 
> finally managed to reproduce this, it took quite a bit of effort though.
> I'll see if I can gether more information about the problem.

Maybe check if the irqnr is 127 (or the last reserved interrupt)
in irq-omap-intc.c. If so, also print out the previous interrupt.
It seems the intc uses the last reserved interrupt to signal a
spurious interrupt for the previous irqnr, so we should probably
add some handling for that.

If the previous interrupt is a cpsw interrupt, then there's probably
something wrong with cpsw interrupt handling. Either a missing
read-back to flush posted write in the cpsw interrupt handler,
or the EOI registers are written at a wrong time.

Regards,

Tony
