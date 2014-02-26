From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH RFC 0/7] Non-promisc bidge ports support
Date: Wed, 26 Feb 2014 10:18:18 -0500
Message-ID: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, shemminger@vyatta.com,
	mst@redhat.com, jhs@mojatatu.com, john.r.fastabend@intel.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63159 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813AbaBZPSo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Feb 2014 10:18:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is a complete re-design and re-implementation of
prior attempts to support non-promiscuous bridge ports.

The basic design is as follows.  The bridge keeps track of
all the ports that flood packets to unknown destinations.  If
the flooding is disabled on the port, to get traffic to flow
through, user/management would need to add an fdb describing
such traffic.  When such fdb is added, we save the address
to bridge private hardware address list. 
Since we now have static configuration for all non-flooding
ports and only 1 flooding port, we can make this single port
non-promiscuous and program the receive filter with our list
of addresses.  On HW that doesn't support unicast filtering or
if the list too bit, the device will be placed in promiscuous mode
by the application of the filter.

There are multiple reasons I chose to do private hw address
list in the bridge in patch 3:
  1)  I tried using the fdb table itself as main repository, but
      this caused difficulties in synchronizing this table with
      the interface filters later on.
  2)  I tried using the bridge device 'uc' list to store these
      addresses, but that caused issues with devices on top of
      a bridge (vlans, bonds) that changed their mac addresses
      and propagated this down to bridge.   I recently figured
      out a way that might allow us to do this which involves
      learning to be added br_dev_xmi().  We can discuss this,
      if there serious objections to current proposal.

There are some other cases when promiscuous mode has to be turned
back on.  One is when the bridge itself if placed in promiscuous
mode (use sets promisc flag).  The other is when vlans devices are
configured on top of the bridge and vlan filtering is disabled (default).
This allows the bridge to receive all tagged frames and doesn't create
a dependency between this code and vlan filtering.

The last patch in the series is a special case where all ports
are non-flooding.  This could be useful in a routed configurations.
In this case, since all ports will be configured manually, we can
sync the our address list across all port of the bridge and make all
ports non-promiscuous.

Thanks
-vlad

Vlad Yasevich (7):
  bridge: Turn flag change macro into a function.
  bridge: Keep track of ports capable of flooding.
  bridge: Add addresses from static fdbs to bridge address list
  bridge: Automatically manage port promiscuous mode.
  bridge: Correctly manage promiscuity when user requested it.
  bridge: Manage promisc mode when vlans are configured on top of a
    bridge
  bridge: Support promisc management when all ports are non-flooding

 include/linux/netdevice.h |   9 +++
 net/bridge/br_device.c    |  23 +++++++
 net/bridge/br_fdb.c       | 122 +++++++++++++++++++++++++++++++++--
 net/bridge/br_if.c        | 159 ++++++++++++++++++++++++++++++++++++++++++++--
 net/bridge/br_netlink.c   |   3 +
 net/bridge/br_private.h   |  18 ++++++
 net/bridge/br_sysfs_if.c  |  33 +++++++---
 net/bridge/br_vlan.c      |   1 +
 net/core/dev.c            |   1 +
 net/core/dev_addr_lists.c |  21 +++---
 10 files changed, 361 insertions(+), 29 deletions(-)

-- 
1.8.5.3
