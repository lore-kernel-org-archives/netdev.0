From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Bug with IPv6-UDP address binding
Date: Wed, 08 Aug 2012 22:37:18 +0200
Message-ID: <1344458238.3069.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14647 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759235Ab2HHUhv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2012 16:37:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi NetDev

I think I have found a problem/bug with IPv6-UDP address binding.

I found this problem while playing with IPVS and IPv6-UDP, but its also
present in more basic/normal situations.

If you have two IPv6 addresses, within the same IPv6 subnet, then one
of the IPv6 addrs takes precedence over the other (for UDP only).

Meaning that, if connecting to the "secondary" IPv6 via UDP, will
result in userspace see/bind the connection as being created to the
"primary" IP, even-though tcpdump shows that the IPv6-UDP packets are
dest the "secondary".

The result is; that only the first IPv6-UDP packet is delivered to
userspace, and the next packets are denied by the kernel as the UDP
socket is "established" with the "primary" IPv6 addr.

I would appreciate some hints to where in the IPv6 code I should look
for this bug.  If any one else wants to fix it, I'm also fine with
that ;-)


Its quite easy to reproduce, using netcat (nc).

Add two addresses to the "server" e.g.:
 ip addr add fee0:cafe::102/64 dev eth0
 ip addr add fee0:cafe::bad/64 dev eth0

Run a netcat listener on "server":
 nc -6 -u -l 2000
(Notice restart the listener between runs, due to limitation in nc)

On the client add an IPv6 addr e.g.:
 ip addr add fee0:cafe::101/64 dev eth0

Run a netcat UDP-IPv6 producer on "client":
  nc -6 -u fee0:cafe::bad 2000

Notice that first packet, will get through, but second packets will
not (nc: Write error: Connection refused).  Running a tcpdump shows
that the kernel is sending back ICMP6, destination unreachable,
unreachable port.

Its also possible to see the problem, simply running "netstat -uan" on
"server", which will show that the "established" UDP connection, is
bound to the wrong "Local Address".

(Tested on both latest net-next kernel at commit 79cda75a1, and also
on RHEL6 approx 2.6.32)
