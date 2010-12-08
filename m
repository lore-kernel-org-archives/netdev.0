From: Brian Haley <brian.haley@hp.com>
Subject: Re: echo > 0 .../disable_ipv6 broken in 2.6.37-rc4
Date: Wed, 08 Dec 2010 17:49:17 -0500
Message-ID: <4D000B6D.1060708@hp.com>
References: <m17hfnlpe1.fsf@fess.ebiederm.org> <4CFD0AF0.9090809@hp.com> <m14oaoeywf.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mahesh Kelkar <maheshkelkar@gmail.com>,
	Lorenzo Colitti <lorenzo@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:39425 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755281Ab0LHWtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 17:49:17 -0500
In-Reply-To: <m14oaoeywf.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/2010 04:29 PM, Eric W. Biederman wrote:
> Brian Haley <brian.haley@hp.com> writes:
> 
>> On 12/05/2010 07:24 PM, Eric W. Biederman wrote:
>>>
>>> In 2.6.37-rc4 ipv6 can be disabled not enabled.
>>> The last kernel I have tested and know this works on is 2.6.33.
>>>
>>> To reproduce:
>>>    ~ # ip link set lo up
>>>    ~ # ping6 ::1
>>>    PING ::1(::1) 56 data bytes
>>>    64 bytes from ::1: icmp_seq=1 ttl=64 time=0.026 ms
>>>    ^C
>>>    --- ::1 ping statistics ---
>>>    1 packets transmitted, 1 received, 0% packet loss, time 782ms
>>>    rtt min/avg/max/mdev = 0.026/0.026/0.026/0.000 ms
>>>    ~ # echo 1 > /proc/sys/net/ipv6/conf/lo/disable_ipv6 
>>>    ~ # ping6 ::1
>>>    connect: Network is unreachable
>>>    ~ # echo 0 > /proc/sys/net/ipv6/conf/lo/disable_ipv6 
>>>    ~ # ping6 ::1
<snip>

>> I'm pulling the latest tree now, my 2.6.32.24 system is running fine, so
>> it's something after that.
> 
> Agreed.  I don't have problems on 2.6.33 either, but because of overload
> I haven't been doing regular testing of the kernels inbetween.

This got broken in 2.6.34-rc1, and the most obvious culprit is this,
although I haven't bisected it:

commit dc2b99f71ef477a31020511876ab4403fb7c4420
Author: stephen hemminger <shemminger@vyatta.com>
Date:   Mon Feb 8 19:48:05 2010 +0000

    IPv6: keep permanent addresses on admin down

    Permanent IPV6 addresses should not be removed when the link is
    set to admin down, only when device is removed.

    When link is lost permanent addresses should be marked as tentative
    so that when link comes back they are subject to duplicate address
    detection (if DAD was enabled for that address).

    Other routing systems keep manually configured IPv6 addresses
    when link is set down.

Even though there was a bugfix update, it didn't help.

I unfortunately won't be able to look at this more until at least Friday,
I couldn't come up with a quick patch just looking quickly at addrconf_ifdown().

-Brian
