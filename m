From: Gilberto Bertin <gilberto.bertin@gmail.com>
Subject: [net-next RFC 0/4] SO_BINDTOSUBNET
Date: Wed, 16 Mar 2016 13:19:05 +0000
Message-ID: <1458134349-2454-1-git-send-email-gilberto.bertin@gmail.com>
Cc: Gilberto Bertin <gilberto.bertin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37800 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933804AbcCPNiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 09:38:13 -0400
Received: by mail-wm0-f54.google.com with SMTP id p65so72992613wmp.0
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 06:38:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is my second attempt to submit an RFC for this patch.

Some arguments for and against it since the first submission:
* SO_BINDTOSUBNET is an arbitrary option and can be seens as nother use
* case of the SO_REUSEPORT BPF patch
* but at the same time using BPF requires more work/code on the server
  and since the bind to subnet use case could potentially become a
  common one maybe there is some value in having it as an option instead
  of having to code (either manually or with clang) an eBPF program that
  would do the same
* it may probably possible to archive the same results using VRF. This
  would require to create a VRF device, configure the device routing
  table and make each bind each process to a different VRF device (but
  I'm not sure how this would work/interfere with an existing iptables
  setup for example)

-----------------------------------------------------------------------------

This series introduces support for the SO_BINDTOSUBNET socket option, which
allows a listener socket to bind to a subnet instead of * or a single address.

Motivation:
consider a set of servers, each one with thousands and thousands of IP
addresses. Since assigning /32 or /128 IP individual addresses would be
inefficient, one solution can be assigning subnets using local routes
(with 'ip route add local').

This allows a listener to listen and terminate connections going to any
of the IP addresses of these subnets without explicitly configuring all
the IP addresses of the subnet range.
This is very efficient.

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
 net/ipv4/udp.c                    |  36 +++++++++++++
 net/ipv6/inet6_connection_sock.c  |  17 +++++-
 net/ipv6/inet6_hashtables.c       |   6 +++
 8 files changed, 218 insertions(+), 2 deletions(-)

-- 
2.7.2
