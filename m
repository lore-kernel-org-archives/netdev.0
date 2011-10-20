From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net-next 5/6] ixgbe: add hardware timestamping support
Date: Thu, 20 Oct 2011 12:57:44 -0700
Message-ID: <1449E6FE3B0E264D9C4EAC778E68775701445683CA@orsmsx502.amr.corp.intel.com>
References: <1318854062-3628-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1318854062-3628-6-git-send-email-jeffrey.t.kirsher@intel.com>
 <20111017164433.GA2028@netboy.at.omicron.at>
 <CA+P7+xoP7VE0FEKnLCbzygw499xLr1PFynPn6W0+ud6KwZHgEg@mail.gmail.com>
 <20111020145637.GC1949@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>,
	Jacob Keller <jacob.keller@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6136 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752420Ab1JTT55 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 15:57:57 -0400
In-Reply-To: <20111020145637.GC1949@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Thursday, October 20, 2011 7:57 AM
> To: Jacob Keller
> Cc: Kirsher, Jeffrey T; davem@davemloft.net; Keller, Jacob E;
> netdev@vger.kernel.org; gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 5/6] ixgbe: add hardware timestamping support
> 
> On Wed, Oct 19, 2011 at 10:04:33AM -0700, Jacob Keller wrote:
> > On Mon, Oct 17, 2011 at 9:44 AM, Richard Cochran
> <richardcochran@gmail.com> wrote:
> > > So, is this wrap around due to the fact that you are tied to the
> > > system time via time_compare? Or, putting it another way, can't you
> > > program the hardware time stamping unit so that the registers have
> > > some reasonable resolution (like 64 bits worth of nanoseconds) and
> > > just offer RAW timestamps?
> >
> > The wrap around is due to hardware limitations. The ixgbe devices
> > cannot support 64bits worth of nanoseconds and still have the ability
> > to adjust the frequency in parts per billion. A larger increment
> > increases the resolution available for frequency adjustments, but
> > decreases the time it takes for the cycle counter to wrap around.
> 
> Oh, well. That stinks.
> 
> I think you do want to offer ppb adjustment.
> 
Correct, which is why the cycle counter wraps around every 35 seconds.

> > > I would really like to move away from the timecompare hacks and
> > > towards a proper PHC->SYS PPS solution.
> > >
> >
> > I agree that this is the correct approach. The timecompare
> > functionality does have issues.
> 
> And these cards are highlighting timecompare weaknesses I had not even
> thought of.
> 
> I expect that if you offer the RAW time stamps, then it should be
> possible to have the time stamp values always correct (or nearly so)
> even with a changing link speed. If the link speed change gives an
> interrupt, then the ISR can reprogram the frequency compensation
> registers and let the counter continue.
> 

The cyclecounter is based off of the DMA clock on the NIC which changes frequency with the link speed. So at 10G link, the DMA ticks once every 6.4ns. The cycle counter gets a value (specified in the TIMINCA register) added to it every DMA tick. In order to allow for ppb adjustments to the cycle counter, I have the TIMINCA value be as many bits wide as possible. Then I use the cyclecounter/timecounter structures to detect wraparound and convert to a ns value.

If we return the raw cycle counter stamps directly, they would not be measured in nanoseconds, but in a division of the DMA clock tick (DMA clock tick / TIMINCA value). This means for the values I chose we are somewhere in the range of femto seconds or so. The problem is that all of the upper stack expects values as nanoseconds. We wouldn't be able to frequency adjust in ppb to get down to nanoseconds again.

This is due to a limitation in the way the hardware was designed, (Ideally it would allow for precise adjustments, but still provide a nanosecond counter. The 82580 igb device does this.)

> > > Again, doing the update thing on every packet won't work for real
> > > world PTP scenarios.
> > >
> > Which is why the PHC solution is better. Work on implementing this
> > support is in progress. Out of curiosity, what is the sync rate for
> > the scenario that breaks this? I would like to try that rate out on
> my
> > setup.
> 
> For the audio/video profile, they have a max of 32 sync packets per
> second. Not sure about delay request rate, maybe 16 per second.
> 

Thanks :)

> Thanks,
> Richard
