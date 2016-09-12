From: Adit Ranadive <aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v4 00/16] Add Paravirtual RDMA Driver
Date: Sun, 11 Sep 2016 21:49:10 -0700
Message-ID: <1473655766-31628-1-git-send-email-aditr@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Adit Ranadive <aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <jhansen-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        <asarwade-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>, <georgezhang-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        <bryantan-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <pv-drivers-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Doug, others,

This patch series adds a driver for a paravirtual RDMA device. The device
is developed for VMware's Virtual Machines and allows existing RDMA
applications to continue to use existing Verbs API when deployed in VMs on
ESXi. We recently did a presentation in the OFA Workshop [1] regarding this
device.

Description and RDMA Support
============================
The virtual device is exposed as a dual function PCIe device. One part is
a virtual network device (VMXNet3) which provides networking properties
like MAC, IP addresses to the RDMA part of the device. The networking
properties are used to register GIDs required by RDMA applications to
communicate.

These patches add support and the all required infrastructure for letting
applications use such a device. We support the mandatory Verbs API as well
as the base memory management extensions (Local Inv, Send with Inv and Fast
Register Work Requests). We currently support both Reliable Connected and
Unreliable Datagram QPs but do not support Shared Receive Queues (SRQs).
Also, we support the following types of Work Requests:
 o Send/Receive (with or without Immediate Data)
 o RDMA Write (with or without Immediate Data)
 o RDMA Read
 o Local Invalidate
 o Send with Invalidate
 o Fast Register Work Requests

This version only adds support for version 1 of RoCE. We will add RoCEv2
support in a future patch. We do support registration of both MAC-based and
IP-based GIDs. I have also created a git tree for our user-level driver [2].

Testing
=======
We have tested this internally for various types of Guest OS - Red Hat,
Centos, Ubuntu 12.04/14.04/16.04, Oracle Enterprise Linux, SLES 12
using backported versions of this driver. The tests included several runs
of the performance tests (included with OFED), Intel MPI PingPong benchmark
on OpenMPI, krping for FRWRs. Mellanox has been kind enough to test the
backported version of the driver internally on their hardware using a
VMware provided ESX build. I have also applied and tested this with Doug's
k.o/for-4.9 branch (commit 64278fe). Note, that this patch series should be
applied all together. I split out the commits so that it may be easier to
review.

PVRDMA Resources
================
[1] OFA Workshop Presentation - https://goo.gl/pHOXJ8
[2] Libpvrdma User-level library - 
http://git.openfabrics.org/?p=~aditr/libpvrdma.git;a=summary
---
Changes v3->v4:
 - Rebased on for-4.9 branch - commit 64278fe89b729
   ("Merge branch 'hns-roce' into k.o/for-4.9")
 - PATCH [01/16]
     - New in v4 - Moved vmxnet3 id to pci_ids.h
 - PATCH [02,03/16]
     - pvrdma_sge was moved into pvrdma_uapi.h
 - PATCH [04/16]
     - Removed explicit enum values.
 - PATCH [05/16]
     - Renamed priviledged -> privileged.
     - Added error numbers for command errors.
     - Removed unnecessary goto in modify_device.
     - Moved pd allocation to after command execution.
     - Removed an incorrect atomic_dec.
 - PATCH [06/16]
     - Renamed priviledged -> privileged.
     - Renamed pvrdma_flush_cqe to _pvrdma_flush_cqe since we hold a lock
     to call it.
     - Added wrapper functions for writing to UARs for CQ/QP.
     - The conversion functions are updated as func_name(dst, src) format.
     - Renamed max_gs to max_sg.
     - Added work struct for net device events.
 - PATCH [07/16]
     - Updated conversion functions to func_name(dst, src) format.
     - Removed unneeded local variables.
 - PATCH [08/16]
     - Removed the min check and added a BUILD_BUG_ON check for size.
 - PATCH [09/16]
     - Added a pvrdma_destroy_cq in the error path.
     - Renamed pvrdma_flush_cqe to _pvrdma_flush_cqe since we need a lock to
     be held while calling this.
     - Updated to use wrapper for UAR write for CQ.
     - Ensure that poll_cq does not return error values.
 - PATCH [10/16]
     - Removed an unnecessary comment.
 - PATCH [11/16]
     - Changed access flag check for DMA MR to using bit operation.
     - Removed some local variables.
 - PATCH [12/16]
     - Removed an unnecessary switch case.
     - Unified the returns in pvrdma_create_qp to use one exit point.
     - Renamed pvrdma_flush_cqe to _pvrdma_flush_cqe since we need a lock to
     be held when calling this.
     - Updated to use wrapper for UAR write for QP.
     - Updated conversion function to func_name(dst, src) format.
     - Renamed max_gs to max_sg.
     - Renamed cap variable to req_cap in pvrdma_set_sq/rq_size.
     - Changed dev_warn to dev_warn_ratelimited in pvrdma_post_send/recv.
     - Added nesting locking for flushing CQs when destroying/resetting a QP.
     - Added missing ret value.
 - PATCH [13/16]
     - Fixed some checkpatch warnings.
     - Added support for new get_dev_fw_str API.
     - Added event workqueue for netdevice events.
     - Restructured the pvrdma_pci_remove function a little bit.
 - PATCH [14/16]
     - Enforced dependency on VMXNet3 module.

Changes v2->v3:
 - I reordered the patches so that the definitions of enums, structures is
 before their use (suggested by Yuval Shaia) so its easier to review.
 - Removed an unneccesary bool in pvrdma_cmd_post (suggested by Yuval Shaia).
 - Made the use of comma at end of enums consistent across files (suggested
 by Leon Romanovsky).

Changes v1->v2:
 - Patch [07/15] - Addressed Yuval Shaia's comments and 32-bit build errors.

---
Adit Ranadive (16):
  vmxnet3: Move PCI Id to pci_ids.h
  IB/pvrdma: Add user-level shared functions
  IB/pvrdma: Add virtual device RDMA structures
  IB/pvrdma: Add the paravirtual RDMA device specification
  IB/pvrdma: Add functions for Verbs support
  IB/pvrdma: Add paravirtual rdma device
  IB/pvrdma: Add helper functions
  IB/pvrdma: Add device command support
  IB/pvrdma: Add support for Completion Queues
  IB/pvrdma: Add UAR support
  IB/pvrdma: Add support for memory regions
  IB/pvrdma: Add Queue Pair support
  IB/pvrdma: Add the main driver module for PVRDMA
  IB/pvrdma: Add Kconfig and Makefile
  IB: Add PVRDMA driver
  MAINTAINERS: Update for PVRDMA driver

 MAINTAINERS                                    |    7 +
 drivers/infiniband/Kconfig                     |    1 +
 drivers/infiniband/hw/Makefile                 |    1 +
 drivers/infiniband/hw/pvrdma/Kconfig           |    7 +
 drivers/infiniband/hw/pvrdma/Makefile          |    3 +
 drivers/infiniband/hw/pvrdma/pvrdma.h          |  473 +++++++++
 drivers/infiniband/hw/pvrdma/pvrdma_cmd.c      |  108 +++
 drivers/infiniband/hw/pvrdma/pvrdma_cq.c       |  428 +++++++++
 drivers/infiniband/hw/pvrdma/pvrdma_defs.h     |  302 ++++++
 drivers/infiniband/hw/pvrdma/pvrdma_dev_api.h  |  342 +++++++
 drivers/infiniband/hw/pvrdma/pvrdma_doorbell.c |  127 +++
 drivers/infiniband/hw/pvrdma/pvrdma_ib_verbs.h |  444 +++++++++
 drivers/infiniband/hw/pvrdma/pvrdma_main.c     | 1222 ++++++++++++++++++++++++
 drivers/infiniband/hw/pvrdma/pvrdma_misc.c     |  303 ++++++
 drivers/infiniband/hw/pvrdma/pvrdma_mr.c       |  332 +++++++
 drivers/infiniband/hw/pvrdma/pvrdma_qp.c       |  980 +++++++++++++++++++
 drivers/infiniband/hw/pvrdma/pvrdma_uapi.h     |  255 +++++
 drivers/infiniband/hw/pvrdma/pvrdma_user.h     |   99 ++
 drivers/infiniband/hw/pvrdma/pvrdma_verbs.c    |  611 ++++++++++++
 drivers/infiniband/hw/pvrdma/pvrdma_verbs.h    |  108 +++
 drivers/net/vmxnet3/vmxnet3_int.h              |    3 +-
 include/linux/pci_ids.h                        |    1 +
 22 files changed, 6155 insertions(+), 2 deletions(-)
 create mode 100644 drivers/infiniband/hw/pvrdma/Kconfig
 create mode 100644 drivers/infiniband/hw/pvrdma/Makefile
 create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma.h
 create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma_cmd.c
 create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma_cq.c
 create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma_defs.h
 create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma_dev_api.h
 create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma_doorbell.c
 create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma_ib_verbs.h
 create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma_main.c
 create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma_misc.c
 create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma_mr.c
 create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma_qp.c
 create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma_uapi.h
 create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma_user.h
 create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma_verbs.c
 create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma_verbs.h

-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
