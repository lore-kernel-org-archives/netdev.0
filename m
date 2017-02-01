From: Edward Cree <ecree@solarflare.com>
Subject: Strange ARP behaviour with VXLAN
Date: Wed, 1 Feb 2017 16:20:13 +0000
Message-ID: <8d73b8f8-0ac4-c4c1-4dfc-c120716d52df@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:62968 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750828AbdBAQUd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 11:20:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I perform the following operations on a recent (net-next) kernel:
[see later for exact commands]
* remove IP address from physical interface
* set up VXLAN tunnel on that interface
* add IP address back to physical interface
* ping over the tunnel
the ping fails.

[ Specific kernel version: 624374a56419c2d6d428c862f32cc1b20519095d.
Note that if I do the same on 3.10.327-el7.x86_64 (RHEL7u2) the problem
does not occur.  I have not yet tested on older mainline kernels, but plan
to do so shortly.  Also note that in both cases, the link partner is running
3.10.327-el7.x86_64. ]

Investigating with tcpdump, I find that the (VXLAN-encapsulated) ARP which
is sent over the physical interface has the wrong (outer) source IP address,
namely that of another interface on the source host.  This despite the ARP
being sent over the correct interface.

To be more specific, I have two hosts, call them A and B.  They are
connected both by a management network (IP addresses Ah and Bh, bnx2 NICs)
and by a back-to-back link (IP addresses Al and Bl, sfc 8000-series NICs).
On B, I run
# ip link add vxlan0 type vxlan id 42 group 239.1.1.1 dev $sfc dstport 4789
# ip addr add 172.16.154.74/21 broadcast 172.16.159.255 dev vxlan0
# ip link set vxlan0 up
# tcpdump -pi $sfc -w somefile
On A, I run
# ip addr del $Al dev $sfc
# ip link add vxlan0 type vxlan id 42 group 239.1.1.1 dev $sfc dstport 4789
# ip addr add 172.16.154.73/21 broadcast 172.16.159.255 dev vxlan0
# ip link set vxlan0 up
# ip addr add $Al brd $Al_bcast dev $sfc
# ping 172.16.154.74
and the ping fails (Dest host unreachable).
In the tcpdump from B, I see VXLAN-encapsulated ARP requests, whose outer IP
header has source address Ah, and no responses.  Actually I see first a
gratuitous ARP reply for ~.73, then a gratuitous ARP request for ~.73, then
a series of normal ARP requests for ~.74; all of these have an outer IP
source address of Ah, even though they were all sent over $sfc.
If I leave out the 'ip addr del' on A, the encapsulated ARPs' outer IP
source address is Al, as expected, the reply is sent, and the ping succeeds.

So: why is host A 'remembering' that the NIC was missing its IP address, and
why is it sending packets out of the (Al) NIC with a source address of Ah?
And, is this behaviour intentional, or a bug?

-Ed
