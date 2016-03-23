From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 0/9] udp: GRO in UDP sockets and fast encap_rcv
Date: Wed, 23 Mar 2016 15:36:49 -0700
Message-ID: <1458772618-845742-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37735 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750994AbcCWWhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 18:37:10 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u2NMaGRA021033
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 15:37:09 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 21v3tk02qp-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 15:37:09 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 c69c02b6f14711e5ae670002c9521c9e-781fb3f0 for <netdev@vger.kernel.org>;	Wed,
 23 Mar 2016 15:37:08 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set does two things:

- Add GRO functions (gro_receive and gro_complete) to UDP sockets.
- Implement "fast receive encapsulation".

Add GRO functions (gro_receive and gro_complete) to UDP sockets. In
udp_gro_receive and udp_gro_complete a socket lookup is done instead of
looking up the port number in udp_offloads.  If a socket is found and
there is are gro functions for it then those are called. This feature
allows binding GRO functions to more than just a port number.
Eventually, we will be able to use this technique to allow application
defined GRO for an application protocol by attaching BPF porgrams to UDP
sockets for doing GRO.

Fast receive encapsulation allows encap_rcv to be called for a socket
without taking the reference to the socket.  The callee can assume it
was called under rcu_read_lock, but must assume that no reference to the
socket is held (so the socket structures should not be written to and
pointer not saved).

In order to implement these function, no socket reference lookup
functions were added in ipv4/udp.c and ipv6/udp.c. Also, inet_iif and
references to skb_dst() were changed to check that dst is set in skbuf
before derefencing.  In the GRO path there is now a UDP socket lookup
performed before dst is set, to the get the device in that case we
simply use skb->dev.

Tested:

Ran various combinations of VXLAN and GUE TCP_STREAM and TCP_RR tests.
DId not see any regressions. perf shows a that the atomic opertions in
taking a reference to UDP sockets in lookup is eliminated for
encapsulation.

Also ran plain UDP_RR. DId not see any regression there.

Tom Herbert (9):
  net: Check skb_dst for NULL in inet_iif
  udp: Add noreference lookup functions
  net: Add fast receive encapsulation
  udp: Add GRO functions to UDP socket
  udp: Add socket based GRO and fast receive encap to tunnel config
  vxlan: change vxlan to use UDP socket GRO
  fou: change to use UDP socket GRO and fast rcv encap
  geneve: change to use UDP socket GRO
  udp: Remove udp_offloads

 drivers/net/geneve.c      |  29 ++----
 drivers/net/vxlan.c       |  31 ++----
 include/linux/netdevice.h |  17 ----
 include/linux/udp.h       |  13 ++-
 include/net/protocol.h    |   3 -
 include/net/route.h       |   7 +-
 include/net/udp.h         |  19 +++-
 include/net/udp_tunnel.h  |   8 ++
 include/net/vxlan.h       |   1 -
 net/ipv4/fou.c            |  49 ++++------
 net/ipv4/udp.c            | 237 +++++++++++++++++++++++++++++-----------------
 net/ipv4/udp_offload.c    | 113 ++++------------------
 net/ipv4/udp_tunnel.c     |   3 +
 net/ipv6/Makefile         |   5 +-
 net/ipv6/af_inet6.c       |   8 ++
 net/ipv6/ip6_offload.c    |   2 -
 net/ipv6/ip6_offload.h    |   3 +-
 net/ipv6/udp.c            | 166 +++++++++++++++++---------------
 net/ipv6/udp_offload.c    |  11 ++-
 19 files changed, 360 insertions(+), 365 deletions(-)

-- 
2.8.0.rc2
