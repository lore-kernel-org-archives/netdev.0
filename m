From: Brian Haley <brian.haley@hp.com>
Subject: Re: Ping Is Broken
Date: Mon, 12 Oct 2009 16:36:18 -0400
Message-ID: <4AD39342.7090209@hp.com>
References: <7e84ed60910090316ne9224fat81d9c79c58fc713b@mail.gmail.com>	 <7e84ed60910090934y2a0d422cr158aa8d15e452f97@mail.gmail.com> <7e84ed60910090944q5c66ea0w63ed55a72482bf2f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Omaha Linux User Group <olug@olug.org>,
	CentOS mailing list <centos@centos.org>
To: Rob.Townley@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:13236 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757113AbZJLUg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 16:36:57 -0400
In-Reply-To: <7e84ed60910090944q5c66ea0w63ed55a72482bf2f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rob Townley wrote:
> ping -I is broken
> 
> The following deals with bug in ping that made it very difficult to set up a
> system with two gateways.
> 
> Demonstration that *ping -I is broken*. When specifying the source
> interface using -I with an *ethX* alias and that interface is not the
> default gateway
> interface, then ping fails. When specifying the interface as an ip address,
> ping works. Search for "Destination Host Unreachable" to find the bug.

I believe ping is working properly here, see below.

> eth*0* = 4.3.2.8 and the default gateway is accessed through a different
> interface eth*1*.
> eth*1* = 192.168.168.155 is used as the device to get to the default
> gateway.
> *FAILS *: ping *-I eth0* 208.67.222.222
> *WORKS*: ping *-I 4.3.2.8* 208.67.222.222
> *WORKS*: ping *-I eth1* 208.67.222.222
> *WORKS*: ping *-I 192.168.168.155* 208.67.222.222
> 
> The following are actual results which can be reproduced from an up-to-date
> Fedora 11 or CentOS 5.3 box. Caused a very very long episode of frustration
> when setting up multi gatewayed systems.
> 
> 
> * ping using eth0 *:
> 
> ping -c 2 -B -I  eth0 208.67.222.222
> PING 208.67.222.222 (208.67.222.222) from 4.3.2.8 eth0: 56(84) bytes of data.
> From 4.3.2.8 icmp_seq=1 Destination Host Unreachable
> From 4.3.2.8 icmp_seq=2 Destination Host Unreachable

In this case ping is doing an SO_BINDTODEVICE to eth0, so the kernel is going
to force the packets out of it, even if it isn't the "correct" interface.  If
you ran tcpdump you'd probably see an ARP resolution failure, or an ICMP from
a gateway.

This confusion could be cleared-up on the man page.  What did you expect to
happen in this case?

> The Following all WORK:
> * ping using 4.3.2.8 *:
> 
> ping -c 2 -B -I  4.3.2.8 208.67.222.222
> PING 208.67.222.222 (208.67.222.222) from 4.3.2.8 : 56(84) bytes of data.
> 64 bytes from 208.67.222.222: icmp_seq=1 ttl=55 time=562 ms
> 64 bytes from 208.67.222.222: icmp_seq=2 ttl=55 time=642 ms

In this case ping is going to bind() the source address to 4.3.2.8, but not
restrict the interface at all.  It works because of the weak end-host model
of Linux where that address can be used on any interface, not just the one
it is configured on.

Your other two examples are similar to this one.

-Brian
