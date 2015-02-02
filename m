From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCHv2 net] net: restore lro after device detached from bridge
Date: Mon, 02 Feb 2015 02:35:02 -0800
Message-ID: <54CF52D6.90701@redhat.com>
References: <1422621209-23222-1-git-send-email-fan.du@intel.com> <54CBEE24.8000603@redhat.com> <54CEDEDC.7060507@gmail.com>
Reply-To: alexander.h.duyck@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, bhutchings@solarflare.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fengyuleidian0615@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37860 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933141AbbBBKfM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2015 05:35:12 -0500
In-Reply-To: <54CEDEDC.7060507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/01/2015 06:20 PM, Fan Du wrote:
> =E4=BA=8E 2015=E5=B9=B401=E6=9C=8831=E6=97=A5 04:48, Alexander Duyck =
=E5=86=99=E9=81=93:
>> On 01/30/2015 04:33 AM, Fan Du wrote:
>>> Either detaching a device from bridge or switching a device
>>> out of FORWARDING state, the original lro feature should
>>> possibly be enabled for good reason, e.g. hw feature like
>>> receive side coalescing could come into play.
>>>
>>> BEFORE:
>>> echo 1 > /proc/sys/net/ipv4/conf/ens806f0/forwarding && ethtool -k=20
>>> ens806f0 | grep large
>>> large-receive-offload: off
>>>
>>> echo 0 > /proc/sys/net/ipv4/conf/ens806f0/forwarding && ethtool -k=20
>>> ens806f0 | grep large
>>> large-receive-offload: off
>>>
>>> AFTER:
>>> echo 1 > /proc/sys/net/ipv4/conf/ens806f0/forwarding && ethtool -k=20
>>> ens806f0 | grep large
>>> large-receive-offload: off
>>>
>>> echo 0 > /proc/sys/net/ipv4/conf/ens806f0/forwarding && ethtool -k=20
>>> ens806f0 | grep large
>>> large-receive-offload: on
>>>
>>> Signed-off-by: Fan Du <fan.du@intel.com>
>>> Fixes: 0187bdfb0567 ("net: Disable LRO on devices that are forwardi=
ng")
>>
>
>> First off this isn't a "fix".  This is going to likely break more th=
an
>> it fixes.  The main reason why LRO is disabled is because it can cau=
se
>> more harm then it helps.  Since GRO is available we should err on th=
e
>> side of caution since enabling LRO/RSC can have undesirable side eff=
ects
>> in a number of cases.
>
> I think you are talking about bad scenarios when net device is=20
> attached to a bridge.
> Then what's the good reason user has to pay extra cpu power for using=
=20
> GRO, instead
> of using hw capable LRO/RSC when this net device is detached from=20
> bridge acting as
> a standalone NIC?
>
> Note, SRC is defaulted to *ON* in practice for ALL ixgbe NICs, as sam=
e=20
> other RSC capable
> NICs. Attaching net device to a bridge _once_ should not changed its=20
> default configuration,
> moreover it's a subtle change without any message that user won't=20
> noticed at all.

No, RSC only has benefits for IPv4/TCP large packets.  However=20
historically there have been issues seen w/ small packet performance=20
with RSC enabled.  Some have been addressed, however there are still=20
other effects such as increasing latency for receive unless the push=20
flag is set in the frame.

I still say this patch is not valid, even with your changes.  Your=20
performance gain doesn't trump the regressions you would be causing on=20
other peoples platforms.

I would suggest figuring out why you are seeing issues with routing or=20
bridging being enabled and disabled and possibly cleaning up the issue=20
via a script rather than trying to modify the kernel to make it take=20
care of it for you.

- Alex
