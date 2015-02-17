From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v2 1/3] Ethernet packet sniffer: Device tree binding and
 vendor prefix
Date: Tue, 17 Feb 2015 16:35:27 +0000
Message-ID: <20150217163527.GR8994@leverpostej>
References: <cover.1424181053.git.stathis.voukelatos@linn.co.uk>
 <0a86907642a97e5bd880f69299664232fcffaf9d.1424181053.git.stathis.voukelatos@linn.co.uk>
 <20150217145124.GM8994@leverpostej>
 <54E36AAC.7010308@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"abrestic@chromium.org" <abrestic@chromium.org>
To: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54E36AAC.7010308@linn.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 17, 2015 at 04:22:04PM +0000, Stathis Voukelatos wrote:
> Hi Mark,
> 
> On 17/02/15 14:51, Mark Rutland wrote:
> 
> >> +Matched packet bytes and timestamp values are returned through a
> >> +FIFO. Timestamps are provided to the module through an externally
> >> +generated Gray-encoded counter.
> >
> > Does this counter unit need to be enabled (or have any input clocks
> > enabled)?
> >
> 
> Yes it does, that is the purpose of the 'tstamp' entry in the
> 'clock-names' property below.

Ah, I see.

> >> +
> >> +Required properties:
> >> +- compatible : must be "linn,eth-sniffer"
> >
> > Is there not a more precise name for this IP block?
> 
> It is generally called 'ethernet packet sniffer', maybe
> linn,eth-packet-sniffer would be a more descriptive name?

Either way is fine. I was expecting something more like a product code.

[...]

> >> +- fifo-block-words : number of words in one data FIFO entry
> >
> > I didn't see a data FIFO described. Is that dynamically allocated and
> > handed to the sniffer, or does that correspond to one of the memory
> > regions above?
> >
> 
> It is a H/W FIFO internal to the module and accessed through
> a register. It is divided in blocks and 'fifo-block-words'
> specify the number of words in each block. It is needed by
> the driver to make sure it reads an entire block, in order
> to clear the 'data available' interrupt.

I see. I assumed that the FIFO was memory mapped rather than exposed
through a register.

Given the above this sounds fine.

> >> +- tstamp-hz : frequency of the timestamp counter

Is this the frequency the clock is running at, or a frequency that it
should be programmed to in order to be used?

The former can be queried from the common clock framework, and if you
intended the latter the wording shuold be a little more explicit about
that being the case.

> >> +- tstamp-shift : shift value for the timestamp cyclecounter struct
> >
> > What exactly is this used for?
> >
> > Are there any docs?
> 
> See: include/linux/clocksource.h
> The driver uses a cyclecounter and timecounter to convert raw timestamps
> to nanoseconds. 'tstamp-shift' refers to the 'shift' field of the
> cyclecounter structure, that can be used to improve the precision of
> the conversion

Sure, but the very concept of a cyclecounter is a Linux implementation
detail. If we have the frequency of the timer we should be able to
dynamically generate this, so there's no need for this to be in the DT.

> >> +- tstamp-bits : width in bits of the timestamp counter
> >> +
> >> +Example:
> >> +
> >> +sniffer@1814a000 {
> >> +	compatible = "linn,eth-sniffer";
> >> +	reg = <0x1814a000 0x100>, <0x1814a400 0x400>,
> >> +	      <0x1814a800 0x400>;
> >> +	reg-names = "regs", "tx-ram", "rx-ram";
> >> +	interrupts = <GIC_SHARED 58 IRQ_TYPE_LEVEL_HIGH>;
> >> +	clocks = <&clk_core CLK_AUDIO>,
> >> +		 <&cr_periph SYS_CLK_EVENT_TIMER>;
> >> +	clock-names = "sys", "tstamp";
> >> +	fifo-block-words = <4>;
> >> +	tstamp-hz = <52000000>;
> >> +	tstamp-shift = <27>;
> >> +	tstamp-bits = <30>;
> >
> > This property wasn't documented.
> >
> > As mentioned previously, I think the relation between this unit and the
> > MAC and/or PHY needs to be explicitly described in the DT.
> 
> Do you suggest a field along the lines of:
> mac = <&eth_controller_0>;
> The driver could check that it exists and is valid but does
> not need to make use of it.

I would expect some level of the software stack to make use of it, or
you have no idea which ethernet interface is related to this monitoring
interface. Perhaps current systems only have one interface, but that
shouldn't be relied upon.

Thanks,
Mark.
