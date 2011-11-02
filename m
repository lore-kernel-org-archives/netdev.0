From: Karel Rericha <karel@maxtel.cz>
Subject: Re: Quick Fair Queue scheduler maturity and examples
Date: Wed, 2 Nov 2011 10:36:31 +0100
Message-ID: <CAN==1Ro3Va7JHfOoENu=gJqfaktrqLvpo3NWV8=ZB9OKtyfeYQ@mail.gmail.com>
References: <CAN==1RowdZ094pkOA3vbs-fd3g-NSABqaGC3WXSPL8Y0Lqg+fQ@mail.gmail.com>
	<1319716772.2601.26.camel@edumazet-laptop>
	<CAN==1Rq+WEcezLPNPNug2V11nftDkm2=aRKw95u_R8OPGxG72g@mail.gmail.com>
	<1319731732.2601.40.camel@edumazet-laptop>
	<1319732832.2601.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:38626 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619Ab1KBJgc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 05:36:32 -0400
Received: by vws1 with SMTP id 1so234412vws.19
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2011 02:36:31 -0700 (PDT)
In-Reply-To: <1319732832.2601.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/10/27 Eric Dumazet <eric.dumazet@gmail.com>:
> Le jeudi 27 octobre 2011 =E0 18:08 +0200, Eric Dumazet a =E9crit :
>> Le jeudi 27 octobre 2011 =E0 14:46 +0200, Karel Rericha a =E9crit :
>>
>> > Actually I am doing some reseach to replace our main shaping machi=
ne
>> > with 60 000+ htb classes, which now saturates 12 core Xeon Westmer=
e to
>> > 30% (there are five gigabit network ports on each interface affini=
ted
>> > to cores). AFAIK QFQ should be O(1) complexity so it would bring
>> > saturation a requirements for number of cores down considerably (H=
TB
>> > has O(log(N)) complexity).
>> >
>> > I have test machine and about two months to decide if we will stay
>> > with HTB or we will try something else. So it would be VERY helpfu=
l,
>> > if you would search you memory instead your dead disk :-) and send=
 me
>> > some example of QFQ usage, if I can ask for a little of your time.=
 I
>> > promise to have results published here in return.
>> >
>> > Thanks, Karel
>> >
>>
>> That seems a good challenge to me ;)
>>
>> First upgrade to a recent kernel with QFQ included.
>> Also upgrade iproute2 to a recent enough version as well.
>>
>> Then you discover "tc =A0... qfq help" is not that helpful :(
>>
>> # tc qdisc add dev eth3 root qfq help
>> Usage: ... qfq
>>
>> OK, its parameters are :
>>
>> =A0 =A0 =A0 qfq weight num1 [maxpkt BYTES]
>>
>> You should not touch maxpkt, its default value being 2048
>>
>> Oh well, I just tried the obvious and my (remote) machine doesnt ans=
wer
>> to me anymore...
>>
>> Time for a bit of debugging I am afraid :(
>
> Never mind, it was an user error :)
>
> Here is what I used during my tests, I guess you can adapt your
> scripts...
>
> DEV=3Deth3
> RATE=3D"rate 40Mbit"
> TNETS=3D"10.2.2.0/25"
> ALLOT=3D"allot 20000"
>
> tc qdisc del dev dummy0 root 2>/dev/null
>
> tc qdisc add dev $DEV root handle 1: cbq avpkt 1000 rate 1000Mbit \
> =A0 =A0 =A0 =A0bandwidth 1000Mbit
> tc class add dev $DEV parent 1: classid 1:1 \
> =A0 =A0 =A0 =A0est 1sec 8sec cbq allot 10000 mpu 64 \
> =A0 =A0 =A0 =A0rate 1000Mbit prio 1 avpkt 1500 bounded
>
> # output to test nets : =A040 Mbit limit
> tc class add dev $DEV parent 1:1 classid 1:11 \
> =A0 =A0 =A0 =A0est 1sec 8sec cbq $ALLOT mpu 64 =A0 =A0 =A0\
> =A0 =A0 =A0 =A0$RATE prio 2 avpkt 1400 bounded
>
> tc qdisc add dev $DEV parent 1:11 handle 11: =A0\
> =A0 =A0 =A0 =A0est 1sec 8sec qfq
>
> tc filter add dev $DEV protocol ip parent 11: handle 3 \
> =A0 =A0 =A0 =A0flow hash keys rxhash divisor 8
>
> for i in `seq 1 8`
> do
> =A0classid=3D11:$(printf %x $i)
> =A0tc class add dev $DEV classid $classid qfq
> =A0tc qdisc add dev $DEV parent $classid pfifo limit 30
> done
>
> for privnet in $TNETS
> do
> =A0 =A0 =A0 =A0tc filter add dev $DEV parent 1: protocol ip prio 100 =
u32 \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0match ip dst $privnet flowid 1:11
> done
>
> tc filter add dev $DEV parent 1: protocol ip prio 100 u32 \
> =A0 =A0 =A0 =A0match ip protocol 0 0x00 flowid 1:1
>
> iperf -u -c 10.2.2.1 -P 32 -l 50
>
>
>

Thanks for example Eric.

But it only added more confusion to me now :-) I was under impression
(and read somewhere) that QFQ is non work conserving scheduler so I
can use it more or less like HTB or HFSC to set bandwidth constraints
to flows. But from this example (and from sources/patches/papers I try
not to pretend I fully understand) it looks to me like some multiqueue
scheduler with arbitrary number of queues and ability to arbitrary
assign flows to this queues. So some sort of fair division of
available bandwidth to flows without arbitrary bandwidth caps to these
flows. I really dont see what is non work conserving here :-S

Please save my soul and enlighten me because I am at dead end now :-)
