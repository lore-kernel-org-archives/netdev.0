From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/5] udp: Flow dissection for tunnels
Date: Wed, 12 Oct 2016 16:25:42 -0700
Message-ID: <20161012232547.2383961-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:54692 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933169AbcJLXZy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 19:25:54 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9CNNfNK004023
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 16:25:53 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 261raxtbq6-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 16:25:53 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 3788814a90d311e691fe0002c9931860-ef9fca50 for <netdev@vger.kernel.org>;        Wed,
 12 Oct 2016 16:25:52 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we have a means to perform a UDP socket lookup without taking
a reference, it is feasible to have flow dissector crack open UDP
encapsulated packets. Generally, we would expect that the UDP source
port or the flow label in IPv6 would contain enough entropy about
the encapsulated flow. However, there will be cases, such as a static
UDP tunnel with fixed ports, where dissecting the encapsulated packet
is valuable.

The model is here is similar to that implemented for UDP GRO. A
tunnel implementation (e.g. GUE) may set a flow_dissect function
in the udp_sk. In __skb_flow_dissect a case has been added for
UDP to check if there is a socket with flow_dissect set. If there
is the function is called. The (per tunnel implementation)
function can parse the encapsulation headers and return the
next protocol for __skb_flow_dissect to process and it's position
in nhoff.

Since performing a UDP lookup on every packet might be expensive
I added a static key check to bypass the lookup if there are no
sockets with flow_dissect set. I should mention that doing the
lookup wasn't particularly a big hit anyway.

Fou/gue was modified to perform tunnel dissection. This is enabled
on each listener socket via a netlink configuration option.

Tested:

Running 200 streams with TCP_RR.

GRE/GUE variable source port (baseline)
RSS distributes packets, RFS is effective
1211702 tps
147/241/442 50/90/99% latencies
87.95 CPU utilization

GRE/GUE fixed source port
All packets to one CPU, RFS is ineffective
173680 tps
1170/1377/1853 50/90/99% latencies
7.42 CPU utilization

GRE/GUE fixed source port with deep hash enabled
All packets to one CPU, but now RFS is effective
730359 tps
263/325/464 50/90/99% latencies
38.25% CPU utilization (Interrupting CPU is maxed out)


Tom Herbert (5):
  udp: Add socket lookup functions with noref
  udp: UDP flow dissector
  udp: Add UDP flow dissection functions to IPv4 and IPv6
  udp: UDP tunnel flow dissection infrastructure
  fou: Support flow dissection

 include/linux/netdevice.h    |  5 +++
 include/linux/udp.h          |  7 +++++
 include/net/flow_dissector.h |  8 +++++
 include/net/udp.h            | 12 ++++++++
 include/net/udp_tunnel.h     |  5 +++
 include/uapi/linux/fou.h     |  1 +
 net/core/flow_dissector.c    | 73 ++++++++++++++++++++++++++++++++++++++++++--
 net/ipv4/fou.c               | 68 ++++++++++++++++++++++++++++++++++++++++-
 net/ipv4/udp.c               | 11 +++++++
 net/ipv4/udp_offload.c       | 39 +++++++++++++++++++++++
 net/ipv4/udp_tunnel.c        |  5 +++
 net/ipv6/udp.c               | 10 ++++++
 net/ipv6/udp_offload.c       | 38 +++++++++++++++++++++++
 13 files changed, 279 insertions(+), 3 deletions(-)

-- 
2.9.3
