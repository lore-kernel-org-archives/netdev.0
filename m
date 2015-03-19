From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: [PATCH V2 0/1] neighbour: Support broadcast ARP in neighbor PROPE
 state
Date: Thu, 19 Mar 2015 10:42:40 +0800
Message-ID: <550A37A0.8060104@windriver.com>
References: <1426143501-30827-1-git-send-email-Yanjun.Zhu@windriver.com> <55013BD4.2080605@windriver.com> <5501518D.2070405@miraclelinux.com> <55093C76.3030208@ericsson.com> <550954A4.2070900@miraclelinux.com> <55096C44.2020604@ericsson.com> <55097C0A.9@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "YOSHIFUJI Hideaki (USAGI Project)" <yoshfuji@linux-ipv6.org>
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kv5ZCJ6Jek6Iux5piO?=
	<hideaki.yoshifuji@miraclelinux.com>,
	Ulf Samuelsson <ulf.samuelsson@ericsson.com>,
	<brian.haley@hp.com>, <davem@davemloft.net>,
	<alexandre.dietsch@windriver.com>,
	<clinton.slabbert@windriver.com>, <kuznet@ms2.inr.ac.ru>,
	<jmorris@namei.org>, <kaber@trash.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:59699 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198AbbCSCnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 22:43:16 -0400
In-Reply-To: <55097C0A.9@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/18/2015 09:22 PM, YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=E6=
=98=8E wrote:
> Hi,
>
> Ulf Samuelsson wrote:
>> On 03/18/2015 11:34 AM, YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=
=E6=98=8E wrote:
>>> Hi,
>>>
>>> Ulf Samuelsson wrote:
>>>>
>>>> On 03/12/2015 09:42 AM, YOSHIFUJI Hideaki wrote:
>>>>> Hello.
>>>>>
>>>>> yzhu1 wrote:
>>>>>> The state machine is in the attachment.
>>>>>> My proposal is rather fix my ancient mistake.
>
>>>>>> Best Regards!
>>>>>> Zhu Yanjun
>>>>>> On 03/12/2015 02:58 PM, Zhu Yanjun wrote:
>>>>>>> V2:
>>>>>>>    set ARP_PROBE_BCAST default N.
>>>>>>>
>>>>>>> V1:
>>>>>>>    Have a problem with an HP router at a certain location, whic=
h
>>>>>>>    is configured to only answer to broadcast ARP requests.
>>>>>>>    That cannot be changed.
>>>>>>>
>>>>>>>    The first ARP request the kernel sends out, is a broadcast=20
>>>>>>> request,
>>>>>>>    which is fine, but after the reply, the kernel sends unicast=
=20
>>>>>>> requests,
>>>>>>>    which will not get any replies.
>>>>>>>
>>>>>>>    The ARP entry will after some time enter STALE state,
>>>>>>>    and if nothing is done it will time out, and be removed.
>>>>>>>    This process takes to long, and I have been told that it is
>>>>>>>    difficult to makes changes that will eventually remove it.
>>>>>>>
>>>>>>>    Have tried to change the state from STALE to INCOMPLETE,=20
>>>>>>> which failed,
>>>>>>>    and then tried to change the state to PROBE which also faile=
d.
>>>>>>>
>>>>>>>    The stack is only sending out unicasts, and never broadcast.
>>>>>>>    Is there any way to get the stack to send out a broadcast AR=
P
>>>>>>>    without having to wait for the entry to be removed?
>>>>>
>>>>> Neighbour subsystem will send multicast probes after unicast
>>>>> probes in NUD_PROBE state if mcast_solicit is more than
>>>>> ucast_solicit.  Try setting net.ipv4.neigh.*.ucast_solicit to
>>>>> the value less than net.ipv4.neigh.*.mcast_solicit, please?
>>>>> e.g.
>>>>>
>>>>> net.ipv4.neigh.eth0.mcast_solicit =3D 3
>>>>> net.ipv4.neigh.eth0.ucast_solicit =3D 1
>>>>>
>>>>> --yoshfuji
>>>>>
>>>> I dont see how, and I would like to focus on code discussion.
>>>>
>>>> Below is simplified pseudo code of the timer handler
>>>> after you have reached REACHABLE the first time.
>>>>
>>>>      "mcast_solicit" is not used at all.
>>>>
>>>> It is only used when in INCOMPLETE state as far as I can tell.
>>>
>>> OK, I found I made this change in 2003:
>>>
>>> From d12fd76789e80ae337408834f45dae7cba23fc55 Mon Sep 17 00:00:00 2=
001
>>> From: Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>
>>> Date: Sun, 6 Jul 2003 23:32:45 +1000
>>> Subject: [PATCH] [NET] Send only unicast NSs in PROBE state.
>>>
>>> ---
>>>  net/core/neighbour.c | 4 +++-
>>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
>>> index c640ad5..001fdb4 100644
>>> --- a/net/core/neighbour.c
>>> +++ b/net/core/neighbour.c
>>> @@ -608,7 +608,9 @@ next_elt:
>>>  static __inline__ int neigh_max_probes(struct neighbour *n)
>>>  {
>>>      struct neigh_parms *p =3D n->parms;
>>> -    return p->ucast_probes + p->app_probes + p->mcast_probes;
>>> +    return (n->nud_state & NUD_PROBE ?
>>> +        p->ucast_probes :
>>> +        p->ucast_probes + p->app_probes + p->mcast_probes);
>>>  }
>>>
>>>
>>> As I recall, I was hesitating adding new sysctl knob, but now I am
>>> okay to have knob to enable mcast probes in PROBE state as well.
>>> (By default, it should NOT send multicast probe (expecially for IPv=
6)
>>> in PROBE state.)
>>>
>>> How about these?
>>> - introduce probe_mcast_probes knob, default to 0.
>>> - Change neigh_max_probes() to reflect that.
>>>
>>> Then, arp_colisit() and ndict_solicit() should send multicast probe=
s
>>> in PROBE state as well, if probe_mcast_probes is set to positive
>>> value.
>>>
>>> Will this work for you?
>>>
>>> Regards,
>>
>> "probe_mcast_probes" as a name sucks...
>>
>> It is also confusing since it is doing something very similar to
>> ucast_solicit, app_solicit and mcast_solicit.
>>
>> As I see it, it should be named "<XXX>_solicit" to show
>> how it is related to the rest of the sysctl entries.
>>
>> If XXX is "bcast", as in my suggestion, is less important.
>>
>> "mcast_probe_solicit" would work for me, but prefer "bcast_solicit".
>
> Sorry, I meant "probe_mcast_solicit", as you see, which denotes
> "mcast_solicit" in PROBE state.  I do not prefer "bcast" because
> 1) it is not a broadcast for IPv6 and 2) it is not descriptive
> about the affected state.
>
>> Your suggestion was my initial suggestion for solution, and after=20
>> consideration
>> by Wind River reviewers it was rejected, since it affected IPv6.
>> Did not check in what way.
>
> The "probe_mcast_solicit" variable can be (and MUST be) set per
> interface, per protocol basis, so I do not think it will affect
> IPv6 if the variable is set properly, and it should be done by
> default.
>
>>
>> The WR proposed solution, which is the one that was sent to the list=
,
>> was to keep neigh_max_probes as is, but add check for "bcast_solicit=
"=20
>> inside
>> the timer handler, which they think makes sure that it affects IPv4=20
>> processing only.
>
> Please do not do this; it becomes more complex.
This can avoid risk to IPv6. I think it should put in the timer handler=
=2E

Best Regards!
Zhu Yanjun

>
> Thanks.
>
> --yoshfuji
>
>
