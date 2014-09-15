From: Dave Taht <dave.taht@gmail.com>
Subject: Re: Qdisc: Measuring Head-of-Line blocking with netperf-wrapper
Date: Mon, 15 Sep 2014 21:55:50 +0300
Message-ID: <CAA93jw7ZNbvwLtcFfwRVVF8asnxwp104g7iR-oZv3nj0mqKbOQ@mail.gmail.com>
References: <20140915184517.6c5474e5@redhat.com>
	<CA+mtBx_EthN8G0oEUENmVhb8MJ2MrijhT+FRjJPomBLvJPoH_w@mail.gmail.com>
	<1410801863.7106.169.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>,
	Tim Shepard <shep@alum.mit.edu>,
	Avery Pennarun <apenwarr@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:42470 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229AbaIOSzv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 14:55:51 -0400
Received: by mail-oa0-f49.google.com with SMTP id m19so2892741oag.36
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 11:55:51 -0700 (PDT)
In-Reply-To: <1410801863.7106.169.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 8:24 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> On Mon, 2014-09-15 at 10:10 -0700, Tom Herbert wrote:
>> On Mon, Sep 15, 2014 at 9:45 AM, Jesper Dangaard Brouer
>> <brouer@redhat.com> wrote:
>> >
>> > Hi Eric,
>> >
>> > I've constructed a "netperf-wrapper" test for measuring Head-of-Li=
ne
>> > blocking, called "tcp_upload_prio", that I hope you will approve o=
f?
>> >
>> >  https://github.com/tohojo/netperf-wrapper/commit/1e6b755e8051b6
>> >
>> > The basic idea is to have ping packets with TOS bit 0x10, which en=
d-up
>> > in the high-prio band of pfifo_fast.  While two TCP uploads utiliz=
e
>> > all the bandwidth.
>> >
>> > These high-prio ping packet should then demonstrate the Head-of-Li=
ne
>> > blocking occurring due to 1) packets in the HW TX ring buffer, or
>> > 2) in the qdisc layers requeue mechanism.  Disgusting these two ca=
se
>> > might be a little difficult.
>> >
>> >
>> >
>> > Special care need to be take for using this on the default
>> > qdisc MQ which have pfifo_fast assigned for every HW queue.
>> >
>> > Setup requirements:
>> >  1. IRQ align CPUs to NIC HW queues
>> >  2. Force netperf-wrapper subcommands to run the same CPU
>> >   E.g: taskset -c 2 ./netperf-wrapper -H IP tcp_upload_prio
>> >
>> > This will force all measurements to go through the same qdisc.  Th=
is
>> > is needed so the ping/latency tests measures the real property of
>> > the qdisc and Head-of-Line blocking effect.
>> >
>> >
>> > Basically the same as:
>> >  sudo taskset -c 2 ping -Q 0x10 192.168.8.2
>> >  sudo taskset -c 2 ping         192.168.8.2
>> >  sudo taskset -c 2 netperf   -H 192.168.8.2 -t TCP_STREAM -l 120
>> >  sudo taskset -c 2 netperf   -H 192.168.8.2 -t TCP_STREAM -l 120
>> > --
>> ping is a very coarse way to measure latency and in network devices =
it
>> doesn't follow same path as TCP/UDP (no 4-tuple for RSS, ECMP) so it=
's
>> biased and not a very realistic workload. You might want to try usin=
g
>> netperf TCP_RR at higher priority for a fairer comparison (this is
>> what I used to verify BQL benefits). Also, you probably want to make
>> sure to have enough antagonist flows to saturate all links when usin=
g
>> MQ.


> Right.
>
> Jesper, relevant netperf option is :
>
>     -y local,remote   Set the socket priority
>
>

Problems with TCP_RR and UDP_RR are that they are subject to a RTO on
packet loss.
The time around a packet loss is "interesting". Secondly, several of
my measurements show that icmp is actually quicker than other code
paths, I figure because a switch to userspace is not needed to handle
the packet.

Outside of ping, the only isochronous packet generation code out there
worth dinking with is owamp,

http://software.internet2.edu/owamp/

And d-itg, at the moment.

There are some neato tools under development for looking at bursty
loss and mixed classifications (see very buggy code in my isochronous
dir on github - I put it down to finish stablizing cerowrt, less buggy
versions are in gfiber's repo which I don't have a link to handy at
the moment)

It would be nice if netperf could sprout a "send a user specified
packet size on this isochronous interval (with a resolution below a
ms) over X transport" test. Or there was something simpler than owamp
but as secure.

--=20
Dave T=C3=A4ht

https://www.bufferbloat.net/projects/make-wifi-fast
