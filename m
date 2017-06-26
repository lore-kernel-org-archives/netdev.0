From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [RFC 00/19] qed*: Add iWARP support for QL4xxxx
Date: Mon, 26 Jun 2017 21:06:50 +0300
Message-ID: <1498500429-22557-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <michal.kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <yuval.mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <ariel.elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This RFC adds iWARP support to our QL4xxxx networking adapters.
The code changes span across qed and qedr drivers.

It is submitted as a single (long) RFC for purpose of reviewing,
but will eventually be split into two separate patch series,
one targeted for qed (net-next) and containing minimal qedr changes
and the other for qedr (rdma-next).

This series was tested and built against net-next.

qedr is used for both RoCE and iWARP. The distinction is made (for now)
at the pci function level. Code prefixed with rdma is shared, roce/iwarp
is specific.

The following was tested for iWARP under OFED: iser, nvmf, NFSoRDMA,
concurrent support of roce and iwarp on different pci functions.

MAINTAINERS file is not updated in this RFC as there is a pending patch
for qedr driver update https://patchwork.kernel.org/patch/9752761.

Your review and comments are highly appreciated.

Michal Kalderon (19):
  qed: Introduce iWARP personality
  qed: Implement iWARP initialization, teardown and qp operations
  qed: Rename some ll2 related defines
  qed: Add iWARP support in ll2 connections
  qed: iWARP CM - setup a ll2 connection for handling SYN packets
  qed: iWARP CM add listener functions and initial SYN processing
  qed: iWARP CM add passive side connect
  qed: iWARP CM add active side connect
  qed: iWARP implement disconnect flows
  qed: iWARP CM add error handling
  qed: Add iWARP protocol support in context allocation
  qed: Add iWARP support for physical queue allocation
  RDMA/qedr: Rename the qedr_cm file as a preparation for iWARP support
  RDMA/qedr: Add support for registering an iWARP device
  RDMA/qedr: Add iWARP support in existing verbs.
  RDMA/qedr: Add support for read with invalidate, supported in iWARP
  RDMA/qedr: Add iWARP connection management qp related callbacks
  RDMA/qedr: Add iWARP connection management functions
  qed*: Add iWARP enablement support

 drivers/infiniband/hw/qedr/Makefile                |    2 +-
 drivers/infiniband/hw/qedr/main.c                  |  107 +-
 drivers/infiniband/hw/qedr/qedr.h                  |   32 +-
 drivers/infiniband/hw/qedr/qedr_hsi_rdma.h         |    6 +-
 drivers/infiniband/hw/qedr/qedr_iw_cm.c            |  746 ++++++
 drivers/infiniband/hw/qedr/qedr_iw_cm.h            |   49 +
 .../hw/qedr/{qedr_cm.c => qedr_roce_cm.c}          |    2 +-
 .../hw/qedr/{qedr_cm.h => qedr_roce_cm.h}          |    0
 drivers/infiniband/hw/qedr/verbs.c                 |  270 ++-
 drivers/infiniband/hw/qedr/verbs.h                 |    2 +
 drivers/net/ethernet/qlogic/qed/Makefile           |    2 +-
 drivers/net/ethernet/qlogic/qed/qed.h              |   30 +-
 drivers/net/ethernet/qlogic/qed/qed_cxt.c          |   27 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c          |   36 +-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h          |    1 +
 drivers/net/ethernet/qlogic/qed/qed_iwarp.c        | 2409 ++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_iwarp.h        |  189 ++
 drivers/net/ethernet/qlogic/qed/qed_l2.c           |   16 +-
 drivers/net/ethernet/qlogic/qed/qed_ll2.c          |   42 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c         |   17 +-
 drivers/net/ethernet/qlogic/qed/qed_mcp.c          |   10 +-
 drivers/net/ethernet/qlogic/qed/qed_rdma.c         |  144 +-
 drivers/net/ethernet/qlogic/qed/qed_rdma.h         |    5 +
 drivers/net/ethernet/qlogic/qed/qed_roce.c         |   20 +
 drivers/net/ethernet/qlogic/qed/qed_sp.h           |    7 +-
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c  |    2 +
 include/linux/qed/common_hsi.h                     |    4 +-
 include/linux/qed/iwarp_common.h                   |   53 +
 include/linux/qed/qed_ll2_if.h                     |    3 +-
 include/linux/qed/qed_rdma_if.h                    |  114 +
 30 files changed, 4166 insertions(+), 181 deletions(-)
 create mode 100644 drivers/infiniband/hw/qedr/qedr_iw_cm.c
 create mode 100644 drivers/infiniband/hw/qedr/qedr_iw_cm.h
 rename drivers/infiniband/hw/qedr/{qedr_cm.c => qedr_roce_cm.c} (99%)
 rename drivers/infiniband/hw/qedr/{qedr_cm.h => qedr_roce_cm.h} (100%)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_iwarp.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_iwarp.h
 create mode 100644 include/linux/qed/iwarp_common.h

-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
