From: Adit Ranadive <aditr@vmware.com>
Subject: [PATCH v5 00/16] Add Paravirtual RDMA Driver
Date: Sat, 24 Sep 2016 16:21:24 -0700
Message-ID: <cover.1474759181.git.aditr@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Adit Ranadive <aditr@vmware.com>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <jhansen@vmware.com>,
        <asarwade@vmware.com>, <georgezhang@vmware.com>,
        <bryantan@vmware.com>
To: <dledford@redhat.com>, <linux-rdma@vger.kernel.org>,
        <pv-drivers@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ex13-edg-ou-002.vmware.com ([208.91.0.190]:3075 "EHLO
        EX13-EDG-OU-002.vmware.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S965526AbcIXXWJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 19:22:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
[1] OFA Workshop Presentation - 
https://openfabrics.org/images/eventpresos/2016presentations/102parardma.pdf
[2] Libpvrdma User-level library - 
http://git.openfabrics.org/?p=~aditr/libpvrdma.git;a=summary
---
Changes v4->v5:
 - PATCH [02/16]
     - Moved pvrdma_uapi.h and pvrdma_user.h into common UAPI folder.
     - Renamed to pvrdma-uapi.h and pvrdma-abi.h respectively.
     - Prefixed unsigned vars with __.
 - PATCH [03/16]
     - Removed __ prefix for unsigned vars.
 - PATCH [04/16]
     - Update include for headers moved to UAPI.
     - Removed __ prefix for unsigned vars.
 - PATCH [05/16]
     - Update include for headers in UAPI folder.
     - Removed setting any properties that are reported by device as 0.
     - Simplified modify_port.
     - PD should be allocated first in kernel then in device.
     - Update to pvrdma_cmd_post for creating/destroying PD, Query port/device.
 - PATCH [06/16]
     - pvrdma_cmd_post takes the response code.
 - PATCH [07/16]
     - Correct var type passed to dma_alloc_coherent.
 - PATCH [08/16]
     - Moved the timeout to pvrdma_cmd_recv.
     - Added additional response code parameter to pvrdma_cmd_post.
 - PATCH [09/16]
     - Updated include for headers in UAPI folder.
     - Changed from EINVAL to ENOMEM if atomic add fails.
     - Added error code if destroy cq command failed.
     - Update to pvrdma_cmd_post for creating/destroying CQ.
 - PATCH [11/16]
     - Check the access flags correctly for DMA MR.
     - Update to pvrdma_cmd_post for creating/destroying MRs.
 - PATCH [12/16]
     - Updated include for headers in UAPI folder.
     - Update to pvrdma_cmd_post for creating/destroying/querying/modifying QPs.
     - Use the pvrdma_sge struct when posting WRs/allocating QP memory.
     - Removed two set but unused variables.
 - PATCH [13/16]
     - Removed two unnecessary lines.
     - Updated include for headers in UAPI folder.
     - Update to pvrdma_cmd_post for add/delete GIDs.
     - Add error code in dev_warn if pvrdma_cmd_post failed.
 - PATCH [16/16]
     - Added pvrdma files to common UAPI folder.

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

 MAINTAINERS                                    |    9 +
 drivers/infiniband/Kconfig                     |    1 +
 drivers/infiniband/hw/Makefile                 |    1 +
 drivers/infiniband/hw/pvrdma/Kconfig           |    7 +
 drivers/infiniband/hw/pvrdma/Makefile          |    3 +
 drivers/infiniband/hw/pvrdma/pvrdma.h          |  473 +++++++++
 drivers/infiniband/hw/pvrdma/pvrdma_cmd.c      |  117 +++
 drivers/infiniband/hw/pvrdma/pvrdma_cq.c       |  426 +++++++++
 drivers/infiniband/hw/pvrdma/pvrdma_defs.h     |  301 ++++++
 drivers/infiniband/hw/pvrdma/pvrdma_dev_api.h  |  342 +++++++
 drivers/infiniband/hw/pvrdma/pvrdma_doorbell.c |  127 +++
 drivers/infiniband/hw/pvrdma/pvrdma_ib_verbs.h |  444 +++++++++
 drivers/infiniband/hw/pvrdma/pvrdma_main.c     | 1220 ++++++++++++++++++++++++
 drivers/infiniband/hw/pvrdma/pvrdma_misc.c     |  304 ++++++
 drivers/infiniband/hw/pvrdma/pvrdma_mr.c       |  334 +++++++
 drivers/infiniband/hw/pvrdma/pvrdma_qp.c       |  973 +++++++++++++++++++
 drivers/infiniband/hw/pvrdma/pvrdma_verbs.c    |  577 +++++++++++
 drivers/infiniband/hw/pvrdma/pvrdma_verbs.h    |  108 +++
 drivers/net/vmxnet3/vmxnet3_int.h              |    3 +-
 include/linux/pci_ids.h                        |    1 +
 include/uapi/rdma/Kbuild                       |    2 +
 include/uapi/rdma/pvrdma-abi.h                 |   99 ++
 include/uapi/rdma/pvrdma-uapi.h                |  255 +++++
 23 files changed, 6125 insertions(+), 2 deletions(-)
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
 create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma_verbs.c
 create mode 100644 drivers/infiniband/hw/pvrdma/pvrdma_verbs.h
 create mode 100644 include/uapi/rdma/pvrdma-abi.h
 create mode 100644 include/uapi/rdma/pvrdma-uapi.h

-- 
2.7.4
