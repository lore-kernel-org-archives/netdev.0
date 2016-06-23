From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Thu, 23 Jun 2016 16:20:31 -0700
Message-ID: <CAKgT0UfPFsv6aH9aQQPD3gZ_0netSS85-mNLnb1bGjvtdyu6fw@mail.gmail.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
 <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
 <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <576B08A2.8080603@hpe.com> <1466635664.6850.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UdbPVqpSVLs0JW7zFU7mNtJn5BM+fMjsr1tLm4kHRcW9A@mail.gmail.com>
 <1466638292.6850.94.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0Uex41aBJX84we2gxNGw6M4s5xGEPnDkGehTZkEE+i+Jhw@mail.gmail.com>
 <CO2PR11MB0088B3C577EC110B845C17B3972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CO2PR11MB0088949623FA99ED86D33205972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0Uc7cCu-5SwrB+4Mv6OM+V1jDwefOoG-Wr61C4F1g1BmFA@mail.gmail.com> <CO2PR11MB00884BBC91DE36D3FA78796C972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hpe.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:33999 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155AbcFWXUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 19:20:33 -0400
Received: by mail-io0-f180.google.com with SMTP id g13so78708282ioj.1
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 16:20:33 -0700 (PDT)
In-Reply-To: <CO2PR11MB00884BBC91DE36D3FA78796C972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 23, 2016 at 2:06 PM, Yuval Mintz <Yuval.Mintz@qlogic.com> wrote:
>>>> Then again, if you're basically saying every HW-assisted offload on
>>>> receive should be done under LRO flag, what would be the use case
>>>> where a GRO-assisted offload would help?
>>>> I.e., afaik LRO is superior to GRO in `brute force' -
>>>> it creates better packed packets and utilizes memory better
>>>> [with all the obvious cons such as inability for defragmentation].
>>>> So if you'd have the choice of having an adpater perform 'classic'
>>>> LRO aggregation or something that resembles a GRO packet,
>>>> what would be the gain from doing the latter?
>
>> LRO and GRO shouldn't really differ in packing or anything like that.
>> The big difference between the two is that LRO is destructive while
>> GRO is not.  Specifically in the case of GRO you should be able to
>> take the resultant frame, feed it through GSO, and get the original
>> stream of frames back out.  So you can pack the frames however you
>> want the only key is that you must capture all the correct offsets and
>> set the gso_size correct for the flow.
>
> While the implementation might lack in things [such as issues with
> future implementation], following your logic it is GRO - I.e., forwarding
> scenarios work fine with HW assisted GRO.
>
>>> Just to relate to bnx2x/qede differences in current implementation -
>>> when this GRO hw-offload was added to bnx2x, it has already
>>> supported classical LRO, and due to above statement whenever LRO
>>> was set driver aggregated incoming traffic as classic LRO.
>>> I agree that in hindsight the lack of distinction between sw/hw GRO
>>> was hurting us.
>
>> In the case of bnx2x it sounds like you have issues that are
>> significantly hurting the performance versus classic software GRO.  If
>> that is the case you might want to simply flip the logic for the
>> module parameter that Rick mentioned and just disable the hardware
>> assisted GRO unless it is specifically requested.
>
> A bit hard to flip; The module parameter also disables LRO support.
> And given that module parameters is mostly a thing of the past, I
> don't think we should strive fixing things through additional changes
> in that area.
>
>> > qede isn't implementing LRO, so we could easily mark this feature
>> > under LRO there - but question is, given that the adapter can support
>> > LRO, if we're going to suffer from all the shotrages that arise from
>> > putting this feature under LRO, why should we bother?
>
>> The idea is to address feature isolation.  The fact is the hardware
>> exists outside of kernel control.  If you end up linking an internal
>> kernel feature to your device like this you are essentially stripping
>> the option of using the kernel feature.
>
>> I would prefer to see us extend LRO to support "close enough GRO"
>> instead of have us extend GRO to also include LRO.
>
> Again - why? What's the benefit of HW doing LRO and trying to
> control imitate GRO, if it's still carrying all the LRO baggage
> [specifically, disabling it on forwarding] as opposed to simply
> doing classic LRO?

In most cases that is all LRO is.  LRO is trying to do the best it can
to emulate GRO.  The reason why it was pushed off into a separate
feature bit is that it never quite works out that way and most vendors
end up with something that comes close but is always missing a few
items.

The "hardware assisted GRO" is really nothing more than a marketing
term and a justification to ignore the fact that we should probably be
disabling it when routing or bridging is enabled.  What you are doing
is LRO but using the wrong bit to test for the feature.  We already
know of one firmware bug you guys have which makes it clear that the
bnx2x is not doing hardware assisted GRO it is doing something else
since it performs much worse than GRO if the MSS is less than what it
would be based on the MTU.

>> > You can argue that we might need a new feature bit for control
>> > over such a feature; If we don't do that, is there any gain in all of this?
>
>> I would argue that yes there are many cases where we will be able to
>> show gain.  The fact is there is a strong likelihood of the GRO on
>> your parts having some differences either now, or at some point in the
>> future as the code evolves.  As I mentioned there was already some
>> talk about possibly needing to push the UDP tunnel aggregation out of
>> GRO and perhaps handling it sometime after IP look up had verified
>> that the destination was in fact a local address in the namespace.  In
>> addition it makes the changes to include the tunnel encapsulation much
>> more acceptable as LRO is already naturally dropped in the routing and
>> bridging cases if I recall correctly.
>
> I think it all boils down to the question of "do we actually want to have
> HW-assisted GRO?". If we do [and not necessarily for the UDP-tunnel
> scenario] then we need to have it distinct from LRO, otherwise there's
> very little gain. If we believe tGRO should remain SW-only, then
> I think the discussion is mott; We need to stop trying this, and offload
> only LRO - in which case we can aggregate it in whichever 'destructive'
> [correct] format we like, without trying to have it resemble GRO.

I believe GRO should be software only.  The LRO feature is meant to
represent hardware assisted aggregation.  If you want to take steps to
define it further or reduce the limitations so that it is not disabled
when routing or bridging is enabled for a device I would be fine with
that.

One of the reasons why LRO is disabled by default for routing and
bridging is because the feature has always been somewhat poorly
defined and resulted in us getting all sort of frames, some that were
route-able and some that weren't.  Arguably your hardware is on the
better end of this but it is still not without its issues. Perhaps
this might be an opportunity to go through and redefine what LRO is so
that we can make better use of it like we did with the ntuple/nfc
stuff a few years ago.  Then it would be easier to go through and make
it programmable so we can do things like turn on and off tunnel
offloads, maybe IPv4/IPv6 support, and perhaps have a flag for
identifying GRO like LRO versus everything else.  That way the end
user has more control over the configuration and can pick and choose
what they want.

- Alex
