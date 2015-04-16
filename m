From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: ioremap_uc() followed by set_memory_wc() - burrying MTRR
Date: Thu, 16 Apr 2015 20:54:26 +0200
Message-ID: <20150416185426.GH5622@wotan.suse.de>
References: <1428695379.6646.69.camel@misato.fc.hp.com>
 <20150410210538.GB5622@wotan.suse.de>
 <1428699490.21794.5.camel@misato.fc.hp.com>
 <CALCETrUP688aNjckygqO=AXXrNYvLQX6F0=b5fjmsCqqZU78+Q@mail.gmail.com>
 <20150411012938.GC5622@wotan.suse.de>
 <CALCETrXd19C6pARde3pv-4pt-i52APtw5xs20itwROPq9VmCfg@mail.gmail.com>
 <20150413174938.GE5622@wotan.suse.de>
 <1429137531.1899.28.camel@palomino.walls.org>
 <20150415235816.GG5622@wotan.suse.de>
 <20150416041837.GA5712@hykim-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Walls <awalls@md.metrocast.net>,
	Hyong-Youb Kim <hykim@myri.com>, netdev@vger.kernel.org,
	Andy Lutomirski <luto@amacapital.net>,
	Toshi Kani <toshi.kani@hp.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>,
	linux-kernel@vger.kernel.org,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Suresh Siddha <sbsiddha@gmail.com>,
	Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Roland Dreier <roland@purestorage.com>,
	Juergen Gross <jgross@suse.com>,
	Mauro Carvalho Chehab <mchehab@osg.samsung.com>,
	Borislav Petkov <bp@suse.de>, Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	Davidlohr Bueso <dbueso@suse.de>,
	Johannes Berg <johannes@sipsolutions.net>,
	Felix Fietkau <nbd@openwrt.org>,
	Benjamin Poirier <bpoirier@suse.de>,
	dave.hansen@linux.intel.com,
To: Hyong-Youb Kim <hkim@cspi.com>
Return-path: <linux-media-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150416041837.GA5712@hykim-PC>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 16, 2015 at 01:18:37PM +0900, Hyong-Youb Kim wrote:
> On Thu, Apr 16, 2015 at 01:58:16AM +0200, Luis R. Rodriguez wrote:
> > 
> > An alternative... is to just ioremap_wc() the entire region, including
> > MMIO registers for these old devices. I see one ethernet driver that does
> > this, myri10ge, and am curious how and why they ended up deciding this
> > and if they have run into any issues. I wonder if this is a reasonable
> > comrpomise for these 2 remaining corner cases.
> > 
> 
> For myri10ge, it a performance thing.  Descriptor rings are in NIC
> memory BAR0, not in host memory.  Say, to send a packet, the driver
> writes the send descriptor to the ioremap'd NIC memory.  It is a
> multi-word descriptor.  So, to send it as one PCIE MWr transaction,
> the driver maps the whole BAR0 as WC and does "copy descriptor; wmb".

Interesting, so you burst write multi-word descriptor writes using
write-combining here for the Ethernet device.

> Without WC, descriptors would end up as multiple 4B or 8B MWr packets
> to the NIC, which has a pretty big performance impact on this
> particular NIC.

How big are the descriptors?

> Most registers that do not want WC are actually in BAR2, which is not
> mapped as WC.  For registers that are in BAR0, we do "write to the
> register; wmb".  If we want to wait till the NIC has seen the write,
> we do "write; wmb; read".

Interesting, thanks, yeah using this as a work around to the problem sounds
plausible however it still would require likely making just as many changes to
the ivtv and ipath driver as to just do a proper split. I do wonder however if
this sort of work around can be generalized somehow though so that others could
use, if this sort of thing is going to become prevalent. If so then this would
serve two purposes: work around for the corner cases of MTRR use on Linux and
also these sorts of device constraints.

In order to determine if this is likely to be generally useful could you elaborate
a bit more about the detals of the performance issues of not bursting writes
for the descriptor on this device.

Even if that is done a conversion over to this work around seems it may require
device specific nitpicks. For instance I note in myri10ge_submit_req() for
small writes you just do a reverse write and do the first set last, then
finally the last 32 bits are rewritten, I guess to trigger something?

> This approach has worked for this device for many years.  I cannot say
> whether it works for other devices, though.

I think it should but the more interesting question would be exactly
*why* it was needed for this device, who determined that, and why?

  Luis
