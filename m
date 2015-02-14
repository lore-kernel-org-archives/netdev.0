From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] net: ipv6: Make address flushing on ifdown optional -
 v3
Date: Sat, 14 Feb 2015 17:49:38 +0100
Message-ID: <54DF7CA2.9090700@6wind.com>
References: <1423715261-53131-1-git-send-email-dsahern@gmail.com> <54DCDB80.9090601@6wind.com> <54DD73EE.8040807@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:46574 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754055AbbBNQtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2015 11:49:41 -0500
Received: by mail-ig0-f174.google.com with SMTP id b16so16478500igk.1
        for <netdev@vger.kernel.org>; Sat, 14 Feb 2015 08:49:40 -0800 (PST)
In-Reply-To: <54DD73EE.8040807@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/02/2015 04:47, David Ahern a =C3=A9crit :
> On 2/12/15 9:57 AM, Nicolas Dichtel wrote:
>> Le 12/02/2015 05:27, David Ahern a =C3=A9crit :
>>> Currently, all ipv6 addresses are flushed when the interface is
>>> configured
>>> down, even static address:
>>>
>> [snip]
>>>
>>> [root@f20 ~]# echo 0 > /proc/sys/net/ipv6/conf/eth1/flush_addr_on_d=
own
>>> [root@f20 ~]# ip -6 addr add dev eth1 2000:11:1:1::1/64
>>> [root@f20 ~]# ip addr show dev eth1
>>> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN
>>> group default qlen 1000
>>>      link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>>>      inet6 2000:11:1:1::1/64 scope global tentative
>>>         valid_lft forever preferred_lft forever
>>> [root@f20 ~]#  ip link set dev eth1 up
>>> [root@f20 ~]#  ip link set dev eth1 down
>>> [root@f20 ~]# ip addr show dev eth1
>>> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN
>>> group default qlen 1000
>>>      link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>>>      inet6 2000:11:1:1::1/64 scope global
>>>         valid_lft forever preferred_lft forever
>>>      inet6 fe80::4:11ff:fe22:3301/64 scope link
>>>         valid_lft forever preferred_lft forever
>> Can you show an output of 'ip -6 route list table local' and 'ip -6
>> route' ?
>
> hmmmm.... interesting. once again ipv6 behavior is radically differen=
t from ipv4.
>
> This is *after* a configure, up, down cycle:
>
> [root@f21 ~]# ip -6 route list table local
> local ::1 dev lo  proto none  metric 0
> local 2000:11:1:1::1 dev lo  proto none  metric 0
> local fe80::11:22ff:fe33:4402 dev lo  proto none  metric 0
> ff00::/8 dev eth0  metric 256
We also need to check netlink notifications. When you set an interface =
down, the
kernel doesn't send rtnl notifications for IPv6 routes. Daemons have to=
 take
care of the ifdow notification.
If your patch is going to keep some routes after an ifdown, we need to =
have a
way in userland to know this.
Advertising the new sysctl (flush_addr_on_down) entry via netconf may b=
e a
solution (Stephen already talks about this feature).

>
> [root@f21 ~]# ip -6 route ls
> unreachable ::/96 dev lo  metric 1024  error -101
> unreachable ::ffff:0.0.0.0/96 dev lo  metric 1024  error -101
> unreachable 2002:a00::/24 dev lo  metric 1024  error -101
> unreachable 2002:7f00::/24 dev lo  metric 1024  error -101
> unreachable 2002:a9fe::/32 dev lo  metric 1024  error -101
> unreachable 2002:ac10::/28 dev lo  metric 1024  error -101
> unreachable 2002:c0a8::/32 dev lo  metric 1024  error -101
> unreachable 2002:e000::/19 dev lo  metric 1024  error -101
> unreachable 3ffe:ffff::/32 dev lo  metric 1024  error -101
> fe80::/64 dev eth0  proto kernel  metric 256
>
> (the ipv6 addresses on lo show up on stock 3.18.3-201.fc21.x86_64; no=
 idea why)
>
> But on a subsequent ifconfig up the route is not inserted:
>
> [root@f21 ~]# ifconfig eth1 up
>
> [root@f21 ~]# ip -6 route ls
> unreachable ::/96 dev lo  metric 1024  error -101
> unreachable ::ffff:0.0.0.0/96 dev lo  metric 1024  error -101
> unreachable 2002:a00::/24 dev lo  metric 1024  error -101
> unreachable 2002:7f00::/24 dev lo  metric 1024  error -101
> unreachable 2002:a9fe::/32 dev lo  metric 1024  error -101
> unreachable 2002:ac10::/28 dev lo  metric 1024  error -101
> unreachable 2002:c0a8::/32 dev lo  metric 1024  error -101
> unreachable 2002:e000::/19 dev lo  metric 1024  error -101
> unreachable 3ffe:ffff::/32 dev lo  metric 1024  error -101
> fe80::/64 dev eth0  proto kernel  metric 256
> fe80::/64 dev eth1  proto kernel  metric 256
>
> So I need to look into why.
Yes. The patch will probably have to play with this connected route.


Regards,
Nicolas
