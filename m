From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH] net_sched: sfq: add optional RED on top of SFQ
Date: Tue, 10 Jan 2012 10:40:23 +0100
Message-ID: <CAA93jw4oWcmSG7rzQVSFBie4Bd+KN37Cg2A1bUQnR+PzHtvW6Q@mail.gmail.com>
References: <1325766316.2415.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAA93jw4ndMg-4BnhmspxgcXYdozu5+YX9VJgtHJ3N5HVX1b4yg@mail.gmail.com>
	<1325770777.2415.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1325867504.2911.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:54307 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754533Ab2AJJkY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 04:40:24 -0500
Received: by iabz25 with SMTP id z25so645296iab.19
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2012 01:40:24 -0800 (PST)
In-Reply-To: <1325867504.2911.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 6, 2012 at 5:31 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Adds an optional Random Early Detection on each SFQ flow queue.
>
> Traditional SFQ limits count of packets, while RED permits to also
> control number of bytes per flow, and adds ECN capability as well.
>
> 1) We dont handle the idle time management in this RED implementation=
,
> since each 'new flow' begins with a null qavg. We really want to addr=
ess
> backlogged flows.
>
> 2) if headdrop is selected, we try to ecn mark first packet instead o=
f
> currently enqueued packet. This gives faster feedback for tcp flows
> compared to traditional RED [ marking the last packet in queue ]
>
> Example of use :
>
> tc qdisc add dev $DEV parent 1:1 handle 10: est 1sec 4sec sfq \
> =A0 =A0 =A0 =A0limit 3000 headdrop flows 512 divisor 16384 \
> =A0 =A0 =A0 =A0redflowlimit 100000 min 8000 max 60000 probability 0.2=
0 ecn
>
> qdisc sfq 10: parent 1:1 limit 3000p quantum 1514b depth 127 headdrop
> flows 512/16384 divisor 16384
> =A0ewma 6 min 8000b max 60000b probability 0.2 ecn
> =A0prob_mark 0 prob_mark_head 4876 prob_drop 6131
> =A0forced_mark 0 forced_mark_head 0 forced_drop 0
> =A0Sent 1175211782 bytes 777537 pkt (dropped 6131, overlimits 11007
> requeues 0)
> =A0rate 99483Kbit 8219pps backlog 689392b 456p requeues 0
>
> In this test, with 64 netperf TCP_STREAM sessions, 50% using ECN enab=
led
> flows, we can see number of packets CE marked is smaller than number =
of
> drops (for non ECN flows)
>
> If same test is run, without RED, we can check backlog is much bigger=
=2E
>

I can confirm that it doesn't crash. It doesn't appear to do harm. It d=
oes
appear to hold queue depths to saner levels, balance competing streams,
really well (tested only with identical RTTs, however), latecomers
ramp up nice to compete...

and in the packet captures I have I see TCP fast retransmits, no signif=
icant
bursty losses, etc.

In other words, all pretty good behavior.

Configuring RED is correctly is still a PITA, but less so now. Not
that I'm getting
it right below. This was a test at 100Mbit, with BQL=3D4500, GSO/TSO of=
f,
with 50 iperf streams across 2 routers to another box (all of which wer=
e
running the newer sfq with the HoL fix in the default mode)

qdisc sfq a: root refcnt 2 limit 300p quantum 1514b depth 127 headdrop
divisor 16384
 ewma 6 min 8000b max 60000b probability 0.2 ecn
 prob_mark 5 prob_mark_head 12863 prob_drop 0
 forced_mark 0 forced_mark_head 0 forced_drop 0
 Sent 10890212752 bytes 8191225 pkt (dropped 76030, overlimits 12868
requeues 2920968)
 rate 41329Kbit 3448pps backlog 442088b 293p requeues 2920968

ping RTT went from ~.3ms unloaded to 1.6 to 2 ms
netperf -t TCP_RR went from ~2000 to ~500

These two changes are due mostly to the number of packets being buffere=
d
in the driver and are far better than pfifo fast does in all cases...

Months of testing is indicated to thoroughly evaluate the effects of
this against
things such as bittorrent, voip, etc, in a long RTT environment, agains=
t
more workloads than just the above. It would be good to test against mo=
re
reference machines at both higher speeds and lower, and with HTB on,
etc., etc.

But as I said, it doesn't crash, is not on by default, more people shou=
ld
definitely try it, and in general... appears to be a big win in additio=
n
to the already huge wins in all the queueing disciplines in 3.3.

With those caveats...

Tested-by: Dave Taht <dave.taht@gmail.com>

--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
