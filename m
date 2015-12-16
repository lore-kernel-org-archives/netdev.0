From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH v7 0/4] Support administratively closing application sockets
Date: Wed, 16 Dec 2015 12:30:01 +0900
Message-ID: <1450236605-87170-1-git-send-email-lorenzo@google.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	eric.dumazet@gmail.com, ek@google.com, tom@herbertland.com,
	zenczykowski@gmail.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36513 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932667AbbLPDaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 22:30:17 -0500
Received: by mail-pa0-f43.google.com with SMTP id nt2so6216379pab.3
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 19:30:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds the ability to administratively close a socket
without any action from the process owning the socket or the
socket protocol.

It implements this by adding a new diag_destroy function pointer
to struct proto. In-kernel callers can access this functionality
directly by calling sk->sk_prot->diag_destroy(sk, err).

It also exposes this functionality to userspace via a new
SOCK_DESTROY operation in the NETLINK_SOCK_DIAG sockets. This
allows a privileged userspace process, such as a connection
manager or system administration tool, to close sockets belonging
to other apps when the network they were established on has
disconnected. It is needed on laptops and mobile hosts to ensure
that network switches / disconnects do not result in applications
being blocked for long periods of time (minutes) in read or
connect calls on TCP sockets that will never succeed because the
IP address they are bound to is no longer on the system. Closing
the sockets causes these calls to fail fast and allows the apps
to reconnect on another network.

Userspace intervention is necessary because in many cases the
kernel does not have enough information to know that a connection
is now inoperable. The kernel can know if a packet can't be
routed, but in general it won't know if a TCP connection is stuck
because it is now routed to a network where its source address is
no longer valid [5][6].

Many other operating systems offer similar functionality:

 - FreeBSD has had this since 5.4 in 2005 [2]. It is available
   to privileged userspace and there is a tool to use it [3].
 - The FreeBSD commit description states that the idea came
   from OpenBSD.
 - iOS has been administratively closing app sockets since
   iOS 4 - see [4], which states that a socket "might get
   reclaimed by the kernel" and after that will return EBADF].
   For many years Android kernels have supported this via an
   out-of-tree SIOCKILLADDR ioctl that is called on every
   RTM_DELADDR event, but this solution is cleaner, more robust
   and more flexible: the connection manager can iterate over all
   connections on the deleted IP address and close all of them.
   It can also be used to close all sockets opened by a given app
   process, for example if the user has restricted that app from
   using the network, if a secure network such as a VPN has
   connected and security policy requires all of an application's
   connections to be routed via the VPN, etc.
 - For many years Android kernels have supported an out-of-tree
   SIOCKILLADDR ioctl that is called when a network disconnects
   or an RTM_DELADDR event is received. This solution is cleaner,
   more robust and more flexible. The connection manager can
   implement SIOCKILLADDR by iterating over all connections on
   the deleted IP address and close all of them, but it can also
   close all sockets opened by a given app process (for example
   if the user has restricted that app from), close all of a
   user's TCP connections if a user has connected a secure
   network such as a VPN and expects all of an application's
   connections to be routed via the VPN, etc.

Alternative schemes such as TCP keepalives in combination with
"iptables -j REJECT --reject-with tcp-reset", could be used to
achieve similar results, but on mobile devices TCP keepalives are
very expensive, and in such a scheme detecting stuck connections
has to wait for a keepalive to be sent or the application to
perform a write. An explicit notification from userspace is
cheaper and faster in the common case where an application is
blocked on read.

SOCK_DESTROY is placed behind an INET_DIAG_DESTROY configuration
option, which is currently off by default.

The TCP implementation of diag_destroy causes a TCP ABORT as
specified by RFC 793 [1]: immediately send a RST and clear local
connection state. This is what happens today if an application
enables SO_LINGER with a timeout of 0 and then calls close.

The first versions of the patchset did not send a RST, but that
is not graceful/correct TCP behaviour. tcp_abort now does a
proper RFC 793 ABORT and sends a RST to the peer. This is
consistent with BSD's tcpdrop, and is more correct in general,
even though in many use cases tcp_abort will only be called when
sending a RST is no longer possible (e.g., the network has
disconnected).

The original patchset also behaved like SIOCKILADDR and closed
TCP sockets with ETIMEDOUT. Tom Herbert pointed out that it would
be better if applications could distinguish between a timeout and
an administrative close. ECONNABORTED was chosen because it is
consistent with BSD.

[1] http://tools.ietf.org/html/rfc793#page-50
[2] http://svnweb.freebsd.org/base?view=revision&revision=141381
[3] https://www.freebsd.org/cgi/man.cgi?query=tcpdrop&sektion=8&manpath=FreeBSD+5.4-RELEASE
[4] https://developer.apple.com/library/ios/technotes/tn2277/_index.html#//apple_ref/doc/uid/DTS40010841-CH1-SUBSECTION3
[5] http://www.spinics.net/lists/netdev/msg352775.html
[6] http://www.spinics.net/lists/netdev/msg352952.html

Lorenzo Colitti (4):
  net: diag: split inet_diag_dump_one_icsk into two
  net: diag: Add the ability to destroy a socket.
  net: diag: Support SOCK_DESTROY for inet sockets.
  net: diag: Support destroying TCP sockets.

 include/linux/inet_diag.h      |  9 ++++++
 include/linux/sock_diag.h      |  2 ++
 include/net/sock.h             |  1 +
 include/net/tcp.h              |  2 ++
 include/uapi/linux/sock_diag.h |  1 +
 net/core/sock_diag.c           | 23 +++++++++++++--
 net/ipv4/Kconfig               | 13 +++++++++
 net/ipv4/inet_diag.c           | 65 +++++++++++++++++++++++++++---------------
 net/ipv4/tcp.c                 | 32 +++++++++++++++++++++
 net/ipv4/tcp_diag.c            | 19 ++++++++++++
 net/ipv4/tcp_ipv4.c            |  1 +
 net/ipv6/tcp_ipv6.c            |  1 +
 12 files changed, 143 insertions(+), 26 deletions(-)

-- 
2.6.0.rc2.230.g3dd15c0
