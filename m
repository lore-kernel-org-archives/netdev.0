From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] virtio/vhost: new features, performance improvements, cleanups
Date: Sun, 20 Mar 2016 15:58:48 +0200
Message-ID: <20160320155848-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pmladek@suse.com, kvm@vger.kernel.org, geliangtang@163.com,
	netdev@vger.kernel.org, mst@redhat.com,
	sebott@linux.vnet.ibm.com, linux-kernel@vger.kernel.org,
	pmladek@suse.cz, virtualization@lists.linux-foundation.org,
	borntraeger@de.ibm.com, luto@kernel.org, pbonzini@redhat.com,
	pabeni@redhat.com, schwidefsky@de.ibm.com, gkurz@linux.vnet.ibm.com
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

The following changes since commit e1f33be9186363da7955bcb5f0b03e6685544c50:

  vhost: fix error path in vhost_init_used() (2016-03-02 17:01:49 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to c67f5db82027ba6d2ea4ac9176bc45996a03ae6a:

  virtio_net: replace netdev_alloc_skb_ip_align() with napi_alloc_skb() (2016-03-17 17:42:00 +0200)

----------------------------------------------------------------
virtio/vhost: new features, performance improvements, cleanups

This adds basic polling support for vhost.
Reworks virtio to optionally use DMA API, fixing it on Xen.
Balloon stats gained a new entry.
Using the new napi_alloc_skb speeds up virtio net.
virtio blk stats can now be read while another VCPU
us busy inflating or deflating the balloon.
Plus misc cleanups in various places.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Andy Lutomirski (6):
      vring: Introduce vring_use_dma_api()
      virtio_ring: Support DMA APIs
      virtio: Add improved queue allocation API
      virtio_mmio: Use the DMA API if enabled
      virtio_pci: Use the DMA API if enabled
      vring: Use the DMA API on Xen

Christian Borntraeger (3):
      dma: Provide simple noop dma ops
      alpha/dma: use common noop dma ops
      s390/dma: Allow per device dma ops

Cornelia Huck (1):
      virtio/s390: size of SET_IND payload

Geliang Tang (1):
      virtio/s390: use dev_to_virtio

Greg Kurz (2):
      vhost: rename cross-endian helpers
      vhost: rename vhost_init_used()

Jason Wang (3):
      vhost: introduce vhost_has_work()
      vhost: introduce vhost_vq_avail_empty()
      vhost_net: basic polling support

Michael S. Tsirkin (1):
      virtio_blk: VIRTIO_BLK_F_WCE->VIRTIO_BLK_F_FLUSH

Paolo Abeni (1):
      virtio_net: replace netdev_alloc_skb_ip_align() with napi_alloc_skb()

Petr Mladek (2):
      virtio_balloon: Use a workqueue instead of "vballoon" kthread
      virtio_balloon: Allow to resize and update the balloon stats in parallel

 arch/s390/include/asm/device.h      |   6 +-
 arch/s390/include/asm/dma-mapping.h |   6 +-
 drivers/vhost/vhost.h               |   5 +-
 drivers/virtio/virtio_pci_common.h  |   6 -
 include/linux/dma-mapping.h         |   2 +
 include/linux/virtio.h              |  23 +-
 include/linux/virtio_ring.h         |  35 +++
 include/uapi/linux/vhost.h          |   6 +
 include/uapi/linux/virtio_blk.h     |   6 +-
 tools/virtio/linux/dma-mapping.h    |  17 ++
 arch/alpha/kernel/pci-noop.c        |  46 +---
 arch/s390/pci/pci.c                 |   1 +
 arch/s390/pci/pci_dma.c             |   4 +-
 drivers/block/virtio_blk.c          |  11 +-
 drivers/net/virtio_net.c            |   2 +-
 drivers/s390/virtio/virtio_ccw.c    |  15 +-
 drivers/vhost/net.c                 |  80 ++++++-
 drivers/vhost/scsi.c                |   2 +-
 drivers/vhost/test.c                |   2 +-
 drivers/vhost/vhost.c               |  69 +++++-
 drivers/virtio/virtio_balloon.c     | 122 +++++-----
 drivers/virtio/virtio_mmio.c        |  67 ++----
 drivers/virtio/virtio_pci_legacy.c  |  42 ++--
 drivers/virtio/virtio_pci_modern.c  |  61 ++---
 drivers/virtio/virtio_ring.c        | 439 +++++++++++++++++++++++++++++++-----
 lib/dma-noop.c                      |  75 ++++++
 arch/s390/Kconfig                   |   5 +-
 drivers/virtio/Kconfig              |   2 +-
 lib/Makefile                        |   1 +
 29 files changed, 823 insertions(+), 335 deletions(-)
 create mode 100644 tools/virtio/linux/dma-mapping.h
 create mode 100644 lib/dma-noop.c
