From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Re: kernel policy routing table src ip not respected since 2.6.37 and
 commit 9fc3bbb4a752
Date: Mon, 14 Oct 2013 15:12:19 -0700
Message-ID: <CAK3+h2ycBwgwoYFhbX4N2ZfoL6xU0_UTKHQYLEGipDA8V0e+Pg@mail.gmail.com>
References: <CAK3+h2zGFnbC-hpPB8fPX7TC3rKCWbPYVY4WW4HDYbN+LXNXXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Joel Sing <jsing@google.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:50855 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813Ab3JNWMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 18:12:20 -0400
Received: by mail-oa0-f41.google.com with SMTP id o9so19925oag.14
        for <netdev@vger.kernel.org>; Mon, 14 Oct 2013 15:12:19 -0700 (PDT)
In-Reply-To: <CAK3+h2zGFnbC-hpPB8fPX7TC3rKCWbPYVY4WW4HDYbN+LXNXXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

here is the actual test output

[root@centos64-vm linux]# ip addr show dev eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP qlen 1000
    link/ether 52:54:00:c4:bd:08 brd ff:ff:ff:ff:ff:ff
    inet 10.1.1.1/24 scope global eth0 <======
    inet 10.1.1.2/24 scope global secondary eth0 <======
    inet6 fe80::5054:ff:fec4:bd08/64 scope link
       valid_lft forever preferred_lft forever


[root@centos64-vm linux]# ip rule list
0:      from all lookup local
245:    from all lookup 245
32766:  from all lookup main
32767:  from all lookup default

[root@centos64-vm linux]# ip route list table 245
10.1.1.0/24 dev eth0  proto kernel  scope link  src 10.1.1.2 <====use
src 10.1.1.2


[root@centos64-vm linux]# ping 10.1.1.9
PING 10.1.1.9 (10.1.1.9) 56(84) bytes of data.
>From 10.1.1.1 icmp_seq=2 Destination Host Unreachable <==expecting
10.1.1.2 as before 2.6.37, but see 10.1.1.1
>From 10.1.1.1 icmp_seq=3 Destination Host Unreachable

Vincent

On Mon, Oct 14, 2013 at 9:13 AM, Vincent Li <vincent.mc.li@gmail.com> wrote:
> I had a simple bash script to test if the policy routing table src ip
> is respected or not, git bisect found the  commit 9fc3bbb4a752 to
> change the policy routing table source ip behavior.
>
> commit 9fc3bbb4a752f108cf096d96640f3b548bbbce6c
> Author: Joel Sing <jsing@google.com>
> Date:   Mon Jan 3 20:24:20 2011 +0000
>
>     ipv4/route.c: respect prefsrc for local routes
>
>     The preferred source address is currently ignored for local routes,
>     which results in all local connections having a src address that is the
>     same as the local dst address. Fix this by respecting the preferred source
>     address when it is provided for local routes.
>
> test script:
>
> #!/bin/bash
> ip addr add 10.1.1.1/24 dev eth0
> ip addr add 10.1.1.2/24 dev eth0
> ip rule add priority 245 table 245
> ip route add 10.1.1.0/24 dev eth0  proto kernel  scope link  src
> 10.1.1.2 table 245 <===source ip 10.1.1.2 to be preferred
>
> ip addr show dev eth0
> ip route list table main
> ip route list table 245
>
>
> tcpdump -nn -i eth0 host 10.1.1.9 and icmp &
>
> ping 10.1.1.9
>
>
>
> --before commit 9fc3bbb4a752
>
> the source is from ip 10.1.1.2 as expected
>
> --after commit 9fc3bbb4a752
>
> the source is from ip 10.1.1.1 which not expected since I have high
> priority table 245 with source ip 10.1.1.2
>
> is this regression of commit 9fc3bbb4a752 ?
>
> Vincent
