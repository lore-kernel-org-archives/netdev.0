From: Ben Greear <greearb@candelatech.com>
Subject: Re: IPv4 multicast and mac-vlans acting weird on 3.0.4+
Date: Wed, 05 Oct 2011 13:56:20 -0700
Message-ID: <4E8CC474.7050803@candelatech.com>
References: <4E8C89EE.3090600@candelatech.com>  <1317844449.3457.3.camel@edumazet-laptop>  <4E8CB990.1010406@candelatech.com>  <1317845835.3457.5.camel@edumazet-laptop>  <4E8CBBD6.3080500@candelatech.com> <1317846693.3457.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:56004 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754846Ab1JEU4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 16:56:21 -0400
In-Reply-To: <1317846693.3457.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2011 01:31 PM, Eric Dumazet wrote:
> Le mercredi 05 octobre 2011 =C3=A0 13:19 -0700, Ben Greear a =C3=A9cr=
it :
>> On 10/05/2011 01:17 PM, Eric Dumazet wrote:
>>> Le mercredi 05 octobre 2011 =C3=A0 13:09 -0700, Ben Greear a =C3=A9=
crit :
>>>> On 10/05/2011 12:54 PM, Eric Dumazet wrote:
>>>>> Le mercredi 05 octobre 2011 =C3=A0 09:46 -0700, Ben Greear a =C3=A9=
crit :
>>>>>> This is on a hacked 3.0.4 kernel...
>>>>>>
>>>>>> I am seeing an issue where an IPv4 mcast receiver will not recei=
ve
>>>>>> a 1473 or larger byte mcast message, but will receive a 1472.  T=
he difference
>>>>>> being that 1473 ends up being two packets on the wire.  It works=
 on
>>>>>> 802.1Q VLANs, VETH interfaces and real Ethernet.  It does not wo=
rk
>>>>>> on a mac-vlan hanging off the VETH.
>>>>>>
>>>>>> I see packets received on the macvlan in tshark, and they appear=
 correct.  No
>>>>>> obvious errors in the macvlan port stats or netstat -s,
>>>>>> and the 'ss' tool doesn't appear to support UDP sockets at all.
>>>>>>
>>>>>> So, I'm about to go digging into the code, but if anyone has any
>>>>>> suggestions for places to look, please let me know!
>>>>>>
>>>>>
>>>>> Well, problem is defragmentation and macvlan cooperation.
>>>>>
>>>>> Multicast messages are broadcasted on all macvlan ports.
>>>>>
>>>>> But IP defrag will probably deliver a single final frame.
>>>>>
>>>>> We probably need to handle defrag in macvlan before broadcasting =
to all
>>>>> ports.
>>>>
>>>> I see packets get to this code in ip_input.c (line 467 or so),
>>>> and that printk is mine of course.
>>>>
>>>> 	if ((dev&&   strcmp(dev->name, "rddVR10#0") =3D=3D 0) ||
>>>> 	    (dev&&   strcmp(dev->name, "rddVR10") =3D=3D 0)) {
>>>> 		printk("calling ip_rcv_finish through NF_HOOK, dev: %s, len: %i\=
n",
>>>> 		       dev->name, skb->len);
>>>> 	}
>>>>
>>>> 	return NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, skb, dev, NULL,
>>>> 		       ip_rcv_finish);
>>>>
>>>> But, the macvlan packets never make it to the ip_rcv_finish method=
=2E
>>>>
>>>> I do see a big and a little packet entering this code.
>>>>
>>>> I have no firewall rules that I'm aware of, though there
>>>> is some conn-track logic (though not associated with the
>>>> mac-vlan interface):
>>>
>>> Say you have 10 vlans on your eth0, how many times do you want one
>>> incoming multicast frame being delivered to your application listen=
ing
>>> on 0.0.0.0:port ?
>>
>> How would it work for two Ethernet devices on the same LAN?  I'd
>> say that mac-vlans should mimic that case.
>>
>> And in my case, I'm binding hard to a device&  IP address,
>> so my app should get it once regardless.
>>
>
> OK, but before frame being delivered to your app, it must be
> re-assembled by net/ipv4/inet_fragment.c&  net/ipv4/ip_fragment.c
> machinery.
>
> This machinery uses :
>
> static int ip4_frag_match(struct inet_frag_queue *q, void *a)
> {
>          struct ipq *qp;
>          struct ip4_create_arg *arg =3D a;
>
>          qp =3D container_of(q, struct ipq, q);
>          return  qp->id =3D=3D arg->iph->id&&
>                          qp->saddr =3D=3D arg->iph->saddr&&
>                          qp->daddr =3D=3D arg->iph->daddr&&
>                          qp->protocol =3D=3D arg->iph->protocol&&
>                          qp->user =3D=3D arg->user;
> }
>
> All frames broadcasted (because of multicast code in macvlan) on vlan=
s
> have same saddr/daddr/protocol (and user).

Wouldn't you have the same problem with two real Ethernet interfaces on
the same LAN, or two 802.1Q devices for that matter?  The addrs will al=
l
be the same in that case too?

Also, if I have just a single mac-vlan active (the other 3 are 'ifconfi=
g foo down'),
I still see the problem with mcast.

 From what you describe, I am thinking I may be hitting a different
issue.  Any ideas on how to figure out why exactly the NF_HOOK isn't
calling the ip_rcv_finish method?

> So kernel will discard all redundant copies of frames and deliver one
> copy only to upper stack.

> Check commit 7736d33f4262d437c5 (packet: Add pre-defragmentation supp=
ort
> for ipv4 fanouts) for a possible hint :
>
> We could perform the re-assembly in macvlan code, before doing the
> "broadcast the frame on all ports" part.

Thanks,
Ben


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
