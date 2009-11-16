From: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: [PATCHv6 0/10] RDMAoE support
Date: Mon, 16 Nov 2009 17:53:02 +0200
Message-ID: <20091116155302.GA2463@mtls03>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux RDMA list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ewg <ewg-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>
To: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <ewg-bounces-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/ewg>,
	<mailto:ewg-request-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/ewg>
List-Post: <mailto:ewg-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>
List-Help: <mailto:ewg-request-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/ewg>,
	<mailto:ewg-request-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org?subject=subscribe>
Sender: ewg-bounces-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org
Errors-To: ewg-bounces-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org
List-Id: netdev.vger.kernel.org

RDMA over Ethernet (RDMAoE) allows running the IB transport protocol using
Ethernet frames, enabling the deployment of IB semantics on lossless Ethernet
fabrics. RDMAoE packets are standard Ethernet frames with an IEEE assigned
Ethertype, a GRH, unmodified IB transport headers and payload.  IB subnet
management and SA services are not required for RDMAoE operation; Ethernet
management practices are used instead. RDMAoE encodes IP addresses into its
GIDs and resolves MAC addresses using the host IP stack. For multicast GIDs,
standard IP to MAC mappings apply.

To support RDMAoE, a new transport protocol was added to the IB core. An RDMA
device can have ports with different transports, which are identified by a port
transport attribute.  The RDMA Verbs API is syntactically unmodified. When
referring to RDMAoE ports, Address handles are required to contain GIDs while
LID fields are ignored. The Ethernet L2 information is subsequently obtained by
the vendor-specific driver (in both kernel and user-space) while modifying QPs
to RTR and creating address handles.  As there is no SA in RDMAoE, the CMA code
is modified to fill the necessary path record attributes locally before sending
CM packets. Similarly, the CMA provides to the user the required address handle
attributes when processing SIDR requests and joining multicast groups.

In this patch set, an RDMAoE port is currently assigned a single GID, encoding
the IPv6 link-local address of the corresponding netdev; the CMA RDMAoE code
temporarily uses IPv6 link-local addresses as GIDs instead of the IP address
provided by the user, thereby supporting any IP address.

To enable RDMAoE with the mlx4 driver stack, both the mlx4_en and mlx4_ib
drivers must be loaded, and the netdevice for the corresponding RDMAoE port
must be running. Individual ports of a multi port HCA can be independently
configured as Ethernet (with support for RDMAoE) or IB, as is already the case.
We have successfully tested MPI, SDP, RDS, and native Verbs applications over
RDMAoE.

Following is a series of 10 patches based on Roland's for-next branch. This new
series reflects changes based on feedback from the community on the previous
set of patches, and is tagged v6. Previous series were posted to the
openfabrics general list only.

Changes from v5:
1. Bug fixes.
2. NIC programming through dev_mc_add/delete were moved from CMA to the hw
specific driver. This allows native verbs applications to receive multicast
traffic too.

Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---


 drivers/infiniband/core/agent.c           |   39 +-
 drivers/infiniband/core/cm.c              |   26 +
 drivers/infiniband/core/cma.c             |  272 ++++++++++++++++--
 drivers/infiniband/core/mad.c             |   78 +++--
 drivers/infiniband/core/multicast.c       |    4 
 drivers/infiniband/core/sa_query.c        |   39 +-
 drivers/infiniband/core/ucm.c             |   14 
 drivers/infiniband/core/ucma.c            |   33 ++
 drivers/infiniband/core/ud_header.c       |  111 +++++++
 drivers/infiniband/core/user_mad.c        |   13 
 drivers/infiniband/core/uverbs.h          |    1 
 drivers/infiniband/core/uverbs_cmd.c      |   32 ++
 drivers/infiniband/core/uverbs_main.c     |    1 
 drivers/infiniband/core/verbs.c           |   35 ++
 drivers/infiniband/hw/mlx4/ah.c           |  181 ++++++++++--
 drivers/infiniband/hw/mlx4/mad.c          |   32 +-
 drivers/infiniband/hw/mlx4/main.c         |  436 +++++++++++++++++++++++++++---
 drivers/infiniband/hw/mlx4/mlx4_ib.h      |   29 +
 drivers/infiniband/hw/mlx4/qp.c           |  199 +++++++++----
 drivers/infiniband/ulp/ipoib/ipoib_main.c |   12 
 drivers/net/mlx4/en_main.c                |   15 -
 drivers/net/mlx4/en_port.c                |    4 
 drivers/net/mlx4/en_port.h                |    3 
 drivers/net/mlx4/fw.c                     |    3 
 drivers/net/mlx4/intf.c                   |   20 +
 drivers/net/mlx4/main.c                   |    6 
 drivers/net/mlx4/mlx4.h                   |    1 
 include/linux/mlx4/cmd.h                  |    1 
 include/linux/mlx4/device.h               |   31 ++
 include/linux/mlx4/driver.h               |   16 -
 include/linux/mlx4/qp.h                   |    8 
 include/rdma/ib_addr.h                    |   92 ++++++
 include/rdma/ib_pack.h                    |   26 +
 include/rdma/ib_user_verbs.h              |   21 +
 include/rdma/ib_verbs.h                   |   26 +
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c   |    3 
 net/sunrpc/xprtrdma/svc_rdma_transport.c  |    2 
 37 files changed, 1594 insertions(+), 271 deletions(-)
