From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 00/29] drivers, mics refcount conversions
Date: Mon,  6 Mar 2017 16:20:47 +0200
Message-ID: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, linux-s390@vger.kernel.org,
 open-iscsi@googlegroups.com, linux-scsi@vger.kernel.org, peterz@infradead.org,
 netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pci@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-raid@vger.kernel.org,
 linux-bcache@vger.kernel.org, target-devel@vger.kernel.org,
 linux-serial@vger.kernel.org, devel@linuxdriverproject.org,
 fcoe-devel@open-fcoe.org, xen-devel@lists.xenproject.org,
 linux1394-devel@lists.sourceforge.net,
 Elena Reshetova <elena.reshetova@intel.com>, linux-media@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

This series, for various different drivers, replaces atomic_t reference
counters with the new refcount_t type and API (see include/linux/refcount.h).
By doing this we prevent intentional or accidental
underflows or overflows that can led to use-after-free vulnerabilities.

The below patches are fully independent and can be cherry-picked separately*.
Since we convert all kernel subsystems in the same fashion, resulting
in about 300 patches, we have to group them for sending at least in some
fashion to be manageable. Please excuse the long cc list.

*with the exception of the media/vb2-related patches that depend on
vb2_vmarea_handler.refcount conversions.

Not run-time tested beyond booting and using kernel with refcount conversions
for my daily work.

If there are no objections to these patches,
I think they can go via Greg's drivers tree, as he suggested before.

Elena Reshetova (29):
  drivers, block: convert xen_blkif.refcnt from atomic_t to refcount_t
  drivers, firewire: convert fw_node.ref_count from atomic_t to
    refcount_t
  drivers, char: convert vma_data.refcnt from atomic_t to refcount_t
  drivers, connector: convert cn_callback_entry.refcnt from atomic_t to
    refcount_t
  drivers, md, bcache: convert cached_dev.count from atomic_t to
    refcount_t
  drivers, md: convert dm_cache_metadata.ref_count from atomic_t to
    refcount_t
  drivers, md: convert dm_dev_internal.count from atomic_t to refcount_t
  drivers, md: convert mddev.active from atomic_t to refcount_t
  drivers, md: convert table_device.count from atomic_t to refcount_t
  drivers, md: convert stripe_head.count from atomic_t to refcount_t
  drivers, media: convert cx88_core.refcount from atomic_t to refcount_t
  drivers, media: convert s2255_dev.num_channels from atomic_t to
    refcount_t
  drivers, media: convert vb2_vmarea_handler.refcount from atomic_t to
    refcount_t
  drivers, media: convert vb2_dc_buf.refcount from atomic_t to
    refcount_t
  drivers, media: convert vb2_dma_sg_buf.refcount from atomic_t to
    refcount_t
  drivers, media: convert vb2_vmalloc_buf.refcount from atomic_t to
    refcount_t
  drivers, pci: convert hv_pci_dev.refs from atomic_t to refcount_t
  drivers, s390: convert urdev.ref_count from atomic_t to refcount_t
  drivers, s390: convert lcs_reply.refcnt from atomic_t to refcount_t
  drivers, s390: convert qeth_reply.refcnt from atomic_t to refcount_t
  drivers, s390: convert fc_fcp_pkt.ref_cnt from atomic_t to refcount_t
  drivers, scsi: convert iscsi_task.refcount from atomic_t to refcount_t
  drivers: convert vme_user_vma_priv.refcnt from atomic_t to refcount_t
  drivers: convert iblock_req.pending from atomic_t to refcount_t
  drivers, usb: convert ffs_data.ref from atomic_t to refcount_t
  drivers, usb: convert dev_data.count from atomic_t to refcount_t
  drivers, usb: convert ep_data.count from atomic_t to refcount_t
  drivers: convert sbd_duart.map_guard from atomic_t to refcount_t
  drivers, xen: convert grant_map.users from atomic_t to refcount_t

 drivers/block/xen-blkback/common.h             |  7 +--
 drivers/block/xen-blkback/xenbus.c             |  2 +-
 drivers/char/mspec.c                           |  9 ++--
 drivers/connector/cn_queue.c                   |  4 +-
 drivers/connector/connector.c                  |  2 +-
 drivers/firewire/core-topology.c               |  2 +-
 drivers/firewire/core.h                        |  8 ++--
 drivers/md/bcache/bcache.h                     |  7 +--
 drivers/md/bcache/super.c                      |  6 +--
 drivers/md/bcache/writeback.h                  |  2 +-
 drivers/md/dm-cache-metadata.c                 |  9 ++--
 drivers/md/dm-table.c                          |  6 +--
 drivers/md/dm.c                                | 12 +++--
 drivers/md/dm.h                                |  3 +-
 drivers/md/md.c                                |  6 +--
 drivers/md/md.h                                |  3 +-
 drivers/md/raid5-cache.c                       |  8 ++--
 drivers/md/raid5.c                             | 66 +++++++++++++-------------
 drivers/md/raid5.h                             |  3 +-
 drivers/media/pci/cx88/cx88-cards.c            |  2 +-
 drivers/media/pci/cx88/cx88-core.c             |  4 +-
 drivers/media/pci/cx88/cx88.h                  |  3 +-
 drivers/media/usb/s2255/s2255drv.c             | 21 ++++----
 drivers/media/v4l2-core/videobuf2-dma-contig.c | 11 +++--
 drivers/media/v4l2-core/videobuf2-dma-sg.c     | 11 +++--
 drivers/media/v4l2-core/videobuf2-memops.c     |  6 +--
 drivers/media/v4l2-core/videobuf2-vmalloc.c    | 11 +++--
 drivers/pci/host/pci-hyperv.c                  |  9 ++--
 drivers/s390/char/vmur.c                       |  8 ++--
 drivers/s390/char/vmur.h                       |  4 +-
 drivers/s390/net/lcs.c                         |  8 ++--
 drivers/s390/net/lcs.h                         |  3 +-
 drivers/s390/net/qeth_core.h                   |  3 +-
 drivers/s390/net/qeth_core_main.c              |  8 ++--
 drivers/scsi/libfc/fc_fcp.c                    |  6 +--
 drivers/scsi/libiscsi.c                        |  8 ++--
 drivers/scsi/qedi/qedi_iscsi.c                 |  2 +-
 drivers/staging/vme/devices/vme_user.c         | 10 ++--
 drivers/target/target_core_iblock.c            | 12 ++---
 drivers/target/target_core_iblock.h            |  3 +-
 drivers/tty/serial/sb1250-duart.c              | 18 +++----
 drivers/usb/gadget/function/f_fs.c             |  8 ++--
 drivers/usb/gadget/function/u_fs.h             |  3 +-
 drivers/usb/gadget/legacy/inode.c              | 17 +++----
 drivers/xen/gntdev.c                           | 11 +++--
 include/linux/connector.h                      |  4 +-
 include/media/videobuf2-memops.h               |  3 +-
 include/scsi/libfc.h                           |  3 +-
 include/scsi/libiscsi.h                        |  3 +-
 49 files changed, 203 insertions(+), 185 deletions(-)

-- 
2.7.4
