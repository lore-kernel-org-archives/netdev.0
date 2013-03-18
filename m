From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH] bnx2x: fix occasional statistics off-by-4GB error
Date: Sun, 17 Mar 2013 23:18:52 -0700
Message-ID: <CANP3RGdZHMTPT6FTbYzSOHkrNq4seF1WcXjysQ6=HEp0A_CxWg@mail.gmail.com>
References: <CANP3RGdWMHv-7TZ4fvASrmz7NXkO7B2g2RCZwV8ecExUsQTQ2w@mail.gmail.com>
	<1363384577-21287-1-git-send-email-zenczykowski@gmail.com>
	<504C9EFCA2D0054393414C9CB605C37F20BE6A2B@SJEXCHMB06.corp.ad.broadcom.com>
	<20130317.142425.1713640249735424829.davem@davemloft.net>
	<1363549074.4752.3.camel@lb-tlvb-eilong.il.broadcom.com>
	<1363551952.29475.93.camel@edumazet-glaptop>
	<1363553608.4752.5.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Linux NetDev <netdev@vger.kernel.org>,
	Mintz Yuval <yuvalmin@broadcom.com>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:57496 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab3CRGSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 02:18:53 -0400
Received: by mail-ob0-f177.google.com with SMTP id eh20so5026023obb.36
        for <netdev@vger.kernel.org>; Sun, 17 Mar 2013 23:18:53 -0700 (PDT)
In-Reply-To: <1363553608.4752.5.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This has nothing to do with atomicity or races or anything.

Look at the ADD_64 macro (which implements a += b) and compare it to
this one (which implents a = b + c).

It simply doesn't know how to correctly add in any situation in which
"qstats_old->t..._lo != 0".
By this point all the stats are already in software and both firmware
and hardware is not relevant.

Normally qstats_old starts off at 0 and the bug isn't visible (since
with a value of 0, there can't be overflow and carry propagation is
not needed).

The reason qstats_old was introduced was to allow for a partial nic
reset [or whatever the proper term is] which resets fw/hw provided
stats to not reset sw exported stats.
During the reset old stats are copied into qstats_old, and in the
future stats are returned as "qstats_old + current stats from fw/hw"
except this addition is buggy and only works if qstats_old happens to
have lower 32-bits zero (ie. basically only before first partial nic
reset).

Imagine:
(a) driver initializes, nic gets brought up, qstats_old = 0, stats
from device = 0
(b) 2GB of xfer happens
(c) qstats_old still = 0, stats from device = 2GB
(d) addition happens qstats = qstats_old + stats_from_dev = 0 + 2GB =
2GB   --- we report 2GB xfer
(e) something partially resets nic (say mtu change), qstats_old = 2GB,
stats from device = 0
(f) 2GB-1 of xfer happens
(g) qstats_old = 2GB, stats from device = 2GB-1
(h) addition happens qstats = qstats_old + stats_from_dev = 2GB +
2GB-1 = 4GB-1   --- we report 4GB-1 xfer
(i) 1 byte of xfer happens
(j) qstats_old = 2GB, stats from device = 2GB
(k) addition happens qstats = qstats_old + stats_from_dev = 2GB + 2GB
= 0   --- we report 0 xfer
(l) 2GB of xfer happens
(m) qstats_old = 2GB, stats from device = 4GB
(n) addition happens qstats = qstats_old + stats_from_dev = 2GB + 4GB
= 6GB   --- we report 6GB xfer

And yes the macro in question when asked to do 2GB+2GB will return 0.

(btw. at least on the driver I tested there's still some weirdness
with mtu change not-resetting per-queue stats but resetting
coalesced-from-all-queues stats)

Now, to be fair, I don't yet have confirmation that my patch fixes the
problem our SREs saw in deployment, but I expect to have that soon.
(and even if it doesn't fix the problem, this code is still buggy and
should be fixed)

Maciej

On Sun, Mar 17, 2013 at 1:53 PM, Eilon Greenstein <eilong@broadcom.com> wrote:
> On Sun, 2013-03-17 at 13:25 -0700, Eric Dumazet wrote:
>> On Sun, 2013-03-17 at 21:37 +0200, Eilon Greenstein wrote:
>> > On Sun, 2013-03-17 at 14:24 -0400, David Miller wrote:
>> > > From: "Dmitry Kravkov" <dmitry@broadcom.com>
>> > > Date: Sun, 17 Mar 2013 13:10:37 +0000
>> > >
>> > > > Probably this commit resolved the issue:
>> > > >
>> > > > commit bef05406ac0ea6f468e1e25e9934f3011ea9259b
>> > > > Author: Dmitry Kravkov <dmitry@broadcom.com>
>> > > > Date:   Tue Sep 11 04:34:08 2012 +0000
>> > > >
>> > > >     bnx2x: Avoid sending multiple statistics queries
>> > > >
>> > > > Can you try it pls?
>> > >
>> > > These are completely seperate bugs.
>> > >
>> > > The macro in question does not handle rollover of the lower 32-bits of
>> > > the statistic properly at all, and therefore Maciej's patch should be
>> > > applied and queud up for -stable.
>> > >
>> > > Please give it your ACK unless you can find a bug in his change.
>> >
>> > Both the high value and the low value are read from the chip - so this
>> > patch will increment the higher 32 bits twice (well, more than once).
>> > Not taking the HW/FW high counter at all is also not acceptable since
>> > the reading frequency is not high enough without those.
>> >
>> > So the original patch is nacked, but we are trying to figure out what is
>> > causing the statistics to misbehave and it might be related to sending
>> > statistics query twice.
>>
>> This looks like the typical problem of updating a 64bit value in non
>> atomic way.
>>
>> Its guaranteed to happen on 32bit hosts.
>> We had to introduce include/linux/u64_stats_sync.h to help to solve this
>> without adding extra cost on 64bit arches.
>>
>> In bnx2x case, we perform 32bit operations even on 64bit host, so we
>> probably need to add a seqcount_t, so that a stat consumer can detect it
>> read a stale value.
>
> This is not such a trivial issue - the HW/FW is guaranteeing the atomic
> read and this is why we can always use 32b variables.
>
>
