From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Thu, 23 Jun 2016 10:07:25 -0700
Message-ID: <CAKgT0Uc7cCu-5SwrB+4Mv6OM+V1jDwefOoG-Wr61C4F1g1BmFA@mail.gmail.com>
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
Received: from mail-it0-f43.google.com ([209.85.214.43]:36358 "EHLO
	mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbcFWRH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 13:07:27 -0400
Received: by mail-it0-f43.google.com with SMTP id a5so131957889ita.1
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 10:07:26 -0700 (PDT)
In-Reply-To: <CO2PR11MB0088949623FA99ED86D33205972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2016 at 9:17 PM, Yuval Mintz <Yuval.Mintz@qlogic.com> wrote:
>> Then again, if you're basically saying every HW-assisted offload on
>> receive should be done under LRO flag, what would be the use case
>> where a GRO-assisted offload would help?
>
>> I.e., afaik LRO is superior to GRO in `brute force' -
>> it creates better packed packets and utilizes memory better
>> [with all the obvious cons such as inability for defragmentation].
>> So if you'd have the choice of having an adpater perform 'classic'
>> LRO aggregation or something that resembles a GRO packet,
>> what would be the gain from doing the latter?

LRO and GRO shouldn't really differ in packing or anything like that.
The big difference between the two is that LRO is destructive while
GRO is not.  Specifically in the case of GRO you should be able to
take the resultant frame, feed it through GSO, and get the original
stream of frames back out.  So you can pack the frames however you
want the only key is that you must capture all the correct offsets and
set the gso_size correct for the flow.

> Just to relate to bnx2x/qede differences in current implementation -
> when this GRO hw-offload was added to bnx2x, it has already
> supported classical LRO, and due to above statement whenever LRO
> was set driver aggregated incoming traffic as classic LRO.
> I agree that in hindsight the lack of distinction between sw/hw GRO
> was hurting us.

In the case of bnx2x it sounds like you have issues that are
significantly hurting the performance versus classic software GRO.  If
that is the case you might want to simply flip the logic for the
module parameter that Rick mentioned and just disable the hardware
assisted GRO unless it is specifically requested.

> qede isn't implementing LRO, so we could easily mark this feature
> under LRO there - but question is, given that the adapter can support
> LRO, if we're going to suffer from all the shotrages that arise from
> putting this feature under LRO, why should we bother?

The idea is to address feature isolation.  The fact is the hardware
exists outside of kernel control.  If you end up linking an internal
kernel feature to your device like this you are essentially stripping
the option of using the kernel feature.

I would prefer to see us extend LRO to support "close enough GRO"
instead of have us extend GRO to also include LRO.  That way when we
encounter issues like the FW limitation that Rick encountered he can
just go in and disable the LRO and have true GRO kick in which would
be significantly better than having to poke around through
documentation to find a module parameter that can force the feature
off.  Really the fact that you have to use a module parameter is
frowned upon as well as most drivers aren't supposed to be using those
in the netdev tree.

> You can argue that we might need a new feature bit for control
> over such a feature; If we don't do that, is there any gain in all of this?

I would argue that yes there are many cases where we will be able to
show gain.  The fact is there is a strong likelihood of the GRO on
your parts having some differences either now, or at some point in the
future as the code evolves.  As I mentioned there was already some
talk about possibly needing to push the UDP tunnel aggregation out of
GRO and perhaps handling it sometime after IP look up had verified
that the destination was in fact a local address in the namespace.  In
addition it makes the changes to include the tunnel encapsulation much
more acceptable as LRO is already naturally dropped in the routing and
bridging cases if I recall correctly.

- Alex
