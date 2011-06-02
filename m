From: "Jeff Haran" <jharan@bytemobile.com>
Subject: forwarding pings out ingress interface
Date: Thu, 2 Jun 2011 12:10:34 -0700
Message-ID: <6F5DE7538AFCDA45A114F5E7510424A7027D8388@hq-exchange01.bytemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport.bytemobile.com ([12.153.136.13]:24386 "EHLO
	ironport.bytemobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752776Ab1FBTVV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 15:21:21 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Running Redhat Enterprize 6.0, seeing the following behavior.

Two Ethernet network segments: 172.30/16 and 169.254.160/24.

Three "devices":

[linux] is the blade running RHEL6.0. It has multiple network interfaces
and has IP forwarding enabled.
[host] is an IP host of some sort.
[lb] is an L3 load balancer.

They are connected like so:

[host] 172.30.0.254 <-> 172.30.0.2 [lb] 169.254.160.20 <-> 169.254.160.1
[linux]

I have not shown the other network interfaces that [linux] is attached
to for brevity in the diagram.

One of the peculiarities of [lb] is if [host] pings it at 172.30.0.2, it
will not respond to the ping itself but instead forward the ping to
[linux]. I realize this is broken, but I have to deal with it (its
cooked into [lb]'s silicon). [lb]'s vendor assures me that if [linux]
would only forward the ping back to [lb] out the same interface it came
in on, then [lb] will generate a ping response back to [host].

My problem is [linux] won't forward the ping back to [lb]. [linux] has a
route to 172.30/16 out the interface that connects it to [lb] and I can
see from tcpdump that [linux] is getting the ICMP Echo requests with
source address 172.30.0.254 and destination address 172.30.0.2, but
nothing gets transmitted out that interface in response.

Now if I modify the route on [linux] to so that packets it receives that
are destined to 172.30/16 are forwarded out another of its network
interfaces, it forwards the pings out that interface just fine. It seems
like [linux] just doesn't want to forward pings it receives on a given
interface back out that same interface.

I am wondering if there is some switch under /proc or /sys that I need
to modify to get [linux] to forward the pings out the interface.
Is there such a thing that defaults to preventing this for security
reasons maybe?

In digging into this I discovered that /proc/1/net/stat/rt_cache was
reporting some non-zero statistics under the "in_martian_src" source
column. I figured maybe that [linux]'s stack was for some reason
determining that these pings were martians and dropping them so I
echo'ed 1 to log_martians. What I then see is a bunch of logs like this:

2011-06-01T17:55:51.103140-07:00 s01b01 kernel: martian source
169.254.160.7 from 169.254.160.6, on dev eth3
2011-06-01T17:55:51.103147-07:00 s01b01 kernel: ll header:
ff:ff:ff:ff:ff:ff:e4:1f:13:f6:60:d8:08:06

I don't know if this is related to the immediate ping problem, there are
other linux hosts on 169.254.160/24 that I've omitted from the diagram,
but I am truly perplexed at the lines beginning with "ll header".
Reading the code that generates these logs, ip_handle_martian_source()
in net/ipv4/route.c, it suggests that what is being shown in those "ll
header" lines is the MAC header of these packets it considers martians.

What is perplexing is that "08:06" at the end of the line. That's the
Ethertype for ARP, not IP. Why are ARP frames being treated as IP
packets? They shouldn't even be getting to ip_handle_martian_source() if
I am following the receive path correctly.

Just thought somebody on this list might have some insights into what I
am seeing here.

Thanks,

Jeff Haran
Bytemobile






