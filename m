From: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Subject: [PATCH v2 00/17] IB/Verbs: IB Management Helpers
Date: Tue, 07 Apr 2015 14:25:57 +0200
Message-ID: <5523CCD5.6030401@profitbricks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tom Tucker <tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Hoang-Nam Nguyen <hnguyen-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Christoph Raisch <raisch-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Mike Marciniszyn <infinipath-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Upinder Malhi <umalhi-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Ilya Nelkenbaum <ilyan-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Bart Van Assche <bvanassche@acm.o
To: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Since v1:
  * Apply suggestions from Doug, Ira, Jason, Tom, thanks for the comments :-)
    and please remind me if I missed anything :-P
  * Adopt new callback query_transport() to directly get the transport type
    of device
  * Reform a lot to adopt new management helpers, cleanup the old helpers

There are plenty of lengthy code to check the transport type of IB device,
or the link layer type of it's port, but actually we are just speculating
whether a particular management/feature is supported by the device/port.

Thus instead of inferring, we should have our own mechanism for IB management
capability/protocol/feature checking, several proposals below.

This patch set will reform the method of getting transport type, we will
now using query_transport() instead of inferring from transport and link
layer respectively, also we defined the new transport type to make the
concept more reasonable.

Mapping List:
		node-type	link-layer	old-transport	new-transport
nes		RNIC		ETH		IWARP		IWARP
amso1100	RNIC		ETH		IWARP		IWARP
cxgb3   	RNIC		ETH		IWARP		IWARP
cxgb4   	RNIC		ETH		IWARP		IWARP
usnic   	USNIC_UDP	ETH		USNIC_UDP	USNIC_UDP
ocrdma  	IB_CA		ETH		IB		IBOE
mlx4    	IB_CA		IB/ETH		IB		IB/IBOE
mlx5    	IB_CA		IB		IB		IB
ehca    	IB_CA		IB		IB		IB
ipath   	IB_CA		IB		IB		IB
mthca   	IB_CA		IB		IB		IB
qib     	IB_CA		IB		IB		IB

For example:
	if (transport == IB) && (link-layer == ETH)
will now become:
	if (query_transport() == IBOE)

Thus we will be able to get rid of the respective transport and link-layer
checking, and it will help us to add new protocol/Technology (like OPA) more
easier, also with the introduced management helpers, IB management logical
will be more clear and easier for extending.

TODO:
    The patch set covered a wide range of IB stuff, thus for those who are
    familiar with the particular part, your suggestion would be invaluable ;-)

    Patches haven't been tested yet, we appreciate if any one who have these
    HW willing to provide his Tested-by :-)

Proposals:
    Sean:
	https://www.mail-archive.com/linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg23339.html
    Doug:
	https://www.mail-archive.com/linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg23418.html
    Jason:
	https://www.mail-archive.com/linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg23425.html

Michael Wang (17):
    [PATCH v2 01/17] IB/Verbs: Implement new callback query_transport() for each HW
    [PATCH v2 02/17] IB/Verbs: Implement raw management helpers
    [PATCH v2 03/17] IB/Verbs: Use management helper cap_ib_mad() for mad-check
    [PATCH v2 04/17] IB/Verbs: Use management helper cap_ib_smi() for smi-check
    [PATCH v2 05/17] IB/Verbs: Use management helper cap_ib_cm() for cm-check
    [PATCH v2 06/17] IB/Verbs: Use management helper cap_ib_sa() for sa-check
    [PATCH v2 07/17] IB/Verbs: Use management helper cap_ib_mcast() for mcast-check
    [PATCH v2 08/17] IB/Verbs: Use management helper cap_ipoib() for ipoib-check
    [PATCH v2 09/17] IB/Verbs: Use helper cap_read_multi_sge() and reform svc_rdma_accept()
    [PATCH v2 10/17] IB/Verbs: Adopt management helpers for IB helpers
    [PATCH v2 11/17] IB/Verbs: Reform link_layer_show() and ib_uverbs_query_port()
    [PATCH v2 12/17] IB/Verbs: Use management helper cap_ib_cm_dev() for cm-device-check
    [PATCH v2 13/17] IB/Verbs: Reform cma/ucma with management helpers
    [PATCH v2 14/17] IB/Verbs: Reserve legacy transport type for 'struct rdma_dev_addr'
    [PATCH v2 15/17] IB/Verbs: Reform cma_acquire_dev() with management helpers
    [PATCH v2 16/17] IB/Verbs: Cleanup rdma_node_get_transport()
    [PATCH v2 17/17] IB/Verbs: Move rdma_port_get_link_layer() to mlx4 head file

---
 drivers/infiniband/core/agent.c              |    2 
 drivers/infiniband/core/cm.c                 |   22 +-
 drivers/infiniband/core/cma.c                |  281 ++++++++++++---------------
 drivers/infiniband/core/device.c             |    1 
 drivers/infiniband/core/mad.c                |   20 -
 drivers/infiniband/core/multicast.c          |   12 -
 drivers/infiniband/core/sa_query.c           |   29 +-
 drivers/infiniband/core/sysfs.c              |    8 
 drivers/infiniband/core/ucm.c                |    3 
 drivers/infiniband/core/ucma.c               |   25 --
 drivers/infiniband/core/user_mad.c           |   26 +-
 drivers/infiniband/core/uverbs_cmd.c         |    6 
 drivers/infiniband/core/verbs.c              |   51 ----
 drivers/infiniband/hw/amso1100/c2_provider.c |    7 
 drivers/infiniband/hw/cxgb3/iwch_provider.c  |    7 
 drivers/infiniband/hw/cxgb4/provider.c       |    7 
 drivers/infiniband/hw/ehca/ehca_hca.c        |    6 
 drivers/infiniband/hw/ehca/ehca_iverbs.h     |    3 
 drivers/infiniband/hw/ehca/ehca_main.c       |    1 
 drivers/infiniband/hw/ipath/ipath_verbs.c    |    7 
 drivers/infiniband/hw/mlx4/main.c            |   10 
 drivers/infiniband/hw/mlx4/mlx4_ib.h         |    8 
 drivers/infiniband/hw/mlx5/main.c            |    7 
 drivers/infiniband/hw/mthca/mthca_provider.c |    7 
 drivers/infiniband/hw/nes/nes_verbs.c        |    6 
 drivers/infiniband/hw/ocrdma/ocrdma_main.c   |    1 
 drivers/infiniband/hw/ocrdma/ocrdma_verbs.c  |    6 
 drivers/infiniband/hw/ocrdma/ocrdma_verbs.h  |    3 
 drivers/infiniband/hw/qib/qib_verbs.c        |    7 
 drivers/infiniband/hw/usnic/usnic_ib_main.c  |    1 
 drivers/infiniband/hw/usnic/usnic_ib_verbs.c |    6 
 drivers/infiniband/hw/usnic/usnic_ib_verbs.h |    2 
 drivers/infiniband/ulp/ipoib/ipoib_main.c    |   17 -
 include/rdma/ib_verbs.h                      |  163 ++++++++++++++-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c      |    4 
 net/sunrpc/xprtrdma/svc_rdma_transport.c     |   12 -
 36 files changed, 490 insertions(+), 294 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
