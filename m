From: David Jander <david@protonic.nl>
Subject: Re: gcc 4.8.3 miscompiles drivers/net/ethernet/freescale/fec_main.c
 ?!
Date: Tue, 16 Sep 2014 13:42:09 +0200
Message-ID: <20140916134209.7cc21f86@archvile>
References: <20140910110943.3673dbb4@archvile>
	<21520.17620.519242.597681@gargle.gargle.HOWL>
	<20140910164920.3c448b40@archvile>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Russell King <rmk+kernel@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, <m.olbrich@pengutronix.de>
To: Mikael Pettersson <mikpelinux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from protonic.xs4all.nl ([83.163.252.89]:16078 "EHLO
	protonic.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752927AbaIPLlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 07:41:45 -0400
In-Reply-To: <20140910164920.3c448b40@archvile>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Mikael,

On Wed, 10 Sep 2014 16:49:20 +0200
David Jander <david@protonic.nl> wrote:

> On Wed, 10 Sep 2014 14:32:20 +0200
> Mikael Pettersson <mikpelinux@gmail.com> wrote:
> 
> > David Jander writes:
> >  > 
> >  > Hi,
> >  > 
> >  > I am seeing a strange problem when building a recent kernel with
> >  > gcc-4.8.3 for armv7-a that contains the following patch:
> >  > 
> >  > https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit?id=bfd4ecdd87d350e19457fe0d02fa1e046774c44e
> >  > 
> >  > Unfortunately I am not good enough at reading ARM assembly output from
> >  > GCC to understand whats going wrong, so I am asking for help.
> >  > 
> >  > I started noticing ethernet packet loss on a i.MX6 board after upgrading
> >  > the kernel from 3.16-rc-something to latest mainline. The problem is
> >  > very easy to reproduce so I started git-bisecting. Git bisect gave me
> >  > the above patch as the culprit, and indeed: Without the patch a
> >  > flood-ping goes fine (just one dot on screen, no lost packets). I apply
> >  > the patch and the dots start filling the screen instantly.
> >  > 
> >  > I am compiling the kernel using Pengutronix's OSELAS toolchain version
> >  > 2013.12.1, which is based on linaro gcc-4.8.3 without any relevant
> >  > patches AFAIK.
> > 
> > Linaro's toolchain is itself heavily modified compared to FSF gcc-4.8.3,
> > so first please try a pure vanilla FSF gcc-4.8.3, and then a likewise
> > vanilla gcc-4.9.1.  If those also cause the malfunction, then you have
> > proof for a bug in upstream gcc (or possibly undefined code in the kernel),
> > otherwise the bug is likely Linaro's.
> 
> Thanks. I will try to build gcc-4.8.3 from vanilla FSF sources and try to
> reproduce the problem there. Do you think there is a chance this is still a
> kernel bug?
> I have assembly output of both working and broken cases (inlined and
> non-inlined function). I can post them here or send to anyone who wants to
> try to make sense of it....

This is getting weird:

I have build both vanilla FSF toolchains: binutils-2.24 with gcc-4.8.3 and
gcc-4.9.1

I can't quite make sense of the results, other than that there is a
race-condition in the Linux kernel fec_main.c:

gcc-4.8.3 with -O2: fails the same as with OSELAS.Toolchain/linaro gcc-4.8.3

gcc-4.8.3 with -Os: Seems to work correctly

gcc-4.9.1 with -O2: Loses packets, but much less often than with gcc-4.8.3 -O2

gcc-4.9.1 with -Os: Fails even worse than with gcc-4.8.3 -O2

Any suggestion on how to make sense of this?
For me this looks slightly more like a kernel bug than a compiler bug...

> >  > Compiling with -O2 breaks the code, while -Os seems to produce a
> >  > correctly working kernel.
> >  > 
> >  > I decided to make changes to the code and see if I could find other ways
> >  > to "fix" the problem, and I got the following result:
> >  > 
> >  > The above mentioned patch introduces the static function
> >  > fec_enet_hwtstamp() near line 1068 of fec_main.c. If I make an exact
> >  > copy of this function, where I only change the name (e.g.
> >  > fec_enet_hwtstamp2), and change one of the two places this function is
> >  > called to instead use the other name, GCC inlines both copies and the
> >  > problem disappears!
> >  > 
> >  > Since I am not very good at GCC internals nor do I know this piece of
> >  > code in fec_main.c very well, I am asking here for help in hunting down
> >  > the real bug, which I suspect is in GCC... but I want to know for sure.
> >  > 

Best regards,

-- 
David Jander
Protonic Holland.
