From: Dave Taht <dave.taht@gmail.com>
Subject: Re: qstats update in packet scheduling
Date: Mon, 24 Nov 2014 11:25:31 -0800
Message-ID: <CAA93jw5mc_xkNQKrheh+t4yk4WidmAzN=ARe=oA=H2pPKvaP6Q@mail.gmail.com>
References: <CAHmvzZQnBJbx3hfdvpXg0TZM-UooKxjM+-1HO6nSSpx4qJLcaw@mail.gmail.com>
	<1416850289.17888.67.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHmvzZRwsd7S+T4cdAVzWGORcbkq+WWMtFAV6Ss3UrA+Ogeujg@mail.gmail.com>
	<1416854568.17888.69.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAA93jw4URTCK_O5mrJB14qAraubqj4Y-pvWMFX7ts=BWSgd-Og@mail.gmail.com>
	<CAHmvzZTF76DwdyBF9og2v9Vumx5v0BhHR584uX54o5R+T+iUMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Josh Clark <jcinma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:35219 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbaKXTZc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 14:25:32 -0500
Received: by mail-oi0-f44.google.com with SMTP id e131so7159520oig.31
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 11:25:31 -0800 (PST)
In-Reply-To: <CAHmvzZTF76DwdyBF9og2v9Vumx5v0BhHR584uX54o5R+T+iUMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2014 at 11:14 AM, Josh Clark <jcinma@gmail.com> wrote:
> On Mon, Nov 24, 2014 at 2:01 PM, Dave Taht <dave.taht@gmail.com> wrot=
e:
>> On Mon, Nov 24, 2014 at 10:42 AM, Eric Dumazet <eric.dumazet@gmail.c=
om> wrote:
>>> On Mon, 2014-11-24 at 13:17 -0500, Josh Clark wrote:
>>>
>>>> But I'm seeing no change at all in qlen. qlen and backlog are both
>>>> zero, which results in zero qavg, meaning I can't test the RED
>>>> functionality at all.
>>>
>>> Wait. If you use some kernel patch without giving it, I can not com=
ment.
>>>
>>> If you use regular "tc -s qdisc ...", then you'll see non zero qlen
>>
>> Well, assuming you have BQL or a software rate limiter in place in
>> front of it...
>>
> At the moment, I'm using standard RED (from /net/sched/sch_red.c) wit=
h
> some printks to output qstats.
> Are you saying that when I set this up, I need to use the -s flag in
> tc to maintain those statistics?

No. tc -s qdisc whatever, prints statistics with the -s option.
Statistics are always kept.



Example:

d@snapon:~$ tc -s qdisc show dev eth0
qdisc fq_codel 8001: root refcnt 2 limit 10240p flows 1024 quantum
1514 target 5.0ms interval 100.0ms ecn
 Sent 76100781413 bytes 60627857 pkt (dropped 0, overlimits 0 requeues =
267912)
 backlog 0b 0p requeues 267912
  maxpacket 68264 drop_overlimit 0 new_flow_count 383247 ecn_mark 0
  new_flows_len 0 old_flows_len 0

And your printks will heisenbug your statistics collections, packet
processing can take place a lot faster than printks can.
>
> One more question: if I don't use -s, then what would RED use to calc=
ulate qavg?

The backlog. And if you dont have BQL in your device driver or a rate
limiter in front of RED, or are using a minimal number of tcp flows,
you rarely will see a backlog anymore in mainline linux.

Why?

"tcp small queues" keeps data in the tcp stack until it is needed.
Without bql there is no backpressure from the device drivers to feed
into the qdisc.

If you dont have BQL but you use a rate limiter, like HTB, + RED, and
run at a low rate, you will start to see RED keeping packets around
long enough to do various degrees of useful to nasty stuff to it.

And...

RED is dead. There is no reason to bother with it anymore. Please feel
free to catch up on decades worth of subsequent research instead.

See for example Van Jacobson's (the original author of RED)'s presentat=
ion here:

http://www.bufferbloat.net/projects/cerowrt/wiki/Bloat-videos

Or paper here:

http://queue.acm.org/detail.cfm?id=3D2209336

If there are interesting statistics you would like to pull out of pie,
codel, or fq_codel instead that are not already provided, please let
us know.

>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>>
>> --
>> Dave T=C3=A4ht
>>
>> thttp://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks



--=20
Dave T=C3=A4ht

thttp://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
