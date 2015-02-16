From: Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: RE: [PATCH v1 00/10] Add network namespace support in the RDMA-CM
Date: Mon, 16 Feb 2015 08:10:00 +0000
Message-ID: <AM3PR05MB0935A5EEE2D530CA002AAA34DC2E0@AM3PR05MB0935.eurprd05.prod.outlook.com>
References: <1423667204-8807-1-git-send-email-raindel@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1423667204-8807-1-git-send-email-raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sean,

Have you looked at this patch set?
Do you have any comments as for the changes done in the CM?

Thanks,
--Shachar

> -----Original Message-----
> From: Shachar Raindel [mailto:raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org]
> Sent: Wednesday, February 11, 2015 5:07 PM
> To: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org; sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
> Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Liran Liss; Guy
> Shapiro; Haggai Eran; Yotam Kenneth; Shachar Raindel
> Subject: [PATCH v1 00/10] Add network namespace support in the RDMA-CM
> 
> RDMA-CM uses IP based addressing and routing to setup RDMA connections
> between
> hosts. Currently, all of the IP interfaces and addresses used by the
> RDMA-CM
> must reside in the init_net namespace. This restricts the usage of
> containers
> with RDMA to only work with host network namespace (aka the kernel
> init_net NS
> instance).
> 
> This patchset allows using network namespaces with the RDMA-CM.
> 
> Each RDMA-CM and CM id is keeping a reference to a network namespace.
> 
> This reference is based on the process network namespace at the time of
> the
> creation of the object or inherited from the listener.
> 
> This network namespace is used to perform all IP and network related
> operations. Specifically, the local device lookup, as well as the remote
> GID
> address resolution are done in the context of the RDMA-CM object's
> namespace.
> This allows outgoing connections to reach the right target, even if the
> same
> IP address exists in multiple network namespaces. This can happen if
> each
> network namespace resides on a different pkey.
> 
> Additionally, the network namespace is used to split the listener
> service ID
> table. From the user point of view, each network namespace has a unique,
> completely independent table of service IDs. This allows running
> multiple
> instances of a single service on the same machine, using containers. To
> implement this, the CM layer now parses the IP address from the CM
> connect
> requests, and searches for the matching networking device. The namespace
> of
> the device found is used when looking up the service ID in the listener
> table.
> 
> The functionnality introduced by this series would come into play when
> the
> transport is InfiniBand and IPoIB interfaces are assigned to each
> namespace.
> Multiple IPoIB interfaces can be created and assigned to different RDMA-
> CM
> capable containers, for example using pipework [1].
> 
> Full support for RoCE will be introduced in a later stage.
> 
> The patches apply against kernel v3.19-rc5, with the patch "RDMA/CMA:
> Mark
> IPv4 addresses correctly when the listener is IPv6" [2] applied.
> 
> The patchset is structured as follows:
> 
> Patches 1 and 2 are relatively trivial API extensions, requiring the
> callers
> of certain ib_addr and ib_core functions to provide a network namespace,
> as
> needed.
> 
> Patches 3 and 4 adds the ability to lookup a network namespace according
> to
> the IP address, device and pkey. It finds the matching IPoIB interfaces,
> and
> safely takes a reference on the network namespace before returning to
> the
> caller.
> 
> Patch 5 moves the logic that extracts the IP address from a connect
> request
> into the CM layer. This is needed for the upcoming listener lookup by
> namespace.
> 
> Patch 6 adds support for network namespaces in the CM layer. All callers
> are
> still passing init_net as the namespace, to maintain backward
> compatibility.
> For incoming requests, the namespace of the relevant IPoIB device is
> used.
> 
> Patches 7 and 8 add proper namespace support to the RDMA-CM module.
> 
> Patches 9 and 10 add namespace support to the relevant user facing
> modules in
> the IB stack.
> 
> 
> [1] https://github.com/jpetazzo/pipework/pull/108
> [2] https://patchwork.kernel.org/patch/5298971/
> 
> Change-log:
> 
> V0 -> V1:
>  - Fix code review comments by Yann
>  - Rebase on top of linux-3.19
> 
> Guy Shapiro (7):
>   IB/addr: Pass network namespace as a parameter
>   IB/core: Pass network namespace as a parameter to relevant functions
>   IB/ipoib: Return IPoIB devices as possible matches to
>     get_net_device_by_port_pkey_ip
>   IB/cm,cma: Move RDMA IP CM private-data parsing code from ib_cma to
>     ib_cm
>   IB/cm: Add network namespace support
>   IB/cma: Add support for network namespaces
>   IB/ucma: Take the network namespace from the process
> 
> Shachar Raindel (1):
>   IB/ucm: Add partial support for network namespaces
> 
> Yotam Kenneth (2):
>   IB/core: Find the network namespace matching connection parameters
>   IB/cma: Separate port allocation to network namespaces
> 
>  drivers/infiniband/core/addr.c                     |  31 +-
>  drivers/infiniband/core/agent.c                    |   4 +-
>  drivers/infiniband/core/cm.c                       | 287
> ++++++++++++++++--
>  drivers/infiniband/core/cma.c                      | 332 +++++++++-----
> -------
>  drivers/infiniband/core/device.c                   |  57 ++++
>  drivers/infiniband/core/mad_rmpp.c                 |  10 +-
>  drivers/infiniband/core/ucm.c                      |   4 +-
>  drivers/infiniband/core/ucma.c                     |   4 +-
>  drivers/infiniband/core/user_mad.c                 |   4 +-
>  drivers/infiniband/core/verbs.c                    |  22 +-
>  drivers/infiniband/hw/ocrdma/ocrdma_ah.c           |   3 +-
>  drivers/infiniband/ulp/ipoib/ipoib_cm.c            |  21 +-
>  drivers/infiniband/ulp/ipoib/ipoib_main.c          | 122 +++++++-
>  drivers/infiniband/ulp/iser/iser_verbs.c           |   2 +-
>  drivers/infiniband/ulp/isert/ib_isert.c            |   2 +-
>  drivers/infiniband/ulp/srp/ib_srp.c                |   2 +-
>  drivers/infiniband/ulp/srpt/ib_srpt.c              |   5 +-
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   4 +-
>  include/rdma/ib_addr.h                             |  44 ++-
>  include/rdma/ib_cm.h                               |  63 +++-
>  include/rdma/ib_verbs.h                            |  44 ++-
>  include/rdma/rdma_cm.h                             |   6 +-
>  net/9p/trans_rdma.c                                |   2 +-
>  net/rds/ib.c                                       |   2 +-
>  net/rds/ib_cm.c                                    |   2 +-
>  net/rds/iw.c                                       |   2 +-
>  net/rds/iw_cm.c                                    |   2 +-
>  net/rds/rdma_transport.c                           |   2 +-
>  net/sunrpc/xprtrdma/svc_rdma_transport.c           |   2 +-
>  net/sunrpc/xprtrdma/verbs.c                        |   3 +-
>  30 files changed, 822 insertions(+), 268 deletions(-)
> 
> --
> 1.7.11.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
