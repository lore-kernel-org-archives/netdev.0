From: Patrick McHardy <kaber@trash.net>
Subject: net 00/06: add GARP/GVRP support
Date: Thu,  3 Jul 2008 19:04:41 +0200 (MEST)
Message-ID: <20080703170441.6650.64717.sendpatchset@localhost.localdomain>
Cc: shemminger@vyatta.com, Patrick McHardy <kaber@trash.net>,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42842 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752194AbYGCREm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 13:04:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches add an implementation of the GARP (Generic Attribute
Registration Protocol) applicant-only participant, which can be used
to dynamically register VLANs and multicast addresses with switches.
Applicant-only means it can only be used as a client, not on a bridge.
Also included is a GVRP (GARP VLAN Registration Protocol) application
on top.

I asked on opinions whether this should be merged a couple of weeks
ago, and Pekka Savola informed me that GARP was considered obsolete
by the IEEE. However, especially GVRP is supported by a huge number
of switches, even very cheap ones, so I think this is still useful
to support.

GARP uses the LLC_SAP_BSPAN LLC, which is also used by STP. Different
multicast addresses are used to distinguish the protocols. Since the
LLC code doesn't allow multiple registrations for the same SAP, a
small mac based demux layer is added that is used by both bridging
and GARP.

GVRP is not enabled by default yet. Since the applicant-only participant
should not be used on a bridge, we first need a reliable way to get
notified when a VLAN device becomes a bridge member. So currently,
the user needs to manually enable it using iproute. I plan to change
this soon.


 include/linux/if_vlan.h   |    1 +
 include/linux/netdevice.h |    2 +
 include/net/garp.h        |  128 +++++++++
 include/net/stp.h         |   14 +
 net/802/Kconfig           |    7 +
 net/802/Makefile          |    2 +
 net/802/garp.c            |  633 +++++++++++++++++++++++++++++++++++++++++++++
 net/802/stp.c             |  102 ++++++++
 net/8021q/Kconfig         |   10 +
 net/8021q/Makefile        |    9 +-
 net/8021q/vlan.c          |   33 ++-
 net/8021q/vlan.h          |   19 ++-
 net/8021q/vlan_dev.c      |   32 ++-
 net/8021q/vlan_gvrp.c     |   66 +++++
 net/8021q/vlan_netlink.c  |    7 +-
 net/Kconfig               |    1 +
 net/bridge/Kconfig        |    1 +
 net/bridge/br.c           |   16 +-
 net/bridge/br_private.h   |    5 +-
 net/bridge/br_stp_bpdu.c  |   12 +-
 20 files changed, 1051 insertions(+), 49 deletions(-)
 create mode 100644 include/net/garp.h
 create mode 100644 include/net/stp.h
 create mode 100644 net/802/Kconfig
 create mode 100644 net/802/garp.c
 create mode 100644 net/802/stp.c
 create mode 100644 net/8021q/vlan_gvrp.c

Patrick McHardy (6):
      net: Add STP demux layer
      bridge: Use STP demux
      net: Add GARP applicant-only participant
      vlan: Change vlan_dev_set_vlan_flag() to handle multiple flags at once
      vlan: Move device unregistration before lower dev cleanup
      vlan: Add GVRP support
