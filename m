From: Dave Taht <dave.taht@gmail.com>
Subject: Re: net: Add network priority cgroup
Date: Mon, 14 Nov 2011 13:32:04 +0100
Message-ID: <CAA93jw7tQtBGFMuDiK_pRUqAdfBVqrwbMegR8gh-8KgVb19PWg@mail.gmail.com>
References: <1320868655-32592-1-git-send-email-nhorman@tuxdriver.com>
	<20111114114700.GA27284@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Robert Love <robert.w.love@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:32818 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689Ab1KNMcF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 07:32:05 -0500
Received: by vcbgb30 with SMTP id gb30so402887vcb.19
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2011 04:32:05 -0800 (PST)
In-Reply-To: <20111114114700.GA27284@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2011 at 12:47 PM, Neil Horman <nhorman@tuxdriver.com> w=
rote:
> On Wed, Nov 09, 2011 at 02:57:33PM -0500, Neil Horman wrote:
>> Data Center Bridging environments are currently somewhat limited in =
their
>> ability to provide a general mechanism for controlling traffic prior=
ity.
>> Specifically they are unable to administratively control the priorit=
y at which
>> various types of network traffic are sent.
>>
>> Currently, the only ways to set the priority of a network buffer are=
:
>>
>> 1) Through the use of the SO_PRIORITY socket option
>> 2) By using low level hooks, like a tc action
>>
>> (1) is difficult from an administrative perspective because it requi=
res that the
>> application to be coded to not just assume the default priority is s=
ufficient,
>> and must expose an administrative interface to allow priority adjust=
ment. =A0Such
>> a solution is not scalable in a DCB environment
>>
>> (2) is also difficult, as it requires constant administrative oversi=
ght of
>> applications so as to build appropriate rules to match traffic belon=
ging to
>> various classes, so that priority can be appropriately set. It is fu=
rther
>> limiting when DCB enabled hardware is in use, due to the fact that t=
c rules are
>> only run after a root qdisc has been selected (DCB enabled hardware =
may reserve
>> hw queues for various traffic classes and needs the priority to be s=
et prior to
>> selecting the root qdisc)
>>
>>
>> I've discussed various solutions with John Fastabend, and we saw a c=
group as
>> being a good general solution to this problem. =A0The network priori=
ty cgroup
>> allows for a per-interface priority map to be built per cgroup. =A0A=
ny traffic
>> originating from an application in a cgroup, that does not explicitl=
y set its
>> priority with SO_PRIORITY will have its priority assigned to the val=
ue
>> designated for that group on that interface. =A0This allows a user s=
pace daemon,
>> when conducting LLDP negotiation with a DCB enabled peer to create a=
 cgroup
>> based on the APP_TLV value received and administratively assign appl=
ications to
>> that priority using the existing cgroup utility infrastructure.
>>
>> Tested by John and myself, with good results
>>
>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>> CC: John Fastabend <john.r.fastabend@intel.com>
>> CC: Robert Love <robert.w.love@intel.com>
>> CC: "David S. Miller" <davem@davemloft.net>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>>
>
> Bump, any other thoughts here? =A0Dave T. has some reasonable thought=
s regarding
> the use of skb->priority, but IMO they really seem orthogonal to the =
purpose of
> this change. =A0Any other reviews would be welcome.

Well, in part I've been playing catchup in the hope that lldp and
openlldp and/or this dcb netlink layer that I don't know anything
about (pointers please?) could help somehow to resolve the semantic
mess skb->priority has become in the first place.

I liked what was described here.

"What if we did at least carve out the DCB functionality away from
skb->priority?  Since, AIUI, we're only concerning ourselves with
locally generated traffic here, we're talking
about skbs that have a socket attached to them.  We could, instead of i=
ndexing
the prio_tc_map with skb->priority, we could index it with
skb->dev->priomap[skb->sk->prioidx] (as provided by this patch).  The c=
group
then could be, instead of a strict priority cgroup, a queue_selector cg=
roup (or
something more appropriately named), and we don't have to touch skb->pr=
iority at
all.  I'd really rather not start down that road until I got more opini=
ons and
consensus on that, but it seems like a pretty good solution, one that w=
ould
allow hardware queue selection in systems that use things like DCB to c=
o-exist
with software queueing features."

The piece that still kind of bothered me about the original proposal
(and perhaps this one) was that setting SO_PRIORITY in an app means
'give my packets more mojo'.

Taking something that took unprioritized packets and assigned them and
*them only* to a hardware queue struck me as possibly deprioritizing
the 'more mojo wanted' packets in the app(s), as they would end up in
some other, possibly overloaded, hardware queue.

So a cgroup that moves all of the packets from an application into a
given hardware queue, and then gets scheduled normally according to
skb->priority and friends (software queue, default of pfifo_fast,
etc), seems to make some sense to me. (I wouldn't mind if we had
abstractions for software queues, too, like, I need a software queue
with these properties, find me a place for it on the hardware - but
I'm dreaming)

One open question is where do packets generated from other subsystems
end up, if you are using a cgroup for the app? arp, dns, etc?

So to rephrase your original description from this:

>> Any traffic originating from an application in a cgroup, that does n=
ot explicitly set its
>> priority with SO_PRIORITY will have its priority assigned to the val=
ue
>> designated for that group on that interface.  This allows a user spa=
ce daemon,
>> when conducting LLDP negotiation with a DCB enabled peer to create a=
 cgroup
>> based on the APP_TLV value received and administratively assign appl=
ications to
>> that priority using the existing cgroup utility infrastructure.
> John, Robert, if you're supportive of these changes, some Acks would =
be
> appreciated.

To this:

"Any traffic originating from an application in a cgroup,  will have
its hardware queue  assigned to the value designated for that group on
that interface.  This allows a user space daemon, when conducting LLDP
negotiation with a DCB enabled peer to create a cgroup based on the
APP_TLV value received and administratively assign applications to
that hardware queue using the existing cgroup utility infrastructure."

Assuming we're on the same page here, what the heck is APP_TLV?

> John, Robert, if you're supportive of these changes, some Acks would =
be
> appreciated.


>
>
> Regards
> Neil
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
