From: "Dupuis, Chad" <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V3 0/2] Add QLogic FastLinQ FCoE (qedf) driver
Date: Fri, 3 Feb 2017 11:17:07 -0800
Message-ID: <1486149429-30095-1-git-send-email-chad.dupuis@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 QLogic-Storage-Upstream-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 yuval.mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
To: <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Unsubscribe: <http://lists.open-fcoe.org/mailman/options/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-fcoe.org/pipermail/fcoe-devel/>
List-Post: <mailto:fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <http://lists.open-fcoe.org/mailman/listinfo/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Errors-To: fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Sender: "fcoe-devel" <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: "Dupuis, Chad" <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

Dave, please apply the qed patch to net-next at your earliest convenience.
Martin, the qed patch needs to be applied first as the qedf patch is dependent
on the FCoE bits in the first qed driver patch.

This series introduces the hardware offload FCoE initiator driver for the
41000 Series Converged Network Adapters (579xx chip) by Cavium. The overall
driver design includes a common module ('qed') and protocol specific
dependent modules ('qedf' for FCoE).

This driver uses the kernel components of libfc and libfcoe as is and does not
make use of the open-fcoe user space components.  Therefore, no changes will need to be
made to any open-fcoe components.

The 'qed' common module, under drivers/net/ethernet/qlogic/qed/, is
enhanced with functionality required for FCoE support.

Changes from V2 -> V3

- Fix uninitialized variables reported by kbuild robot in qedf
- Remove superfluous comments from qedf.h
- Introduce new qedf_ctx flag to different stopping I/O for debug purposes.
- Don't take lport->disc.disc_mutex when restarting an rport.
- Remove extra whitespace in qedf_hsi.h

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
 drivers/scsi/qedf/qedf.h                          |  545 ++++
 drivers/scsi/qedf/qedf_attr.c                     |  165 +
 drivers/scsi/qedf/qedf_dbg.c                      |  195 ++
 drivers/scsi/qedf/qedf_dbg.h                      |  154 +
 drivers/scsi/qedf/qedf_debugfs.c                  |  460 +++
 drivers/scsi/qedf/qedf_els.c                      |  981 ++++++
 drivers/scsi/qedf/qedf_fip.c                      |  269 ++
 drivers/scsi/qedf/qedf_hsi.h                      |  422 +++
 drivers/scsi/qedf/qedf_io.c                       | 2282 ++++++++++++++
 drivers/scsi/qedf/qedf_main.c                     | 3336 +++++++++++++++++++++
 drivers/scsi/qedf/qedf_version.h                  |   15 +
 include/linux/qed/common_hsi.h                    |   10 +-
 include/linux/qed/fcoe_common.h                   |  715 +++++
 include/linux/qed/qed_fcoe_if.h                   |  145 +
 include/linux/qed/qed_if.h                        |   41 +-
 41 files changed, 12000 insertions(+), 19 deletions(-)
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
