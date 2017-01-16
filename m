From: "Dupuis, Chad" <chad.dupuis@cavium.com>
Subject: [PATCH 0/2] Add QLogic FastLinQ FCoE (qedf) driver
Date: Mon, 16 Jan 2017 11:53:55 -0800
Message-ID: <1484596437-27637-1-git-send-email-chad.dupuis@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-scsi@vger.kernel.org>, <fcoe-devel@open-fcoe.org>,
        <netdev@vger.kernel.org>, <yuval.mintz@cavium.com>,
        <QLogic-Storage-Upstream@cavium.com>
To: <martin.petersen@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0088.outbound.protection.outlook.com ([104.47.37.88]:6106
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750927AbdAPULA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 15:11:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dupuis, Chad" <chad.dupuis@cavium.com>

This series introduces the hardware offload FCoE initiator driver for the
41000 Series Converged Network Adapters (579xx chip) by Cavium. The overall
driver design includes a common module ('qed') and protocol specific
dependent modules ('qedf' for FCoE).

This driver uses the kernel components of libfc and libfcoe as is and does not
make use of the open-fcoe user space components.  Therefore, no changes will need to be
made to any open-fcoe components.

The 'qed' common module, under drivers/net/ethernet/qlogic/qed/, is
enhanced with functionality required for FCoE support.

Changes from RFC -> V1

- Squash qedf patches to one patch now that the initial review has taken place
- Convert qedf to use hotplug state machine
- Return via va_end to match corresponding va_start in logging functions
- Convert qedf_ctx offloaded port list to a RCU list so searches do not need
  to make use of spinlocks.  Also eliminates the need to fcport conn_id's.
- Use IS_ERR(fp) in qedf_flogi_resp() instead of checking individual FC_EX_* errors.
- Remove scsi_block_target when executing TMF request.
- Checkpatch fixes in the qed and qedf patches

At the current time I couldn't make use of Christoph's IRQ allocation changes
as changes are needed to the core module (qed) which would affect other drivers
that are already in tree (qede, qedr, qedi).

Arun Easi (1):
  qed: Add support for hardware offloaded FCoE.

Dupuis, Chad (1):
  qedf: Add QLogic FastLinQ offload FCoE driver framework.

 MAINTAINERS                                       |    6 +
 drivers/net/ethernet/qlogic/Kconfig               |    3 +
 drivers/net/ethernet/qlogic/qed/Makefile          |    1 +
 drivers/net/ethernet/qlogic/qed/qed.h             |   11 +
 drivers/net/ethernet/qlogic/qed/qed_cxt.c         |   98 +-
 drivers/net/ethernet/qlogic/qed/qed_cxt.h         |    3 +
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c        |   11 +
 drivers/net/ethernet/qlogic/qed/qed_dcbx.h        |    1 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c         |  205 +-
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h     |   42 +
 drivers/net/ethernet/qlogic/qed/qed_fcoe.c        |  990 ++++++
 drivers/net/ethernet/qlogic/qed/qed_fcoe.h        |   52 +
 drivers/net/ethernet/qlogic/qed/qed_hsi.h         |  781 ++++-
 drivers/net/ethernet/qlogic/qed/qed_hw.c          |    3 +
 drivers/net/ethernet/qlogic/qed/qed_ll2.c         |   25 +
 drivers/net/ethernet/qlogic/qed/qed_ll2.h         |    2 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c        |    7 +
 drivers/net/ethernet/qlogic/qed/qed_mcp.c         |    3 +
 drivers/net/ethernet/qlogic/qed/qed_mcp.h         |    1 +
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h    |    8 +
 drivers/net/ethernet/qlogic/qed/qed_sp.h          |    4 +
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c |    3 +
 drivers/scsi/Kconfig                              |    1 +
 drivers/scsi/qedf/Kconfig                         |   11 +
 drivers/scsi/qedf/Makefile                        |    5 +
 drivers/scsi/qedf/qedf.h                          |  555 ++++
 drivers/scsi/qedf/qedf_attr.c                     |  165 +
 drivers/scsi/qedf/qedf_dbg.c                      |  195 ++
 drivers/scsi/qedf/qedf_dbg.h                      |  154 +
 drivers/scsi/qedf/qedf_debugfs.c                  |  471 +++
 drivers/scsi/qedf/qedf_els.c                      |  984 ++++++
 drivers/scsi/qedf/qedf_fip.c                      |  267 ++
 drivers/scsi/qedf/qedf_hsi.h                      |  427 +++
 drivers/scsi/qedf/qedf_io.c                       | 2301 ++++++++++++++
 drivers/scsi/qedf/qedf_main.c                     | 3483 +++++++++++++++++++++
 drivers/scsi/qedf/qedf_version.h                  |   15 +
 include/linux/qed/common_hsi.h                    |   10 +-
 include/linux/qed/fcoe_common.h                   |  715 +++++
 include/linux/qed/qed_fcoe_if.h                   |  145 +
 include/linux/qed/qed_if.h                        |   39 +
 40 files changed, 12192 insertions(+), 11 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_fcoe.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_fcoe.h
 create mode 100644 drivers/scsi/qedf/Kconfig
 create mode 100644 drivers/scsi/qedf/Makefile
 create mode 100644 drivers/scsi/qedf/qedf.h
 create mode 100644 drivers/scsi/qedf/qedf_attr.c
 create mode 100644 drivers/scsi/qedf/qedf_dbg.c
 create mode 100644 drivers/scsi/qedf/qedf_dbg.h
 create mode 100644 drivers/scsi/qedf/qedf_debugfs.c
 create mode 100644 drivers/scsi/qedf/qedf_els.c
 create mode 100644 drivers/scsi/qedf/qedf_fip.c
 create mode 100644 drivers/scsi/qedf/qedf_hsi.h
 create mode 100644 drivers/scsi/qedf/qedf_io.c
 create mode 100644 drivers/scsi/qedf/qedf_main.c
 create mode 100644 drivers/scsi/qedf/qedf_version.h
 create mode 100644 include/linux/qed/fcoe_common.h
 create mode 100644 include/linux/qed/qed_fcoe_if.h

-- 
1.8.5.6
