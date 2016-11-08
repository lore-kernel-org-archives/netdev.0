From: Manish Rangankar <manish.rangankar@cavium.com>
Subject: [PATCH v2 0/6] Add QLogic FastLinQ iSCSI (qedi) driver.
Date: Mon, 7 Nov 2016 22:56:57 -0800
Message-ID: <1478588223-16183-1-git-send-email-manish.rangankar@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-scsi@vger.kernel.org>, <netdev@vger.kernel.org>,
        <QLogic-Storage-Upstream@cavium.com>, <Yuval.Mintz@cavium.com>
To: <martin.petersen@oracle.com>, <lduncan@suse.com>,
        <cleech@redhat.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series introduces hardware offload iSCSI initiator driver for the
41000 Series Converged Network Adapters (579xx chip) by Qlogic. The overall
driver design includes a common module ('qed') and protocol specific
dependent modules ('qedi' for iSCSI).

This is an open iSCSI driver, modifications to open iSCSI user components
'iscsid', 'iscsiuio', etc. are required for the solution to work. The user
space changes are also in the process of being submitted.

    https://groups.google.com/forum/#!forum/open-iscsi

The 'qed' common module, under drivers/net/ethernet/qlogic/qed/, is
enhanced with functionality required for the iSCSI support. This series
is based on:

    net tree base: Merge of net and net-next as of 10/31/2016

Changes from RFC v1:

 RFC v1 comments reference:

  http://marc.info/?l=linux-scsi&w=2&r=1&s=qed&q=b

 The following comments were incorporated:-

  1. MAC copying to use unaligned macro in qed_sp_iscsi_conn_offload()
  2. Contain scattered IS_ENABLED() check inside header file.
  3. Reduce indent in qed_iscsi_start() by changing logic slightly.
  4. Use kernel-doc style documentation.
  5. Shorten qed_ll2_lb_rxq_completion() by removing queue handling as
     a separate function.
  6. Reduce code duplication by creating qed_ooo_submit_[tr]x_buffers().
  7. Remove dynamic memory allocation in ISR for solicited packets. 
  8. Rearrange qedi_process_iscsi_error() code to use mapping values
     onto strings.
  9. Use kernel-doc style documentation in qedi_hsi.h
  10. Change pr_crit to pr_err. 
  11. Remove unnecessary typecasting. 
  12. Change kmalloc to kmalloc_array in qedi_setup_cid_que(). 
  13. Rearrange firmware and driver version information print. 
  14. Change variable names from scsi_lun to other, as scsi_lun struct exists.
  15. Introduce QEDI_U64_HI and QEDI_U64_LO macros for code readability. 
  16. Move scsi_dma_unmap above sge_valid in qedi_iscsi_unmap_sg_list(). 
  17. Introduce QEDI_OFLD_WAIT_STATE for code readability.
  18. Add cond_resched() in per_cpu_io_thread to avoid soft-lockups.
  19. Change trace_io to accomodate all the scsi commands. 
  20. Spell correction in comments section.

 The following comments were not incorporated:-
  1. Remove "QLogic qed NIC Driver" comment
     - Applies to drivers/net/ethernet/qlogic/qed/*.[ch]
     - This will be submitted as a separate patch, as there are multiple
       files (files that are not part of this series) need to be updated
       and this change is not related to this series.
  2. Update copyright
     - Applies to drivers/net/ethernet/qlogic/qed/*.[ch]
     - Same as above, will submit a separate patch, as multiple files
       need to be updated and this change is not related to this series.
  3. Remove adding and removing of QEDI Kconfig entries. Added by
     "qed" patch and removed and re-added by "qedi" patch.
     - QEDI driver is composed of two parts, the common module (qed) and
       the protocol module (qedi), which goes in net and scsi trees
       respectively. The qed module conditionally enables certain
       functionality for the QEDI module in qed; hence the Kconfig entry was
       added for QEDI by qed; otherwise it looks odd to use CONFIG_QEDI
       in qed. So, the remove and re-add is left as is.
  4. Workqueue implementation in completion path.
     - This change will be submitted as a separate patch, as it requires 
       complete performance validation cycle.
  5. IRQ handling changes from Christoph H. irq work. 
     - This change will also be subitted as a separate patch, as it also
       require change in qed.ko module which will affect other protocol
       drivers (qedr, qede) as well.
     - This change will be integral part of MQ/MQ-TAG infrastructure that
       we want to employ in our qedi driver. 
  6. Using multiple memory barriers.
     - We kept both memory barriers as a failsafe, as for some architectures
       the call is the same but on others they are two different assembly
       operations. We have updated patch with same information in comments.


Manish Rangankar (4):
  qedi: Add QLogic FastLinQ offload iSCSI driver framework.
  qedi: Add LL2 iSCSI interface for offload iSCSI.
  qedi: Add support for iSCSI session management.
  qedi: Add support for data path.

Yuval Mintz (2):
  qed: Add support for hardware offloaded iSCSI.
  qed: Add iSCSI out of order packet handling.

 MAINTAINERS                                    |    6 +
 drivers/net/ethernet/qlogic/Kconfig            |   15 +
 drivers/net/ethernet/qlogic/qed/Makefile       |    1 +
 drivers/net/ethernet/qlogic/qed/qed.h          |    8 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c      |   22 +
 drivers/net/ethernet/qlogic/qed/qed_int.h      |    1 -
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c    | 1276 +++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_iscsi.h    |   52 +
 drivers/net/ethernet/qlogic/qed/qed_l2.c       |    1 -
 drivers/net/ethernet/qlogic/qed/qed_ll2.c      |  507 ++++-
 drivers/net/ethernet/qlogic/qed/qed_ll2.h      |    9 +
 drivers/net/ethernet/qlogic/qed/qed_ooo.c      |  501 +++++
 drivers/net/ethernet/qlogic/qed/qed_ooo.h      |  173 ++
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |    2 +
 drivers/net/ethernet/qlogic/qed/qed_roce.c     |    1 +
 drivers/net/ethernet/qlogic/qed/qed_spq.c      |   24 +
 drivers/scsi/Kconfig                           |    1 +
 drivers/scsi/Makefile                          |    1 +
 drivers/scsi/qedi/Kconfig                      |   10 +
 drivers/scsi/qedi/Makefile                     |    5 +
 drivers/scsi/qedi/qedi.h                       |  364 ++++
 drivers/scsi/qedi/qedi_dbg.c                   |  143 ++
 drivers/scsi/qedi/qedi_dbg.h                   |  144 ++
 drivers/scsi/qedi/qedi_debugfs.c               |  244 +++
 drivers/scsi/qedi/qedi_fw.c                    | 2378 ++++++++++++++++++++++++
 drivers/scsi/qedi/qedi_gbl.h                   |   73 +
 drivers/scsi/qedi/qedi_hsi.h                   |   52 +
 drivers/scsi/qedi/qedi_iscsi.c                 | 1624 ++++++++++++++++
 drivers/scsi/qedi/qedi_iscsi.h                 |  232 +++
 drivers/scsi/qedi/qedi_main.c                  | 2143 +++++++++++++++++++++
 drivers/scsi/qedi/qedi_sysfs.c                 |   52 +
 drivers/scsi/qedi/qedi_version.h               |   14 +
 include/linux/qed/qed_if.h                     |    2 +
 include/linux/qed/qed_iscsi_if.h               |  229 +++
 34 files changed, 10297 insertions(+), 13 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_iscsi.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_iscsi.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_ooo.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_ooo.h
 create mode 100644 drivers/scsi/qedi/Kconfig
 create mode 100644 drivers/scsi/qedi/Makefile
 create mode 100644 drivers/scsi/qedi/qedi.h
 create mode 100644 drivers/scsi/qedi/qedi_dbg.c
 create mode 100644 drivers/scsi/qedi/qedi_dbg.h
 create mode 100644 drivers/scsi/qedi/qedi_debugfs.c
 create mode 100644 drivers/scsi/qedi/qedi_fw.c
 create mode 100644 drivers/scsi/qedi/qedi_gbl.h
 create mode 100644 drivers/scsi/qedi/qedi_hsi.h
 create mode 100644 drivers/scsi/qedi/qedi_iscsi.c
 create mode 100644 drivers/scsi/qedi/qedi_iscsi.h
 create mode 100644 drivers/scsi/qedi/qedi_main.c
 create mode 100644 drivers/scsi/qedi/qedi_sysfs.c
 create mode 100644 drivers/scsi/qedi/qedi_version.h
 create mode 100644 include/linux/qed/qed_iscsi_if.h

-- 
1.8.3.1

