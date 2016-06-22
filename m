From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Wed, 22 Jun 2016 10:45:35 -0700
Message-ID: <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
 <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com> <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33366 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876AbcFVRph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 13:45:37 -0400
Received: by mail-io0-f170.google.com with SMTP id t74so50544819ioi.0
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 10:45:36 -0700 (PDT)
In-Reply-To: <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2016 at 10:16 AM, Yuval Mintz <Yuval.Mintz@qlogic.com> wrote:
>>> This series adds driver support for the processing of tunnel
>>> [specifically vxlan/geneve/gre tunnels] packets which are
>>> aggregated [GROed] by the hardware before driver passes
>>> such packets upto the stack.
>
>> First off I am pretty sure this isn't GRO.  This is LRO.
> Nopes. This is GRO - each MSS-sized frame will arrive on its
> own frag, whereas the headers [both  internal & external]
> would arrive on the linear part of the SKB.

No it is LRO, it just very closely mimics GRO.  If it is in hardware
it is LRO.  GRO is extensible in software and bugs can be fixed in
kernel, LRO is not extensible and any bugs in it are found in hardware
or the driver and would have to be fixed there.  It all comes down to
bug isolation.  If we find that disabling LRO makes the bug go away we
know the hardware aggregation has an issue.  Both features should not
operate on the same bit.  Otherwise when some bug is found in your
implementation it will be blamed on GRO when the bug is actually in
LRO.

I realize this causes some pain when routing or bridging as LRO is
disabled but that is kind of the point.  We don't want the hardware to
be mangling frames when we are attempting to route packets between any
two given devices.

>> Also I don't know if you have been paying attention to recent
>> discussions on the mailing list but the fact is GRO over UDP tunnels
>> is still a subject for debate.  This patch takes things in the
>> opposite direction of where we are currently talking about going with
>> GRO.  I've added Hannes and Tom to this discussion just to make sure I
>> have the proper understanding of all this as my protocol knowledge is
>> somewhat lacking.
> I guess we're on the exact opposite side of the discussion - I.e., we're
> the vendor that tries pushing offload capabilities to the device.
> Do notice however that we're not planning on pushing anything new
> feature-wise, just like we haven't done anything for regular TCP GRO -
> All we do is allow our HW/FW to aggregate packets instead of stack.

If you have been following the list then arguably you didn't fully
understand what has been going on.  I just went through and cleaned up
all the VXLAN, GENEVE, and VXLAN-GPE mess that we have been creating
and tried to get this consolidated so that we could start to have
conversations about this without things being outright rejected.  I
feel like you guys have just prooven the argument for the other side
that said as soon as we start support any of it, the vendors were
going to go nuts and try to stuff everything and the kitchen sink into
the NICs.  The fact is I am starting to think they were right.

>> Ideally we need to be able to identify that a given packet terminates
>> on a local socket in our namespace before we could begin to perform
>> any sort of mangling on the local packets.  It is always possible that
>> we could be looking at a frame that uses the same UDP port but is not
>> the tunnel protocol if we are performing bridging or routing.  The
>> current GRO implementation fails in that regard and there are
>> discussions between several of us on how to deal with that.  It is
>> likely that we would be forcing GRO for tunnels to move a bit further
>> up the stack if bridging or routing so that we could verify that the
>> frame is not being routed back out before we could aggregate it.

> I'm aware of the on-going discussion, but I'm not sure this should
> bother us greatly - the aggregation is done based on the
> inner TCP connection; I.e., it's guaranteed all the frames belong to
> the same TCP connection. While HW requires the UDP port for the
> initial classification effort, it doesn't take decision solely on that.

I realize that UDP port is only one piece of this.  Exactly what
fields are being taken into account.  That information would be useful
as we could then go though and determine what the probability is of us
having a false match between any two packets in a given UDP flow.

Also I would still argue this is LRO.  If we are doing routing it
should be disabled for us to later re-enable if we feel it is safe.
Having a feature like this enabled by default with GRO is a really bad
idea.

>> Also I would be interested in knowing how your hardware handles
>> tunnels with outer checksums.  Is it just ignoring the frames in such
>> a case, ignoring the checksum, or is it actually validating the frames
>> and then merging the resulting checksum?

> HW is validating both inner and outer csum; if it wouldn't be able to
> due to some limitation, it would not try to pass the packet as a GRO
> aggregation but rather as regular seperated packets.
> But I don't believe it merges the checksum, only validate each
> independently [CSUM_UNNECESSARY].

So it is mangling the packets then.  If this were flagged as LRO at
least if bridging or routing is enabled you won't be mangling the
frames without the user having to specifically go back through and
re-enable LRO.

- Alex
