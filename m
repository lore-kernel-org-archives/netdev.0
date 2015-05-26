From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2 net-next 0/3] net: Add incoming CPU mask to sockets
Date: Tue, 26 May 2015 13:01:03 -0700
Message-ID: <CALx6S34AGs79MvbS52Hkc44=0vN=Ga=H_b8QCTbN0MG6fP2-uQ@mail.gmail.com>
References: <1432658049-3400132-1-git-send-email-tom@herbertland.com>
	<1432660689.4060.275.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S34DxrhBvnMyovQFF+Kzpvx3h6=Nviu7XOegPsZa71KrvA@mail.gmail.com>
	<1432664388.4060.292.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:38571 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbbEZUBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 16:01:04 -0400
Received: by igcau1 with SMTP id au1so62170126igc.1
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 13:01:03 -0700 (PDT)
In-Reply-To: <1432664388.4060.292.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 26, 2015 at 11:19 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-05-26 at 11:00 -0700, Tom Herbert wrote:
>> On Tue, May 26, 2015 at 10:18 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Tue, 2015-05-26 at 09:34 -0700, Tom Herbert wrote:
>> >> Added matching of CPU to a socket CPU mask. This is useful for TCP
>> >> listeners and unconnected UDP. This works with SO_REUSPORT to steer
>> >> packets to listener sockets based on CPU affinity. These patches
>> >> allow steering packets to listeners based on numa locality. This is
>> >> only useful for passive connections.
>> >>
>> >> v2:
>> >>   - Add cache alignment for fields used in socket lookup in sock_common
>> >>   - Added UDP test results
>> >
>> > What about the feedback I gave earlier Tom ???
>> >
>> > This cannot work for TCP in its current state.
>> >
>> It does work and it fixes cache server locality issues we are seeing.
>> Right now half of our connections are persistently crossing numa nodes
>> on receive-- this is having big negative impact. Yes, there may be
>> edge conditions where SYN goes to a different CPU than the rest of the
>> flow (probably need RFS or flow director for that problem), and that
>> sounds like something nice to fix, but this patch is not dependent on
>> that. Besides, did you foresee an API change would be required?
>
> With current stack, there is no guarantee SYN and ACK packets are
> handled by same cpu.
>
> These are no edge conditions, but real ones, even with RFS.
>
> Not everyone tweaks /proc/irq/*/smp_affinity
>
> Default is still allowing cpus being almost random (affinity=fffffff)
>
In that case there's no guarantee that any two packets in a flow will
hit the same CPU so there's no way to establish affinity to the
interrupt anyway. RFS would work okay to get affinity of the soft
processing, but there would be no point in trying to do any affinity
with incoming cpu so this feature wouldn't help.

The general problem is that the flow hash and/or RX CPU for a flow are
not guaranteed to be persistent for a connection. UDP doesn't have a
problem with this since every RX UDP packet can be independently
steered to a good socket in SO_REUSEPORT. For TCP we only get to make
this decision once for the whole lifetime of the flow, which means
that eventually that may turn out to made "wrong". These patches don't
try to fix that problem, for that I believe we're going to need to do
something a little more radical :-)

> That was partly for these reasons that SO_REUSEPORT (for TCP) could not
> use cpu number, but a flow hash to select the target socket.
>
>
>
