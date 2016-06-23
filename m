From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Wed, 22 Jun 2016 17:11:16 -0700
Message-ID: <CAKgT0Uex41aBJX84we2gxNGw6M4s5xGEPnDkGehTZkEE+i+Jhw@mail.gmail.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
 <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
 <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <576B08A2.8080603@hpe.com> <1466635664.6850.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UdbPVqpSVLs0JW7zFU7mNtJn5BM+fMjsr1tLm4kHRcW9A@mail.gmail.com> <1466638292.6850.94.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rick Jones <rick.jones2@hpe.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:35745 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbcFWALS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 20:11:18 -0400
Received: by mail-io0-f179.google.com with SMTP id f30so58182720ioj.2
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 17:11:18 -0700 (PDT)
In-Reply-To: <1466638292.6850.94.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2016 at 4:31 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-06-22 at 15:56 -0700, Alexander Duyck wrote:
>
>> It could be that you and Rick are running different firmware. I
>> believe you can expose that via "ethtool -i".  This is the ugly bit
>> about all this.  We are offloading GRO into the firmware of these
>> devices with no idea how any of it works and by linking GRO to LRO on
>> the same device you are stuck having to accept either the firmware
>> offload or nothing at all.  That is kind of the point Rick was trying
>> to get at.
>
>
> Well, we offload TSO to the NIC. Or checksums as much as we can.
>
> At one point we have to trust the NIC we plug in our hosts, right ?
>
> Why RX is so different than TX exactly ?

Exactly my point.  The problem I have with the bnx2x and qede drivers
is that the NIC driver is using the GRO flag to enable LRO on the
device. It is like arguing that the NIC can do segmentation based on
the GSO flag instead of the TSO flag.  We should be keeping TSO/LRO as
the device features while GSO/GRO are kernel features that don't
directly change any settings on the device.

> Yes, LRO is hard to implement properly compared to TSO,
> but not something that is _fundamentally_ broken.

Yes and no.  More often then not there are issues that pop up as
protocols change.  I'm not assuming they are fundamentally broken.
The bit that I consider broken is that I cannot disable the NIC LRO
functionality without having to disable the stack from doing GRO.  All
I am asking for is LRO controls all of the NIC aggregation features
and GRO be kept a software only feature instead of being tied to a
hardware feature.

> Claiming that hardware assist GRO is not possible is a plain mantra.

I have no issue claiming hardware assist GRO is possible.  My problem
is saying that the GRO feature flag can be used to enable it.  I would
argue that any packet aggregation at the device or driver level is LRO
regardless of how close it comes to GRO feature wise.  GRO should only
be occurring in the receive path after calling the appropriate GRO
function.  Otherwise it becomes really difficult to work around any
possible issues that the hardware assisted GRO introduces without
paying a huge penalty.  We need to keep these feature flags separate.
I thought that was the whole reason why we have the distinction
between LRO and GRO in the first place.

- Alex
