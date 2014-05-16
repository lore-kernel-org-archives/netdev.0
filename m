From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v3 net-next 0/6] Non-promisc bidge ports support
Date: Fri, 16 May 2014 09:59:14 -0400
Message-ID: <1400248760-20672-1-git-send-email-vyasevic@redhat.com>
Cc: john.r.fastabend@intel.com, Vlad Yasevich <vyasevic@redhat.com>,
	shemminger@vyatta.com, bridge@lists.linux-foundation.org, mst@redhat.com
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

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

Changes since v2:
 - White space and spelling fixes from Michael Tsirkin
 - Squash patches 6, 7 and 8 to prevent bisect breakage.

Changes since v1:
 - Address issues rasied by Stephen Heminger
 - Address initializer comments raised by Sergey Shtylyov
 - Rebased recent net-next.

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

Vlad Yasevich (6):
  bridge: Turn flag change macro into a function.
  bridge: Keep track of ports capable of automatic discovery.
  bridge: Add functionality to sync static fdb entries to hw
  bridge: Introduce BR_PROMISC flag
  bridge: Add addresses from static fdbs to non-promisc ports
  bridge: Automatically manage port promiscuous mode.

 net/bridge/br_device.c   |   7 +++
 net/bridge/br_fdb.c      | 131 ++++++++++++++++++++++++++++++++++++++++++++---
 net/bridge/br_if.c       | 123 ++++++++++++++++++++++++++++++++++++++++++--
 net/bridge/br_netlink.c  |   3 ++
 net/bridge/br_private.h  |  19 +++++++
 net/bridge/br_sysfs_if.c |  30 +++++++----
 net/bridge/br_vlan.c     |   1 +
 7 files changed, 294 insertions(+), 20 deletions(-)

-- 
1.9.0
