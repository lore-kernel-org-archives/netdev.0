From: Gilberto Bertin <gilberto.bertin@gmail.com>
Subject: [net-next RFC 0/4] SO_BINDTOPREFIX
Date: Wed, 23 Mar 2016 02:26:02 +0000
Message-ID: <1458699966-3752-1-git-send-email-gilberto.bertin@gmail.com>
Cc: tom@herbertland.com, markzzzsmith@gmail.com,
	Gilberto Bertin <gilberto.bertin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37230 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055AbcC2Nhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 09:37:50 -0400
Received: by mail-wm0-f47.google.com with SMTP id p65so26891586wmp.0
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 06:37:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the net-next window just opened, I'm resubmitting my RFC for the
SO_BINDTOSUBNET patch, following Mark Smith's suggestion to rename the
whole thing to a more clear SO_BINDTOPREFIX.

Some arguments for and against it since the first submission:
* SO_BINDTOPREFIX is an arbitrary option and can be seens as nother use
* case of the SO_REUSEPORT BPF patch
* but at the same time using BPF requires more work/code on the server
  and since the bind to prefix use case could potentially become a
  common one maybe there is some value in having it as an option instead
  of having to code (either manually or with clang) an eBPF program that
  would do the same
* it may probably possible to archive the same results using VRF. This
  would require to create a VRF device, configure the device routing
  table and make each bind each process to a different VRF device (but
  I'm not sure how this would work/interfere with an existing iptables
  setup for example)

-----------------------------------------------------------------------------

This series introduces support for the SO_BINDTOPREFIX socket option, which
allows a listener socket to bind to a prefix instead of * or a single address.

Motivation:
consider a set of servers, each one with thousands and thousands of IP
addresses. Since assigning /32 or /128 IP individual addresses would be
inefficient, one solution can be assigning prefixes using local routes
(with 'ip route add local').

This allows a listener to listen and terminate connections going to any
of the IP addresses of these prefixes without explicitly configuring all
the IP addresses of the prefix range.
This is very efficient.

Unfortunately there may be the need to use different prefixes for
different purposes.
One can imagine port 80 being served by one HTTP server for some IP
prefix, while another server used for another prefix.
Right now Linux does not allow this.
It is either possible to bind to *, indicating ALL traffic going to
given port, or to individual IP addresses.
The first only allows to accept connections from all the prefixes.
The latter does not scale well with lots of IP addresses.

Using bindtoprefix would solve this problem: just by adding a local
route rule and setting the SO_BINDTOPREFIX option for a socket it would
be possible to easily partition traffic by prefixes.

API:
the prefix is specified (as argument of the setsockopt syscall) by the
address of the network, and the prefix length of the netmask.

IPv4:
	struct ipv4_prefix {
		__be32 net;
		u_char plen;
	};

and IPv6:
	struct ipv6_prefix {
		struct in6_addr net;
		u_char plen;
	};

Bind conflicts:
two sockets with the bindtoprefix option enabled generate a bind
conflict if their network addresses masked with the shortest of their
prefix are equal.
The bindtoprefix option can be combined with soreuseport so that two
listener can bind on the same prefix.

Any questions/feedback appreciated.

Thanks,
 Gilberto

Gilberto Bertin (4):
  bindtoprefix: infrastructure
  bindtoprefix: TCP/IPv4 implementation
  bindtoprefix: TCP/IPv6 implementation
  bindtoprefix: UPD implementation

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
2.7.3
