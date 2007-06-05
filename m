From: Patrick McHardy <kaber@trash.net>
Subject: [RFC RTNETLINK 00/09]: Netlink link creation API
Date: Tue,  5 Jun 2007 16:12:51 +0200 (MEST)
Message-ID: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Cc: socketcan@hartkopp.net, hadi@cyberus.ca, xemul@sw.ru,
	Patrick McHardy <kaber@trash.net>, ebiederm@xmission.com,
	tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63886 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762971AbXFEOMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:12:54 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patches contain the rtnetlink link creation API I promised,
as well as two simple driver conversion to use the API as an example.
I've also converted VLAN as a more complex example, but these patches
need some more work and are most likely not interesting to all the CCed
parties, so I'm sending them seperately.

A few words about the API:

Drivers wishing to use the API register a struct rtnl_link_ops, which
contains a few function pointers for device setup, registation, changing
and deletion, as well as netlink attribute validation and device dumping.

All netlink communication happens within the AF_UNSPEC family. I
initially introduced new netlink families for this, but removed them
again since that would require adding new protocol families that serve
no further purpose for most drivers. Additionally we currently use
RTM.*LINK messages with ifi_family != AF_UNSPEC for information that
is related to the device, but doesn't come from the driver that created
the device itself, like bridge port state, IPv6 device configuration etc.

The device specific attributes are nested within a new attribute
IFLA_LINKINFO. I didn't use IFLA_PROTINFO since userspace can reasonably
expect to have IFLA_PROTINFO unset for AF_UNSPEC messages, and the
userspace STP daemon does that. Identification of the driver happens
by name, stored in the IFLA_INFO_NAME attribute. IFLA_INFO_DATA contains
driver specific attributes, IFLA_INFO_XSTATS driver specific statistics.

The API does *not* use the existing RTM_SETLINK message type, instead
it adds support for receiving RTM_NEWLINK within the kernel. I did this
because of three reasons: 

- RTM_SETLINK does not follow the usual rtnetlink conventions and ignores
  all netlink flags

- Other rtnetlink subsystems use the same message type for dumps and
  notifications from the kernel as for configuration from userspace,
  which usually allows to recreate an object by simply setting the
  NLM_F_REQUEST flag on message received from the kernel and sending
  it back.

- Easier for userspace to detect support for the new features

The RTM_NEWLINK message type is a superset of RTM_SETLINK, it allows
to change both driver specific and generic attributes of the device.
The set of generic device attributes that may be supplied during
device creation is limited to a few simple ones, it currently does
not support specifying link layer address/broadcast address as well
as device flags. The change operation can change all device attributes.

Not sure what else to say .. comments welcome.


 drivers/net/dummy.c               |  144 +++++++-----
 drivers/net/ifb.c                 |  115 ++++++---
 include/linux/if_link.h           |   13 +
 include/linux/netdevice.h         |    3 
 include/net/fib_rules.h           |    2 
 include/net/genetlink.h           |    2 
 include/net/ip_fib.h              |    2 
 include/net/netlink.h             |   12 -
 include/net/rtnetlink.h           |   57 ++++
 net/core/neighbour.c              |    4 
 net/core/rtnetlink.c              |  451 +++++++++++++++++++++++++++++++++-----
 net/decnet/dn_dev.c               |    2 
 net/decnet/dn_rules.c             |    2 
 net/ipv4/devinet.c                |    2 
 net/ipv4/fib_frontend.c           |    2 
 net/ipv4/fib_rules.c              |    2 
 net/ipv6/addrconf.c               |    2 
 net/ipv6/fib6_rules.c             |    2 
 net/ipv6/route.c                  |    2 
 net/netlabel/netlabel_cipso_v4.c  |    2 
 net/netlabel/netlabel_mgmt.c      |    2 
 net/netlabel/netlabel_unlabeled.c |    2 
 net/netlink/attr.c                |    8 
 net/netlink/genetlink.c           |    2 
 24 files changed, 665 insertions(+), 172 deletions(-)

Patrick McHardy (9):
      [NETLINK]: Mark netlink policies const
      [RTNETLINK]: ifindex 0 does not exist
      [RTNETLINK]: Split up rtnl_setlink
      [RTNETLINK]: Link creation API
      [DUMMY]: Use dev->stats
      [DUMMY]: Keep dummy devices on list
      [DUMMY]: Use rtnl_link API
      [IFB]: Keep ifb devices on list
      [IFB]: Use rtnl_link API
