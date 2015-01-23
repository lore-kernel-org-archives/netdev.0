From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH] net: ipv6: Make address flushing on ifdown optional
Date: Thu, 22 Jan 2015 22:40:33 -0800
Message-ID: <20150122224033.6e2db5ce@urahara>
References: <1421263039-96198-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@redhat.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:59758 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbbAWGkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 01:40:45 -0500
Received: by mail-pd0-f174.google.com with SMTP id ft15so6737958pdb.5
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 22:40:44 -0800 (PST)
In-Reply-To: <1421263039-96198-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Jan 2015 12:17:19 -0700
David Ahern <dsahern@gmail.com> wrote:

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
> 
> Suggested-by: Hannes Frederic Sowa <hannes@redhat.com>
> Signed-off-by: David Ahern <dsahern@gmail.com>
> Cc: Hannes Frederic Sowa <hannes@redhat.com>

Would this break existing application expecting a particular semantic
by listening to netlink?  What happens to packets received with the static
address when interface is down? With IPv4 Linux is mostly a weak host
model, and IPv6 somewhere in between.

For vendors that control the application stack or have limited number
of services this would work fine, but what about RHEL?
