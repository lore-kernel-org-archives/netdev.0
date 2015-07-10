From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC net-next 00/22] Lightweight & flow based tunneling
Date: Fri, 10 Jul 2015 16:19:02 +0200
Message-ID: <cover.1436537414.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40437 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932653AbbGJOTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 10:19:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series combines the work previously posted by Roopa, Robert and
myself. It's according to what we discussed at NFWS. The series
accomplishes:

 * Lightweight tunnel infrastructure to attach encapsulation
   instructions to routes.
 * Metadata dst to carry metadata between forwarding elements.
 * Use of this new infrastructure in VXLAN and GRE to enable
   flow based RX/TX tunnels using iproute2 and to get rid of
   OVS specific vports.

iproute examples:

  VXLAN:
  ip route add 40.1.1.1/32 encap vxlan id 10 dst 50.1.1.2 dev vxlan0

  MPLS:
  ip route add 10.1.1.0/30 encap mpls 200 via inet 10.1.1.1 dev swp1

The series is functional for both iproute2 and OVS and demonstrates
how a unified and combined code path can look like.

Comments?

Pravin Shelar (1):
  openvswitch: Use regular GRE net_device instead of vport

Roopa Prabhu (9):
  rtnetlink: introduce new RTA_ENCAP_TYPE and RTA_ENCAP attributes
  lwtunnel: infrastructure for handling light weight tunnels like mpls
  ipv4: support for fib route lwtunnel encap attributes
  ipv6: support for fib route lwtunnel encap attributes
  lwtunnel: support dst output redirect function
  ipv4: redirect dst output to lwtunnel output
  ipv6: rt6_info output redirect to tunnel output
  mpls: export mpls functions for use by mpls iptunnels
  mpls: ip tunnel support

Thomas Graf (12):
  ip_tunnel: Make ovs_tunnel_info and ovs_key_ipv4_tunnel generic
  dst: Metadata destinations
  arp: Inherit metadata dst when creating ARP requests
  vxlan: Flow based tunneling
  route: Extend flow representation with tunnel key
  route: Per route IP tunnel metadata via lightweight tunnel
  fib: Add fib rule match on tunnel id
  vxlan: Factor out device configuration
  openvswitch: Make tunnel set action attach a metadata dst
  openvswitch: Move dev pointer into vport itself
  openvswitch: Abstract vport name through ovs_vport_name()
  openvswitch: Use regular VXLAN net_device device

 drivers/net/vxlan.c                  | 671 +++++++++++++++++++++--------------
 include/linux/lwtunnel.h             |   6 +
 include/linux/mpls_iptunnel.h        |   6 +
 include/linux/skbuff.h               |   1 +
 include/net/dst.h                    |   5 +-
 include/net/dst_metadata.h           |  55 +++
 include/net/fib_rules.h              |   1 +
 include/net/flow.h                   |   7 +
 include/net/ip6_fib.h                |   3 +
 include/net/ip_fib.h                 |   5 +-
 include/net/ip_tunnels.h             |  84 ++++-
 include/net/lwtunnel.h               | 144 ++++++++
 include/net/mpls_iptunnel.h          |  29 ++
 include/net/route.h                  |   1 +
 include/net/vxlan.h                  |  83 ++++-
 include/uapi/linux/fib_rules.h       |   2 +-
 include/uapi/linux/if_link.h         |   1 +
 include/uapi/linux/lwtunnel.h        |  16 +
 include/uapi/linux/mpls_iptunnel.h   |  28 ++
 include/uapi/linux/openvswitch.h     |   2 +-
 include/uapi/linux/rtnetlink.h       |  17 +
 net/Kconfig                          |   7 +
 net/core/Makefile                    |   1 +
 net/core/dev.c                       |   7 +-
 net/core/dst.c                       |  76 +++-
 net/core/fib_rules.c                 |  17 +-
 net/core/lwtunnel.c                  | 228 ++++++++++++
 net/ipv4/arp.c                       |  71 ++--
 net/ipv4/fib_frontend.c              |   8 +
 net/ipv4/fib_semantics.c             | 101 +++++-
 net/ipv4/ip_gre.c                    | 165 ++++++++-
 net/ipv4/ip_input.c                  |   3 +-
 net/ipv4/ip_tunnel_core.c            | 114 ++++++
 net/ipv4/route.c                     |  26 +-
 net/ipv6/ip6_fib.c                   |   2 +
 net/ipv6/route.c                     |  34 +-
 net/mpls/Kconfig                     |   8 +-
 net/mpls/Makefile                    |   1 +
 net/mpls/af_mpls.c                   |  11 +-
 net/mpls/internal.h                  |   3 +
 net/mpls/mpls_iptunnel.c             | 229 ++++++++++++
 net/openvswitch/Kconfig              |  12 -
 net/openvswitch/Makefile             |   2 -
 net/openvswitch/actions.c            |  12 +-
 net/openvswitch/datapath.c           |  19 +-
 net/openvswitch/datapath.h           |   5 +-
 net/openvswitch/dp_notify.c          |   5 +-
 net/openvswitch/flow.c               |   4 +-
 net/openvswitch/flow.h               |  78 +---
 net/openvswitch/flow_netlink.c       |  81 ++++-
 net/openvswitch/flow_netlink.h       |   3 +-
 net/openvswitch/vport-geneve.c       |  17 +-
 net/openvswitch/vport-gre.c          | 313 ----------------
 net/openvswitch/vport-internal_dev.c |  38 +-
 net/openvswitch/vport-netdev.c       | 272 +++++++++++---
 net/openvswitch/vport-netdev.h       |  13 -
 net/openvswitch/vport-vxlan.c        | 322 -----------------
 net/openvswitch/vport-vxlan.h        |  11 -
 net/openvswitch/vport.c              |  34 +-
 net/openvswitch/vport.h              |  21 +-
 60 files changed, 2292 insertions(+), 1249 deletions(-)
 create mode 100644 include/linux/lwtunnel.h
 create mode 100644 include/linux/mpls_iptunnel.h
 create mode 100644 include/net/dst_metadata.h
 create mode 100644 include/net/lwtunnel.h
 create mode 100644 include/net/mpls_iptunnel.h
 create mode 100644 include/uapi/linux/lwtunnel.h
 create mode 100644 include/uapi/linux/mpls_iptunnel.h
 create mode 100644 net/core/lwtunnel.c
 create mode 100644 net/mpls/mpls_iptunnel.c
 delete mode 100644 net/openvswitch/vport-gre.c
 delete mode 100644 net/openvswitch/vport-vxlan.c
 delete mode 100644 net/openvswitch/vport-vxlan.h

-- 
2.4.3
