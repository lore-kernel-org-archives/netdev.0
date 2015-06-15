From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 00/11] Demux IB CM requests in the rdma_cm module
Date: Mon, 15 Jun 2015 11:47:05 +0300
Message-ID: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
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
Patches 1-2 add the ability to lookup a network device according to the IB
device, port, P_Key, GID and IP address. They find the matching IPoIB
interfaces, and return a matching net_device if one exists.

Patches 3-5 make necessary changes in ib_cm to allow RDMA CM get the
information it needs out of CM and SIDR requests, and share a single
ib_cm_id with multiple RDMA CM listeners.

Patches 6-7 do some preliminary refactoring to the rdma_cm module. They
allow extracting information out of incoming requests instead of retrieving
them from a listening CM ID, and add helper functions to access the port
space IDRs.

Finally, patches 8-10 change rdma_cm to demultiplex requests on its own, and
patch 11 cleans up the now unneeded code in ib_cm to compare against the
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

Haggai Eran (9):
  IB/cm: Expose service ID in request events
  IB/cm: Expose DGID in SIDR request events
  IB/cm: Share listening CM IDs
  IB/cma: Refactor RDMA IP CM private-data parsing code
  IB/cma: Helper functions to access port space IDRs
  IB/cma: Add net_dev and private data checks to RDMA CM
  IB/cma: validate routing of incoming requests
  IB/cma: Share ib_cm_ids between rdma_cm_ids
  IB/cm: Remove compare_data checks

Yotam Kenneth (1):
  IB/core: Find the network device matching connection parameters

 drivers/infiniband/core/cm.c              | 204 +++++++----
 drivers/infiniband/core/cma.c             | 555 ++++++++++++++++++++++--------
 drivers/infiniband/core/device.c          |  29 ++
 drivers/infiniband/core/ucm.c             |   3 +-
 drivers/infiniband/ulp/ipoib/ipoib_cm.c   |   2 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c | 141 +++++++-
 drivers/infiniband/ulp/srpt/ib_srpt.c     |   2 +-
 include/rdma/ib_cm.h                      |  21 +-
 include/rdma/ib_verbs.h                   |  35 ++
 9 files changed, 765 insertions(+), 227 deletions(-)

-- 
1.7.11.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
