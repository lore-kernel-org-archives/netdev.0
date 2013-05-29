From: sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Subject: [PATCH v5 00/28] rdma/cm: Add support for native IB addressing
Date: Wed, 29 May 2013 10:09:06 -0700
Message-ID: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

This patch series adds support for native IB addressing to the
rdma cm.  The full patch series is available from:

        git://git.openfabrics.org/~shefty/rdma-dev.git for-next

The rdma cm is the only widely usable interface for establishing
communication over Infiniband.  Other interfaces are either privileged
(e.g. umad) or incomplete in that they do not contact the IB SA
for necessary data (e.g. ucm).  The rdma cm is the only interface
which provides support for path record queries and multicast joins.
However, users of the rdma cm interface are restricted to using IP
addresses, which must be translated into IB addresses.

Allowing the use of native IB addresses removes the requirement
for IPoIB, which in turn allows us to offload name and/or address
translation services to a user space daemon.  The primary motivation
is to support large scale fabrics, with address and name services
either cached or bypassed completely.  For example, IB GIDs are
known or the information is exchanged out of band by an MPI process
manager.  However, another use case involves load balancing software.
Currently the rdma cm cannot establish rdma connections through
a load balancer, since the IP -> GID mapping is not well defined.
An out of band mechanism could be used in such situations to
determine the correct mapping, with the rdma cm still managing
the connection.

The patch set introduces af_ib and sockaddr_ib.  The kernel
rdma_cm is updated accordingly, mainly to make its handling of
addresses more generic.  However, since sockaddr_ib is larger
than sockaddr_in6, the rdma_ucm requires changes to its user to
kernel interface.  To provide backwards compatibility, the userspace
ABI is extended to support the larger address size.

Note that this series only touches the main networking stack to
define AF_IB.

Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Changes from v4:
Updated to newer base kernel.
Removed unused SDP header definitions and related code.
Exposed private data to servers bound to AF_IB addresses.
Fixed issue on client side accessing NULL private data.

Sean Hefty (28):
  rdma/cm: define native IB address
  rdma/cm: Allow enabling reuseaddr in any state
  rdma/cm: Include AF_IB in loopback and any address checks
  ib/addr: Add AF_IB support to ip_addr_size
  rdma/cm: Update port reservation to support AF_IB
  rdma/cm: Allow user to specify AF_IB when binding
  rdma/cm: Do not modify sa_family when setting loopback address
  rdma/cm: Add helper functions to return id address information
  rdma/cm: Restrict AF_IB loopback to binding to IB devices only
  rdma/cm: Verify that source and dest sa_family are the same
  rdma/cm: Add support for AF_IB to rdma_resolve_addr
  rdma/cm: Add support for AF_IB to rdma_resolve_route
  rdma/cm: Add support for AF_IB to cma_get_service_id
  rdma/cm: Remove unused SDP related code
  rdma/cm: Merge cma_get/save_net_info
  rdma/cm: Expose private data when using AF_IB
  rdma/cm: Set qkey for AF_IB
  rdma/cm: Only listen on IB devices when using AF_IB
  rdma/ucm: Support querying for AF_IB addresses
  ib/sa: Export function to pack a path record into wire format
  rdma/ucm: Support querying when IB paths are not reversible
  rdma/cm: Export cma_get_service_id
  rdma/ucm: Add ability to query GID addresses
  rdma/ucm: Name changes to indicate only IP addresses supported
  rdma/ucm: Allow user space to bind to AF_IB
  rdma/ucm: Allow user space to pass AF_IB into resolve
  rdma/ucm: Allow user space to specify AF_IB when joining multicast
  rdma/cm: Export AF_IB statistics

 drivers/infiniband/core/addr.c     |   20 +-
 drivers/infiniband/core/cma.c      |  906 +++++++++++++++++++++---------------
 drivers/infiniband/core/sa_query.c |    6 +
 drivers/infiniband/core/ucma.c     |  321 +++++++++++--
 include/linux/socket.h             |    2 +
 include/rdma/ib.h                  |   89 ++++
 include/rdma/ib_addr.h             |    6 +-
 include/rdma/ib_sa.h               |    7 +
 include/rdma/rdma_cm.h             |   13 +
 include/uapi/rdma/rdma_user_cm.h   |   73 +++-
 10 files changed, 1001 insertions(+), 442 deletions(-)
 create mode 100644 include/rdma/ib.h

-- 
1.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
