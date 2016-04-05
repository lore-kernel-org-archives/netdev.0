From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/8] udp: GRO in UDP sockets
Date: Tue, 5 Apr 2016 08:22:48 -0700
Message-ID: <1459869776-2090500-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:11812 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751464AbcDEPXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 11:23:07 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u35FL1QB028957
	for <netdev@vger.kernel.org>; Tue, 5 Apr 2016 08:23:05 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 224d629bf0-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 08:23:05 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 4a232278fb4211e5b9fc24be05956610-e6fc13f0 for <netdev@vger.kernel.org>;	Tue,
 05 Apr 2016 08:23:03 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds GRO functions (gro_receive and gro_complete) to UDP
sockets and removes udp_offload infrastructure.

Add GRO functions (gro_receive and gro_complete) to UDP sockets. In
udp_gro_receive and udp_gro_complete a socket lookup is done instead of
looking up the port number in udp_offloads.  If a socket is found and
there are GRO functions for it then those are called. This feature
allows binding GRO functions to more than just a port number.
Eventually, we will be able to use this technique to allow application
defined GRO for an application protocol by attaching BPF porgrams to UDP
sockets for doing GRO.

In order to implement these functions, we added exported
udp6_lib_lookup_skb and udp4_lib_lookup_skb functions in ipv4/udp.c and
ipv6/udp.c. Also, inet_iif and references to skb_dst() were changed to
check that dst is set in skbuf before derefencing. In the GRO path there
is now a UDP socket lookup performed before dst is set, to the get the
device in that case we simply use skb->dev.

Tested:

Ran various combinations of VXLAN and GUE TCP_STREAM and TCP_RR tests.
Did not see any material regression.

Tom Herbert (8):
  net: Checks skb_dst to be NULL in inet_iif
  udp: Add udp6_lib_lookup_skb and udp4_lib_lookup_skb
  udp: Add GRO functions to UDP socket
  udp: Add socket based GRO and config
  vxlan: change vxlan to use UDP socket GRO
  fou: change to use UDP socket GRO
  geneve: change to use UDP socket GRO
  udp: Remove udp_offloads

 drivers/net/geneve.c      |  28 ++++--------
 drivers/net/vxlan.c       |  30 ++++--------
 include/linux/netdevice.h |  17 -------
 include/linux/udp.h       |   8 ++++
 include/net/protocol.h    |   3 --
 include/net/route.h       |   7 +--
 include/net/udp.h         |  11 ++++-
 include/net/udp_tunnel.h  |   7 +++
 include/net/vxlan.h       |   1 -
 net/ipv4/fou.c            |  48 +++++++-------------
 net/ipv4/udp.c            |  13 ++++++
 net/ipv4/udp_offload.c    | 113 ++++++++--------------------------------------
 net/ipv4/udp_tunnel.c     |   2 +
 net/ipv6/Makefile         |   5 +-
 net/ipv6/af_inet6.c       |   8 ++++
 net/ipv6/ip6_offload.c    |   2 -
 net/ipv6/ip6_offload.h    |   3 +-
 net/ipv6/udp.c            |  13 ++++++
 net/ipv6/udp_offload.c    |  11 +++--
 19 files changed, 129 insertions(+), 201 deletions(-)

-- 
2.8.0.rc2
