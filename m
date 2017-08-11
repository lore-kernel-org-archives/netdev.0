From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv4: set orig_oif based on fib result
 for local traffic
Date: Fri, 11 Aug 2017 14:41:15 -0700 (PDT)
Message-ID: <20170811.144115.401281325600007661.davem@davemloft.net>
References: <1502398150-4220-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60460 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753742AbdHKVlQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 17:41:16 -0400
In-Reply-To: <1502398150-4220-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Thu, 10 Aug 2017 13:49:10 -0700

> Attempts to connect to a local address with a socket bound
> to a device with the local address hangs if there is no listener:
> 
>   $ ip addr sh dev eth1
>   3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
>     link/ether 02:e0:f9:1c:00:37 brd ff:ff:ff:ff:ff:ff
>     inet 10.100.1.4/24 scope global eth1
>        valid_lft forever preferred_lft forever
>     inet6 2001:db8:1::4/120 scope global
>        valid_lft forever preferred_lft forever
>     inet6 fe80::e0:f9ff:fe1c:37/64 scope link
>        valid_lft forever preferred_lft forever
> 
>   $ vrf-test -I eth1 -r 10.100.1.4
>   <hangs when there is no server>
> 
> (don't let the command name fool you; vrf-test works without vrfs.)
> 
> The problem is that the original intended device, eth1 in this case, is
> lost when the tcp reset is sent, so the socket lookup does not find a
> match for the reset and the connect attempt hangs. Fix by adjusting
> orig_oif for local traffic to the device from the fib lookup result.
> 
> With this patch you get the more user friendly:
>   $ vrf-test -I eth1 -r 10.100.1.4
>   connect failed: 111: Connection refused
> 
> orig_oif is saved to the newly created rtable as rt_iif and when set
> it is used as the dif for socket lookups. It is set based on flowi4_oif
> passed in to ip_route_output_key_hash_rcu and will be set to either
> the loopback device, an l3mdev device, nothing (flowi4_oif = 0 which
> is the case in the example above) or a netdev index depending on the
> lookup path. In each case, resetting orig_oif to the device in the fib
> result for the RTN_LOCAL case allows the actual device to be preserved
> as the skb tx and rx is done over the loopback or VRF device.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>
> ---
> As far as I can tell the current behavior goes back to the 2.6 days
> at least. Not sure it is worth adding to stable branches.

Applied, thanks David.
