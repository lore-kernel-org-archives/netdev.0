From: "Dupuis, Chad" <chad.dupuis@cavium.com>
Subject: [PATCH V2 0/2] Add QLogic FastLinQ FCoE (qedf) driver
Date: Wed, 25 Jan 2017 12:33:41 -0800
Message-ID: <1485376423-18737-1-git-send-email-chad.dupuis@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-scsi@vger.kernel.org>, <fcoe-devel@open-fcoe.org>,
        <netdev@vger.kernel.org>, <yuval.mintz@cavium.com>,
        <QLogic-Storage-Upstream@cavium.com>
To: <martin.petersen@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0072.outbound.protection.outlook.com ([104.47.32.72]:28800
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751324AbdAYUeb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Jan 2017 15:34:31 -0500
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

Martin, This patch needs to be applied first as the qedf patch is dependent
on the FCoE bits in the first qed driver patch.

Changes from V1 -> V2

Changes in qed:
- Fix compiler warning when CONFIG_DCB is not set.

Fixes in qedf:
- Add qedf to scsi directory Makefile.
- Updates to convert LightL2 and I/O processing kthreads to workqueues.

Changes from RFC -> V1

- Squash qedf patches to one patch now that the initial review has taken place
- Convert qedf to use hotplug state machine
- Return via va_end to match corresponding va_start in logging functions
- Convert qedf_ctx offloaded port list to a RCU list so searches do not need
  to make use of spinlocks.  Also eliminates the need to fcport conn_id's.
- Use IS_ERR(fp) in qedf_flogi_resp() instead of checking individual FC_EX_* errors.
- Remove scsi_block_target when executing TMF request.
- Checkpatch fixes in the qed and qedf patches

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
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c        |   13 +-
 drivers/net/ethernet/qlogic/qed/qed_dcbx.h        |    5 +-
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
 drivers/scsi/Makefile                             |    1 +
 drivers/scsi/qedf/Kconfig                         |   11 +
 drivers/scsi/qedf/Makefile                        |    5 +
 drivers/scsi/qedf/qedf.h                          |  548 ++++
 drivers/scsi/qedf/qedf_attr.c                     |  165 +
 drivers/scsi/qedf/qedf_dbg.c                      |  195 ++
 drivers/scsi/qedf/qedf_dbg.h                      |  154 +
 drivers/scsi/qedf/qedf_debugfs.c                  |  460 +++
 drivers/scsi/qedf/qedf_els.c                      |  983 ++++++
 drivers/scsi/qedf/qedf_fip.c                      |  269 ++
 drivers/scsi/qedf/qedf_hsi.h                      |  427 +++
 drivers/scsi/qedf/qedf_io.c                       | 2280 ++++++++++++++
 drivers/scsi/qedf/qedf_main.c                     | 3335 +++++++++++++++++++++
 drivers/scsi/qedf/qedf_version.h                  |   15 +
 include/linux/qed/common_hsi.h                    |   10 +-
 include/linux/qed/fcoe_common.h                   |  715 +++++
 include/linux/qed/qed_fcoe_if.h                   |  145 +
 include/linux/qed/qed_if.h                        |   41 +-
 41 files changed, 12007 insertions(+), 19 deletions(-)
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
