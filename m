From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] sch_htb.c consume the classes's tokens bellow the
	HTB_CAN_SEND level
Date: Wed, 4 Nov 2009 17:16:42 +0800
Message-ID: <412e6f7f0911040116q6b25b705k83e5a45464698af1@mail.gmail.com>
References: <4AEF9862.8040404@gmail.com> <20091103080022.GA6718@ff.dom.local>
	 <412e6f7f0911030147k659e0079ibd1f424fef0a487f@mail.gmail.com>
	 <20091103100538.GC6718@ff.dom.local>
	 <412e6f7f0911030518w7a5f02a4ue8a4b6539496dd8f@mail.gmail.com>
	 <20091103230035.GA2352@ami.dom.local>
	 <412e6f7f0911031753m4af1467fn1b0326bdf17fe48b@mail.gmail.com>
	 <20091104082808.GA6224@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, devik@cdi.cz,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.216.179]:58557 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045AbZKDJQh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 04:16:37 -0500
Received: by pxi9 with SMTP id 9so4503312pxi.4
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2009 01:16:42 -0800 (PST)
In-Reply-To: <20091104082808.GA6224@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 4, 2009 at 4:28 PM, Jarek Poplawski <jarkao2@gmail.com> wro=
te:
>> >
>> > If it's really necessary you should present some test case fixed b=
y
>> > your patch, I guess.
>> >
>> > In the meantime let's consider what could be broken:
>> > class 1:1 (parent) rate 10 packets/sec
>> > class 1:2 rate 5 packets/sec ceil 10 packets/sec
>> > class 1:3 rate 5 packets/sec ceil 10 packets/sec
>> >
>> > class 1:2 doesn't use all its rate, and sends every other second
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0(in even seconds)
>> > class 1:3 sends 10 packets during the first second, so with your
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0patch it will use its tokens for 2 seco=
nds
>> > class 1:2 uses its rate in the second second..., so class 1:1
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0can't lend anything
>> > class 1:3 can only borrow, so it won't be able to send during
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0this second anything
>> >
>> > So, the effect would be class 1:3 sending every odd second 10 pack=
ets
>> > while every even second - nothing...
>>
>> class 1:3 can send, as its parent rate is 10, but class 1:2 only use=
s
>> half of it, and class 1:1 is still in HTB_CAN_SEND mode.
>>
>> The result is, hasn't any difference with or without my patch :
>> class 1:1 sends 10 packets in odd seconds, and 5 packets in even sec=
onds.
>
> I guess you meant class 1:3.

You are right. :)

> and there is a difference: it sends 5
> packets in even seconds only if it manages to borrow from 1:1, but
> it's not _guaranteed_ at all. In this particular case it's quite
> probable class 1:2 will send 10 packets in even seconds instead, or
> with some finer borrowing control it could be: class 1:2 8 packets,
> class 1:3 2 packets, as well.

It is just correct. You focus on 1 second fairness, while I focus on 2
seconds fairness.

>
>> class 1:2 sends 5 packets in even seconds.
>> class 1:1 (parent) sends 10 packets in every second.
>>
>> Let's think this case in another way: which class sends packets in
>> even seconds first, class 1:2 or class 1:3.
>> With my patch, as 1:3 in HTB_MAY_BORROW mode, and 1:2 in HTB_CAN_SEN=
D
>> mode, so 1:2 sends all its 5 packets first.
>> Without my patch, as 1:2 and 1:3 are both in HTB_CAN_SEND mode, the
>> sequence is undetermined. In other word, 1:2 and 1:3 are treated
>> fairly, and it isn't fair for 1:2, because 1:2 sends nothing in odd
>> seconds, and has no deficit in rate as 1:3.
>
> The token bucket (cl->buffer) is just to account distinctly when a
> class is entitled to send and when it actually does send within its
> rate. The fairness is controlled by classes itself with HTB_CAN_SEND
> state. Using this bucket to account for borrowed sending deprives us
> of this precise information. "The fairness" would be controlled by
> priorities of borrowing instead (see above).
>
The token bucket and ctoken bucket both use cl->mbuffer to control
rate granularities. If we don't account token bucket when the
corresponding class in HTB_MAY_BORROW mode, the cl->mbuffer will
become useless.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
