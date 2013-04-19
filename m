From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2 net-next 0/6] Allow bridge to function in non-promisc mode
Date: Fri, 19 Apr 2013 16:52:44 -0400
Message-ID: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, mst@redhat.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16260 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754567Ab3DSUwx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 16:52:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series is an almost complete rework of the prior attempt
to make the bridge function in non-promisc mode.  In this series
the "promiscuity" of an interface is dynamically determined and
the interface may transition from/to promiscuous mode based on
bridge configuration.

The series keeps an idea of an "uplink" port.  That is still user
designated.
The series also adds a concept of "dynamic" bridge port.  This is
the default state of the port and means that the user has not
specified any static FDBs for that port.
Once a user has added a static FDB entry to port and also specified
an "uplink" flag for that FDB, the mac address from that FDB is
added to the bridge hw address list and synched down to uplinks.
"Uplinks" are always considered dynamic ports even if a static entry
has been added for them.
Promiscuity is determined by the number of dynamic ports.  If there
are no dynamic ports (i.e all ports have static FDBs set), then we
know all the neighbors and can switch promisc off on all of the ports.
If we have only 1 dynamic port and its an uplink, we can synch all
static hw addresses to this port and mark it non-promisc.
If we have more then 1 dynamic port, then all ports have to be
promiscuouse.
This is the algorith that Michael Tsirkin proposed earlier.

Changes since v1:
 - Dynamic promisc mode selection.  Almost complete re-write.

Vlad Yasevich (6):
  bridge: Allow an ability to designate an uplink port
  bridge: make flags sysfs interface a little bit more extensible
  bridge: Implement IFF_UNICAST_FLT.
  bridge: Allow user to program hw addresses to uplink devices.
  bridge: Automatically set promisc on uplink ports.
  bridge: Store bridge mac to uplinks

 include/uapi/linux/if_link.h   |    1 +
 include/uapi/linux/neighbour.h |    6 +-
 net/bridge/br_device.c         |   69 ++++++++++++++++++++++++--
 net/bridge/br_fdb.c            |  108 +++++++++++++++++++++++++++++++---------
 net/bridge/br_if.c             |   50 +++++++++++++++---
 net/bridge/br_netlink.c        |    5 ++
 net/bridge/br_private.h        |   12 ++++-
 net/bridge/br_stp_if.c         |    2 +-
 net/bridge/br_sysfs_if.c       |   60 ++++++++++++++++++----
 net/core/dev.c                 |    1 +
 net/core/rtnetlink.c           |    4 +-
 11 files changed, 265 insertions(+), 53 deletions(-)

-- 
1.7.7.6
