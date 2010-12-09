From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: echo > 0 .../disable_ipv6 broken in 2.6.37-rc4
Date: Wed, 08 Dec 2010 18:42:04 -0800
Message-ID: <m11v5rekg3.fsf@fess.ebiederm.org>
References: <m17hfnlpe1.fsf@fess.ebiederm.org> <4CFD0AF0.9090809@hp.com>
	<m14oaoeywf.fsf@fess.ebiederm.org> <4D000B6D.1060708@hp.com>
	<m1tyineu3p.fsf@fess.ebiederm.org> <20101208154932.5bc4b254@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org,
	Mahesh Kelkar <maheshkelkar@gmail.com>,
	Lorenzo Colitti <lorenzo@google.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:43686 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932305Ab0LICmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 21:42:13 -0500
In-Reply-To: <20101208154932.5bc4b254@nehalam> (Stephen Hemminger's message of
	"Wed, 8 Dec 2010 15:49:32 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> On Wed, 08 Dec 2010 15:13:30 -0800
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
>> Brian Haley <brian.haley@hp.com> writes:
>> 
>> > This got broken in 2.6.34-rc1, and the most obvious culprit is this,
>> > although I haven't bisected it:
>> >
>> > commit dc2b99f71ef477a31020511876ab4403fb7c4420
>> > Author: stephen hemminger <shemminger@vyatta.com>
>> > Date:   Mon Feb 8 19:48:05 2010 +0000
>> >
>> >     IPv6: keep permanent addresses on admin down
>> >
>> >     Permanent IPV6 addresses should not be removed when the link is
>> >     set to admin down, only when device is removed.
>> >
>> >     When link is lost permanent addresses should be marked as tentative
>> >     so that when link comes back they are subject to duplicate address
>> >     detection (if DAD was enabled for that address).
>> >
>> >     Other routing systems keep manually configured IPv6 addresses
>> >     when link is set down.
>> >
>> > Even though there was a bugfix update, it didn't help.
>> >
>> > I unfortunately won't be able to look at this more until at least Friday,
>> > I couldn't come up with a quick patch just looking quickly at
>> > addrconf_ifdown().
>> 
>> This is almost certainly it.
>> ip link set lo down
>> ip link set lo up
>> 
>> Is enough to break ping6 ::1.
>> 
>> I get the feeling the loopback address was not actually tested and
>> there is something different about it.
>
> Loopback is already handled as special case in addrconf. Look at IFF_LOOPBACK
> perhaps there is a logic error there.

Playing with this some more I have come up with a totally evil testcase.

If I bring lo down, and back up again I cannot talk to local addresses
through the loopback device, that I could before.

Somewhere in route flushing, and route cache something has gone wrong,
making configurations that existed before the loopback interface was
brought down not work after the loopback interface is brought up.

I can fix any this problem by deleting and re-adding the address
but seems wrong, and this does seem related to the loopback case.

A nondad address goes up and down just fine on any interface I
want except on lo.  And pinging any local address seems to break
when I bring lo up and down.

Eric


# ip link set lo up
# ip link add veth0 type veth peer name veth1
# ip link set veth0 up
# ip link set veth1 up
# ip -6 addr add fdff:ffff:ffff:ffff::1/128 dev veth0 nodad
# ping6 fdff:ffff:ffff:ffff::1    
PING fdff:ffff:ffff:ffff::1(fdff:ffff:ffff:ffff::1) 56 data bytes
64 bytes from fdff:ffff:ffff:ffff::1: icmp_seq=1 ttl=64 time=0.039 ms
64 bytes from fdff:ffff:ffff:ffff::1: icmp_seq=2 ttl=64 time=0.046 ms
^C
--- fdff:ffff:ffff:ffff::1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1466ms
rtt min/avg/max/mdev = 0.039/0.042/0.046/0.007 ms
# ip link set lo down
# ip link set lo up
# ping6 fdff:ffff:ffff:ffff::1
PING fdff:ffff:ffff:ffff::1(fdff:ffff:ffff:ffff::1) 56 data bytes
ping: sendmsg: Network is unreachable
ping: sendmsg: Network is unreachable
ping: sendmsg: Network is unreachable
ping: sendmsg: Network is unreachable
ping: sendmsg: Network is unreachable
ping: sendmsg: Network is unreachable
ping: sendmsg: Network is unreachable
^C
--- fdff:ffff:ffff:ffff::1 ping statistics ---
10 packets transmitted, 0 received, 100% packet loss, time 9250ms


# ip -6 addr del fdff:ffff:ffff:ffff::1/128 dev veth0 nodad
# ip -6 addr add fdff:ffff:ffff:ffff::1/128 dev veth0 nodad
# ping6 fdff:ffff:ffff:ffff::1
PING fdff:ffff:ffff:ffff::1(fdff:ffff:ffff:ffff::1) 56 data bytes
64 bytes from fdff:ffff:ffff:ffff::1: icmp_seq=1 ttl=64 time=0.032 ms
64 bytes from fdff:ffff:ffff:ffff::1: icmp_seq=2 ttl=64 time=0.060 ms
^C
--- fdff:ffff:ffff:ffff::1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 0.032/0.046/0.060/0.014 ms
# ip link set veth0 down
# ip link set veth0 up
# ping6 fdff:ffff:ffff:ffff::1
PING fdff:ffff:ffff:ffff::1(fdff:ffff:ffff:ffff::1) 56 data bytes
64 bytes from fdff:ffff:ffff:ffff::1: icmp_seq=1 ttl=64 time=0.034 ms
64 bytes from fdff:ffff:ffff:ffff::1: icmp_seq=2 ttl=64 time=0.052 ms
64 bytes from fdff:ffff:ffff:ffff::1: icmp_seq=3 ttl=64 time=0.062 ms
64 bytes from fdff:ffff:ffff:ffff::1: icmp_seq=4 ttl=64 time=0.066 ms
64 bytes from fdff:ffff:ffff:ffff::1: icmp_seq=5 ttl=64 time=0.066 ms
^C
--- fdff:ffff:ffff:ffff::1 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4045ms
rtt min/avg/max/mdev = 0.034/0.056/0.066/0.012 ms
# ip link set lo down
# ip link set lo up
# ping6 fdff:ffff:ffff:ffff::1
connect: Network is unreachable
# ping6 fdff:ffff:ffff:ffff::1
connect: Network is unreachable
# ip -6 addr show
13: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
15: veth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 fe80::c403:15ff:fe12:f05c/64 scope link 
       valid_lft forever preferred_lft forever
16: veth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 fdff:ffff:ffff:ffff::1/128 scope global nodad 
       valid_lft forever preferred_lft forever
    inet6 fe80::c01b:5ff:fe39:510b/64 scope link 
       valid_lft forever preferred_lft forever
# ip link show
13: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
15: veth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether c6:03:15:12:f0:5c brd ff:ff:ff:ff:ff:ff
16: veth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether c2:1b:05:39:51:0b brd ff:ff:ff:ff:ff:ff
