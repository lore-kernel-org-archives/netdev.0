From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next 0/8] Non-promisc bidge ports support
Date: Wed, 14 May 2014 11:09:20 -0400
Message-ID: <1400080168-16625-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, shemminger@vyatta.com,
	mst@redhat.com, john.r.fastabend@intel.com, jhs@mojatatu.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45372 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752156AbaENPJi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 11:09:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds functionality to the bridge device to enable
operations without setting all ports to promiscuous mode.

The basic concept is this.  The bridge keeps track of the ports
that support learning and flooding packets to unknown destinations.
We call these ports auto-discovery ports since they automatically
discover who is behind them through learning and flooding.  

If flooding and learning are disabled via flags, then the port
requires static configuration to tell it which mac addresses
are behind it.  This is accomplished through adding of fdbs.
These fdbs should be static as dynamic fdbs can expire and systems
will become unreachable due to lack of flooding.

If the user marks all ports as needing static configuration then
we can safely make them non-promiscuous since we will know all the
information about them.

If the user leaves only 1 port as automatic, then we can mark
that port as not-promiscuous as well.  One could think of
this a edge relay similar to what's support by embedded switches
in SRIOV devices.  Since we have all the information about the
other ports, we can just program the mac addresses into the
single automatic port to receive all necessary traffic.
More information about this is patch 6.

In other cases, we keep all ports promiscuous as before.

There are some other cases when promiscuous mode has to be turned
back on.  One is when the bridge itself if placed in promiscuous
mode (user sets promisc flag).  The other is if vlan filtering is
turned off.  Since this is the default configuration, the default
bridge operation is not changed.

Changes since rfc v2:
 - Better description of in the commit logs
 - Leave port in promiscuous mode if IFF_UNICAST_FLT is disabled on the
   device.
 - Fix issue with flag masking
 - Rework patch ordering a bit.

Changes since rfc v1:
 - Removed private list.  We now traverse the fdb hashtable itself
   to write necessary addresses to the ports (Stephen's concern)
 - Add learning flag to the mask for flags that decides if the port
   is 'auto' or not (suggest by MST and Jamal).
 - Simplified tracking of such ports at the cost of a loop over all
   ports (suggested by MST)

I've played with quite a large number of ports and the current approach
seems to work fairly well.

Thanks
-vlad

Vlad Yasevich (8):
  bridge: Turn flag change macro into a function.
  bridge: Keep track of ports capable of automatic discovery.
  bridge: Add functionality to sync static fdb entries to hw
  bridge: Introduce BR_PROISC flag
  bridge: Add addresses from static fdbs to non-promisc ports
  bridge: Automatically manage port promiscuous mode.
  bridge: Correctly manage promiscuity when user requested it.
  bridge: Automatically manage promisc mode when vlan filtering is on.

 net/bridge/br_device.c   |   7 +++
 net/bridge/br_fdb.c      | 132 ++++++++++++++++++++++++++++++++++++++++++++---
 net/bridge/br_if.c       | 126 ++++++++++++++++++++++++++++++++++++++++++--
 net/bridge/br_netlink.c  |   3 ++
 net/bridge/br_private.h  |  20 +++++++
 net/bridge/br_sysfs_if.c |  31 +++++++----
 net/bridge/br_vlan.c     |   1 +
 7 files changed, 300 insertions(+), 20 deletions(-)

-- 
1.9.0
