From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: [PATCHv2 net] net: restore lro after device detached from bridge
Date: Tue, 03 Feb 2015 15:08:58 +0800
Message-ID: <54D0740A.6050701@gmail.com>
References: <1422621209-23222-1-git-send-email-fan.du@intel.com> <54CBEE24.8000603@redhat.com> <54CEDEDC.7060507@gmail.com> <54CF52D6.90701@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, bhutchings@solarflare.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:63230 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933559AbbBCHNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 02:13:12 -0500
Received: by mail-pa0-f48.google.com with SMTP id ey11so92812897pad.7
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2015 23:13:11 -0800 (PST)
In-Reply-To: <54CF52D6.90701@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B402=E6=9C=8802=E6=97=A5 18:35, Alexander Duyck =E5=
=86=99=E9=81=93:
> On 02/01/2015 06:20 PM, Fan Du wrote:
>> =E4=BA=8E 2015=E5=B9=B401=E6=9C=8831=E6=97=A5 04:48, Alexander Duyck=
 =E5=86=99=E9=81=93:
>>> On 01/30/2015 04:33 AM, Fan Du wrote:
>>>> Either detaching a device from bridge or switching a device
>>>> out of FORWARDING state, the original lro feature should
>>>> possibly be enabled for good reason, e.g. hw feature like
>>>> receive side coalescing could come into play.
>>>>
>>>> BEFORE:
>>>> echo 1 > /proc/sys/net/ipv4/conf/ens806f0/forwarding && ethtool -k=
 ens806f0 | grep large
>>>> large-receive-offload: off
>>>>
>>>> echo 0 > /proc/sys/net/ipv4/conf/ens806f0/forwarding && ethtool -k=
 ens806f0 | grep large
>>>> large-receive-offload: off
>>>>
>>>> AFTER:
>>>> echo 1 > /proc/sys/net/ipv4/conf/ens806f0/forwarding && ethtool -k=
 ens806f0 | grep large
>>>> large-receive-offload: off
>>>>
>>>> echo 0 > /proc/sys/net/ipv4/conf/ens806f0/forwarding && ethtool -k=
 ens806f0 | grep large
>>>> large-receive-offload: on
>>>>
>>>> Signed-off-by: Fan Du <fan.du@intel.com>
>>>> Fixes: 0187bdfb0567 ("net: Disable LRO on devices that are forward=
ing")
>>>
>>
>>> First off this isn't a "fix".  This is going to likely break more t=
han
>>> it fixes.  The main reason why LRO is disabled is because it can ca=
use
>>> more harm then it helps.  Since GRO is available we should err on t=
he
>>> side of caution since enabling LRO/RSC can have undesirable side ef=
fects
>>> in a number of cases.
>>
>> I think you are talking about bad scenarios when net device is attac=
hed to a bridge.
>> Then what's the good reason user has to pay extra cpu power for usin=
g GRO, instead
>> of using hw capable LRO/RSC when this net device is detached from br=
idge acting as
>> a standalone NIC?
>>
>> Note, SRC is defaulted to *ON* in practice for ALL ixgbe NICs, as sa=
me other RSC capable
>> NICs. Attaching net device to a bridge _once_ should not changed its=
 default configuration,
>> moreover it's a subtle change without any message that user won't no=
ticed at all.

> No, RSC only has benefits for IPv4/TCP large packets.  However
> historically there have been issues seen w/ small packet performance
> with RSC enabled.

Only when parallel client exceeds 4, gro trumps lro performance on my t=
estbed for small packets.
The difference comes from the fact that TCP RSS hash flows from clients=
 into different NIC queues
for multiple cpu, while RSC engine inside NIC has limit resource compar=
ed with that of cpu used by gro.

NICs: 82599EB
server:ipserf -s -B 192.168.5.1
client:iperf  -c 192.168.5.1 -i 1 -M 100 -P x

-P   Bandwidth/lro on        Bandwidth/lro off
                gro off                 gro on

1     2.31 Gbits/sec           947 Mbits/sec
2     3.09 Gbits/sec          1.97 Gbits/sec
3     3.19 Gbits/sec          2.70 Gbits/sec
4     3.16 Gbits/sec          3.39 Gbits/sec
5     3.23 Gbits/sec          3.33 Gbits/sec
6     3.19 Gbits/sec          3.74 Gbits/sec
7     3.18 Gbits/sec          3.88 Gbits/sec
8     3.17 Gbits/sec          3.24 Gbits/sec
9     3.16 Gbits/sec          3.70 Gbits/sec
10    3.15 Gbits/sec          3.76 Gbits/sec
11    3.10 Gbits/sec          4.03 Gbits/sec
12    3.11 Gbits/sec          3.13 Gbits/sec
13    3.12 Gbits/sec          4.12 Gbits/sec
14    3.07 Gbits/sec          4.04 Gbits/sec
15    3.03 Gbits/sec          3.14 Gbits/sec
16    2.99 Gbits/sec          3.93 Gbits/sec




Some have been addressed, however there are still
> other effects such as increasing latency for receive unless the push
> flag is set in the frame.
>
> I still say this patch is not valid, even with your changes.  Your
> performance gain doesn't trump the regressions you would be causing o=
n
> other peoples platforms.
>
> I would suggest figuring out why you are seeing issues with routing o=
r
> bridging being enabled and disabled and possibly cleaning up the issu=
e
> via a script rather than trying to modify the kernel to make it take
> care of it for you.
> - Alex
