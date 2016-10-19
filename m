From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v4 net-next 0/7] udp: Flow dissection for tunnels
Date: Wed, 19 Oct 2016 16:03:02 -0700
Message-ID: <20161019230309.3746853-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:40268 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752104AbcJSXDU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 19:03:20 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9JN2D1H004913
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 16:03:19 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 266e7eha33-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 16:03:19 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.212.236.87) with ESMTP id
 38fcb974965011e68fa30002c9521c9e-f5dfba50 for <netdev@vger.kernel.org>;        Wed,
 19 Oct 2016 16:03:18 -0700
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

v2:
  - davem suggested that we don't need udp_flow_dissect and that
    udp{v6}_encap_needed could be used. Problem is that those are
    in respective udp.c and flow_dissector.c is in net/core. Keep
    udp_flow_dissect as more generic item.
  - Fixed Makefile issue where we were using CONFIG_NET instead of
    CONFIG_INET.
  - Added limits inf flow dissector from controlling number of nested
    encapsulations or EHs that are dissected.
  - Added CONFIG_INET around use of inet_offloads in flow_dissector.c.

v3:
  - Fix build issues with modules that call IPv6 functions and
    CONFIG_INET is not set.
  - Fix compilation error in init'ing .flow_dissect in IPv6 UDP
    offload.

v4:
  - Fix compilation error in init'ing .flow_dissect in IPv6 UDP
    offload. (hopefully for real this time).

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


Tom Herbert (7):
  ipv6: Fix Makefile conditional to use CONFIG_INET
  flow_dissector: Limit processing of next encaps and extensions
  udp: Add socket lookup functions with noref
  udp: UDP flow dissector
  udp: Add UDP flow dissection functions to IPv4 and IPv6
  udp: UDP tunnel flow dissection infrastructure
  fou: Support flow dissection

 drivers/net/usb/cdc_mbim.c   |   4 ++
 include/linux/netdevice.h    |   5 ++
 include/linux/udp.h          |   7 +++
 include/net/flow_dissector.h |   8 +++
 include/net/ipv6.h           |  15 ++++++
 include/net/net_namespace.h  |   2 +
 include/net/udp.h            |  12 +++++
 include/net/udp_tunnel.h     |   5 ++
 include/uapi/linux/fou.h     |   1 +
 net/Makefile                 |   2 +-
 net/core/flow_dissector.c    | 122 ++++++++++++++++++++++++++++++++++++++-----
 net/ipv4/fou.c               |  68 +++++++++++++++++++++++-
 net/ipv4/udp.c               |  11 ++++
 net/ipv4/udp_offload.c       |  39 ++++++++++++++
 net/ipv4/udp_tunnel.c        |   5 ++
 net/ipv6/udp.c               |  10 ++++
 net/ipv6/udp_offload.c       |  40 +++++++++++++-
 17 files changed, 341 insertions(+), 15 deletions(-)

-- 
2.9.3
