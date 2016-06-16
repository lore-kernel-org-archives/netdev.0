From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Thu, 16 Jun 2016 10:51:54 -0700
Message-ID: <1466099522-690741-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:31347 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754697AbcFPRwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 13:52:18 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5GHpiWY005858
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:52:18 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 23kyrn8bf9-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:52:18 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 10b55baa33eb11e6b7aa0002c9dfb610-84cc2e0 for <netdev@vger.kernel.org>;	Thu,
 16 Jun 2016 10:52:17 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Transports over UDP is intended to encapsulate TCP and other transport
protocols directly and securely in UDP.

The goal of this work is twofold:

1) Allow applications to run their own transport layer stack (i.e.from
   userspace). This eliminates dependencies on the OS (e.g. solves a
   major dependency issue for Facebook on clients).

2) Make transport layer headers (all of L4) invisible to the network
   so that they can't do intrusive actions at L4. This will be enforced
   with DTLS in use.

Note that #1 is really about running a transport stack in userspace
applications in clients, not necessarily servers. For servers we
intend to modified the kernel stack in order to leverage existing
implementation for building scalable serves (hence these patches).

This is described in more detail in the Internet Draft:
https://tools.ietf.org/html/draft-herbert-transports-over-udp-00

In Part I we implement a straightforward encapsulation of TCP in GUE.
The implements the basic mechanics of TOU encapsulation for TCP,
however does not yet implement the IP addressing interactions so
therefore so this is not robust to use in the presence of NAT.
TOU is enabled per socket with a new socket option. This
implementation includes GSO, GRO, and RCO support.

These patches also establish the baseline performance of TOU
and isolate the performance cost of UDP encapsulation. Performance
results are below.

Tested: Various cases of TOU with IPv4, IPv6 using TCP_STREAM and
TCP_RR. Also, tested IPIP for comparing TOU encapsulation to IP
tunneling.

    - IPv6 native
      1 TCP_STREAM
	8394 tps
      200 TCP_RR
	1726825 tps
	100/177/361 90/95/99% latencies

    - IPv6 TOU with RCO
      1 TCP_STREAM
	7410 tps
      200 TCP_RR
	1445603 tps
	121/211/395 90/95/99% latencies

    - IPv4 native
      1 TCP_STREAM
	8525 tps
      200 TCP_RR
	1826729 tps
	94/166/345 90/95/99% latencies

    - IPv4 TOU with RCO
      1 TCP_STREAM
	7624 tps
      200 TCP_RR
	1599642 tps
	108/190/377 90/95/99% latencies

    - IPIP with GUE and RCO
      1 TCP_STREAM
	5092 tps
      200 TCP_RR
	1276716 tps
	137/237/445 90/95/99% latencies


Tom Herbert (8):
  net: Change SKB_GSO_DODGY to be a tx_flag
  fou: Change ip_tunnel_encap to take net argument
  tou: Base infrastructure for Transport over UDP
  ipv4: Support TOU
  tcp: Support for TOU
  ipv6: Support TOU
  tcp6: Support for TOU
  tou: Support for GSO

 drivers/net/xen-netfront.c       |   2 +-
 include/linux/netdev_features.h  |   4 +-
 include/linux/netdevice.h        |   2 +-
 include/linux/skbuff.h           |   6 +-
 include/linux/virtio_net.h       |   2 +-
 include/net/fou.h                |   4 +-
 include/net/inet_sock.h          |   2 +
 include/net/ip6_tunnel.h         |   5 +-
 include/net/ip_tunnels.h         |   6 +-
 include/net/udp.h                |   2 +
 include/uapi/linux/if_tunnel.h   |  10 +++
 include/uapi/linux/in.h          |   1 +
 include/uapi/linux/in6.h         |   1 +
 net/core/dev.c                   |   2 +-
 net/core/skbuff.c                |   2 +-
 net/ipv4/Makefile                |   3 +-
 net/ipv4/af_inet.c               |   4 +
 net/ipv4/fou.c                   |  20 ++---
 net/ipv4/ip_output.c             |  44 +++++++++--
 net/ipv4/ip_sockglue.c           |   7 ++
 net/ipv4/tcp_ipv4.c              |   9 ++-
 net/ipv4/tou.c                   | 140 +++++++++++++++++++++++++++++++++
 net/ipv4/udp_offload.c           | 163 +++++++++++++++++++++++++++++++++++++--
 net/ipv6/fou6.c                  |   8 +-
 net/ipv6/inet6_connection_sock.c |  61 +++++++++++++--
 net/ipv6/ipv6_sockglue.c         |   7 ++
 net/ipv6/tcp_ipv6.c              |  11 +--
 net/ipv6/udp_offload.c           | 128 +++++++++++++++---------------
 net/packet/af_packet.c           |   2 +-
 29 files changed, 538 insertions(+), 120 deletions(-)
 create mode 100644 net/ipv4/tou.c

-- 
2.8.0.rc2
