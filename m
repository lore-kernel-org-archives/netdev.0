From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v2 net-next 0/6] flow_dissector: Protocol specific flow dissector offload
Date: Tue, 29 Aug 2017 16:27:05 -0700
Message-ID: <20170829232711.1465-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35066 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751240AbdH2X12 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 19:27:28 -0400
Received: by mail-pf0-f182.google.com with SMTP id g13so14379502pfm.2
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 16:27:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds a new offload type to perform flow dissection for
specific protocols (either by EtherType or by IP protocol). This is
primary useful to crack open UDP encapsulations (like VXLAN, GUE) for
the purposes of parsing the encapsulated packet.

Items in this patch set:
- Constify skb argument to UDP lookup functions
- Create new protocol case in __skb_dissect for ETH_P_TEB. This is based
  on the code in the GRE dissect function and the special handling in
  GRE can now be removed (it sets protocol to ETH_P_TEB and returns so
  goto proto_again is done)
- Add infrastructure for protocol specific flow dissection offload
- Add infrastructure to perform UDP flow dissection. Uses same model of
  GRO where a flow_dissect callback can be associated with a UDP
  socket
- Use the infrastructure to support flow dissection of VXLAN and GUE

Tested:

Forced RPS to call flow dissection for VXLAN, FOU, and GUE. Observed
that inner packet was being properly dissected.

v2: Add signed off

Tom Herbert (6):
  flow_dissector: Move ETH_P_TEB processing to main switch
  udp: Constify skb argument in lookup functions
  flow_dissector: Add protocol specific flow dissection offload
  udp: flow dissector offload
  fou: Support flow dissection
  vxlan: support flow dissect

 drivers/net/vxlan.c          |  50 ++++++++++++
 include/linux/netdevice.h    |   7 ++
 include/linux/udp.h          |   8 ++
 include/net/flow_dissector.h |   9 +++
 include/net/ip.h             |   2 +-
 include/net/sock_reuseport.h |   2 +-
 include/net/udp.h            |  19 +++--
 include/net/udp_tunnel.h     |   8 ++
 net/core/dev.c               |  14 ++++
 net/core/flow_dissector.c    | 176 +++++++++++++++++++++++++++++--------------
 net/core/sock_reuseport.c    |   5 +-
 net/ipv4/fou.c               |  63 ++++++++++++++++
 net/ipv4/route.c             |   4 +-
 net/ipv4/udp.c               |  11 +--
 net/ipv4/udp_offload.c       |  45 +++++++++++
 net/ipv4/udp_tunnel.c        |   1 +
 net/ipv6/udp.c               |  10 +--
 net/ipv6/udp_offload.c       |  13 ++++
 18 files changed, 369 insertions(+), 78 deletions(-)

-- 
2.11.0
