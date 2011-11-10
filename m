From: Dave Taht <dave.taht@gmail.com>
Subject: Re: creating netdev queues on the fly?
Date: Thu, 10 Nov 2011 16:25:25 +0100
Message-ID: <CAA93jw7ECQegWj6rpd48sbmDQUjorCYzXANXJSj0baHtxzC7EA@mail.gmail.com>
References: <1320933501.3967.68.camel@jlt3.sipsolutions.net>
	<CAGXE3d-_RFgW_zwfX2vTBe1psXmgoBFO5pd5cAgtYo=Jwpddhw@mail.gmail.com>
	<7be02f26a67fac4c7448a74f1f17aa01@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Helmut Schaa <helmut.schaa@googlemail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Denys Fedoryshchenko <denys@wbc.net.sa>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40350 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934229Ab1KJPZ1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 10:25:27 -0500
In-Reply-To: <7be02f26a67fac4c7448a74f1f17aa01@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 10, 2011 at 3:55 PM, Denys Fedoryshchenko <denys@wbc.net.sa=
> wrote:
> On Thu, 10 Nov 2011 15:40:01 +0100, Helmut Schaa wrote:
>>>
>>> I think this might also make implementing reservation (tspec) easie=
r.
>>> Not sure if anyone wants/needs that though.
>>
>> Wouldn't it be possible to implement something like this as a qdisc =
on top
>> of
>> mq that makes use of the current tx rate per station to distribute
>> the airtime
>> equitably?
>>
>> Of course this would require the qdisc to know the tx rate a priori =
but
>> for
>> mac80211 drivers we could just use last_tx_rate as an estimate ...

Need last_aggregation_depth bytes and packets and last feasible
versions of those for an estimate with n. completion rate, perhaps...

>>
>> Helmut
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
> Maybe someone will make something like "tfifo" in future :)

Did some of it last weekend. Code doesn't work yet - I mixed in too
many of the ideas mentioned in
my earlier, longer, more difficult to read missive. Time based queue
limits are an important part of the answer, however.

Our current fixed packet queue limits are merely a proxy for time. At
100Mbit ethernet, they were 100ms - which is conus distances...

 and I'd hope that someone more knowledgable than I at these layers
take all this on...

Two notes:

1) Getting 'time' from the kernel is expensive. And: System time wander=
s.

mac80211 Wifi devices however do export a get_tsf function which could
be used as a relative-to-the-queue clock - and we actually don't need
accuracy down to the level of get_tsf (25ns)

2) You need to get a timestamp on entry to the first queue and check
against the allowable latency on exit from the last. So to construct a
tc chain you'd want a tfifo (timestamp on entry), fifot (check
timestamp against limit on dequeue), and for the simplest of
applications : tfifot (timestamp on entry, check on exit)


> And when clients are connected, each have his own queue.

Needed, yes. Particularly with mixed g/n, but also to optimize
aggregation AND fairness.

>
> then, for example qdisc add dev wlan0 parent 1:10 handle 10 tfifo lim=
it
> 100ms
> If packet are older than 100ms will be dropped, or new packets are no=
t
> added, if
> there is packet older than 100ms are not sent yet.

Aside from me calling it 'tfifot last weekend, yes. Though I prefer
using 'timelimit' as the key name, to distinguish between previous
overloaded uses of the word limit.


>
> I am not sure that bandwidth will be distributed fairly, it is differ=
ent
> question,
> probably each queue should have some "limited chunk of time" to send =
data.

Round robin with random starting points for each cycle through the
stations in what I was calling a 'grouper' in the previous mail.

> And again, 802.11a/b/g at least are half-duplex and CSMA, and without
> polling/TDMA or CTS/RTS tricks
> it will be complicated to give guaranteed chunks of time.

I *think* but am not sure that what I have described interacts with
the EDCA reasonably well.

>
> P.S. That's just a dream :)
>
> ---
> Network engineer
> Denys Fedoryshchenko
>
> P.O.Box 41553 Jeddah 21531
> Tel: =A0 920023422
> Fax: =A0+966 26501784
> E-Mail: denys@wbc.net.sa
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wirel=
ess" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
