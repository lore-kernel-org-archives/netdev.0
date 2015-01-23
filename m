From: Brian Haley <brian.haley@hp.com>
Subject: Re: [RFC PATCH] net: ipv6: Make address flushing on ifdown optional
Date: Fri, 23 Jan 2015 11:09:04 -0500
Message-ID: <54C27220.7020600@hp.com>
References: <1421263039-96198-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: hannes@redhat.com
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hp.com ([15.201.208.55]:43096 "EHLO
	g4t3427.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755856AbbAWQJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 11:09:06 -0500
In-Reply-To: <1421263039-96198-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/2015 02:17 PM, David Ahern wrote:
> Currently, ipv6 addresses are flushed when the interface is configured down:
> 
> [root@f20 ~]# ip -6 addr add dev eth1 2000:11:1:1::1/64
> [root@f20 ~]# ip addr show dev eth1
> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
>     link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>     inet6 2000:11:1:1::1/64 scope global tentative
>        valid_lft forever preferred_lft forever
> [root@f20 ~]# ip link set dev eth1 up
> [root@f20 ~]# ip link set dev eth1 down
> [root@f20 ~]# ip addr show dev eth1
> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
>     link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
> 
> Add a new sysctl to make this behavior optional. Setting defaults to flush
> addresses to maintain backwards compatibility. When reset flushing is bypassed:
> 
> [root@f20 ~]# echo 0 > /proc/sys/net/ipv6/conf/eth1/flush_addr_on_down
> [root@f20 ~]# ip -6 addr add dev eth1 2000:11:1:1::1/64
> [root@f20 ~]# ip addr show dev eth1
> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
>     link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>     inet6 2000:11:1:1::1/64 scope global tentative
>        valid_lft forever preferred_lft forever
> [root@f20 ~]#  ip link set dev eth1 up
> [root@f20 ~]#  ip link set dev eth1 down
> [root@f20 ~]# ip addr show dev eth1
> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
>     link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>     inet6 2000:11:1:1::1/64 scope global
>        valid_lft forever preferred_lft forever
>     inet6 fe80::4:11ff:fe22:3301/64 scope link
>        valid_lft forever preferred_lft forever

I think this was brought up in a previous thread on this, but don't you have to
do DAD on these addresses once the interface comes back up?  Some other system
could have come along, done DAD, succeeded, and is now using it.  Or does the
use of this flag assume the user is Ok without doing DAD, and will deal with the
fallout?

-Brian
