From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] UNIX: Do not loop forever at unix_autobind().
Date: Sat, 4 Sep 2010 13:52:13 +0200
Message-ID: <AANLkTiksRN1DweFkwzhaTe7fUayKEDrjHzn7xSScikV7@mail.gmail.com>
References: <201008212101.IJG87048.QMOHFtSOVOLFFJ@I-love.SAKURA.ne.jp>
	<AANLkTi=oWoHUmm_3xkRY7UzoXTuptKvUHzn0gK2WDiSa@mail.gmail.com>
	<201008302227.DJH30258.OQFMFtFJOOVSHL@I-love.SAKURA.ne.jp>
	<1283370450.2484.19.camel@edumazet-laptop>
	<201009040658.o846wxnU028775@www262.sakura.ne.jp>
	<1283584269.3402.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:58013 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706Ab0IDLwO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 07:52:14 -0400
Received: by qwh6 with SMTP id 6so2650683qwh.19
        for <netdev@vger.kernel.org>; Sat, 04 Sep 2010 04:52:13 -0700 (PDT)
In-Reply-To: <1283584269.3402.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/9/4 Eric Dumazet <eric.dumazet@gmail.com>:
> Le samedi 04 septembre 2010 =C3=A0 15:58 +0900, Tetsuo Handa a =C3=A9=
crit :
>> From a67ccbb8033993df29f26bde9944e37bffe4fc1b Mon Sep 17 00:00:00 20=
01
>> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>> Date: Sat, 4 Sep 2010 15:22:22 +0900
>> Subject: [PATCH] UNIX: Do not loop forever at unix_autobind().
>>
>> We assumed that unix_autobind() never fails if kzalloc() succeeded.
>> But unix_autobind() allows only 1048576 names. If /proc/sys/fs/file-=
max is
>> larger than 1048576 (e.g. systems with more than 10GB of RAM), a loc=
al user can
>> consume all names using fork()/socket()/bind().
>>
>> If all names are in use, those who call bind() with addr_len =3D=3D =
sizeof(short)
>> or connect()/sendmsg() with setsockopt(SO_PASSCRED) will continue
>>
>> =C2=A0 while (1)
>> =C2=A0 =C2=A0 =C2=A0 yield();
>>
>> loop at unix_autobind() till a name becomes available.
>> This patch changes unix_autobind() to fail if all names are in use.
>>
>> Note that currently a local user can consume 2GB of kernel memory if=
 the user
>> is allowed to create and autobind 1048576 UNIX domain sockets. We sh=
ould
>> consider adding some restriction for autobind operation.
[cut patch]
> Sorry, this wont work very well if you have many processes using
> autobind(). Some of them will loop many time before hitting
> "stop_ordernum".
>
> unsigned int counter;
>
> ...
>
> if (++maxtries =3D=3D 1<<20) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0...
> }
>
>
> This is a pathological situation. We are not forced to give a success=
ful
> autobind() when so many sockets are in use, even if some slots are
> available.

Is there any specific requirement on generated names for auto-bind?
Wouldn't it be easier and more efficient to use some pseudo-random
name. i.e. derived from current time and/or owning process state?

Best Regards,
Micha=C5=82 Miros=C5=82aw
