From: Ofer Heifetz <oferh@marvell.com>
Subject: RE: Splice status
Date: Tue, 13 Jul 2010 14:41:39 +0300
Message-ID: <EE71107DF0D1F24FA2D95041E64AB9E8ED254E7B66@IL-MB01.marvell.com>
References: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B63A@IL-MB01.marvell.com>
 	<AANLkTimbVY2xhIiYXFvphajuZyn8_PJ0gOqf8VfW-NsM@mail.gmail.com>
 	<EE71107DF0D1F24FA2D95041E64AB9E8ED2541B66E@IL-MB01.marvell.com>
 	<1278334254.2877.158.camel@edumazet-laptop>
 <AANLkTim_eBmT-6HmkqG5d7k0jjrGKAFBjzqVCricTpgK@mail.gmail.com>
 	<1278388580.2466.305.camel@edumazet-laptop>
 <AANLkTinRnDwMOS5NrmzKqYZpczG4nfHSvKA9Gw-_UUzO@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jens Axboe <axboe@kernel.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from galiil.marvell.com ([199.203.130.254]:62111 "EHLO
	galiil.marvell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253Ab0GMLnA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 07:43:00 -0400
In-Reply-To: <AANLkTinRnDwMOS5NrmzKqYZpczG4nfHSvKA9Gw-_UUzO@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I wanted to let you know that I have been testing Samba splice on Marve=
ll 6282 SoC on 2.6.35_rc3 and noticed that it gave worst performance th=
an not using it and also noticed that on re-writing file the iowait is =
high.

iometer using 2G file (file is created before test)

Splice  write cpu% iow%
-----------------------
 No     58    98    0
Yes     14   100   48

iozone using 2G file (file created during test)

Splice  write cpu% iow%  re-write cpu% iow% =20
-------------------------------------------
 No     35    85    4    58.2     70    0
Yes     33    85    4    15.7    100   58

Any clue why splice introduces a high iowait?
I noticed samba uses up to 16K per splice syscall, changing the samba t=
o try more did not help, so I guess it is a kernel limitation.

-Ofer

-----Original Message-----
=46rom: Changli Gao [mailto:xiaosuo@gmail.com]=20
Sent: Sunday, July 11, 2010 4:09 PM
To: Eric Dumazet
Cc: Jens Axboe; Ofer Heifetz; netdev@vger.kernel.org
Subject: Re: Splice status

On Tue, Jul 6, 2010 at 11:56 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 06 juillet 2010 =E0 10:01 +0800, Changli Gao a =E9crit :
>>
>> If we don't drain the pipe before calling splice(2), the data splice=
d
>> from pipe maybe not be what we expect. Then data corruption occurs.
>>
>
> This is not true. A pipe is a pipe is a buffer. You dont need it to b=
e
> empty when using it. Nowhere in documentation its stated.

Do you mean splice(2) empties the pipe buffer before using it as an
output buffer? If not, the pipe draining is needed to avoid data
corruption.

>
> However, a single skb can fill a pipe, even if "its empty"
>

Yea. Because tcp_splice_read() doesn't know if the __tcp_splice_read
returns due to pipe fulling.

>
>> >
>> > splice(sock, pipe) can block if caller dont use appropriate "non
>> > blocking pipe' splice() mode, even if pipe is empty before a splic=
e()
>> > call.
>>
>> I don't think it is expected. The code of sys_recvfile is much like
>> the sendfile(2) implementation in kernel. If sys_recvfile may block
>> without non_block flag, sendfile(2) may block too.
>
> Then it would be a bug. You might fix it easily.

It seems reasonable. I'll fix it.

>
> Using splice() correctly (ie, not blocking on sock->pipe) should work
> too.
>
> Again, you can block on splice(sock, pipe), iff you have a second thr=
ead
> doing the opposite (pipe->file) in parallel to unblock you. But samba
> recvfile algo is using a single thread.
>




--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
