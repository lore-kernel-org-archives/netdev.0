From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v9 net-next 05/12] bridge: Add the ability to configure
 pvid
Date: Mon, 04 Feb 2013 11:59:23 -0500
Message-ID: <510FE8EB.1080503@redhat.com>
References: <1359748930-31475-1-git-send-email-vyasevic@redhat.com> <1359748930-31475-6-git-send-email-vyasevic@redhat.com> <CAHXqBFKXEHjghyDe4UQs4inH55UzWcsz+eWAXR4qFiM7+4yVxw@mail.gmail.com> <CAHXqBFJ3FutyBGNAXPueWLqJncvzNqd69nTJc0nLgUqzFMTWjw@mail.gmail.com> <510C786E.5040406@redhat.com> <CAHXqBFKOpQUam4aPB0mqWFRYONsdAHSU-jxKx9AJqabvCwupNA@mail.gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62809 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753654Ab3BDQ71 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Feb 2013 11:59:27 -0500
In-Reply-To: <CAHXqBFKOpQUam4aPB0mqWFRYONsdAHSU-jxKx9AJqabvCwupNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2013 09:49 AM, Micha=C5=82 Miros=C5=82aw wrote:
> 2013/2/2 Vlad Yasevich <vyasevic@redhat.com>:
>> On 02/01/2013 08:15 PM, Micha=C5=82 Miros=C5=82aw wrote:
>>> 2013/2/2 Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>:
>>>> 2013/2/1 Vlad Yasevich <vyasevic@redhat.com>:
>>>>> A user may designate a certain vlan as PVID.  This means that
>>>>> any ingress frame that does not contain a vlan tag is assigned to
>>>>> this vlan and any forwarding decisions are made with this vlan in=
 mind.
>>>>
>>>> [...]
>>>>>
>>>>>    struct net_port_vlans {
>>>>>           u16                             port_idx;
>>>>> +       u16                             pvid;
>>>>
>>>>
>>>> I'm confused about the implementation. I would expect pvid field i=
n
>>>> net_bridge_port and adding a tag if it isn't there on ingress path=
=2E
>>>> The rest would be just like without PVIDs. But here you pvid field=
 to
>>>> net_port_vlans, and don't do anything with it in receive nor trans=
mit
>>>> path. Does it work? What am I missing?
>>> Found the answer in next patch (you should merge #5 and #6).
>> It was split for incremental testing.  #5 added the ability to set a=
nd
>> delete it without impacting anything.  #6 added the actual work that=
 pvid
>> does.
>>
>>> Still,
>>> the implementation looks overly complicated. If you force the packe=
t
>>> to canonical form on ingress (keeping outer tag in skb->vlan_tci, a=
nd
>>> setting skb->vlan_tci =3D pvid if there is no tag) the code should =
get
>>> simpler.
>>
>>
>> What if there is no outer tag?  That's what the ingress code is doin=
g.
>> If there is no outer tag, pvid is written to vlan_tci.  If there was
>> outer tag in vlan_tci, it's left alone.  This way at the end of ingr=
ess
>> vlan_tci is always set.
>> At egress, we grab that tag and compare it against pvid if any.  If =
it
>> matches, it's stripped.  If it doesn't, we output with the tag thus
>> adding the header.
>>
>> The only thing I can simplify is grab the tci directly at egress, bu=
t
>> that's what the code will do anyway.
>
> ... br_allowed_input(..., struct sk_buff **pskb)
> {
>    *pskb =3D vlan_untag(*pskb);
>    skb =3D *pskb;
>    if (!skb)
>      return 0;
>
>    if (!skb->vlan_tci && (pvid & VLAN_TAG_PRESENT))
>      skb->vlan_tci =3D pvid;
>    return check_vlan_allowed(skb->vlan_tci);
> }

vlan_untag typically already happens for non-accelerated packets, so no=
=20
need to call it again.  We shouldn't really be touching accelerated=20
packets at ingress, because we may have to undo what we've done on=20
egress.  That would be very expensive in case of flooding.

>
> struct sk_buff *br_handle_vlan(..., struct sk_buff *skb)
> {
>     /* we guaranteed in br_allowed_input() that all packets processed
> in bridge code
>      * will be like received with NETIF_F_HW_VLAN_RX feature enabled.=
 */
>     if (skb->vlan_tci & (VLAN_VID_MASK|VLAN_TAG_PRESENT) =3D=3D pvid)
>       skb->vlan_tci =3D 0;  // what about 802.1p?
>     return skb;
> }

This doesn't work for when you should be sending a tagged frame to the=20
bridge device when receive was non-accelerated.  It would mean that the
802.1q header was already stripped, and you have to put it back=20
correctly so that it can go through the vlan interface (think vlan on=20
top of bridge).

>
> BTW, you implement three features: VLAN filtering, PVID handling,
> per-VLAN FDB. Yet there are 10 patches that mix and match parts of th=
e
> implementation.

I've tried to separate them as well as I can.  I guess the only ones ou=
t
of order are 11 and 12.  12 is last on purpose since its contentious an=
d=20
can be easily dropped from the end.  I can and should move 11 in with=20
main vlan filtering code.  Essentially 1-5 would be VLAN filtering, 5 &=
=20
6 would be PVID, and the rest would FDB.

If you can see a better breakdown, I would appreciate it.

Thanks
-vlad

> It's really hard to review this when you have to jump
> between patches to understand whats going on. I don't know what the
> best split would be, but I got the feeling that this is not the
> presented one.
>
> Best Regards,
> Micha=C5=82 Miros=C5=82aw
>
