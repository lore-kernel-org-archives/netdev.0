From: Ben Greear <greearb@candelatech.com>
Subject: Re: IPv4 multicast and mac-vlans acting weird on 3.0.4+
Date: Wed, 05 Oct 2011 15:35:07 -0700
Message-ID: <4E8CDB9B.6010900@candelatech.com>
References: <4E8C89EE.3090600@candelatech.com>  <1317844449.3457.3.camel@edumazet-laptop>  <4E8CB990.1010406@candelatech.com>  <1317845835.3457.5.camel@edumazet-laptop>  <4E8CBBD6.3080500@candelatech.com>  <1317846693.3457.11.camel@edumazet-laptop>  <4E8CC474.7050803@candelatech.com> <1317850603.3457.21.camel@edumazet-laptop> <4E8CD180.5010905@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:39694 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932231Ab1JEWfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 18:35:10 -0400
In-Reply-To: <4E8CD180.5010905@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2011 02:52 PM, Ben Greear wrote:
> On 10/05/2011 02:36 PM, Eric Dumazet wrote:
>> Le mercredi 05 octobre 2011 =C3=A0 13:56 -0700, Ben Greear a =C3=A9c=
rit :
>>
>>> Wouldn't you have the same problem with two real Ethernet interface=
s on
>>> the same LAN, or two 802.1Q devices for that matter? The addrs will=
 all
>>> be the same in that case too?
>>>
>>
>> Usually multicast is coupled with routing.
>>
>> A JOIN message from your app wont be sent on all interfaces...
>
> It will be if you open two sockets and bind each one of them
> to a network device, at least as far as I can tell.
>
>>
>> But yes, we might have a similar issue with regular vlans.
>>
>> Probably nobody noticed yet. Just say no to fragments :)
>
> Heh, it's regression testing time..we're trying all the weird
> stuff this week :)
>
>>> Also, if I have just a single mac-vlan active (the other 3 are 'ifc=
onfig foo down'),
>>> I still see the problem with mcast.
>>>
>>
>> Thats another bug : macvlan doesnt test IFF_UP on broadcasts, only f=
or
>> unicast messages. Please test following patch.
>>
>>> From what you describe, I am thinking I may be hitting a different
>>> issue. Any ideas on how to figure out why exactly the NF_HOOK isn't
>>> calling the ip_rcv_finish method?
>>>
>>
>> Really I believe I tried to explain the thing already...
>>
>> ip_local_deliver() -> ip_defrag() :
>
> It seems that netfilter is reporting the pkt as NF_STOLEN, probably
> because of the nf_ct_ipv4_gather_frags (which ends up calling ip_defr=
ag)
> logic in nf_defrag_ipv4.c, line 86 or so. I'm adding more debugging
> to verify this.

Ok, this is definitely the problem.  Also, even if you have a single
mac-vlan, you will still have this problem because the underlying devic=
e
will get a copy first.  So, your patch doesn't solve my particular prob=
lem,
but it does appear to be correct.

If someone wants to cook up macvlan-ip-defrag patch I'll be happy
to test it.  But, as far as I can tell, this problem can happen on
any two interfaces.  The reason that some of mine work (.1q vlans)
and macvlan didn't is probably because those were separated by
some virtual network links that imparted extra delay...so the
vlan consumed all its fragments and passed the complete pkt up
the stack before the mac-vlan ever saw the initial frame.

With this in mind, it seems that using multiple udp multicast
sockets bound to specific devices is fundamentally broken for
fragmented packets.

I have no pressing need for this feature, so now that I better understa=
nd
the problem I can just document it and move on to other things.

Thanks for all the help.

Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
