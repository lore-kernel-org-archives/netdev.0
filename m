From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next V3 0/4] net/sched: ip tunnel metadata set/release/classify by using TC
Date: Thu, 25 Aug 2016 19:13:43 +0300
Message-ID: <1472141627-27339-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38671 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751615AbcHYQUt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 12:20:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset introduces ip tunnel manipulation support using the TC subsystem.

In the decap flow, it enables the user to redirect packets from a shared tunnel
device and classify by outer and inner headers. The outer headers are extracted
from the metadata and used by the flower filter. A new action act_tunnel_key,
releases the metadata.

In the encap flow, act_tunnel_key creates a metadata object to be used by the
shared tunnel device. The actual redirection to the tunnel device is done using
act_mirred.

For example:
$ tc qdisc add dev vnet0 ingress
$ tc filter add dev vnet0 protocol ip parent ffff: \
	flower \
	 ip_proto 1 \
	action tunnel_key set \
	 src_ip 11.11.0.1 \
	 dst_ip 11.11.0.2 \
	 id 11 \
	action mirred egress redirect dev vxlan0

$ tc qdisc add dev vxlan0 ingress
$ tc filter add dev vxlan0 protocol ip parent ffff: \
	flower \
	 enc_src_ip 11.11.0.2 \
	 enc_dst_ip 11.11.0.1 \
	 enc_key_id 11 \
	action tunnel_key release \
	action mirred egress redirect dev vnet0

Amir & Hadar

Changes from V2:
- Use union in struct fl_flow_key for enc_ipv6 and enc_ipv4.
- Rename functions _ip_tun_rx_dst and _ipv6_tun_rx_dst to _ip_tun_set_dst and
  _ipv6_tun_set_dst accordingly.
- Remove local parameter 'encapdecap' from tunnel_key_init function.
- Don't copy in6_addr values in tunnel_key_dump_addresses function, use pointers.

Changes from V1:
- More cleanups to key32_to_tunnel_id() and tunnel_id_to_key32()
- IPv6 Support added
- Set TUNNEL_KEY flag to make GRE work
- Handle zero tunnel id properly in act_tunnel_key
- Don't leave junk in decap action
- Fix bug in act_tunnel_key initialization where (exists & ocr) is true
- Remove BUG() from code
- Rename action to tunnel_key
- Improve grep-ability of code
- Reuse code from ip_tun_rx_dst() and ipv6_tun_rx_dst()

Changes from RFC:
- Add a new action instead of making mirred too complex
- No need to specify UDP port in action - it is already in the tunnel device
  configuration
- Added a decap operation to drop tunnel metadata

Amir Vadai (4):
  net/ip_tunnels: Introduce tunnel_id_to_key32() and
    key32_to_tunnel_id()
  net/dst: Utility functions to build dst_metadata without supplying an
    skb
  net/sched: cls_flower: Classify packet in ip tunnels
  net/sched: Introduce act_tunnel_key

 drivers/net/vxlan.c                       |   4 +-
 include/net/dst_metadata.h                |  45 +++--
 include/net/ip_tunnels.h                  |  19 ++
 include/net/tc_act/tc_tunnel_key.h        |  25 +++
 include/net/vxlan.h                       |  18 --
 include/uapi/linux/pkt_cls.h              |  11 ++
 include/uapi/linux/tc_act/tc_tunnel_key.h |  42 ++++
 net/ipv4/ip_gre.c                         |  23 +--
 net/sched/Kconfig                         |  11 ++
 net/sched/Makefile                        |   1 +
 net/sched/act_tunnel_key.c                | 312 ++++++++++++++++++++++++++++++
 net/sched/cls_flower.c                    | 101 +++++++++-
 12 files changed, 556 insertions(+), 56 deletions(-)
 create mode 100644 include/net/tc_act/tc_tunnel_key.h
 create mode 100644 include/uapi/linux/tc_act/tc_tunnel_key.h
 create mode 100644 net/sched/act_tunnel_key.c

-- 
1.8.3.1
