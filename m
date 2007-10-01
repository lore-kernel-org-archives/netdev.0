From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: 2.6.21 -> 2.6.22 & 2.6.23-rc8 performance regression
Date: Mon, 01 Oct 2007 10:20:07 +0200
Message-ID: <4700ADB7.7050102@cosmosbay.com>
References: <200709301425.37564.nickpiggin@yahoo.com.au> <20070930223503.M8966@nuclearcat.com> <47008CB0.7010808@cosmosbay.com> <20071001.001259.28812610.davem@davemloft.net> <20071001080339.M21850@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Denys <nuclearcat@nuclearcat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753753AbXJAIXe@vger.kernel.org>
In-Reply-To: <20071001080339.M21850@nuclearcat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys a =C3=A9crit :
> Well, i can play a bit more on "live" servers. I have now hot-swap se=
rver with
> full gentoo,  where i can rebuild any kernel you want, with any appli=
ed patch.
> But it looks more like not overhead, load becoming high too "spiky", =
and it is
> not just permantenly higher. Also it is not normal that all system be=
coming
> unresposive (for example ping 127.0.0.1 becoming 300ms for period, wh=
en usage
> softirq jumps to 100%).
>
>  =20
Could you try a pristine 2.6.22.9 and some patch in=20
secure_tcp_sequence_number() like :

--- drivers/char/random.c.orig 2007-10-01 10:18:42.000000000 +0200
+++ drivers/char/random.c 2007-10-01 10:19:58.000000000 +0200
@@ -1554,7 +1554,7 @@
* That's funny, Linux has one built in! Use it!
* (Networks are faster now - should this be increased?)
*/
- seq +=3D ktime_get_real().tv64;
+ seq +=3D ktime_get_real().tv64 / 1000;
#if 0
printk("init_seq(%lx, %lx, %d, %d) =3D %d\n",
saddr, daddr, sport, dport, seq);

Thank you


> On Mon, 01 Oct 2007 00:12:59 -0700 (PDT), David Miller wrote
>  =20
>> From: Eric Dumazet <dada1@cosmosbay.com>
>> Date: Mon, 01 Oct 2007 07:59:12 +0200
>>
>>    =20
>>> No problem here on bigger servers, so I CC David Miller and netdev
>>> on this one.  AFAIK do_gettimeofday() and ktime_get_real() should
>>> use the same underlying hardware functions on PC and no performance
>>> problem should happen here.
>>>      =20
>> One thing that jumps out at me is that on 32-bit (and to a certain
>> extent on 64-bit) there is a lot of stack accesses and missed
>> optimizations because all of the work occurs, and gets expanded,
>> inside of ktime_get_real().
>>
>> The timespec_to_ktime() inside of there constructs the ktime_t retur=
n
>> value on the stack, then returns that as an aggregate to the caller.
>>
>> That cannot be without some cost.
>>
>> ktime_get_real() is definitely a candidate for inlining especially i=
n
>> these kinds of cases where we'll happily get computations in local
>> registers instead of all of this on-stack nonsense.  And in several
>> cases (if the caller only needs the tv_sec value, for example)
>> computations can be elided entirely.
>>
>> It would be constructive to experiment and see if this is in fact=20
>> part of the problem.
>>    =20
>
>
> --
> Denys Fedoryshchenko
> Technical Manager
> Virtual ISP S.A.L.
>
>
>  =20
