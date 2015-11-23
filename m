From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: What's the benefit of large Rx rings?
Date: Mon, 23 Nov 2015 07:16:25 -0800
Message-ID: <CAKgT0Uem9MdrtJTA1gsoz2D_Fy2N2CdZq5ufdXBs7zsYkLMo-Q@mail.gmail.com>
References: <CO2PR11MB008832EB5323120812FFDAF597180@CO2PR11MB0088.namprd11.prod.outlook.com>
	<CAKgT0UeiuMM-AV=_6sGob6_mLS5F_dO47AQou8bo8Z1AoqNCxQ@mail.gmail.com>
	<CO2PR11MB00887B710566F1CBEFDF837D97070@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:34142 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485AbbKWPQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 10:16:26 -0500
Received: by ioir85 with SMTP id r85so189903701ioi.1
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 07:16:25 -0800 (PST)
In-Reply-To: <CO2PR11MB00887B710566F1CBEFDF837D97070@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 22, 2015 at 8:47 PM, Yuval Mintz <Yuval.Mintz@qlogic.com> wrote:
>>> This might be a dumb question, but I recently touched this
>>> and felt like I'm missing something basic -
>>>
>>> NAPI is being scheduled from soft-interrupt contex, and it
>>> has a ~strict quota for handling Rx packets [even though we're
>>> allowing practically unlimited handling of Tx completions].
>>> Given these facts, what's the benefit of having arbitrary large
>>> Rx buffer rings? Assuming quota is 64, I would have expected
>>> that having more than twice or thrice as many buffers could not
>>> help in real traffic scenarios - in any given time-unit
>>> [the time between 2 NAPI runs which should be relatively
>>> constant] CPU can't handle more than the quota; If HW is
>>> generating more packets on a regular basis the buffers are bound
>>> to get exhausted, no matter how many there are.
>>>
>>> While there isn't any obvious downside to allowing drivers to
>>> increase ring sizes to be larger [other than memory footprint],
>>> I feel like I'm missing the scenarios where having Ks of
>>> buffers can actually help.
>>> And for the unlikely case that I'm not missing anything,
>>> why aren't we supplying some `default' max and min amounts
>>> in a common header?
>
>> The main benefit of large Rx rings is that you could theoretically
>> support longer delays between device interrupts.  So for example if
>> you have a protocol such as UDP that doesn't care about latency then
>> you could theoretically set a large ring size, a large interrupt delay
>> and process several hundred or possibly even several thousand packets
>> per device interrupt instead of just a few.
>
> So we're basically spending hundred of MBs [at least for high-speed
> ethernet devices] on memory that helps us mostly on the first
> coalesced interrupt [since later it all goes through napi re-scheduling]?
> Sounds a bit... wasteful.

The hundreds of MBs might be stretching it a bit.  It is most likely
more like tens of MBs, not hundreds.  For example the ixgbe driver
uses 512 buffers for Rx by default.  Each Rx buffer is 4K so that
comes out to only 2MB per ring.  Other than that there are 8K worth of
descriptors and another 12K worth of buffer info data.

It all depends on priorities.  You could decrease the delay between
interrupts and reduce the Rx ring size but it means for a lightly
loaded system you may see significantly higher CPU utilization.

Another thing to keep in mind is for things like virtualization the
interrupt latency is increased and as a result you need more buffering
to allow for the greater delay between the IRQ and when the NAPI
instance in the guest actually begins polling.

- Alex
