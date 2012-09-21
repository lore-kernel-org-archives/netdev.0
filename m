From: Michael Tokarev <mjt@tls.msk.ru>
Subject: multicast, interfaces, kernel 3.0+...
Date: Fri, 21 Sep 2012 22:46:31 +0400
Message-ID: <505CB607.7080207@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:37984 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757439Ab2IUSqg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2012 14:46:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

We found some, well, interesting behavour of kernels
3.0 and later, while 2.6.32 (previous long-stable
series) worked fine.  I'm not sure when it "broke",
since this is a production machine and we've difficult
time diagnosing it, and the app causing it is, well,
large.

The short story.  A big java app uses multicast group
to register one component and find it later.

The machine in question has 3 active network interfaces:
usual lo, eth0, and virtual (tap, pointopoint) tinc.
Tinc interface is marked as "multicast off".

When the app starts on 2.6.32 kernel, netstat -g shows
that multicast group on 2 interfaces: lo and eth0, but
not on tinc, which is sort of expected:

$ netstat -g
IPv6/IPv4 Group Memberships
Interface       RefCnt Group
--------------- ------ ---------------------
lo              4      228.5.6.7
lo              1      all-systems.mcast.net
eth0            4      228.5.6.7
eth0            1      all-systems.mcast.net
tinc            1      all-systems.mcast.net


But when the same app (actually the same userspace) is
booted on the same machine but on 3.0+ kernel, the same
multicast group is registered also on 2 interfaces, but
this time these are lo (as before) and tinc, but not eth0:

$ netstat -g
IPv6/IPv4 Group Memberships
Interface       RefCnt Group
--------------- ------ ---------------------
lo              4      228.5.6.7
lo              1      all-systems.mcast.net
eth0            1      all-systems.mcast.net
tinc            4      228.5.6.7
tinc            1      all-systems.mcast.net

Now, on 3.0+ kernel, parts of this app can't find each
other.  The "client" tries to send a datagram packet
to this address, 228.5.6.7, but receives no reply.

On 2.6.32 kernel, when eth0 is used instead of tinc,
it all works as expected.

Now, my knowlege of this multicast stuff is very limited
(reading about it now), so I don't really know what it
all means.  At least the fact that it somehow registers
tinc (which is multicast-off!) is already somewhat strange.
I tried removing this multicast setting from this iface,
but that didn't help.  I also tried enabling multicast on
lo (which was disabled!) and disabling it on others, but
that didn't help either.

According to strace, the app does not try to change iface
group membership, it does bind of a udp socket to 0.0.0.0:port,
and uses SOL_IP, IP_ADD_MEMBERSHIP to add this socket to a
multicast group.

Note: there's just ONE machine involved, and two applications
running on it.

Why with 3.0+, the non-multicast "tinc" interface is shown
as a member of 228.5.6.7 group, but not eth0 which actually
*is* multicast?

For the record, this "big java app" is Oracle reports server.
I've no idea why they use multicast to find two components
of one thing running on the same machine, and does not provide
any usable unicast solution...

Thanks!

/mjt
