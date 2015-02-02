From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net: ipv6: Make address flushing on ifdown optional -
 v2
Date: Tue, 3 Feb 2015 00:10:57 +0100
Message-ID: <20150203001057.3e0e22b2@uryu.home.lan>
References: <1422504065-17445-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Hannes Frederic Sowa <hannes@redhat.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:49369 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790AbbBBXLP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 18:11:15 -0500
Received: by mail-ig0-f171.google.com with SMTP id h15so6068671igd.4
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2015 15:11:15 -0800 (PST)
In-Reply-To: <1422504065-17445-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Jan 2015 21:01:05 -0700
David Ahern <dsahern@gmail.com> wrote:

> Currently, all ipv6 addresses are flushed when the interface is configured
> down, even static address:
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
> Add a new sysctl to make this behavior optional. The new setting defaults to
> flush all addresses to maintain backwards compatibility. When the setting is
> reset static addresses are not flushed:
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
> v2:
> - only keep static addresses as suggested by Hannes
> - added new managed flag to track configured addresses
> - on ifdown do not remove from configured address from inet6_addr_lst
> - on ifdown reset the TENTATIVE flag and set state to DAD so that DAD is
>   redone when link is brought up again
> 
> Suggested-by: Hannes Frederic Sowa <hannes@redhat.com>
> Signed-off-by: David Ahern <dsahern@gmail.com>
> Cc: Hannes Frederic Sowa <hannes@redhat.com>
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Checkpatch complains about space before tab, which could be your
mailer mangling the patch.

This should probably go into the netconf netlink message as well.
