From: Darren Hart <dvhart@linux.intel.com>
Subject: Re: [PATCH 3/3] pch_gbe: Add MinnowBoard support
Date: Sat, 13 Jul 2013 09:08:01 -0700
Message-ID: <1373731681.3475.113.camel@envy.home>
References: <ce5dd365d05f8747d269aa74e0bb929935d9cdee.1373676797.git.dvhart@linux.intel.com>
	 <ad20133699c36bd8d183dd685f1b35f6d6b99005.1373676797.git.dvhart@linux.intel.com>
	 <20130713011731.GA17939@kroah.com> <1373694381.3475.95.camel@envy.home>
	 <20130713062631.GB15155@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130713062631.GB15155@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-07-12 at 23:26 -0700, Greg KH wrote:
> On Fri, Jul 12, 2013 at 10:46:21PM -0700, Darren Hart wrote:
> > On Fri, 2013-07-12 at 18:17 -0700, Greg KH wrote:
> > > On Fri, Jul 12, 2013 at 05:58:07PM -0700, Darren Hart wrote:
> > > > The MinnowBoard uses an AR803x PHY with the PCH GBE which requires
> > > > special handling. Use the MinnowBoard PCI Subsystem ID to detect this
> > > > and add a pci_device_id.driver_data structure and functions to handle
> > > > platform setup.
> > > > 
> > > > The AR803x does not implement the RGMII 2ns TX clock delay in the trace
> > > > routing nor via strapping. Add a detection method for the board and the
> > > > PHY and enable the TX clock delay via the registers.
> > > > 
> > > > This PHY will hibernate without link for 10 seconds. Ensure the PHY is
> > > > awake for probe and then disable hibernation. A future improvement would
> > > > be to convert pch_gbe to using PHYLIB and making sure we can wake the
> > > > PHY at the necessary times rather than permanently disabling it.
> > > > 
> > > > Signed-off-by: Darren Hart <dvhart@linux.intel.com>
> > > > Cc: "David S. Miller" <davem@davemloft.net>
> > > > Cc: "H. Peter Anvin" <hpa@zytor.com>
> > > > Cc: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> > > > Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> > > > Cc: netdev@vger.kernel.org
> > > > Cc: <stable@vger.kernel.org> # 3.8.x: 5829e9b mfd: lpc_sch: Accomodate partial
> > > > Cc: <stable@vger.kernel.org> # 3.8.x: 3cbf182 gpio-sch: Allow for more than 8
> > > > Cc: <stable@vger.kernel.org> # 3.8.x: 91bbe92: PCI: Add CircuitCo vendor ID
> > > > Cc: <stable@vger.kernel.org> # 3.8.x: bd79680: pch_gbe: remove inline keyword
> > > > Cc: <stable@vger.kernel.org> # 3.8.x: 453ca93: pch_gbe: convert pr_* to
> > > > Cc: <stable@vger.kernel.org> # 3.8.x: 29cc436: pch_gbe: use managed functions
> > > > Cc: <stable@vger.kernel.org> # 3.8.x
> > > > Cc: <stable@vger.kernel.org> # 3.10.x: 91bbe92: PCI: Add CircuitCo vendor ID
> > > > Cc: <stable@vger.kernel.org> # 3.10.x: bd79680: pch_gbe: remove inline keyword
> > > > Cc: <stable@vger.kernel.org> # 3.10.x: 453ca93: pch_gbe: convert pr_* to
> > > > Cc: <stable@vger.kernel.org> # 3.10.x: 29cc436: pch_gbe: use managed functions
> > > > Cc: <stable@vger.kernel.org> # 3.10.x
> > > > Signed-off-by: Darren Hart <dvhart@linux.intel.com>
> > > > ---
> > > >  drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    | 15 ++++
> > > >  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 48 +++++++++++
> > > >  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c    | 98 ++++++++++++++++++++++
> > > >  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h    |  2 +
> > > >  4 files changed, 163 insertions(+)
> > > 
> > > This is _far_ more than just a simple "add a new device id" for a stable
> > > kernel update.   Please go read Documentation/stable_kernel_rules.txt
> > > again for why there's no way I can take this type of thing.
> > >
> > > You know better than this.
> > 
> > I do appreciate the documentation that is there, and I have read it
> > (several times). The first two for 3.8 should be acceptable.
> 
> I didn't even look at those other patches (and hint, 3.8 is dead and
> burried, no stable releases are happening for it that really matter.)
> 
> I'm talking about _this_ patch.  Look at it.  How big it is.  How it's
> not just "add a new device id."  Now please explain how _this_ patch
> meets the stable kernel rules as documented?  Let alone the pr_*
> conversions, ick, don't get me started...

I was looking at it as a quirk:

" - New device IDs and quirks are also accepted."

I even considered implementation as a pci quirk. I didn't because the
PHY work needed to happen too late during probe. The frustrating thing
is there is probably 15 lines of code that are needed to get it to
work, all the rest is infrastructure to make it generic.

I get the size argument. It's too big. The docs say 100 lines with
context, I've seen much larger go in... I just wasn't sure where the
line is. It seems things are getting more strict here, not less. OK.
Lesson learned.


> Would you really send something like this to Linus after -rc4?  If not,
> then it's not a stable patch.  See the 3.10.1-rc1 thread on lkml for the
> details as to why I now need to push back and be harsher for this.

Wow, good thread. I don't appear to be the only one unsure of the
rules. I'll keep watching that thread for a definitive policy as you
and Linus do appear to be saying slightly different things.

> Just have users use 3.11, it's not like you have shipping hardware yet,

We're talking days here, but yes.

> and again, who cares about 3.8.  Heck, who cares about 3.9 or even 3.10
> for brand-new hardware.  Just use 3.11 or 3.12 and don't worry about
> backport hell.
> 
> This isn't going to land in Linus's tree until 3.12 anyway, so what's
> the rush?

My reasoning is that the BSP for this is based on 3.8. I would like to
bring 3.8 in sync with master for support of this board so I can update
the release BSP to use the same sources. People can use my code from
the linux-yocto_3.8 standard/minnow branch, but it would be preferable
if that code was also destined for upstream. Not the end of the world,
and I certainly don't mind directing people to 3.12 and ensuring the
next BSP release is fully aligned with mainline. And yes, none of the
above qualifies it for stable - it's only the "and quirks" that I felt
qualified this patch for stable, and I recognize it as a "freakish
giant" of a patch for stable. See, I really did read that entire
thread.

If you still feel this doesn't qualify as a "quirk", I'll drop the
stable push. If you can see that argument, I can look at breaking it up
into smaller chunks, or possibly reducing some of the generic bits and
doing the bare minimum to get it working and follow-up in master with
more generic bits.

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Technical Lead - Linux Kernel
