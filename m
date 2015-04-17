From: Hyong-Youb Kim <hkim@cspi.com>
Subject: Re: ioremap_uc() followed by set_memory_wc() - burrying MTRR
Date: Fri, 17 Apr 2015 17:00:46 +0900
Message-ID: <20150417080046.GA4620@hykim-PC>
References: <20150410210538.GB5622@wotan.suse.de>
 <1428699490.21794.5.camel@misato.fc.hp.com>
 <CALCETrUP688aNjckygqO=AXXrNYvLQX6F0=b5fjmsCqqZU78+Q@mail.gmail.com>
 <20150411012938.GC5622@wotan.suse.de>
 <CALCETrXd19C6pARde3pv-4pt-i52APtw5xs20itwROPq9VmCfg@mail.gmail.com>
 <20150413174938.GE5622@wotan.suse.de>
 <1429137531.1899.28.camel@palomino.walls.org>
 <20150415235816.GG5622@wotan.suse.de>
 <20150416041837.GA5712@hykim-PC>
 <20150416185426.GH5622@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andy Walls <awalls@md.metrocast.net>,
	Hyong-Youb Kim <hykim@myri.com>, <netdev@vger.kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Toshi Kani <toshi.kani@hp.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Suresh Siddha <sbsiddha@gmail.com>,
	Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Roland Dreier <roland@purestorage.com>,
	"Juergen Gross" <jgross@suse.com>,
	Mauro Carvalho Chehab <mchehab@osg.samsung.com>,
	Borislav Petkov <bp@suse.de>, Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	Davidlohr Bueso <dbueso@suse.de>,
	Johannes Berg <johannes@sipsolutions.net>,
	Felix Fietkau <nbd@openwrt.org>,
	"Benjamin Poirier" <bpoirier@suse.de>,
	<dave.hansen@linux.i
To: "Luis R. Rodriguez" <mcgrof@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0137.outbound.protection.outlook.com ([157.56.112.137]:29328
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752157AbbDQIBs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Apr 2015 04:01:48 -0400
Content-Disposition: inline
In-Reply-To: <20150416185426.GH5622@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2015 at 08:54:26PM +0200, Luis R. Rodriguez wrote:
> > Without WC, descriptors would end up as multiple 4B or 8B MWr packets
> > to the NIC, which has a pretty big performance impact on this
> > particular NIC.
> 
> How big are the descriptors?

Some are 64B (a batch of eight 8B descriptors).  Some are 16B.

> > Most registers that do not want WC are actually in BAR2, which is not
> > mapped as WC.  For registers that are in BAR0, we do "write to the
> > register; wmb".  If we want to wait till the NIC has seen the write,
> > we do "write; wmb; read".
> 
> Interesting, thanks, yeah using this as a work around to the problem sounds
> plausible however it still would require likely making just as many changes to
> the ivtv and ipath driver as to just do a proper split. I do wonder however if
> this sort of work around can be generalized somehow though so that others could
> use, if this sort of thing is going to become prevalent. If so then this would
> serve two purposes: work around for the corner cases of MTRR use on Linux and
> also these sorts of device constraints.

These Myricom devices are very non-standard in my opinion, at least in
the Ethernet world.  Few, if any, other devices depend so much on WC
like these do.  I think almost all devices now have rings in host
memory.  The NIC pulls them via DMA.  No need for WC, and no need to
special case registers...

> In order to determine if this is likely to be generally useful could you elaborate
> a bit more about the detals of the performance issues of not bursting writes
> for the descriptor on this device.

For this particular Myricom device, performance penalty stems from the
use of slow path in the firmware.  They are not about how effectively
we use PCI Express or latency or bandwidth.  Small MWr packets end up
casuing slow path processing via the firmware in this device.

There are HPC low latency NICs that use WC for different reasons.  To
reduce latency as much as possible, some of these copy small packets
to the NIC memory via PIO (BAR0, and so on), instead of DMA.  They
want WC mapping to minimize PCI Express packets/transactions.

I do not know about video adapters and their use for WC.

> Even if that is done a conversion over to this work around seems it may require
> device specific nitpicks. For instance I note in myri10ge_submit_req() for
> small writes you just do a reverse write and do the first set last, then
> finally the last 32 bits are rewritten, I guess to trigger something?

Right.  The device polls the last word to start sending, DMA, etc.

> > This approach has worked for this device for many years.  I cannot say
> > whether it works for other devices, though.
> 
> I think it should but the more interesting question would be exactly
> *why* it was needed for this device, who determined that, and why?

Hopefully, the above text answers some of your questions.
