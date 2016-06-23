From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Thu, 23 Jun 2016 21:06:20 +0000
Message-ID: <CO2PR11MB00884BBC91DE36D3FA78796C972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
 <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
 <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <576B08A2.8080603@hpe.com>
 <1466635664.6850.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UdbPVqpSVLs0JW7zFU7mNtJn5BM+fMjsr1tLm4kHRcW9A@mail.gmail.com>
 <1466638292.6850.94.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0Uex41aBJX84we2gxNGw6M4s5xGEPnDkGehTZkEE+i+Jhw@mail.gmail.com>
 <CO2PR11MB0088B3C577EC110B845C17B3972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CO2PR11MB0088949623FA99ED86D33205972D0@CO2PR11MB0088.namprd11.prod.outlook.com>,<CAKgT0Uc7cCu-5SwrB+4Mv6OM+V1jDwefOoG-Wr61C4F1g1BmFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hpe.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	"Tom Herbert" <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0115.outbound.protection.outlook.com ([157.56.111.115]:21174
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751646AbcFWVGY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 17:06:24 -0400
In-Reply-To: <CAKgT0Uc7cCu-5SwrB+4Mv6OM+V1jDwefOoG-Wr61C4F1g1BmFA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> Then again, if you're basically saying every HW-assisted offload on
>>> receive should be done under LRO flag, what would be the use case
>>> where a GRO-assisted offload would help?
>>> I.e., afaik LRO is superior to GRO in `brute force' -
>>> it creates better packed packets and utilizes memory better
>>> [with all the obvious cons such as inability for defragmentation].
>>> So if you'd have the choice of having an adpater perform 'classic'
>>> LRO aggregation or something that resembles a GRO packet,
>>> what would be the gain from doing the latter?

> LRO and GRO shouldn't really differ in packing or anything like that.
> The big difference between the two is that LRO is destructive while
> GRO is not.=A0 Specifically in the case of GRO you should be able to
> take the resultant frame, feed it through GSO, and get the original
> stream of frames back out.=A0 So you can pack the frames however you
> want the only key is that you must capture all the correct offsets an=
d
> set the gso_size correct for the flow.

While the implementation might lack in things [such as issues with
future implementation], following your logic it is GRO - I.e., forwardi=
ng
scenarios work fine with HW assisted GRO.

>> Just to relate to bnx2x/qede differences in current implementation -
>> when this GRO hw-offload was added to bnx2x, it has already
>> supported classical LRO, and due to above statement whenever LRO
>> was set driver aggregated incoming traffic as classic LRO.
>> I agree that in hindsight the lack of distinction between sw/hw GRO
>> was hurting us.

> In the case of bnx2x it sounds like you have issues that are
> significantly hurting the performance versus classic software GRO.=A0=
 If
> that is the case you might want to simply flip the logic for the
> module parameter that Rick mentioned and just disable the hardware
> assisted GRO unless it is specifically requested.

A bit hard to flip; The module parameter also disables LRO support.
And given that module parameters is mostly a thing of the past, I
don't think we should strive fixing things through additional changes
in that area.

> > qede isn't implementing LRO, so we could easily mark this feature
> > under LRO there - but question is, given that the adapter can suppo=
rt
> > LRO, if we're going to suffer from all the shotrages that arise fro=
m
> > putting this feature under LRO, why should we bother?

> The idea is to address feature isolation.=A0 The fact is the hardware
> exists outside of kernel control.=A0 If you end up linking an interna=
l
> kernel feature to your device like this you are essentially stripping
> the option of using the kernel feature.

> I would prefer to see us extend LRO to support "close enough GRO"
> instead of have us extend GRO to also include LRO.=A0

Again - why? What's the benefit of HW doing LRO and trying to
control imitate GRO, if it's still carrying all the LRO baggage
[specifically, disabling it on forwarding] as opposed to simply
doing classic LRO?

> > You can argue that we might need a new feature bit for control
> > over such a feature; If we don't do that, is there any gain in all =
of this?

> I would argue that yes there are many cases where we will be able to
> show gain.=A0 The fact is there is a strong likelihood of the GRO on
> your parts having some differences either now, or at some point in th=
e
> future as the code evolves.=A0 As I mentioned there was already some
> talk about possibly needing to push the UDP tunnel aggregation out of
> GRO and perhaps handling it sometime after IP look up had verified
> that the destination was in fact a local address in the namespace.=A0=
 In
> addition it makes the changes to include the tunnel encapsulation muc=
h
> more acceptable as LRO is already naturally dropped in the routing an=
d
> bridging cases if I recall correctly.

I think it all boils down to the question of "do we actually want to ha=
ve
HW-assisted GRO?". If we do [and not necessarily for the UDP-tunnel
scenario] then we need to have it distinct from LRO, otherwise there's
very little gain. If we believe tGRO should remain SW-only, then
I think the discussion is mott; We need to stop trying this, and offloa=
d
only LRO - in which case we can aggregate it in whichever 'destructive'
[correct] format we like, without trying to have it resemble GRO.
   =20=20
