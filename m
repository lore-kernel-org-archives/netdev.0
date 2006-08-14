From: Innocenti Maresin <qq@inCTV.ru>
Subject: Q: remapping remote IP addresses for locally bound traffic
Date: Mon, 14 Aug 2006 19:24:33 +0000
Message-ID: <44E0CDF1.B3694213@inCTV.ru>
References: <LKML-nat-0.qq@inCTV.ru> <44DF4275.8A68AAC@inCTV.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from vmail.comtv.ru ([217.10.32.17]:62376 "EHLO comtv.ru")
	by vger.kernel.org with ESMTP id S932718AbWHNUZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 16:25:35 -0400
Received: from [10.128.0.36] (account qq@inctv.ru HELO inCTV.ru)
  by comtv.ru (CommuniGate Pro SMTP 4.1.8)
  with ESMTP-TLS id 164154505 for netdev@vger.kernel.org; Tue, 15 Aug 2006 00:25:47 +0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello! 

Let one Linux box have two interfaces to 2 different IPv4 networks, 
and for some IP both networks have the host with this IP address, 
e.g. for an address from RFC1918. 
Or even both use the same IPv4 address block. 
We can say that one IP from the first network 
and numerically the same IP from the second "means" different hosts. 

The software of this box needs to connect all hosts in both networks, 
and also to receive inbound TCP connections. 
The evident way is to "remap" overlapping IPv4 area of one network 
to some spare area not used neither in it nor in other. 

(used area) [] [] [] ----\shift  |~~~~~~~~~~~~  direct IPs -|----- [] [] [] (used area)
(spare area) _ _ _ _ _ _  \______|internal IPs ............ |                (unused area)


This means that, when we receive a packet from remapped area, 
the kernel should replace the source IP to an "internal representaion". 
Versa, sending something to "internally represented" IP 
the kernel should replace such IP by its external value. 
Some people in news:comp.os.linux.networking states that this task is a "no-go". 
I don't think so and will base on IP translation abilities of Linux 2.4.

Iproute2 can do similar things when *forwarding* packets. 
I need no forwarding at all, no *connection* between 2 networks. 
I need only to *serve* both networks, 
such that some "external" IPs need to be replaced by internally used IP and versa. 
BTW, hosts those IPs I want to replace lie behind a router, 
thus no problem with ARP tables will appear. 

So, suppose that I try to use FastNAT/iproute2 on Linux 2.4, 
a "dummy NAT address" is an "internally represented" in my terms, 
and "via" address (in iproute2 terms) is my "external". 
Unfortunally, by iproute2 idiots' design, I can't locally send packet 
to a so called "dummy NAT address". 
I even can't use connect() on it, the kernel says "Invalid argument". 
So, my "internal addresses" become really unusable. 

I found the cause in the function ip_route_output_slow() in net/ipv4/route.c.
There is such code as:
        if (res.type == RTN_NAT)
                goto e_inval;
 
In late 2.4 it is line 1922 (2.6 is irrelevant because of elimination of RTN_NAT).
I realize that this condition means, at least, an explicit ban
on all attempts to use RTN_NATted destination addresses in connect(),
so the kernel fails before the process (or the transport level) attempts to send any packet.
Please, tell me, what value should return this function by design
and what is the difference between it and a similar situation in ip_route_input_slow()
where fib_rules_map_destination() is called instead of just failing.
For what reasons (religious, I think) locally generated packets
may not be RTN_NATted in a manner similar to the routing of forwarding traffic?

I expect only one serious problem with FastNATting of locally bound traffic. 
Unlike the forwarding NAT described by A.N. Kuznetsov, 
in my case we don't want to see external IPs locally, at socket level (this is the goal). 
We must convert any such source IP to internal form before treating a packet as inbound. 
As Kuznetsov's IP Command Reference states (page 51), 
every declaration of NAT address must be coupled with an "ip rule" 
which give a reverse IP translation (ip route nat don't do this) 
for the traffic coming from the NATted host through the router. 
If we wanted to use such NAT for locally bound traffic, 
we obviously should translate inbound traffic 
in the same manner as we translate it in the "forwarding NAT" model. 
But such traffic is now not _routed_ because it is _inbound_! 
How can I enable this translation for inbound traffic?

 
Thank you for your attention.


 
--
qq~~~~\
/ /\   \
\  /_/ /
 \____/
