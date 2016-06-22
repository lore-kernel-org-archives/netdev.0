From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Wed, 22 Jun 2016 15:56:55 -0700
Message-ID: <CAKgT0UdbPVqpSVLs0JW7zFU7mNtJn5BM+fMjsr1tLm4kHRcW9A@mail.gmail.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
 <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
 <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <576B08A2.8080603@hpe.com> <1466635664.6850.90.camel@edumazet-glaptop3.roam.corp.google.com>
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
Received: from mail-it0-f51.google.com ([209.85.214.51]:37367 "EHLO
	mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752818AbcFVW5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 18:57:03 -0400
Received: by mail-it0-f51.google.com with SMTP id f6so50464172ith.0
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 15:56:56 -0700 (PDT)
In-Reply-To: <1466635664.6850.90.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2016 at 3:47 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-06-22 at 14:52 -0700, Rick Jones wrote:
>> On 06/22/2016 11:22 AM, Yuval Mintz wrote:
>> > But seriously, this isn't really anything new but rather a step forward in
>> > the direction we've already taken - bnx2x/qede are already performing
>> > the same for non-encapsulated TCP.
>>
>> Since you mention bnx2x...   I would argue that the NIC firmware on
>> those NICs driven by bnx2x is doing it badly.  Not so much from a
>> functional standpoint I suppose, but from a performance one.  The
>> NIC-firmware GRO done there has this rather unfortunate assumption about
>> "all MSSes will be directly driven by my own physical MTU" and when it
>> sees segments of a size other than would be suggested by the physical
>> MTU, will coalesce only two segments together.  They then do not get
>> further coalesced in the stack.
>>
>> Suffice it to say this does not do well from a performance standpoint.
>>
>> One can disable LRO via ethtool for these NICs, but what that does is
>> disable old-school LRO, not GRO-in-the-NIC.  To get that disabled, one
>> must also get the bnx2x module loaded with "disable-tpa=1" so the Linux
>> stack GRO gets used instead.
>>
>> Had the bnx2x-driven NICs' firmware not had that rather unfortunate
>> assumption about MSSes I probably would never have noticed.
>
> I do not see this behavior on my bnx2x nics ?

It could be that you and Rick are running different firmware. I
believe you can expose that via "ethtool -i".  This is the ugly bit
about all this.  We are offloading GRO into the firmware of these
devices with no idea how any of it works and by linking GRO to LRO on
the same device you are stuck having to accept either the firmware
offload or nothing at all.  That is kind of the point Rick was trying
to get at.

The preferred setup would be to have any aggregation offload on the
device be flagged as LRO and then the offload performed by the kernel
be GRO.  By linking the two features as has apparently happened with
bnx2x and qede it limits the users options and kind of forces them
into an all or nothing situation unless they have insight into
proprietary driver options to disable these features.

- Alex
