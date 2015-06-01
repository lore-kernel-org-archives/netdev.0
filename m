From: Thomas Graf <tgraf@suug.ch>
Subject: [net-next RFC 00/14] Convert OVS tunnel vports to use regular net_devices
Date: Mon,  1 Jun 2015 16:27:24 +0200
Message-ID: <cover.1433167295.git.tgraf@suug.ch>
Cc: pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, dev@openvswitch.org, tom@herbertland.com,
	edumazet@google.com, jiri@resnulli.us, hannes@stressinduktion.org,
	marcelo.leitner@gmail.com, stephen@networkplumber.org,
	jpettit@nicira.com, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50930 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbbFAO1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 10:27:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the first series in a greater effort to bring the scalability
and programmability advantages of OVS to the rest of the network
stack and to get rid of as much OVS specific code as possible.

This first series focuses on getting rid of OVS tunnel vports and use
regular tunnel net_devices instead. As part of this effort, the
routing subsystem is extended with support for flow based tunneling.
In this new tunneling mode, the route is able to match on tunnel
information as well as set tunnel encapsulation parameters per route.
This allows to perform L3 forwarding for a large number of tunnel
endpoints and virtual networks using a single tunnel net_device.

TODO:
 - Geneve support
 - IPv6 support
 - Benchmarks

Pravin Shelar (1):
  openvswitch: Use regular GRE net_device instead of vport

Thomas Graf (13):
  ip_tunnel: Make ovs_tunnel_info and ovs_key_ipv4_tunnel generic
  ip_tunnel: support per packet tunnel metadata
  vxlan: Flow based tunneling
  route: Extend flow representation with tunnel key
  route: Per route tunnel metadata with RTA_TUNNEL
  fib: Add fib rule match on tunnel id
  vxlan: Factor out device configuration
  openvswitch: Allocate & attach ip_tunnel_info for tunnel set action
  openvswitch: Move dev pointer into vport itself
  openvswitch: Abstract vport name through ovs_vport_name()
  openvswitch: Use regular VXLAN net_device device
  vxlan: remove indirect call to vxlan_rcv() and vni member
  arp: Associate ARP requests with tunnel info

 drivers/net/vxlan.c                  | 663 ++++++++++++++++++++---------------
 include/linux/skbuff.h               |   2 +
 include/net/fib_rules.h              |   1 +
 include/net/flow.h                   |   7 +
 include/net/ip_fib.h                 |   3 +
 include/net/ip_tunnels.h             | 127 ++++++-
 include/net/route.h                  |  18 +
 include/net/vxlan.h                  |  82 ++++-
 include/uapi/linux/fib_rules.h       |   2 +-
 include/uapi/linux/if_link.h         |   1 +
 include/uapi/linux/openvswitch.h     |   2 +-
 include/uapi/linux/rtnetlink.h       |  16 +
 net/core/dev.c                       |   5 +-
 net/core/fib_rules.c                 |  17 +-
 net/core/skbuff.c                    |   8 +
 net/ipv4/arp.c                       |   8 +
 net/ipv4/fib_frontend.c              |  57 +++
 net/ipv4/fib_semantics.c             |  45 +++
 net/ipv4/ip_gre.c                    | 161 ++++++++-
 net/ipv4/ip_tunnel_core.c            |  15 +
 net/ipv4/route.c                     |  32 +-
 net/openvswitch/Kconfig              |  12 -
 net/openvswitch/Makefile             |   2 -
 net/openvswitch/actions.c            |  10 +-
 net/openvswitch/datapath.c           |  19 +-
 net/openvswitch/datapath.h           |   5 +-
 net/openvswitch/dp_notify.c          |   5 +-
 net/openvswitch/flow.c               |   4 +-
 net/openvswitch/flow.h               |  77 +---
 net/openvswitch/flow_netlink.c       |  78 ++++-
 net/openvswitch/flow_netlink.h       |   3 +-
 net/openvswitch/vport-geneve.c       |  17 +-
 net/openvswitch/vport-gre.c          | 313 -----------------
 net/openvswitch/vport-internal_dev.c |  38 +-
 net/openvswitch/vport-netdev.c       | 271 +++++++++++---
 net/openvswitch/vport-netdev.h       |  13 -
 net/openvswitch/vport-vxlan.c        | 322 -----------------
 net/openvswitch/vport.c              |  34 +-
 net/openvswitch/vport.h              |  21 +-
 39 files changed, 1334 insertions(+), 1182 deletions(-)
 delete mode 100644 net/openvswitch/vport-gre.c
 delete mode 100644 net/openvswitch/vport-vxlan.c

-- 
2.3.5
