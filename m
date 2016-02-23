From: Gilberto Bertin <gilberto.bertin@gmail.com>
Subject: [net-next RFC 0/4] SO_BINDTOSUBNET
Date: Tue, 23 Feb 2016 15:27:41 +0000
Message-ID: <1456241265-5766-1-git-send-email-gilberto.bertin@gmail.com>
Cc: Gilberto Bertin <gilberto.bertin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38487 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752496AbcBWP1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 10:27:47 -0500
Received: by mail-wm0-f42.google.com with SMTP id a4so214314501wme.1
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 07:27:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series introduces support for the SO_BINDTOSUBNET socket option, which
allows a listener socket to bind to a subnet instead of * or a single address.

Motivation:
consider a set of servers, each one with thousands and thousands of IP
addresses. Since assigning /32 or /128 IP individual addresses would be
inefficient, one solution can be assigning subnets using local routes
(with 'ip route add local').

This allows a listener to listen and terminate connections going to any
of the IP addresses of these subnets without explicitly configuring all
of them. This is very efficient.

Unfortunately there may be the need to use different subnets for
different purposes.
One can imagine port 80 being served by one HTTP server for some IP
subnet, while another server used for another subnet.
Right now Linux does not allow this.
It is either possible to bind to *, indicating ALL traffic going to
given port, or to individual IP addresses.
The first only allows to accept connections from all the subnets.
The latter does not scale well with lots of IP addresses.

Using bindtosubnet would solve this problem: just by adding a local
route rule and setting the SO_BINDTOSUBNET option for a socket it would
be possible to easily partition traffic by subnets.

API:
the subnet is specified (as argument of the setsockopt syscall) by the
address of the network, and the prefix length of the netmask.

IPv4:
	struct ipv4_subnet {
		__be32 net;
		u_char plen;
	};

and IPv6:
	struct ipv6_subnet {
		struct in6_addr net;
		u_char plen;
	};

Bind conflicts:
two sockets with the bindtosubnet option enabled generate a bind
conflict if their network addresses masked with the shortest of their
prefix are equal.
The bindtosubnet option can be combined with soreuseport so that two
listener can bind on the same subnet.

Any questions/feedback appreciated.

Thanks,
  Gilberto

Gilberto Bertin (4):
  bindtosubnet: infrastructure
  bindtosubnet: TCP/IPv4 implementation
  bindtosubnet: TCP/IPv6 implementation
  bindtosubnet: UPD implementation

 include/net/sock.h                |  20 +++++++
 include/uapi/asm-generic/socket.h |   1 +
 net/core/sock.c                   | 111 ++++++++++++++++++++++++++++++++++++++
 net/ipv4/inet_connection_sock.c   |  20 ++++++-
 net/ipv4/inet_hashtables.c        |   9 ++++
 net/ipv4/udp.c                    |  35 ++++++++++++
 net/ipv6/inet6_connection_sock.c  |  17 +++++-
 net/ipv6/inet6_hashtables.c       |   6 +++
 8 files changed, 217 insertions(+), 2 deletions(-)

-- 
2.7.1
