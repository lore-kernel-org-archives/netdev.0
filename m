From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Wed, 29 Apr 2009 17:26:00 +0200
Message-ID: <49F87188.9000904@cosmosbay.com>
References: <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au> <49EE1C32.1060202@myri.com> <20090422104811.GA30981@gondor.apana.org.au> <49EF39B4.1040607@myri.com> <20090424054557.GA24575@gondor.apana.org.au> <49F1E5C8.7010303@myri.com> <20090427080501.GA21433@gondor.apana.org.au> <20090428061225.GA1591@gondor.apana.org.au> <49F71A00.5090701@myri.com> <20090428152047.GB7549@gondor.apana.org.au> <49F77134.9030907@myri.com> <49F85945.7030900@myri.com> <49F85BF1.1020501@cosmosbay.com> <49F861BF.7060403@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45785 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654AbZD2P0i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 11:26:38 -0400
In-Reply-To: <49F861BF.7060403@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Gallatin a =E9crit :
> Eric Dumazet wrote:
>> Andrew Gallatin a =E9crit :
>>> Andrew Gallatin wrote:
>>>> For variety, I grabbed a different "slow" receiver.  This is anoth=
er
>>>> 2 CPU machine, but a dual-socket single-core opteron (Tyan S2895)
>>>>
>>>> processor       : 0
>>>> vendor_id       : AuthenticAMD
>>>> cpu family      : 15
>>>> model           : 37
>>>> model name      : AMD Opteron(tm) Processor 252
>>> <...>
>>>> The sender was an identical machine running an ancient RHEL4 kerne=
l
>>>> (2.6.9-42.ELsmp) and our downloadable (backported) driver.
>>>> (http://www.myri.com/ftp/pub/Myri10GE/myri10ge-linux.1.4.4.tgz)
>>>> I disabled LRO, on the sender.
>>>>
>>>> Binding the IRQ to CPU0, and the netserver to CPU1 I see 8.1Gb/s w=
ith
>>>> LRO and 8.0Gb/s with GRO.
>>> With the recent patch to fix idle CPU time accounting from LKML app=
lied,
>>> it is again possible to trust netperf's service demand (based on %C=
PU).
>>> So here is raw netperf output for LRO and GRO, bound as above.
>>>
>>> TCP SENDFILE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
>>> hail1-m.sw.myri.com (10.0.130.167) port 0 AF_INET : cpu bind
>>> Recv   Send    Send                          Utilization       Serv=
ice
>>> Demand
>>> Socket Socket  Message  Elapsed              Send     Recv     Send
>    Recv
>>> Size   Size    Size     Time     Throughput  local    remote   loca=
l
> remote
>>> bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/K=
B
>>> us/KB
>>>
>>> LRO:
>>>  87380  65536  65536    60.00      8279.36   8.10     77.55    0.16=
0
> 1.535
>>> GRO:
>>>  87380  65536  65536    60.00      8053.19   7.86     85.47    0.16=
0
> 1.739
>>>
>>> The difference is bigger if you disable TCP timestamps (and thus sh=
rink
>>> the packets headers down so they require fewer cachelines):
>>> LRO:
>>>  87380  65536  65536    60.02      7753.55   8.01     74.06    0.16=
9
> 1.565
>>> GRO:
>>>  87380  65536  65536    60.02      7535.12   7.27     84.57    0.15=
8
> 1.839
>>>
>>>
>>> As you can see, even though the raw bandwidth is very close, the
>>> service demand makes it clear that GRO is more expensive
>>> than LRO.  I just wish I understood why.
>>>
>>
>> What are "vmstat 1" ouputs on both tests ? Any difference on say...
> context switches ?
>=20
> Not much difference is apparent from vmstat, except for a
> lower load and slightly higher IRQ rate from LRO:
>=20
> LRO:
> procs -----------memory---------- ---swap-- -----io---- --system--
> -----cpu------
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us =
sy
> id wa st
>  1  0      0 676960  19280 209812    0    0     0     0 14817   24  0=
 73
> 27  0  0
>  1  0      0 677084  19280 209812    0    0     0     0 14834   20  0=
 73
> 27  0  0
>  1  0      0 676916  19280 209812    0    0     0     0 14833   16  0=
 74
> 26  0  0
>=20
>=20
> GRO:
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us =
sy
> id wa st
>  1  0      0 678244  18008 209784    0    0     0    24 14288   32  0=
 84
> 16  0  0
>  1  0      0 678268  18008 209788    0    0     0     0 14403   22  0=
 85
> 15  0  0
>  1  0      0 677956  18008 209788    0    0     0     0 14331   20  0=
 84
> 16  0  0
>=20
>=20
>=20
>=20
> The real difference is visible mainly from mpstat on the CPU handing =
the
> interrupts where you see softirq is much higher:
>=20
> LRO:
> 07:15:16     CPU   %user   %nice    %sys %iowait    %irq   %soft  %st=
eal
>   %idle    intr/s
> 07:15:17       0    0.00    0.00    0.00    0.00    0.00   45.00    0=
=2E00
>   55.00  12907.92
> 07:15:18       0    0.00    0.00    1.00    0.00    2.00   43.00    0=
=2E00
>   54.00  12707.92
> 07:15:19       0    0.00    0.00    1.00    0.00    0.00   46.00    0=
=2E00
>   53.00  12825.00
>=20
>=20
> GRO
> 07:11:59     CPU   %user   %nice    %sys %iowait    %irq   %soft  %st=
eal
>   %idle    intr/s
> 07:12:00       0    0.00    0.00    0.00    0.00    0.99   66.34    0=
=2E00
>   32.67  12242.57
> 07:12:01       0    0.00    0.00    0.00    0.00    1.01   66.67    0=
=2E00
>   32.32  12220.00
> 07:12:02       0    0.00    0.00    0.99    0.00    0.99   65.35    0=
=2E00
>   32.67  12336.00
>=20
>=20
> So it is like "something" GRO is doing in the softirq context is more
> expensive than what LRO is doing.


Sure, probably more cache misses or something...

You could try a longer oprofile session (with at least one million samp=
les)
and :

opannotate -a vmlinux >/tmp/FILE

And select 3 or 4 suspect functions : inet_gro_receive() tcp_gro_receiv=
e(),
skb_gro_receive(), skb_gro_header()


