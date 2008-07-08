From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v3 2/2] hfsc: add link layer overhead adaption
Date: Tue, 08 Jul 2008 17:59:06 +0200
Message-ID: <48738ECA.9050703@trash.net>
References: <20080703220311.30053.63477.stgit@fate.lan>	<20080703220317.30053.87947.stgit@fate.lan> <487203B4.4030701@trash.net> <20080708141135.174942dv1q2og4o4@hayate.ip6>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64921 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753753AbYGHQKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 12:10:21 -0400
In-Reply-To: <20080708141135.174942dv1q2og4o4@hayate.ip6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jussi Kivilinna wrote:
> Quoting "Patrick McHardy" <kaber@trash.net>:
>>
>> This means HFSC will use other packet sizes as inner qdiscs, policers,
>> statistics etc, which I don't like very much. My original patch used
>> the size tables to calculate the size when enqueing to the root qdisc
>> and stored it in the cb, so all qdiscs in the hierarchy can use the
>> same size.
>
> With this patch I have tried to make HFSC support link layer emulation 
> in same way as done in HTB with rate table, so that overhead is 
> defined on leaf qdisc (if have understood right).

The difference is that with this approach you are actually
able to make the entire qdisc hierarchy use the same size
for calculations/statistics/etc. The rate tables only work
in TBF based qdiscs and policers (which was always one of
my complaints).

>
> I have used this patch to have different overhead between qdisc leafs 
> to account for extra overhead of ipv6-in-ipv4 tunnel (redirecting 
> traffic to IMQ device and filtering ipv4&ipv6 to corresponding leafs). 
> If overhead/linklayer is defined on root qdisc, this wouldn't be 
> possible?

You could override the size in inner classes and qdiscs.
Having an optional size table per qdisc would make this
consistent from a user perspective with the top-level
size calculation. (And I agree that including tunnel
overhead makes sense).

>
> I'm not too happy about statistics being affected either, I'll look in 
> to it.
>
>>> @@ -987,9 +997,11 @@ hfsc_change_usc(struct hfsc_class *cl, struct  
>>> tc_service_curve *usc,
>>> }
>>>  static const struct nla_policy hfsc_policy[TCA_HFSC_MAX + 1] = {
>>> -    [TCA_HFSC_RSC]    = { .len = sizeof(struct tc_service_curve) },
>>> -    [TCA_HFSC_FSC]    = { .len = sizeof(struct tc_service_curve) },
>>> -    [TCA_HFSC_USC]    = { .len = sizeof(struct tc_service_curve) },
>>> +    [TCA_HFSC_RSC]        = { .len = sizeof(struct 
>>> tc_service_curve) },
>>> +    [TCA_HFSC_FSC]        = { .len = sizeof(struct 
>>> tc_service_curve) },
>>> +    [TCA_HFSC_USC]        = { .len = sizeof(struct 
>>> tc_service_curve) },
>>> +    [TCA_HFSC_SZOPTS]    = { .len = sizeof(struct tc_sizespec) },
>>> +    [TCA_HFSC_STAB]        = { .type = NLA_BINARY, .len = 
>>> TC_STAB_SIZE },
>>
>> Why are these two separate attributes?
>
> I copied qdisc_get_rtab() to qdisc_get_stab() and qdisc_get_rtab uses 
> nla_data(tab) to get the buffer. Should use single attribute instead?
> I have worked on patch that would merge qdisc_get_rtab/stab to generic 
> qdisc_get_xtab supporting both types of link layer emulation tables. 
> With single attribute here, patch wouldn't work so easily.

Right, I forgot that rtabs also use two attribures. Well,
usually they use one attribute and one structure embedded in
their base structure, but only because they were using RTABs
from the beginning. So that looks OK.


