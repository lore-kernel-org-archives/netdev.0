From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [RFC 0/2] xen-backend interfaces and IFF_MULTICAST
Date: Mon, 10 Feb 2014 14:29:49 -0800
Message-ID: <1392071391-13215-1-git-send-email-mcgrof@do-not-panic.com>
Cc: xen-devel@lists.xenproject.org,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:41645 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111AbaBJWaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 17:30:11 -0500
Received: by mail-pa0-f52.google.com with SMTP id bj1so6781983pad.25
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 14:30:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Virtualization hypervisors do not make use of backend Ethernet interfaces
like typical Ethernet interfaces. In my current testing at least xen-netback
requires at least a struct in_device with a proper MTU setting in order for
the front end interface to function properly. Under the current design this
will kick off ipv6 autoconfiguration and DAD on these interfaces. This does
not happen for xen's TAP interface when HVM is used. KVM only uses TAP
interfaces but their backend interfaces *do not* perform ipv6 autoconfiguration
and DAD even though its TAP interfaces do have multicast enabled.

In xen's case some xen users used to run into issues with the current
architecture when bundles of xen guests were on the same network and ipv6
autoconfiguration was performed. This happens because the MAC address is
static and while this can be corrected by randomizing it an ipv6 address
is simply not needed for them. There is currently no way to disable ipv6
interfaces on specific type of interfaces but this is just begging review
of the architecture on why an interface is even needed at all, how about
ipv4 addresses, why do we need inetdev_init() on these virtualized
interfaces?

Disabling multicast on an interface should disable ipv6 autoconfiguration
and DAD but the note on include/uapi/linux/if_link.h makes it clear that
IFF_MULTICAST should be considered carefully given that not-NBMA links are
known to support multicast, this includes all IFF_POINTOPOINT and IFF_BROADCAST
as well. If we are to follow the RFCs on ipv6 autoconfiguration and DAD
however its clear that muliticast is required -- but if we have no reliable
way of determining this capability we won't know when we could perform
autoconfiguration and DAD properly.

If the patch to require IFF_MULTICAST for autoconfiguration and DAD is
valid then xen-netback can simply clear the flag, clearing it is required
as ether_setup() is used during the net_device allocation. I'm currently
reviewing the need for any proper-mtu interface on xen-netback but in the
meantime I'd like some feedback on IFF_MULTICAST and the following
patches.

Luis R. Rodriguez (2):
  ipv6: disable autoconfiguration and DAD on non-multicast links
  xen-netback: disable multicast and use a random hw MAC address

 drivers/net/xen-netback/interface.c | 14 +++++---------
 net/ipv6/addrconf.c                 | 18 ++++++++++++------
 2 files changed, 17 insertions(+), 15 deletions(-)

-- 
1.8.5.3
