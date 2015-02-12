From: Dave Taht <dave.taht@gmail.com>
Subject: Wifi outside the faraday cage (was: Throughput regression with `tcp:
 refine TSO autosizing`)
Date: Thu, 12 Feb 2015 14:14:14 -0800
Message-ID: <CAA93jw7W-gOJOgByeoN+Kn3yAznQ8XTcSm0biTx+dogHmMkDnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eyal Perry <eyalpe@dev.mellanox.co.il>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	David Lang <david@lang.hm>,
	Andrew McGregor <andrewmcgr@gmail.com>
To: Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:48851 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541AbbBLWOP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 17:14:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 6, 2015 at 1:57 AM, Michal Kazior <michal.kazior@tieto.com>=
 wrote:
> On 5 February 2015 at 20:50, Dave Taht <dave.taht@gmail.com> wrote:
> [...]
>> And I really, really, really wish, that just once during this thread=
,
>> someone had bothered to try running a test
>> at a real world MCS rate - say MCS1, or MCS4, and measured the laten=
cy
>> under load of that...
>
> Time between frame submission to firmware and tx-completion on one of
> my ath10k machines:

THANK YOU for running these tests!

>
> Legacy 54mbps: ~18ms
> Legacy 6mbps: ~37ms

"legacy rates" are what many people actually achieve, given the
limited market penetration ac has on clients and APs.

> 11n MCS 3 (nss=3D0): ~13ms
> 11n MCS 8 (nss=3D1): ~6-8ms
> 11ac NSS=3D1 MCS=3D2: ~4-6ms
> 11ac NSS=3D2 MCS=3D0: ~5-8ms
>
> Keep in mind this is a clean room environment so retransmissions are
> kept at minimum. Obviously with a noisy environment you'll get retrie=
s
> at different rates and higher latency.

It is difficult to reconcile the results you get in the clean room
with the results I get from measurements in the real wold. I encourage
you to go test your code in coffee shops, in offices with wifi, and in
hotels and apartment buildings in preference to testing in the lab.

I typically measure induced delays in the 3 to 6 second range in your
typical conference scenario, which I measure at every conference I go
to. The latest talk, including data on that, is friday morning,
starting at 2:15 or so, at nznog:

http://new.livestream.com/i-filmservices/NZNOG2015/videos/75358960

1) In the real world, I rarely see the maximum *rates*.

I am personally quite fond of designing stuff with gears out of the
middle of the Boston Gear Catalog. [1]. In looking over my largely
outdoor wifi network, I see a cluster of values around mcs11,
followed\by mcs4,3, 7 and 0, and *nothing* with MCS15. David lang is
planning on doing some measurements at the SCALE conference next week,
and I expect heaps of data from that, but I strongly suspect that the
vast majority of connections in every circumstance except the
test-bench are not even coming close to the maximum MCS rate in the
standard(s).

I would have thought that the lessons of the chromecast, where *every*
attempt at reviewing it in an office environment failed, might have
supplied industry clue that even 20Mbit to a given station is
impossible in many cases due to airtime contention.

Aggregates should be sized to have a maximum of 2 full ones stacked up
at the rate being achieved for the destination, and the rest
backlogged in the qdisc layer, if possible. 37ms backed up in the
firmware is a lot, considering that the test above had no airtime
contention in it, and no multicast.

Drivers need to be aware that every TXOP is precious. I could see
having a watchdog timer set on getting one packet into a wifi driver
to wait a few hundred usec longer to fire off the write to the
hardware in order to maximize aggregation by accumulating more packets
to aggregate.

I have hopes for xmit_more also being useful, but I am really not sure
how well that works on single cores, interactions with napi, and with
other wifi aggregates. It looks like adding xmit_more to the ag71xx
driver will be easy...

2) In the real world I see media acquisition times *far* greater than 1=
ms.

Please feel free to test your drivers in coffee shops, in the office,
at hotels, in apartments...

And retries... let's not talk about retries...


3) Longer AMPDUs lead to more tail loss and retries

I have a paper around here somewhere that shows AMPDU loss and retries
go up disproportionately as the length of transmission approaches 4ms.
I hate drawing a conclusion from a paper I can't find, but my overall
take on it is that as media acquisition time and retransmits go up,
reducing AMPDU size from the maximum down to about 1ms at the current
rate would lead to more fair, responsive, and fast-feeling wifi for
everyone, improve ack clocking, flow mixing for web traffic, etc, etc.

4) There is some fairly decent academic work on other aspects of
excessive buffering at lower rates

http://hph16.uwaterloo.ca/~bshihada/publications/buffer-AMPDU.pdf

(there are problems with this paper, but at least it tests n)

and see google scholar for bufferbloat related papers in 2014 and
later on wifi and LTE.

5) As for rate control, Minstrel was designed in an era when there
wasn't one AP for every 4 people in the USA. Other people's rate
controllers are even dumber, and minstrel-ht itself needs a hard look
at n speeds, much less ac speeds.

6) Everything I say above applies to both stations and APs.

APs have FAR worse problems, where per-tid (station) queuing is really
needed in order to effectively aggregate when two or more stations are
in use. Statistically, with two or more stations using traffic,
aggregation possibilities will go down rapidly on a FIFO, (and go down
even faster with FQ in place without per sta queuing!),  and with the
usual fixed buffersize underneath that, without per-tid queuing, this
grows the delays enormously, and wastes space in txops.

(please try the netperf-wrapper RTT_Fair tests on 2 or more stations.
Add in some multicast traffic while you are at it.

Some early tests I did of the ath10k showed it going from 600mbit to
20mbit - at full rate in a lab with the stations located 2m away - on
a 4-station test. Somewhere around there I gave up on wifi and worked
on refining "cake" instead.)

There are a zillion other things that can be improved in wifi, some of
which I've already pointed to in the ieee talk, and the original
thread forked with andrew mcgregor pitching in as to what can be
improved in minstrel. [2]

Wifi does not need to suck as bad as it does at mid to low rates and
under contention. I find it really depressing that a technology that
has billions of users, has so few people working on making it better.
I hope to be able to spend some time on it myself, finally, starting
in april.

[1] https://books.google.com/books?id=3D7papZR4oVssC&pg=3DPA101&lpg=3DP=
A101&dq=3Dfeynman+gears&source=3Dbl&ots=3DetPYearM00&sig=3D9R0R88rOfAxm=
_U21mMLOwxO6Mfg&hl=3Den&sa=3DX&ei=3DcjfcVM2VDY_XoASYiYCwDg&ved=3D0CDYQ6=
AEwBg#v=3Donepage&q=3Dfeynman%20gears&f=3Dfalse

[2] Other fork of this thread:
https://lists.bufferbloat.net/pipermail/cerowrt-devel/2015-February/004=
001.html

>
> Micha=C5=82



--=20
Dave T=C3=A4ht

thttp://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
