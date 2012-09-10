From: Robert Love <robert.w.love@intel.com>
Subject: [RFC PATCH 0/5] Reorganize libfcoe control interfaces
Date: Mon, 10 Sep 2012 15:59:08 -0700
Message-ID: <20120910225908.13140.97277.stgit@fritz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: devel@open-fcoe.org
To: netdev@vger.kernel.org, gregkh@linuxfoundation.org,
	linux-scsi@vger.kernel.org, bprakash@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:1518 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753837Ab2IJW7f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 18:59:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements a move from using module parameters
as control interfaces to /sys/bus/fcoe based interfaces. A sysfs infrastructure
was added to the kernel a few cycles ago, this series builds on that work.

It moves the create, vn2vn_create, destroy, enable and disable interfaces
from /sys/module/libfcoe/parameters/ to various places under /sys/bus/fcoe/.
These interfaces simply are not module configurations- they are control
interfaces.

A second goal of this series is to change the initialization sequence for
a FCoE device. The result of this series is that interfaces created using
libfcoe.ko interfaces (i.e. fcoe.ko or bnx2fc.ko) will have the following
starting steps-

1) Create/alloc the port
   - Allocate kernel memory and create per-instance sysfs devices
   - No discovery or login

2) Configure the port
   - Change mode, set ddp_min, etc...

3) Start the port
   - Begins discovery and/or login (depending on mode)

4) Destroy the port
   - Logout and free all memory

I'm looking for feedback on using sysfs files as control interfaces that
the user (application) would write interface names to. I modeled this
series off of the bonding sysfs interface, but it was suggested to me that
it might not be a good example. I belive bonding uses two values per-file
a '+' or a '-" to add or delete and then the ifname apended. I am simply
writing the ifname to the ctlr_create or ctlr_destroy.

Series compiled and tested against v3.5. libfcoe.ko compile warning fixed
upstream after v3.5, anyone who compiles this can ignore section mismatch
warning. Also note that a modified fcoemon is needed to use the fcoe system
service against this kernel modification. I'd be happy to provide that
fcoemon code on request.

---

Robert Love (5):
      libfcoe, fcoe: Allow user to set a ctlr's mode
      libfcoe: Create new libfcoe control interfaces
      fcoe: Use new fcoe_sysfs control interface
      bnx2fc: Use new fcoe_sysfs control interface
      libfcoe, fcoe: Remove libfcoe module parameters


 Documentation/ABI/testing/sysfs-bus-fcoe |   51 +++++++
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c        |   98 ++++++++-----
 drivers/scsi/fcoe/fcoe.c                 |  229 +++++++++++++++---------------
 drivers/scsi/fcoe/fcoe.h                 |    9 +
 drivers/scsi/fcoe/fcoe_ctlr.c            |   24 +++
 drivers/scsi/fcoe/fcoe_sysfs.c           |  139 ++++++++++++++++++
 drivers/scsi/fcoe/fcoe_transport.c       |  174 ++++-------------------
 include/scsi/fcoe_sysfs.h                |    5 +
 include/scsi/libfcoe.h                   |   20 ++-
 9 files changed, 445 insertions(+), 304 deletions(-)

-- 

Thanks, //Rob
