From: Ben Greear <greearb@candelatech.com>
Subject: Re: IPv4 multicast and mac-vlans acting weird on 3.0.4+
Date: Wed, 05 Oct 2011 13:09:52 -0700
Message-ID: <4E8CB990.1010406@candelatech.com>
References: <4E8C89EE.3090600@candelatech.com> <1317844449.3457.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53581 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935116Ab1JEUJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 16:09:53 -0400
In-Reply-To: <1317844449.3457.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2011 12:54 PM, Eric Dumazet wrote:
> Le mercredi 05 octobre 2011 =C3=A0 09:46 -0700, Ben Greear a =C3=A9cr=
it :
>> This is on a hacked 3.0.4 kernel...
>>
>> I am seeing an issue where an IPv4 mcast receiver will not receive
>> a 1473 or larger byte mcast message, but will receive a 1472.  The d=
ifference
>> being that 1473 ends up being two packets on the wire.  It works on
>> 802.1Q VLANs, VETH interfaces and real Ethernet.  It does not work
>> on a mac-vlan hanging off the VETH.
>>
>> I see packets received on the macvlan in tshark, and they appear cor=
rect.  No
>> obvious errors in the macvlan port stats or netstat -s,
>> and the 'ss' tool doesn't appear to support UDP sockets at all.
>>
>> So, I'm about to go digging into the code, but if anyone has any
>> suggestions for places to look, please let me know!
>>
>
> Well, problem is defragmentation and macvlan cooperation.
>
> Multicast messages are broadcasted on all macvlan ports.
>
> But IP defrag will probably deliver a single final frame.
>
> We probably need to handle defrag in macvlan before broadcasting to a=
ll
> ports.

I see packets get to this code in ip_input.c (line 467 or so),
and that printk is mine of course.

	if ((dev && strcmp(dev->name, "rddVR10#0") =3D=3D 0) ||
	    (dev && strcmp(dev->name, "rddVR10") =3D=3D 0)) {
		printk("calling ip_rcv_finish through NF_HOOK, dev: %s, len: %i\n",
		       dev->name, skb->len);
	}

	return NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, skb, dev, NULL,
		       ip_rcv_finish);

But, the macvlan packets never make it to the ip_rcv_finish method.

I do see a big and a little packet entering this code.

I have no firewall rules that I'm aware of, though there
is some conn-track logic (though not associated with the
mac-vlan interface):

[root@lec2010-ath9k-1 ~]# iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination


And, I just reproduced the problem on vanilla linus top-of-tree (3.1.0-=
rc9).


Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
