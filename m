From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v1 00/12] Demux IB CM requests in the rdma_cm module
Date: Mon, 22 Jun 2015 15:42:29 +0300
Message-ID: <1434976961-27424-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thanks everyone for the review comments. I've updated the patch set
accordingly. The changes are listed below.

Changes from v0:
- Added a patch to prevent a race between ib_unregister_device() and
  ib_get_net_dev_by_params().
- Removed the patch that exported a UD GMP packet's GID from the GRH, and
  related code.
- Patch 3:
  * Add _rcu suffix to ipoib_is_dev_match_addr().
  * Add helper function to get the master netdev for bonding support.
  * Scan for matching net devices in two phases: first without looking at
  * the IP address, and then looking at the IP address only when the first
    phase did not find a unique net device.
- Patch 5:
  * Do not init listen_sharecount = 1 for non-listening ib_cm_ids.
  * Remove code that sets a CM ID's state to IB_CM_IDLE right before
    destruction.
  * Rename ib_cm_id_create_and_listen() to ib_cm_insert_listen().
  * Do not increase reference counts when failing to add a shared CM ID due
    to having a different handler callback.
- Patch 9: Clean IPv4 net_dev validation function.
- Added patch 10: new patch to use the found net_dev in IB/cma for
  eliminating unneeded calls to cma_translate_addr.
- Patch 12: Remove the lock argument to __ib_cm_listen().

The rdma_cm module relies today on the ib_cm module to demux incoming
requests based on their service ID and IP address. The ib_cm module is the
wrong place to perform this task, as it can also be used with services that
do not adhere to the RDMA IP CM service as defined in the IBA
specifications. It is forced to use an opaque private data struct and mask
to compare incoming requests against.

This series moves that demux task responsibility to the rdma_cm module. The
rdma_cm module can look into the private data attached to a CM request,
containing the IP addresses related to the request. It uses the details of
the request to find the net device associated with the request, and use
that net device to find the correct listening rdma_cm_id.

The series applies against Doug's for-v4.2 tree with the patch adding a
rwsem to IB core [2] applied.

The series is structured as follows:
Patch 1 prevents a possible race between ib_client.remove() callbacks from
ib_unregister_device(), and ib_client callbacks that rely on the
lists_rwsem locked for read, such as ib_get_net_dev_by_params(). Both
callbacks may call ib_get_client_data(), and the patch makes sure that the
remove callback doesn't free the client data while it is being used by the
other callback.

Patches 2-3 add the ability to lookup a network device according to the IB
device, port, P_Key, GID and IP address. They find the matching IPoIB
interfaces, and return a matching net_device if one exists.

Patches 4-5 make necessary changes in ib_cm to allow RDMA CM get the
information it needs out of CM and SIDR requests, and share a single
ib_cm_id with multiple RDMA CM listeners.

Patches 6-7 do some preliminary refactoring to the rdma_cm module. They
allow extracting information out of incoming requests instead of retrieving
them from a listening CM ID, and add helper functions to access the port
space IDRs.

Finally, patches 8-11 change rdma_cm to demultiplex requests on its own, and
patch 12 cleans up the now unneeded code in ib_cm to compare against the
private data.

This series contains a subset of the RDMA CM namespaces patches [1]. The
changes from v4 of the relevant patches are:
- Patch 1
  * in addition to the IB device, port, P_Key and IP address, pass
    also the GID, to make future IPoIB devices with alias GIDs to unique.
  * return the matching net_device instead of a network namespace.
- Patch 2: use IS_ENABLED(CONFIG_IPV6) without ifdefs.
- Patch 5:
  * rename sharecount -> listen_sharecount.
  * use a regular int instead of atomic for the share count, protected by
    the cm.lock spinlock.
  * change id destruction and shared listener creation to prevent the case
    where an id is found but it is under destruction.

[1] [PATCH v4 for-next 00/12] Add network namespace support in the RDMA-CM
    http://www.spinics.net/lists/linux-rdma/msg25244.html
[2] [PATCH for-next V5 02/12] IB/core: Add rwsem to allow reading device list or client list
    http://www.spinics.net/lists/linux-rdma/msg25931.html

Guy Shapiro (1):
  IB/ipoib: Return IPoIB devices matching connection parameters

Haggai Eran (10):
  IB/core: pass client data to remove() callbacks
  IB/cm: Expose service ID in request events
  IB/cm: Share listening CM IDs
  IB/cma: Refactor RDMA IP CM private-data parsing code
  IB/cma: Helper functions to access port space IDRs
  IB/cma: Add net_dev and private data checks to RDMA CM
  IB/cma: validate routing of incoming requests
  IB/cma: use found net_dev for passive connections
  IB/cma: Share ib_cm_ids between rdma_cm_ids
  IB/cm: Remove compare_data checks

Yotam Kenneth (1):
  IB/core: Find the network device matching connection parameters

 drivers/infiniband/core/cache.c           |   2 +-
 drivers/infiniband/core/cm.c              | 199 ++++++----
 drivers/infiniband/core/cma.c             | 603 ++++++++++++++++++++++--------
 drivers/infiniband/core/device.c          |  56 ++-
 drivers/infiniband/core/mad.c             |   2 +-
 drivers/infiniband/core/multicast.c       |   7 +-
 drivers/infiniband/core/sa_query.c        |   6 +-
 drivers/infiniband/core/ucm.c             |   9 +-
 drivers/infiniband/core/user_mad.c        |   6 +-
 drivers/infiniband/core/uverbs_main.c     |   6 +-
 drivers/infiniband/ulp/ipoib/ipoib_cm.c   |   2 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c | 234 +++++++++++-
 drivers/infiniband/ulp/srp/ib_srp.c       |   6 +-
 drivers/infiniband/ulp/srpt/ib_srpt.c     |   7 +-
 include/rdma/ib_cm.h                      |  19 +-
 include/rdma/ib_verbs.h                   |  43 ++-
 net/rds/ib.c                              |   8 +-
 net/rds/ib_send.c                         |   3 -
 net/rds/iw.c                              |  11 +-
 net/rds/iw_cm.c                           |  18 +-
 net/rds/iw_send.c                         |   4 +
 21 files changed, 934 insertions(+), 317 deletions(-)

-- 
1.7.11.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
