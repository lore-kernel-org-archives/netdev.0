From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH v2 00/11] Add network namespace support in the RDMA-CM
Date: Mon, 20 Apr 2015 12:03:31 +0300
Message-ID: <1429520622-10303-1-git-send-email-haggaie@mellanox.com>
Cc: Sean Hefty <sean.hefty@intel.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>
To: Doug Ledford <dledford@redhat.com>,
	Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:44640 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754102AbbDTJEm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2015 05:04:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/15/2015 3:39 PM, Doug Ledford wrote:
> For instance, the namespace patches aren't included, and that's at least partially because they didn't apply cleanly any more.

Here's an updated series on top of your tree. I've also included the fix for
IPv4 connections to IPv6 listeners.

Regards,
Haggai

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

Each RDMA-CM and CM id is keeping a reference to a network namespace.

This reference is based on the process network namespace at the time of the
creation of the object or inherited from the listener.

This network namespace is used to perform all IP and network related
operations. Specifically, the local device lookup, as well as the remote GID
address resolution are done in the context of the RDMA-CM object's namespace.
This allows outgoing connections to reach the right target, even if the same
IP address exists in multiple network namespaces. This can happen if each
network namespace resides on a different pkey.

Additionally, the network namespace is used to split the listener service ID
table. From the user point of view, each network namespace has a unique,
completely independent table of service IDs. This allows running multiple
instances of a single service on the same machine, using containers. To
implement this, the CM layer now parses the IP address from the CM connect
requests, and searches for the matching networking device. The namespace of
the device found is used when looking up the service ID in the listener table.

The functionnality introduced by this series would come into play when the
transport is InfiniBand and IPoIB interfaces are assigned to each namespace.
Multiple IPoIB interfaces can be created and assigned to different RDMA-CM
capable containers, for example using pipework [1].

Full support for RoCE will be introduced in a later stage.

The patches apply against Roland's/Doug's tree for v4.1.

The patchset is structured as follows:

Patch 1 is a resend of patch to fix IPv4 connections to an IPv4/IPv6 listener.

Patches 2 and 4 are relatively trivial API extensions, requiring the callers
of certain ib_addr and ib_core functions to provide a network namespace, as
needed.

Patches 4 and 5 adds the ability to lookup a network namespace according to
the IP address, device and pkey. It finds the matching IPoIB interfaces, and
safely takes a reference on the network namespace before returning to the
caller.

Patch 6 moves the logic that extracts the IP address from a connect request
into the CM layer. This is needed for the upcoming listener lookup by
namespace.

Patch 7 adds support for network namespaces in the CM layer. All callers are
still passing init_net as the namespace, to maintain backward compatibility.
For incoming requests, the namespace of the relevant IPoIB device is used.

Patches 8 and 9 add proper namespace support to the RDMA-CM module.

Patches 10 and 11 add namespace support to the relevant user facing modules in
the IB stack.

[1] https://github.com/jpetazzo/pipework/pull/108

Guy Shapiro (7):
  IB/addr: Pass network namespace as a parameter
  IB/core: Pass network namespace as a parameter to relevant functions
  IB/ipoib: Return IPoIB devices as possible matches to
    get_net_device_by_port_pkey_ip
  IB/cm, cma: Move RDMA IP CM private-data parsing code from ib_cma to
    ib_cm
  IB/cm: Add network namespace support
  IB/cma: Add support for network namespaces
  IB/ucma: Take the network namespace from the process

Shachar Raindel (1):
  IB/ucm: Add partial support for network namespaces

Yotam Kenneth (3):
  RDMA/CMA: Mark IPv4 addresses correctly when the listener is IPv6
  IB/core: Find the network namespace matching connection parameters
  IB/cma: Separate port allocation to network namespaces

 drivers/infiniband/core/addr.c                     |  31 +-
 drivers/infiniband/core/agent.c                    |   4 +-
 drivers/infiniband/core/cm.c                       | 287 ++++++++++++++++--
 drivers/infiniband/core/cma.c                      | 332 +++++++++------------
 drivers/infiniband/core/device.c                   |  57 ++++
 drivers/infiniband/core/mad_rmpp.c                 |  10 +-
 drivers/infiniband/core/ucm.c                      |   4 +-
 drivers/infiniband/core/ucma.c                     |   4 +-
 drivers/infiniband/core/user_mad.c                 |   4 +-
 drivers/infiniband/core/verbs.c                    |  22 +-
 drivers/infiniband/hw/ocrdma/ocrdma_ah.c           |   3 +-
 drivers/infiniband/ulp/ipoib/ipoib_cm.c            |  21 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c          | 122 +++++++-
 drivers/infiniband/ulp/iser/iser_verbs.c           |   2 +-
 drivers/infiniband/ulp/isert/ib_isert.c            |   2 +-
 drivers/infiniband/ulp/srp/ib_srp.c                |   2 +-
 drivers/infiniband/ulp/srpt/ib_srpt.c              |   5 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   4 +-
 include/rdma/ib_addr.h                             |  44 ++-
 include/rdma/ib_cm.h                               |  63 +++-
 include/rdma/ib_verbs.h                            |  44 ++-
 include/rdma/rdma_cm.h                             |   6 +-
 net/9p/trans_rdma.c                                |   2 +-
 net/rds/ib.c                                       |   2 +-
 net/rds/ib_cm.c                                    |   2 +-
 net/rds/iw.c                                       |   2 +-
 net/rds/iw_cm.c                                    |   2 +-
 net/rds/rdma_transport.c                           |   2 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c           |   2 +-
 net/sunrpc/xprtrdma/verbs.c                        |   3 +-
 30 files changed, 822 insertions(+), 268 deletions(-)

-- 
1.7.11.2
