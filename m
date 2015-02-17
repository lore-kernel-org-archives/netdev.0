From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v2 1/3] Ethernet packet sniffer: Device tree binding and
 vendor prefix
Date: Tue, 17 Feb 2015 17:30:00 +0000
Message-ID: <20150217173000.GT8994@leverpostej>
References: <cover.1424181053.git.stathis.voukelatos@linn.co.uk>
 <0a86907642a97e5bd880f69299664232fcffaf9d.1424181053.git.stathis.voukelatos@linn.co.uk>
 <20150217145124.GM8994@leverpostej>
 <54E36AAC.7010308@linn.co.uk>
 <20150217163527.GR8994@leverpostej>
 <54E376AF.80602@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"abrestic@chromium.org" <abrestic@chromium.org>
To: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54E376AF.80602@linn.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 17, 2015 at 05:13:19PM +0000, Stathis Voukelatos wrote:
> Hi Mark,
> 
> On 17/02/15 16:35, Mark Rutland wrote:
> >
> >>>> +- tstamp-hz : frequency of the timestamp counter
> >
> > Is this the frequency the clock is running at, or a frequency that it
> > should be programmed to in order to be used?
> >
> > The former can be queried from the common clock framework, and if you
> > intended the latter the wording shuold be a little more explicit about
> > that being the case.
> >
> 
> It is the frequency of the timestamp values supplied to the sniffer
> module. It is used by the driver to convert to nanoseconds.
> I was trying to be somewhat generic here and not assume that it
> is necessarily the same as the 'tstamp' clock below, in which case we
> could indeed obtain it using the common clock framework.

In what cases would it _not_ be the same? From your description this is
that clock, no?

> >> See: include/linux/clocksource.h
> >> The driver uses a cyclecounter and timecounter to convert raw timestamps
> >> to nanoseconds. 'tstamp-shift' refers to the 'shift' field of the
> >> cyclecounter structure, that can be used to improve the precision of
> >> the conversion
> >
> > Sure, but the very concept of a cyclecounter is a Linux implementation
> > detail. If we have the frequency of the timer we should be able to
> > dynamically generate this, so there's no need for this to be in the DT.
> >
> 
> Most networking driver use hard-coded values for that, but in my case
> I did not want to assume a certain fixed clock frequency. I will remove
> it from the DT and generate it dynamically. There is a kernel function
> clocks_calc_mult_shift() to do it but unfortunately it is not exported,
> so I guess I will need to replicate the code.

Or submit a patch exporting it, along with the rationale for doing so?

> >>> As mentioned previously, I think the relation between this unit and the
> >>> MAC and/or PHY needs to be explicitly described in the DT.
> >>
> >> Do you suggest a field along the lines of:
> >> mac = <&eth_controller_0>;
> >> The driver could check that it exists and is valid but does
> >> not need to make use of it.
> >
> > I would expect some level of the software stack to make use of it, or
> > you have no idea which ethernet interface is related to this monitoring
> > interface. Perhaps current systems only have one interface, but that
> > shouldn't be relied upon.
> 
> Yes, but the sniffer module is hard-wired to a certain Ethernet Mii
> interface. We can add an entry to tie it to an Ethernet controller, but
> apart of a sanity check I am not sure what else the S/W can do.

Fundamentally, the use-case for this is monitoring an ethernet
interface. So regardless of which kernel framework this plumbs into,
there needs to be a way to go from ethN to whatever this is exposed as.

Exposing a completely separate interface makes no sense. Singleton stuff
like that inevitably gets broken as someone later builds a board with
multiple instances of some similar IP block.

So I would imagine that either the link between interface and monitoring
interface would be described somewhere in the filesystem, or there'd be
a syscall/ioctl/whatever to go from an interface to the appropriate
monitoring interface.

That all depends on exactly how this gets exposed in the end, however.

Thanks,
Mark.
