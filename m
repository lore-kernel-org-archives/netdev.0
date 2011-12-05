From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Time in Queue, bufferbloat, and... our accidentally
 interplanetary network
Date: Mon, 05 Dec 2011 11:59:34 +0100
Message-ID: <1323082774.2670.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAA93jw7kQYONQiAozatRmdRRJeK0GB9eNDWtRZ3AL+OVKn0OpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bloat <bloat@lists.bufferbloat.net>,
	bloat-devel <bloat-devel@lists.bufferbloat.net>,
	netdev@vger.kernel.org,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:40138 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755825Ab1LEK7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 05:59:38 -0500
In-Reply-To: <CAA93jw7kQYONQiAozatRmdRRJeK0GB9eNDWtRZ3AL+OVKn0OpA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 d=C3=A9cembre 2011 =C3=A0 10:05 +0100, Dave Taht a =C3=A9cr=
it :

> And Eric dumazet also produced a preliminary patch a few weeks back
> that tied timestamping to before the head of a queue, but that tried =
to use a
> reserved field in the skb that appears from points A to Z is not guar=
anteed
> to be preserved.

It is guaranteed to be preserved, as it is part of skb->cb[], and
skb->cb[] content is private to each layer.

Here, Qdisc layer.

Adding a time limit is possible, all we need is a proper design and
implementation :)

Here is my suggestion :

Design a new tfifo/tred qdisc, with following properties :

Adaptative RED, (ECN enabled + head drop), but instead of using
bytes/packet qlen average, use time_in_queue average.

A single mandatory parameter to specify the tmin value
tmax default value would be tmin*3  (so that target avg is 2*tmin)
tlimit default value would be tmax*8

Adaptative RED dynamically adjusts maxp between 1% and 50%
[Using a timer, every 500ms, and AIMD]

tc qdisc add dev eth0 root tfifo tmin 1ms [tmax val] [tlimit val]


I volunteer to work on this new tfifo experimental qdisc :)

This can be used in replacement of pfifo/bfifo in a complex qdisc setup=
=2E
As it has RED included, it also can replace RED.

Please note that once skb leaves Qdisc and is delivered to device, any
time limit feature must be handled in the driver itself (if it can queu=
e
packet for a long time period)
