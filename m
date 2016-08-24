From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next V2 0/4] net/sched: ip tunnel metadata set/release/classify by using TC
Date: Wed, 24 Aug 2016 15:27:06 +0300
Message-ID: <20160824122710.30356-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@redhat.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34794 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751063AbcHXM2m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 08:28:42 -0400
Received: by mail-wm0-f66.google.com with SMTP id q128so2436935wma.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 05:27:18 -0700 (PDT)
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

Amir

Changes from V0:
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
 net/sched/act_tunnel_key.c                | 314 ++++++++++++++++++++++++++++++
 net/sched/cls_flower.c                    |  89 ++++++++-
 12 files changed, 546 insertions(+), 56 deletions(-)
 create mode 100644 include/net/tc_act/tc_tunnel_key.h
 create mode 100644 include/uapi/linux/tc_act/tc_tunnel_key.h
 create mode 100644 net/sched/act_tunnel_key.c

-- 
2.9.0
