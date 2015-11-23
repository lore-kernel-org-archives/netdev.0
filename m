From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: What's the benefit of large Rx rings?
Date: Mon, 23 Nov 2015 14:48:30 -0200
Message-ID: <20151123164829.GA6114@mrl.redhat.com>
References: <CO2PR11MB008832EB5323120812FFDAF597180@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0UeiuMM-AV=_6sGob6_mLS5F_dO47AQou8bo8Z1AoqNCxQ@mail.gmail.com>
 <CO2PR11MB00887B710566F1CBEFDF837D97070@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0Uem9MdrtJTA1gsoz2D_Fy2N2CdZq5ufdXBs7zsYkLMo-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38774 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754566AbbKWQsc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 11:48:32 -0500
Content-Disposition: inline
In-Reply-To: <CAKgT0Uem9MdrtJTA1gsoz2D_Fy2N2CdZq5ufdXBs7zsYkLMo-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 23, 2015 at 07:16:25AM -0800, Alexander Duyck wrote:
> On Sun, Nov 22, 2015 at 8:47 PM, Yuval Mintz <Yuval.Mintz@qlogic.com> wrote:
> >>> This might be a dumb question, but I recently touched this
> >>> and felt like I'm missing something basic -
> >>>
> >>> NAPI is being scheduled from soft-interrupt contex, and it
> >>> has a ~strict quota for handling Rx packets [even though we're
> >>> allowing practically unlimited handling of Tx completions].
> >>> Given these facts, what's the benefit of having arbitrary large
> >>> Rx buffer rings? Assuming quota is 64, I would have expected
> >>> that having more than twice or thrice as many buffers could not
> >>> help in real traffic scenarios - in any given time-unit
> >>> [the time between 2 NAPI runs which should be relatively
> >>> constant] CPU can't handle more than the quota; If HW is
> >>> generating more packets on a regular basis the buffers are bound
> >>> to get exhausted, no matter how many there are.
> >>>
> >>> While there isn't any obvious downside to allowing drivers to
> >>> increase ring sizes to be larger [other than memory footprint],
> >>> I feel like I'm missing the scenarios where having Ks of
> >>> buffers can actually help.
> >>> And for the unlikely case that I'm not missing anything,
> >>> why aren't we supplying some `default' max and min amounts
> >>> in a common header?
> >
> >> The main benefit of large Rx rings is that you could theoretically
> >> support longer delays between device interrupts.  So for example if
> >> you have a protocol such as UDP that doesn't care about latency then
> >> you could theoretically set a large ring size, a large interrupt delay
> >> and process several hundred or possibly even several thousand packets
> >> per device interrupt instead of just a few.
> >
> > So we're basically spending hundred of MBs [at least for high-speed
> > ethernet devices] on memory that helps us mostly on the first
> > coalesced interrupt [since later it all goes through napi re-scheduling]?
> > Sounds a bit... wasteful.
> 
> The hundreds of MBs might be stretching it a bit.  It is most likely
> more like tens of MBs, not hundreds.  For example the ixgbe driver
> uses 512 buffers for Rx by default.  Each Rx buffer is 4K so that
> comes out to only 2MB per ring.  Other than that there are 8K worth of
> descriptors and another 12K worth of buffer info data.
> 
> It all depends on priorities.  You could decrease the delay between
> interrupts and reduce the Rx ring size but it means for a lightly
> loaded system you may see significantly higher CPU utilization.
> 
> Another thing to keep in mind is for things like virtualization the
> interrupt latency is increased and as a result you need more buffering
> to allow for the greater delay between the IRQ and when the NAPI
> instance in the guest actually begins polling.

There are other factors too that may cause extra processing during that
softirq. If you have netfilter rules, for example, they are processed
in the same SI that is receiving the packets, it's part of it. Then you
can have rules that are check for some packets and rules are skipped,
etc..

Even tcp processing is done at this time, specially if you don't use
RFS. If a given socket starts to get its rx buffer full, it may trigger
a buffer collapse (tcp_collapse()) and will consume an extra cpu time
for that packet only.

But for how big is worth having it, that's a good question, as these
extra processing depends on traffic pattern, CPU model, memory
speed/availability, etc, while NIC line rate may remain nearly constant.

  Marcelo
