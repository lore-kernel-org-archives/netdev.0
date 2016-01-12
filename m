From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 12 Jan 2016 23:26:29 +0100
Message-ID: <56957D95.1090307@stressinduktion.org>
References: <5682665A.7090102@list.ru> <56951D1D.5080602@stressinduktion.org>
 <56952147.80201@stressinduktion.org> <569523C0.5040504@list.ru>
 <56952593.8040409@stressinduktion.org> <56952D01.6070204@list.ru>
 <56953059.1020506@list.ru> <569532A6.1070905@stressinduktion.org>
 <56953560.9050906@list.ru> <56953740.1090204@stressinduktion.org>
 <569538FD.2060200@list.ru> <56953C27.4030405@stressinduktion.org>
 <5695655A.60509@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:43289 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753729AbcALW0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 17:26:32 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 2EA6F20AC1
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 17:26:31 -0500 (EST)
In-Reply-To: <5695655A.60509@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 12.01.2016 21:43, Stas Sergeev wrote:
> 12.01.2016 20:47, Hannes Frederic Sowa =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
>> On 12.01.2016 18:33, Stas Sergeev wrote:
>>> 12.01.2016 20:26, Hannes Frederic Sowa =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
>>>> On 12.01.2016 18:18, Stas Sergeev wrote:
>>>>> 12.01.2016 20:06, Hannes Frederic Sowa =D0=BF=D0=B8=D1=88=D0=B5=D1=
=82:
>>>>>> On 12.01.2016 17:56, Stas Sergeev wrote:
>>>>>>> 12.01.2016 19:42, Stas Sergeev =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>>>>>> Also the rfc1620 you pointed, seems to be saying this:
>>>>>>>
>>>>>>>                    A Redirect message SHOULD be silently
>>>>>>> discarded if the
>>>>>>>                    new router address it specifies is not on th=
e
>>>>>>> same
>>>>>>>                    connected (sub-) net through which the
>>>>>>> Redirect arrived,
>>>>>>>                    or if the source of the Redirect is not the
>>>>>>> current
>>>>>>>                    first-hop router for the specified destinati=
on.
>>>>>>>
>>>>>>> It seems, this is exactly the rule we were trying to find
>>>>>>> during the thread. And it seems violated, either. Unless I am
>>>>>>> mis-interpreting it, of course.
>>>>>>
>>>>>> If you read on you will read that with shared_media this exact
>>>>>> clause (the first of those) is not in effect any more.
>>>>> OK. But how to get such a redirect to work, if (checked with
>>>>> tcpdump) the packets do not even go to eth0, but to "lo"?
>>>>
>>>> I don't know, the router must be on the same shared medium. I gues=
s
>>>> physical reconfiguration is required?
>>> It is same.
>>> Router 192.168.8.1 has just one ethernet port.
>>> And even on the 192.168.10.202 node I can do:
>>> # arp -a |grep "0.1"
>>> ? (192.168.0.1) at 14:d6:4d:1c:97:3d [ether] on eth0
>>> So even 0.1 is about to be reachable.
>>> Still nothing works.
>>> Should it work if 192.168.0.1 router, to which 8.1 redirects,
>>> has shared_media disabled?
>>
>> Can you check with tcpdump?
> That's what I already did.
> I monitored on 8.1 router and on the node itself,
> and my conclusion was that the packets do not
> even reach the eth0 interface. Instead I captured
> them on "lo" interface, so I assumed such route is
> completely broken.

I didn't check a full featured setup but just did some dirty testing=20
with namespaces and I had correct arp request for the now to be assumed=
=20
on-link router on the external veth.

> If it is not - how can I even see that it exist? How to
> list these redirect routes?

Yeah, that might be a minor issue. The rt_cache procfs files are empty=20
since the deletion of the cache and we probably don't have an interface=
=20
for next hop exceptions, I consider this todo. :) ip route get is your=20
only hope right now.

Anyway, seems like there are problems with redirect timeout somehow. I=20
am investigating this.

> I'd like to do some investigations, but this looks no
> more than a black magic without a proper support
> from tools, proper documentation, etc.

Hmm, so far I think shared_media is behaving like it should, besides=20
maybe it shouldn't be the default setting. Maybe someone who can=20
remember why it is default could chime in?

> And I suspect that shared_media is disabled on a 0.1
> router, so I wonder if this can work at all, even if the node
> is cured to do the right thing with those redirects.
> In a nearby message David Miller says:

Default is that shared_media is enabled, so the chances are relatively=20
high that it is enabled if it is not turned off.

> ---
>
> 2) increasing the chance of successful communication with peers
>
> ---
> If this can't work right when one of the gateways has
> shared_media disabled, then this rule is clearly violated.

It can work right and I think the RFC actually gives examples where it=20
is very useful. Also IPv6 adapts it as the default, so it might make=20
sense to have it as default.

I still consider something broken in your network setup, maybe.

>> ping requires the router to also find a correct way back, so packet
>> can get stuck at a lot of places. Also uRPF is maybe active which ki=
nd
>> of defeats shared_media and please check netfilter.
> I am pretty sure the node has a default ubuntu without
> any special network tweaks, but I'll double-check.

Please do that. Thanks!

Bye,
Hannes
