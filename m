From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] virtio, vhost: new device, fixes, speedups
Date: Fri, 16 Dec 2016 01:05:07 +0200
Message-ID: <20161216010507-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, kvm@vger.kernel.org, mst@redhat.com,
	virtualization@lists.linux-foundation.org, hch@lst.de,
	stefan@osg.samsung.com, krzk@kernel.org, felipe@nutanix.com,
	tklauser@distanz.ch, liuyuan@google.com,
	arend.vanspriel@broadcom.com, marcel@holtmann.org,
	mkl@pengutronix.de, kvalo@codeaurora.org,
	omarapazanadi@gmail.com, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	netdev@vger.kernel.org, torvalds@linux-foundation.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

The following changes since commit a57cb1c1d7974c62a5c80f7869e35b492ace12cd:

  Merge branch 'akpm' (patches from Andrew) (2016-12-14 17:25:18 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to 6bdf1e0efb04a1716373646cb6f35b73addca492:

  Makefile: drop -D__CHECK_ENDIAN__ from cflags (2016-12-16 00:13:43 +0200)

----------------------------------------------------------------
virtio, vhost: new device, fixes, speedups

This includes the new virtio crypto device, and fixes all over the
place.  In particular enabling endian-ness checks for sparse builds
found some bugs which this fixes.  And it appears that everyone is in
agreement that disabling endian-ness sparse checks shouldn't be
necessary any longer.

So this enables them for everyone, and drops __CHECK_ENDIAN__
and __bitwise__ APIs.

IRQ handling in virtio has been refactored somewhat, the
larger switch to IRQ_SHARED will have to wait as
it proved too aggressive.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Christoph Hellwig (4):
      virtio_pci: use pci_alloc_irq_vectors
      virtio_pci: remove the call to vp_free_vectors in vp_request_msix_vectors
      virtio_pci: merge vp_free_vectors into vp_del_vqs
      virtio_pci: split vp_try_to_find_vqs into INTx and MSI-X variants

Felipe Franciosi (1):
      virtio_ring: fix description of virtqueue_get_buf

Gao feng (1):
      vsock: lookup and setup guest_cid inside vhost_vsock_lock

Gonglei (3):
      virtio_pci_modern: fix complaint by sparse
      virtio_ring: fix complaint by sparse
      crypto: add virtio-crypto driver

Jason Wang (2):
      vhost: cache used event for better performance
      vhost: remove unused feature bit

Mark Rutland (3):
      tools/virtio: fix READ_ONCE()
      vringh: kill off ACCESS_ONCE()
      tools/virtio: use {READ,WRITE}_ONCE() in uaccess.h

Michael S. Tsirkin (18):
      virtio_console: drop unused config fields
      drm/virtio: fix endianness in primary_plane_update
      drm/virtio: fix lock context imbalance
      drm/virtio: annotate virtio_gpu_queue_ctrl_buffer_locked
      vhost: make interval tree static inline
      vhost: add missing __user annotations
      vsock/virtio: add a missing __le annotation
      vsock/virtio: mark an internal function static
      vsock/virtio: fix src/dst cid format
      virtio: clean up handling of request_irq failure
      linux/types.h: enable endian checks for all sparse builds
      tools: enable endian checks for all sparse builds
      Documentation/sparse: drop __bitwise__
      checkpatch: replace __bitwise__ with __bitwise
      linux: drop __bitwise__ everywhere
      Documentation/sparse: drop __CHECK_ENDIAN__
      fs/logfs: drop __CHECK_ENDIAN__
      Makefile: drop -D__CHECK_ENDIAN__ from cflags

Tobias Klauser (1):
      vhost/scsi: Remove unused but set variable

Yuan Liu (1):
      virtio_mmio: Set dev.release() to avoid warning

 Documentation/translations/zh_CN/sparse.txt        |   7 +-
 arch/arm/plat-samsung/include/plat/gpio-cfg.h      |   2 +-
 drivers/crypto/virtio/virtio_crypto_common.h       | 128 +++++
 drivers/md/dm-cache-block-types.h                  |   6 +-
 drivers/net/ethernet/sun/sunhme.h                  |   2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h   |   4 +-
 drivers/vhost/vhost.h                              |   3 +
 drivers/virtio/virtio_pci_common.h                 |   1 -
 fs/logfs/logfs.h                                   |   4 +-
 include/linux/mmzone.h                             |   2 +-
 include/linux/serial_core.h                        |   4 +-
 include/linux/types.h                              |   4 +-
 include/scsi/iscsi_proto.h                         |   2 +-
 include/target/target_core_base.h                  |   2 +-
 include/uapi/linux/types.h                         |   4 -
 include/uapi/linux/vhost.h                         |   2 -
 include/uapi/linux/virtio_crypto.h                 | 450 +++++++++++++++++
 include/uapi/linux/virtio_ids.h                    |   1 +
 include/uapi/linux/virtio_types.h                  |   6 +-
 net/ieee802154/6lowpan/6lowpan_i.h                 |   2 +-
 net/mac80211/ieee80211_i.h                         |   4 +-
 tools/include/linux/types.h                        |   4 -
 tools/virtio/linux/compiler.h                      |   2 +-
 tools/virtio/linux/uaccess.h                       |   9 +-
 drivers/char/virtio_console.c                      |  14 +-
 drivers/crypto/virtio/virtio_crypto_algs.c         | 540 +++++++++++++++++++++
 drivers/crypto/virtio/virtio_crypto_core.c         | 476 ++++++++++++++++++
 drivers/crypto/virtio/virtio_crypto_mgr.c          | 264 ++++++++++
 drivers/gpu/drm/virtio/virtgpu_plane.c             |   4 +-
 drivers/gpu/drm/virtio/virtgpu_vq.c                |   6 +-
 drivers/vhost/scsi.c                               |   2 -
 drivers/vhost/vhost.c                              |  40 +-
 drivers/vhost/vringh.c                             |   5 +-
 drivers/vhost/vsock.c                              |  25 +-
 drivers/virtio/virtio_mmio.c                       |   2 +
 drivers/virtio/virtio_pci_common.c                 | 201 ++++----
 drivers/virtio/virtio_pci_modern.c                 |   8 +-
 drivers/virtio/virtio_ring.c                       |   6 +-
 net/vmw_vsock/virtio_transport.c                   |   2 +-
 net/vmw_vsock/virtio_transport_common.c            |  17 +-
 Documentation/dev-tools/sparse.rst                 |  14 +-
 MAINTAINERS                                        |   9 +
 drivers/bluetooth/Makefile                         |   2 -
 drivers/crypto/Kconfig                             |   2 +
 drivers/crypto/Makefile                            |   1 +
 drivers/crypto/virtio/Kconfig                      |  10 +
 drivers/crypto/virtio/Makefile                     |   5 +
 drivers/net/can/Makefile                           |   1 -
 drivers/net/ethernet/altera/Makefile               |   1 -
 drivers/net/ethernet/atheros/alx/Makefile          |   1 -
 drivers/net/ethernet/freescale/Makefile            |   2 -
 drivers/net/wireless/ath/Makefile                  |   2 -
 drivers/net/wireless/ath/wil6210/Makefile          |   2 -
 .../wireless/broadcom/brcm80211/brcmfmac/Makefile  |   2 -
 .../wireless/broadcom/brcm80211/brcmsmac/Makefile  |   1 -
 drivers/net/wireless/intel/iwlegacy/Makefile       |   2 -
 drivers/net/wireless/intel/iwlwifi/Makefile        |   2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/Makefile    |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/Makefile    |   2 +-
 drivers/net/wireless/intersil/orinoco/Makefile     |   3 -
 drivers/net/wireless/mediatek/mt7601u/Makefile     |   2 -
 drivers/net/wireless/realtek/rtlwifi/Makefile      |   2 -
 .../wireless/realtek/rtlwifi/btcoexist/Makefile    |   2 -
 .../wireless/realtek/rtlwifi/rtl8188ee/Makefile    |   2 -
 .../net/wireless/realtek/rtlwifi/rtl8192c/Makefile |   2 -
 .../wireless/realtek/rtlwifi/rtl8192ce/Makefile    |   2 -
 .../wireless/realtek/rtlwifi/rtl8192cu/Makefile    |   2 -
 .../wireless/realtek/rtlwifi/rtl8192de/Makefile    |   2 -
 .../wireless/realtek/rtlwifi/rtl8192ee/Makefile    |   2 -
 .../wireless/realtek/rtlwifi/rtl8192se/Makefile    |   2 -
 .../wireless/realtek/rtlwifi/rtl8723ae/Makefile    |   2 -
 .../wireless/realtek/rtlwifi/rtl8723be/Makefile    |   2 -
 .../wireless/realtek/rtlwifi/rtl8723com/Makefile   |   2 -
 .../wireless/realtek/rtlwifi/rtl8821ae/Makefile    |   2 -
 drivers/net/wireless/ti/wl1251/Makefile            |   2 -
 drivers/net/wireless/ti/wlcore/Makefile            |   2 -
 drivers/staging/rtl8188eu/Makefile                 |   2 +-
 drivers/staging/rtl8192e/Makefile                  |   2 -
 drivers/staging/rtl8192e/rtl8192e/Makefile         |   2 -
 include/uapi/linux/Kbuild                          |   1 +
 net/bluetooth/Makefile                             |   2 -
 net/ieee802154/Makefile                            |   2 -
 net/mac80211/Makefile                              |   2 +-
 net/mac802154/Makefile                             |   2 -
 net/wireless/Makefile                              |   2 -
 scripts/checkpatch.pl                              |   4 +-
 86 files changed, 2106 insertions(+), 280 deletions(-)
 create mode 100644 drivers/crypto/virtio/virtio_crypto_common.h
 create mode 100644 include/uapi/linux/virtio_crypto.h
 create mode 100644 drivers/crypto/virtio/virtio_crypto_algs.c
 create mode 100644 drivers/crypto/virtio/virtio_crypto_core.c
 create mode 100644 drivers/crypto/virtio/virtio_crypto_mgr.c
 create mode 100644 drivers/crypto/virtio/Kconfig
 create mode 100644 drivers/crypto/virtio/Makefile
