From: Brian Haley <brian.haley@hp.com>
Subject: Re: [RFC PATCH] net: ipv6: Make address flushing on ifdown optional
Date: Fri, 23 Jan 2015 16:17:04 -0500
Message-ID: <54C2BA50.6080208@hp.com>
References: <1421263039-96198-1-git-send-email-dsahern@gmail.com> <54C27220.7020600@hp.com> <54C2919A.2050707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: hannes@redhat.com
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hp.com ([15.201.208.54]:44602 "EHLO
	g4t3426.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbbAWVRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 16:17:06 -0500
In-Reply-To: <54C2919A.2050707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/2015 01:23 PM, David Ahern wrote:

>>> Add a new sysctl to make this behavior optional. Setting defaults to flush
>>> addresses to maintain backwards compatibility. When reset flushing is bypassed:
>>>
>>> [root@f20 ~]# echo 0 > /proc/sys/net/ipv6/conf/eth1/flush_addr_on_down
>>> [root@f20 ~]# ip -6 addr add dev eth1 2000:11:1:1::1/64
>>> [root@f20 ~]# ip addr show dev eth1
>>> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group
>>> default qlen 1000
>>>      link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>>>      inet6 2000:11:1:1::1/64 scope global tentative
>>>         valid_lft forever preferred_lft forever
>>> [root@f20 ~]#  ip link set dev eth1 up
>>> [root@f20 ~]#  ip link set dev eth1 down
>>> [root@f20 ~]# ip addr show dev eth1
>>> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group
>>> default qlen 1000
>>>      link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>>>      inet6 2000:11:1:1::1/64 scope global
>>>         valid_lft forever preferred_lft forever
>>>      inet6 fe80::4:11ff:fe22:3301/64 scope link
>>>         valid_lft forever preferred_lft forever
>>
>> I think this was brought up in a previous thread on this, but don't you have to
>> do DAD on these addresses once the interface comes back up?  Some other system
>> could have come along, done DAD, succeeded, and is now using it.  Or does the
>> use of this flag assume the user is Ok without doing DAD, and will deal with the
>> fallout?
> 
> You have the same problem today, don't you? Current code allows an IPv6 address
> to be configured on interface in the down state. The intent of this sysctl is to
> allow that address to stay on an up-down cycle.

Yes, looks like ndisc_send_skb() never returns any lower-level error back up to
the caller, so it's assumed the Neighbour Advertisement is always sent.
Although the address will be marked "tentative" until IFF_UP is set.

> I don't have a strong IPv6 background so the first email thread and this RFC
> patch are both asking first and foremost if there is any harm in this behavior.
> None has been raised - so far. To maintain backwards compatibility this is a new
> option which when reset allows the addresses to be retained (not flushed).

Seems as though you're in an RFC grey area then.  Personally, I'd do DAD, even
though the possibility of a collision is always very small.  But that's just my
opinion.

-Brian
