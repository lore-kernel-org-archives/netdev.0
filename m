From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v4 net-next 0/8] flow_dissector: Protocol specific flow dissector offload
Date: Thu, 28 Sep 2017 16:52:22 -0700
Message-ID: <20170928235230.22158-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:54583 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751456AbdI1Xws (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 19:52:48 -0400
Received: by mail-pf0-f177.google.com with SMTP id d187so1626099pfg.11
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 16:52:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds a new offload type to perform flow dissection for
specific protocols (either by EtherType or by IP protocol). This is
primary useful to crack open UDP encapsulations (like VXLAN, GUE) for
the purposes of parsing the encapsulated packet.

Items in this patch set:
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

v3:
   - Make skb argument of flow dissector to be non const
   - Change UDP GRO to only do something if encap_needed static
     key is set
   - don't reference inet6_offloads or inet_offloads, get to
     them through ptype

v4:
   - skb argument to ndo_rx_flow_steer allso needs to become
     non constant

Tom Herbert (8):
  flow_dissector: Change skbuf argument to be non const
  flow_dissector: Move ETH_P_TEB processing to main switch
  udp: Check static key udp_encap_needed in udp_gro_receive
  flow_dissector: Add protocol specific flow dissection offload
  ip: Add callbacks to flow dissection by IP protocol
  udp: flow dissector offload
  fou: Support flow dissection
  vxlan: support flow dissect

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  2 +-
 drivers/net/ethernet/cisco/enic/enic_clsf.c       |  2 +-
 drivers/net/ethernet/cisco/enic/enic_clsf.h       |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c |  2 +-
 drivers/net/ethernet/qlogic/qede/qede.h           |  2 +-
 drivers/net/ethernet/qlogic/qede/qede_filter.c    |  2 +-
 drivers/net/ethernet/sfc/efx.h                    |  2 +-
 drivers/net/ethernet/sfc/falcon/efx.h             |  2 +-
 drivers/net/ethernet/sfc/falcon/rx.c              |  2 +-
 drivers/net/ethernet/sfc/rx.c                     |  2 +-
 drivers/net/vxlan.c                               | 40 +++++++++++++
 include/linux/netdevice.h                         | 31 +++++++++-
 include/linux/skbuff.h                            | 12 ++--
 include/linux/udp.h                               |  8 +++
 include/net/flow_dissector.h                      |  1 +
 include/net/ip_fib.h                              |  4 +-
 include/net/route.h                               |  4 +-
 include/net/udp.h                                 | 10 ++++
 include/net/udp_tunnel.h                          |  8 +++
 net/core/dev.c                                    | 65 +++++++++++++++++++++
 net/core/flow_dissector.c                         | 71 ++++++++++++++---------
 net/ipv4/af_inet.c                                | 27 +++++++++
 net/ipv4/fib_semantics.c                          |  2 +-
 net/ipv4/fou.c                                    | 63 ++++++++++++++++++++
 net/ipv4/route.c                                  | 10 ++--
 net/ipv4/udp.c                                    |  4 +-
 net/ipv4/udp_offload.c                            | 55 ++++++++++++++++++
 net/ipv4/udp_tunnel.c                             |  1 +
 net/ipv6/ip6_offload.c                            | 27 +++++++++
 net/ipv6/udp_offload.c                            | 23 ++++++++
 net/sched/sch_sfq.c                               |  2 +-
 33 files changed, 433 insertions(+), 59 deletions(-)

-- 
2.11.0
