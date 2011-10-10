From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH net-next] macvlan: handle fragmented multicast frames
Date: Mon, 10 Oct 2011 09:53:47 -0700
Message-ID: <4E93231B.2040207@candelatech.com>
References: <4E8C89EE.3090600@candelatech.com>  <1317844449.3457.3.camel@edumazet-laptop>  <4E8CB990.1010406@candelatech.com>  <1317845835.3457.5.camel@edumazet-laptop>  <4E8CBBD6.3080500@candelatech.com>  <1317846693.3457.11.camel@edumazet-laptop>  <4E8CC474.7050803@candelatech.com>  <1317850603.3457.21.camel@edumazet-laptop>  <4E8CD180.5010905@candelatech.com>  <4E8CDB9B.6010900@candelatech.com>  <1317932911.3457.31.camel@edumazet-laptop>  <4E931CEC.5050404@candelatech.com> <1318264891.3227.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53078 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753196Ab1JJQxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 12:53:49 -0400
In-Reply-To: <1318264891.3227.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2011 09:41 AM, Eric Dumazet wrote:
> Le lundi 10 octobre 2011 =C3=A0 09:27 -0700, Ben Greear a =C3=A9crit =
:
>
>> I applied this to Linus' top-of-tree this morning and it does appear
>> to fix the problem for mac-vlans.
>>
>
> Thanks for testing
>
>> I do see this error, but I doubt it has anything to do with your
>> patch:
>>
>> device eth0 entered promiscuous mode
>> device rddVR10 entered promiscuous mode
>> ADDRCONF(NETDEV_CHANGE): rddVR1b: link becomes ready
>>
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
>> [ BUG: lock held when returning to user space! ]
>> ------------------------------------------------
>> ip/3452 is leaving the kernel with locks still held!
>> 1 lock held by ip/3452:
>>    #0:  (rcu_read_lock){.+.+..}, at: [<f8c5336f>] rcu_read_lock+0x0/=
0x26 [ipv6]
>> ADDRCONF(NETDEV_CHANGE): rddVR4b: link becomes ready
>> ADDRCONF(NETDEV_CHANGE): rddVR5b: link becomes ready
>>
>>
>> I have no idea why it doesn't print out a more useful stack
>> trace.  It seems repeatable (2 of 2 reboots so far).  I'm
>> configuring a pretty complex virtual network, with veth devices,
>> xorp instances running ipv4 and ipv6 routing protocols, etc.
>>
>
> Do you have LOCKDEP enabled ?

Yes, as far as I can tell:
[greearb@build-32 linux-2.6.p4s]$ grep LOCKDEP .config
CONFIG_LOCKDEP_SUPPORT=3Dy
CONFIG_LOCKDEP=3Dy

And it doesn't appear to have turned itself off:

[root@lec2010-ath9k-1 ~]# dmesg|grep lockdep
	RCU lockdep checking is enabled.
lockdep: fixing up alternatives.
[root@lec2010-ath9k-1 ~]#

I looked through the kernel debug section of the config, and it
seems normal enough...

But, after this splat, if I run sysrq-d, then it says sysrq is off,
maybe because the splat disabled it?

SysRq : Show Locks Held
INFO: lockdep is turned off.

sysrq-l does show backtraces, so the backtrace logic in general
seems to work fine.

>
>> This is a clean upstream kernel with no outside patches aside from y=
our
>> own.
>
> Hmm, it seems we have an rcu_read_unlock() missing...
>
> Any idea what was done by this "ip" command ?

No, it's called multiple times by my user-space control logic.  Basical=
ly,
it configures around 30 interfaces, some GRE, veth, mac-vlans, .1q vlan=
s, normal ethernet, etc.
Also, I have some ipv6 addrs configured on many of them.

And, setting up routing rules, for ipv4 and ipv6 for the virtual router=
s.

Thanks,
Ben


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
