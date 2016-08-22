From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next 0/3] net/sched: iptunnel encap/decap/classify using TC
Date: Mon, 22 Aug 2016 17:38:31 +0300
Message-ID: <20160822143834.32422-1-amir@vadai.me>
Cc: netdev@vger.kernel.org,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36426 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755329AbcHVOjE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 10:39:04 -0400
Received: by mail-wm0-f68.google.com with SMTP id i138so13768672wmf.3
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 07:38:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset introduces iptunnel support using the TC subsystem.

In the decap flow, it enables the user to redirect packets from a shared tunnel
device and classify by outer and inner headers. The outer headers are extracted
from the metadata and used by the flower filter. A new action act_iptunnel,
releases the metadata.

In the encap flow, act_iptunnel creates a metadata object to be used by the
shared tunnel device. The actual redirection to the tunnel device is done using
act_mirred.

For example:
$ tc qdisc add dev vnet0 ingress
$ tc filter add dev vnet0 protocol ip parent ffff: \
    flower \
  	  ip_proto 1 \
  	action iptunnel encap \
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
  	action iptunnel decap \
  	  action mirred egress redirect dev vnet0

note: Current implementation supports ipv4 only, but it should be easy to add
      ipv6 later on.

Amir

Changes from RFC:
- Add a new action instead of making mirred too complex
- No need to specify UDP port in action - it is already in the tunnel device
	configuration
- Added a decap operation to drop tunnel metadata

Amir Vadai (3):
  net/ip_tunnels: Introduce tunnel_id_to_key32() and
    key32_to_tunnel_id()
  net/sched: cls_flower: Classify packet in ip tunnels
  net/sched: Introduce act_iptunnel

 drivers/net/vxlan.c                     |   4 +-
 include/net/ip_tunnels.h                |  19 +++
 include/net/tc_act/tc_iptunnel.h        |  24 +++
 include/net/vxlan.h                     |  18 --
 include/uapi/linux/pkt_cls.h            |  11 ++
 include/uapi/linux/tc_act/tc_iptunnel.h |  40 +++++
 net/ipv4/ip_gre.c                       |  23 +--
 net/sched/Kconfig                       |  11 ++
 net/sched/Makefile                      |   1 +
 net/sched/act_iptunnel.c                | 292 ++++++++++++++++++++++++++++++++
 net/sched/cls_flower.c                  |  59 ++++++-
 11 files changed, 459 insertions(+), 43 deletions(-)
 create mode 100644 include/net/tc_act/tc_iptunnel.h
 create mode 100644 include/uapi/linux/tc_act/tc_iptunnel.h
 create mode 100644 net/sched/act_iptunnel.c

-- 
2.9.0
