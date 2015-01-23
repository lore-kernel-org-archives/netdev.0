From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH] net: ipv6: Make address flushing on ifdown optional
Date: Fri, 23 Jan 2015 11:23:22 -0700
Message-ID: <54C2919A.2050707@gmail.com>
References: <1421263039-96198-1-git-send-email-dsahern@gmail.com> <54C27220.7020600@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com
To: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:56240 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278AbbAWSX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 13:23:27 -0500
Received: by mail-pa0-f42.google.com with SMTP id bj1so9131458pad.1
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 10:23:27 -0800 (PST)
In-Reply-To: <54C27220.7020600@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/23/15 9:09 AM, Brian Haley wrote:
> On 01/14/2015 02:17 PM, David Ahern wrote:
>> Currently, ipv6 addresses are flushed when the interface is configured down:
>>
>> [root@f20 ~]# ip -6 addr add dev eth1 2000:11:1:1::1/64
>> [root@f20 ~]# ip addr show dev eth1
>> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
>>      link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>>      inet6 2000:11:1:1::1/64 scope global tentative
>>         valid_lft forever preferred_lft forever
>> [root@f20 ~]# ip link set dev eth1 up
>> [root@f20 ~]# ip link set dev eth1 down
>> [root@f20 ~]# ip addr show dev eth1
>> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
>>      link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>>
>> Add a new sysctl to make this behavior optional. Setting defaults to flush
>> addresses to maintain backwards compatibility. When reset flushing is bypassed:
>>
>> [root@f20 ~]# echo 0 > /proc/sys/net/ipv6/conf/eth1/flush_addr_on_down
>> [root@f20 ~]# ip -6 addr add dev eth1 2000:11:1:1::1/64
>> [root@f20 ~]# ip addr show dev eth1
>> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
>>      link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>>      inet6 2000:11:1:1::1/64 scope global tentative
>>         valid_lft forever preferred_lft forever
>> [root@f20 ~]#  ip link set dev eth1 up
>> [root@f20 ~]#  ip link set dev eth1 down
>> [root@f20 ~]# ip addr show dev eth1
>> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
>>      link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>>      inet6 2000:11:1:1::1/64 scope global
>>         valid_lft forever preferred_lft forever
>>      inet6 fe80::4:11ff:fe22:3301/64 scope link
>>         valid_lft forever preferred_lft forever
>
> I think this was brought up in a previous thread on this, but don't you have to
> do DAD on these addresses once the interface comes back up?  Some other system
> could have come along, done DAD, succeeded, and is now using it.  Or does the
> use of this flag assume the user is Ok without doing DAD, and will deal with the
> fallout?

You have the same problem today, don't you? Current code allows an IPv6 
address to be configured on interface in the down state. The intent of 
this sysctl is to allow that address to stay on an up-down cycle.

I don't have a strong IPv6 background so the first email thread and this 
RFC patch are both asking first and foremost if there is any harm in 
this behavior. None has been raised - so far. To maintain backwards 
compatibility this is a new option which when reset allows the addresses 
to be retained (not flushed).

David
