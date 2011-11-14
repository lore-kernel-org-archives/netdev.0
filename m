From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: net: Add network priority cgroup
Date: Mon, 14 Nov 2011 08:38:20 -0800
Message-ID: <4EC143FC.5060704@intel.com>
References: <1320868655-32592-1-git-send-email-nhorman@tuxdriver.com> <20111114114700.GA27284@hmsreliant.think-freely.org> <CAA93jw7tQtBGFMuDiK_pRUqAdfBVqrwbMegR8gh-8KgVb19PWg@mail.gmail.com> <20111114144358.GB27284@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Love, Robert W" <robert.w.love@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59610 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751276Ab1KNQiV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Nov 2011 11:38:21 -0500
In-Reply-To: <20111114144358.GB27284@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2011 6:43 AM, Neil Horman wrote:
> On Mon, Nov 14, 2011 at 01:32:04PM +0100, Dave Taht wrote:
>> On Mon, Nov 14, 2011 at 12:47 PM, Neil Horman <nhorman@tuxdriver.com=
> wrote:
>>> On Wed, Nov 09, 2011 at 02:57:33PM -0500, Neil Horman wrote:
>>>> Data Center Bridging environments are currently somewhat limited i=
n their
>>>> ability to provide a general mechanism for controlling traffic pri=
ority.
>>>> Specifically they are unable to administratively control the prior=
ity at which
>>>> various types of network traffic are sent.
>>>>
>>>> Currently, the only ways to set the priority of a network buffer a=
re:
>>>>
>>>> 1) Through the use of the SO_PRIORITY socket option
>>>> 2) By using low level hooks, like a tc action
>>>>
>>>> (1) is difficult from an administrative perspective because it req=
uires that the
>>>> application to be coded to not just assume the default priority is=
 sufficient,
>>>> and must expose an administrative interface to allow priority adju=
stment.  Such
>>>> a solution is not scalable in a DCB environment
>>>>
>>>> (2) is also difficult, as it requires constant administrative over=
sight of
>>>> applications so as to build appropriate rules to match traffic bel=
onging to
>>>> various classes, so that priority can be appropriately set. It is =
further
>>>> limiting when DCB enabled hardware is in use, due to the fact that=
 tc rules are
>>>> only run after a root qdisc has been selected (DCB enabled hardwar=
e may reserve
>>>> hw queues for various traffic classes and needs the priority to be=
 set prior to
>>>> selecting the root qdisc)
>>>>
>>>>
>>>> I've discussed various solutions with John Fastabend, and we saw a=
 cgroup as
>>>> being a good general solution to this problem.  The network priori=
ty cgroup
>>>> allows for a per-interface priority map to be built per cgroup.  A=
ny traffic
>>>> originating from an application in a cgroup, that does not explici=
tly set its
>>>> priority with SO_PRIORITY will have its priority assigned to the v=
alue
>>>> designated for that group on that interface.  This allows a user s=
pace daemon,
>>>> when conducting LLDP negotiation with a DCB enabled peer to create=
 a cgroup
>>>> based on the APP_TLV value received and administratively assign ap=
plications to
>>>> that priority using the existing cgroup utility infrastructure.
>>>>
>>>> Tested by John and myself, with good results
>>>>
>>>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>>>> CC: John Fastabend <john.r.fastabend@intel.com>
>>>> CC: Robert Love <robert.w.love@intel.com>
>>>> CC: "David S. Miller" <davem@davemloft.net>
>>>> --

Acked-by: John Fastabend <john.r.fastabend@intel.com>

>>>
>>> Bump, any other thoughts here?  Dave T. has some reasonable thought=
s regarding
>>> the use of skb->priority, but IMO they really seem orthogonal to th=
e purpose of
>>> this change.  Any other reviews would be welcome.
>>
>> Well, in part I've been playing catchup in the hope that lldp and
>> openlldp and/or this dcb netlink layer that I don't know anything
>> about (pointers please?) could help somehow to resolve the semantic
>> mess skb->priority has become in the first place.
>>
>> I liked what was described here.
>>
>> "What if we did at least carve out the DCB functionality away from
>> skb->priority?  Since, AIUI, we're only concerning ourselves with
>> locally generated traffic here, we're talking
>> about skbs that have a socket attached to them.  We could, instead o=
f indexing
>> the prio_tc_map with skb->priority, we could index it with
>> skb->dev->priomap[skb->sk->prioidx] (as provided by this patch).  Th=
e cgroup
>> then could be, instead of a strict priority cgroup, a queue_selector=
 cgroup (or
>> something more appropriately named), and we don't have to touch skb-=
>priority at
>> all.  I'd really rather not start down that road until I got more op=
inions and
>> consensus on that, but it seems like a pretty good solution, one tha=
t would
>> allow hardware queue selection in systems that use things like DCB t=
o co-exist
>> with software queueing features."
>>
> I was initially ok with this, but the more I think about it, the more=
 I think
> its just not needed (see further down in this email for my reasoning)=
=2E  John,
> Rob, do you have any thoughts here?
>=20

I agree the original mechanism seems sufficient. skb->priority already =
has
all the qdisc and netfilter infrastructure in place to be used and usin=
g
it to prioritize "steer" packets at queues seems reasonable to me. Usin=
g
the skb->priority this way is not new pfifo_fast uses it to pick a band
and sch_prio does some similar prioritization, mqprio is a multiqueue
variant.

>> The piece that still kind of bothered me about the original proposal
>> (and perhaps this one) was that setting SO_PRIORITY in an app means
>> 'give my packets more mojo'.
>>
>> Taking something that took unprioritized packets and assigned them a=
nd
>> *them only* to a hardware queue struck me as possibly deprioritizing
>> the 'more mojo wanted' packets in the app(s), as they would end up i=
n
>> some other, possibly overloaded, hardware queue.
>>
> I don't really see what you mean by this at all.  Taking packets with=
 no
> priority and assigning them a priority doesn't really have an effect =
on
> pre-prioritized packets.  Or rather it shouldn't.  You can certainly =
create a
> problem by having apps prioritized according to conflicting semantic =
rules, but
> that strikes me as administrative error.  Garbage in...Garbage out.
>=20
>> So a cgroup that moves all of the packets from an application into a
>> given hardware queue, and then gets scheduled normally according to
>> skb->priority and friends (software queue, default of pfifo_fast,
>> etc), seems to make some sense to me. (I wouldn't mind if we had
>> abstractions for software queues, too, like, I need a software queue
>> with these properties, find me a place for it on the hardware - but
>> I'm dreaming)
>>
>> One open question is where do packets generated from other subsystem=
s
>> end up, if you are using a cgroup for the app? arp, dns, etc?
>>
> The overriding rule is the association of an skb to a socket.  If a t=
ransmitted
> frame has skb->sk set in dev_queue_xmit, then we interrogate its prio=
rity index
> as set when we passed through the sendmsg code at the top of the stac=
k.
> Otherwise its behavior is unchanged from its current standpoint.
>=20

Having a queue selection (skb->queue_mapping?) cgroup also would defeat
any hashing across multiple queues. With mqprio we can assign many hard=
ware
queues to a skb->priority.

w.r.t. software queue abstractions don't we already have this? mq and
mqprio enumerate a software qdisc per hardware queue. You can attach
your favorite qdisc to these. This is likely off-topic for this thread =
though.

[...]

> In the end, I think its just plain old more useful to assign priorty =
here than
> some new thing.

I agree.

Thanks,
John


>=20
> Neil
> =20
>>> John, Robert, if you're supportive of these changes, some Acks woul=
d be
>>> appreciated.
>>
>>
>>>
>>>
>>> Regards
>>> Neil
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>>
>>
>> --=20
>> Dave T=E4ht
>> SKYPE: davetaht
>> US Tel: 1-239-829-5608
>> FR Tel: 0638645374
>> http://www.bufferbloat.net
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
