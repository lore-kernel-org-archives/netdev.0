From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: On Linux rate limiting and the magic value of 34.64 Gbps...
Date: Sun, 27 Mar 2011 21:43:33 -0700
Message-ID: <AANLkTikZ7b_nvmm1kjHgP9n-mh6J1XH0QZQvCn-eaojz@mail.gmail.com>
References: <AANLkTi=UTcZ8Q-ULk4CAkbZztYKkDeZHK55LHVDRFH2r@mail.gmail.com>
	<1301037459.2714.570.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59019 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788Ab1C1Eng convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 00:43:36 -0400
Received: by wwa36 with SMTP id 36so3353701wwa.1
        for <netdev@vger.kernel.org>; Sun, 27 Mar 2011 21:43:35 -0700 (PDT)
In-Reply-To: <1301037459.2714.570.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/3/25 Eric Dumazet <eric.dumazet@gmail.com>:
> Le vendredi 25 mars 2011 =C3=A0 00:14 -0700, Maciej =C5=BBenczykowski=
 a =C3=A9crit :
>> Hey,
>>
>> The Linux rate limiting code relies on the rate field of struct tc_r=
atespec.
>> This field is a __u32 and measures rate in "bytes per second".
>>
>> This basically means maximum representable rate is 4GB per second.
>> This is equivalent to 34.36 Gbps and I just ran across that limit wi=
th
>> 40 Gbps (which behaves like 5.64 Gbps because of overflow/truncation=
).
>> Seeing as this structure is exposed to userspace for both read and
>> write via various netlink paths (in cbq, htb, tbf, etc...) there
>> doesn't seem to be a particularly clean way to increase the size of
>> this field. =C2=A0While there is a __reserved field that could
>> theoretically be repurposed as some sort of rate bit shift register,=
 I
>> don't think we can rely on __reserved having been set to zero by
>> userspace (by older programs), and we will definitely see problems
>> with output by programs (tc) that don't expect to have to parse this
>> field to output an understandable rate limit...
>>
>> Anybody have any bright ideas?
>
> Well, netlink is extensible, so we can easily add a new structure, wi=
th
> 64bit fields if necessary.
>
> We did that for 64bit stats already.

I assume you are referring to:

commit 10708f37ae729baba9b67bd134c3720709d4ae62
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Thu Mar 11 09:57:29 2010 +0000

    net: core: add IFLA_STATS64 support

    `ip -s link` shows interface counters truncated to 32 bit. This is
    because interface statistics are transported only in 32-bit quantit=
y
    to userspace. This commit adds a new IFLA_STATS64 attribute that
    exports them in full 64 bit.

    References: http://lkml.indiana.edu/hypermail/linux/kernel/0307.3/0=
215.html
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: David S. Miller <davem@davemloft.net>

include/linux/if_link.h
net/core/rtnetlink.c

That commit is relatively simple, since the statistics structure is
only ever exported by the kernel and is only exported in one location.

Here the situation is significantly more complex, we both export and
import this structure from userspace.  And we do so in many different
locations.

((v2.6.38))$ egrep -r 'qdisc_(get|put)_rtab' . | wc -l
36

It looks like the amount of backward compatibility code would be have
to be quite large.
