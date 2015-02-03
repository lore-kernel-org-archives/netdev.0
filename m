From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCHv2 net] net: restore lro after device detached from bridge
Date: Tue, 03 Feb 2015 09:37:31 +0100
Message-ID: <54D088CB.8090907@redhat.com>
References: <1422621209-23222-1-git-send-email-fan.du@intel.com> <54CBEE24.8000603@redhat.com> <54CEDEDC.7060507@gmail.com> <54CF52D6.90701@redhat.com> <54D0740A.6050701@gmail.com>
Reply-To: alexander.h.duyck@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, bhutchings@solarflare.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fengyuleidian0615@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53190 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933405AbbBCIhm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 03:37:42 -0500
In-Reply-To: <54D0740A.6050701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2015 08:08 AM, Fan Du wrote:
> =E4=BA=8E 2015=E5=B9=B402=E6=9C=8802=E6=97=A5 18:35, Alexander Duyck =
=E5=86=99=E9=81=93:
>> On 02/01/2015 06:20 PM, Fan Du wrote:
>>> =E4=BA=8E 2015=E5=B9=B401=E6=9C=8831=E6=97=A5 04:48, Alexander Duyc=
k =E5=86=99=E9=81=93:
>>>> On 01/30/2015 04:33 AM, Fan Du wrote:
>>>>> Either detaching a device from bridge or switching a device
>>>>> out of FORWARDING state, the original lro feature should
>>>>> possibly be enabled for good reason, e.g. hw feature like
>>>>> receive side coalescing could come into play.
>>>>>
>>>>> BEFORE:
>>>>> echo 1 > /proc/sys/net/ipv4/conf/ens806f0/forwarding && ethtool -=
k=20
>>>>> ens806f0 | grep large
>>>>> large-receive-offload: off
>>>>>
>>>>> echo 0 > /proc/sys/net/ipv4/conf/ens806f0/forwarding && ethtool -=
k=20
>>>>> ens806f0 | grep large
>>>>> large-receive-offload: off
>>>>>
>>>>> AFTER:
>>>>> echo 1 > /proc/sys/net/ipv4/conf/ens806f0/forwarding && ethtool -=
k=20
>>>>> ens806f0 | grep large
>>>>> large-receive-offload: off
>>>>>
>>>>> echo 0 > /proc/sys/net/ipv4/conf/ens806f0/forwarding && ethtool -=
k=20
>>>>> ens806f0 | grep large
>>>>> large-receive-offload: on
>>>>>
>>>>> Signed-off-by: Fan Du <fan.du@intel.com>
>>>>> Fixes: 0187bdfb0567 ("net: Disable LRO on devices that are=20
>>>>> forwarding")
>>>>
>>>
>>>> First off this isn't a "fix".  This is going to likely break more =
than
>>>> it fixes.  The main reason why LRO is disabled is because it can c=
ause
>>>> more harm then it helps.  Since GRO is available we should err on =
the
>>>> side of caution since enabling LRO/RSC can have undesirable side=20
>>>> effects
>>>> in a number of cases.
>>>
>>> I think you are talking about bad scenarios when net device is=20
>>> attached to a bridge.
>>> Then what's the good reason user has to pay extra cpu power for=20
>>> using GRO, instead
>>> of using hw capable LRO/RSC when this net device is detached from=20
>>> bridge acting as
>>> a standalone NIC?
>>>
>>> Note, SRC is defaulted to *ON* in practice for ALL ixgbe NICs, as=20
>>> same other RSC capable
>>> NICs. Attaching net device to a bridge _once_ should not changed it=
s=20
>>> default configuration,
>>> moreover it's a subtle change without any message that user won't=20
>>> noticed at all.
>
>> No, RSC only has benefits for IPv4/TCP large packets.  However
>> historically there have been issues seen w/ small packet performance
>> with RSC enabled.
>
> Only when parallel client exceeds 4, gro trumps lro performance on my=
=20
> testbed for small packets.
> The difference comes from the fact that TCP RSS hash flows from=20
> clients into different NIC queues
> for multiple cpu, while RSC engine inside NIC has limit resource=20
> compared with that of cpu used by gro.
>
> NICs: 82599EB
> server:ipserf -s -B 192.168.5.1
> client:iperf  -c 192.168.5.1 -i 1 -M 100 -P x
>
> -P   Bandwidth/lro on        Bandwidth/lro off
>                gro off                 gro on
>
> 1     2.31 Gbits/sec           947 Mbits/sec
> 2     3.09 Gbits/sec          1.97 Gbits/sec
> 3     3.19 Gbits/sec          2.70 Gbits/sec
> 4     3.16 Gbits/sec          3.39 Gbits/sec
> 5     3.23 Gbits/sec          3.33 Gbits/sec
> 6     3.19 Gbits/sec          3.74 Gbits/sec
> 7     3.18 Gbits/sec          3.88 Gbits/sec
> 8     3.17 Gbits/sec          3.24 Gbits/sec
> 9     3.16 Gbits/sec          3.70 Gbits/sec
> 10    3.15 Gbits/sec          3.76 Gbits/sec
> 11    3.10 Gbits/sec          4.03 Gbits/sec
> 12    3.11 Gbits/sec          3.13 Gbits/sec
> 13    3.12 Gbits/sec          4.12 Gbits/sec
> 14    3.07 Gbits/sec          4.04 Gbits/sec
> 15    3.03 Gbits/sec          3.14 Gbits/sec
> 16    2.99 Gbits/sec          3.93 Gbits/sec
>
>
>
>
> Some have been addressed, however there are still

The point I think you are not getting is that bulk throughput=20
performance does not justify enabling a feature that may impact=20
stability or possibly harm small packet performance.

There are more reasons than routing and bridging to disable LRO. Those=20
two reasons though were so bad that we couldn't allow end users to=20
possibly encounter them so we disabled the feature for them.

There are a number of other cases where LRO might be disabled as in the=
=20
possible latency case I reported.  As such you should not be enabling=20
LRO just because only two of the possible issues have now been addresse=
d.

It is best to leave this up to the end-user to re-enable.  If you are=20
seeing the feature disabled as a result of some init script on the=20
system you may want to look at re-enabling it as a part of some other=20
init script that you use when disabling routing or bridging.

- Alex
