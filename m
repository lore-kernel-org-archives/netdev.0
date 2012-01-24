From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net V4 1/2] igb: add PTP Hardware Clock code
Date: Tue, 24 Jan 2012 18:44:07 +0100
Message-ID: <20120124174405.GA2149@netboy.at.omicron.at>
References: <cover.1327161325.git.richardcochran@gmail.com>
 <40a74998520e385c2c690b85fd309ca59590ae75.1327161325.git.richardcochran@gmail.com>
 <02874ECE860811409154E81DA85FBB58040BDD@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:58272 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757167Ab2AXRoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 12:44:24 -0500
Received: by eaac13 with SMTP id c13so1196907eaa.19
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2012 09:44:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <02874ECE860811409154E81DA85FBB58040BDD@ORSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2012 at 06:39:44PM +0000, Keller, Jacob E wrote:

> > +static int ptp_82576_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
> > +{
> > +	u64 rate;
> > +	u32 incvalue;
> > +	int neg_adj = 0;
> > +	struct igb_adapter *igb = container_of(ptp, struct igb_adapter, caps);
> > +	struct e1000_hw *hw = &igb->hw;
> > +
> > +	if (ppb < 0) {
> > +		neg_adj = 1;
> > +		ppb = -ppb;
> > +	}
> > +	rate = ppb;
> > +	rate <<= 14;
> > +	rate = div_u64(rate, 1953125);
> > +
> 
> So is the rate ppb accumulating? I was under the impression that it
> calculated from the current clock frequency so it would need to be
> applied to the current incvalue, not the base... Is this not the
> case? What was the intention of the ppb?

The ppb is simply the desired rate offset in parts per billion. It is
not a delta from the current offset, but rather fixed from the clock's
nominal frequency. This comes from the NTP timex.freq field (but the
unit here is ppb, timex.freq is ppm with a 16 bit fraction.)

If the clock servo is a typical PI controller for example, then the
servo output already represents the accumulated offset.

> > +	incvalue = 16 << IGB_82576_TSYNC_SHIFT;
> > +
> > +	if (neg_adj)
> > +		incvalue -= rate;
> > +	else
> > +		incvalue += rate;
> > +
> > +	wr32(E1000_TIMINCA, INCPERIOD_82576 | (incvalue & INCVALUE_82576_MASK));
> > +
> > +	return 0;
> > +}

> > +		/* Dial the nominal frequency. */
> > +		wr32(E1000_TIMINCA, INCPERIOD_82576 | INCVALUE_82576);
> > +		break;
> > +
> 
> It would be good to check whether the link speed has an impact on
> the SYSTIME register rate. I know on the 10 Gb parts the systime
> registers are driven by the DMA clock which is partitioned
> differently at slower speeds so the values have to be updated
> whenever the link speed changes..

If this is true for 82576, then it certainly is not documented. I
don't have that card, so maybe someone from Intel can answer this?

I think the documentation for the 82580 is clear about the basic rate
always being the same.

Thanks,
Richard
