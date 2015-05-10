From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v3 for-next 00/13] Add network namespace support in the RDMA-CM
Date: Sun, 10 May 2015 13:26:31 +0300
Message-ID: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thanks everyone for the review comments. I've updated the patch set
accordingly. The new patch set doesn't look inside a CM request's private
data in the CM module, and instead use a single CM ID with several RDMA CM
IDs from different namespaces. Also, we noticed we had a deadlock in the
code similar to the one Matan has tried to prevent with the patch adding
krefs to ib_devices [1]. Following the mailing list discussion [2] we
wrote a patch that hopefully solves both deadlocks and added it as patch 1
in this series.

Let me know if I missed anything, or if there are other issues with the
series.

Regards,
Haggai

Changes from v2:
- Add patch 1 to change device_mutex to an RCU.
- Remove patch that fixed IPv4 connections to an IPv4/IPv6 listener.
- Limit namespace related changes to RDMA CM and InfiniBand only.
- Rebase on dledford/for-v4.2, with David Ahern's unaligned access patch [3].
  * Use Michael Wang's capability functions where needed.
- Move the struct net argument to be the first in all functions, to match the
  networking core scheme.
- Patch 2:
  * Remove unwanted braces.
- Patch 4: check the return value of ib_find_cached_pkey.
- Patch 8: verify the address family before calling cm_save_ib_info.
- Patch 10: use generic_net instead of a custom radix tree for having per
  network namespace data.
- Minor changes.

Changes from v1:
- Include patch 1 in this series.
- Rebase for v4.1.

Changes from v0:
- Fix code review comments by Yann
- Rebase on top of linux-3.19

RDMA-CM uses IP based addressing and routing to setup RDMA connections between
hosts. Currently, all of the IP interfaces and addresses used by the RDMA-CM
must reside in the init_net namespace. This restricts the usage of containers
with RDMA to only work with host network namespace (aka the kernel init_net NS
instance).

This patchset allows using network namespaces with the RDMA-CM.

Each RDMA-CM id keeps a reference to a network namespace.

This reference is based on the process network namespace at the time of the
creation of the object or inherited from the listener.

This network namespace is used to perform all IP and network related
operations. Specifically, the local device lookup, as well as the remote GID
address resolution are done in the context of the RDMA-CM object's namespace.
This allows outgoing connections to reach the right target, even if the same
IP address exists in multiple network namespaces. This can happen if each
network namespace resides on a different P_Key.

Additionally, the network namespace is used to split the listener service ID
table. From the user point of view, each network namespace has a unique,
completely independent table of service IDs. This allows running multiple
instances of a single service on the same machine, using containers. To
implement this, multiple RDMA CM IDs, belonging to different namespaces may
now share their CM ID. When a request on such a CM ID arrives, the RDMA CM
module finds out the correct namespaces and looks for the RDMA CM ID
matching the request's parameters.

The functionality introduced by this series would come into play when the
transport is InfiniBand and IPoIB interfaces are assigned to each namespace.
Multiple IPoIB interfaces can be created and assigned to different RDMA-CM
capable containers, for example using pipework [4].

Full support for RoCE will be introduced in a later stage.

The patches apply against Doug's tree for v4.2, with David Ahern's
patch for unaligned access [3] in the CM module also applied.

The patchset is structured as follows:

Patch 1 adds an SRCU in addition to the device mutex in ib_core to allow
traversing the client list without a deadlock in Patch 3.

Patch 2 is a relatively trivial API extension, requiring the callers
of certain ib_addr functions to provide a network namespace, as needed.

Patches 3 and 4 adds the ability to lookup a network namespace according to
the IP address, device and P_Key. It finds the matching IPoIB interfaces, and
safely takes a reference on the network namespace before returning to the
caller.

Patches 5-7 make necessary changes to the CM layer, to allow sharing of a
single CM ID between multiple RDMA CM IDs. This includes adding a reference
count to ib_cm_id structs, add an API to either create a new CM ID or use
an existing one, and expose the service ID to ib_cm clients.

Patches 8-9 do some preliminary refactoring to the rdma_cm module. Patch 7
refactors the logic that extracts the IP address from a connect request to
allow reuse by the namespace lookup code further on.  Patch 8 changes the
way RDMA CM module creates CM IDs, to avoid relying on the compare_data
feature of ib_cm. This feature associate a single compare_data struct per
ib_cm_id, so it cannot be used when sharing CM IDs.

Patches 10-13 add proper namespace support to the RDMA-CM module. This
includes adding multiple port space tables, sharing ib_cm_ids between
rdma_cm_ids, adding a network namespace parameter, and finally retrieving
the namespace from the creating process.

[1] [PATCH v3 for-next 02/33] IB/core: Add kref to IB devices
    http://www.spinics.net/lists/linux-rdma/msg23537.html
[2] http://www.spinics.net/lists/linux-rdma/msg24733.html
[3] 0d0f738f6a11 ("IB/core: Fix unaligned accesses")
    http://permalink.gmane.org/gmane.linux.drivers.rdma/25112
[4] https://github.com/jpetazzo/pipework/pull/108

Guy Shapiro (4):
  IB/addr: Pass network namespace as a parameter
  IB/ipoib: Return IPoIB devices matching connection parameters
  IB/cma: Add support for network namespaces
  IB/ucma: Take the network namespace from the process

Haggai Eran (8):
  IB/core: Use SRCU when reading client_list or device_list
  IB/cm: Reference count ib_cm_ids
  IB/cm: API to retrieve existing listening CM IDs
  IB/cm: Expose service ID in request events
  IB/cma: Refactor RDMA IP CM private-data parsing code
  IB/cma: Add compare_data checks to the RDMA CM module
  IB/cma: Separate port allocation to network namespaces
  IB/cma: Share CM IDs between namespaces

Yotam Kenneth (1):
  IB/core: Find the network namespace matching connection parameters

 drivers/infiniband/core/addr.c                     |  18 +-
 drivers/infiniband/core/cm.c                       | 153 ++++++-
 drivers/infiniband/core/cma.c                      | 467 +++++++++++++++------
 drivers/infiniband/core/device.c                   | 128 +++++-
 drivers/infiniband/core/ucma.c                     |   4 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c          | 139 +++++-
 drivers/infiniband/ulp/iser/iser_verbs.c           |   2 +-
 drivers/infiniband/ulp/isert/ib_isert.c            |   2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   4 +-
 include/rdma/ib_addr.h                             |  16 +-
 include/rdma/ib_cm.h                               |  18 +-
 include/rdma/ib_verbs.h                            |  33 ++
 include/rdma/rdma_cm.h                             |   6 +-
 net/9p/trans_rdma.c                                |   4 +-
 net/rds/ib.c                                       |   2 +-
 net/rds/ib_cm.c                                    |   2 +-
 net/rds/iw.c                                       |   2 +-
 net/rds/iw_cm.c                                    |   2 +-
 net/rds/rdma_transport.c                           |   4 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c           |   4 +-
 net/sunrpc/xprtrdma/verbs.c                        |   3 +-
 21 files changed, 835 insertions(+), 178 deletions(-)

-- 
1.7.11.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
