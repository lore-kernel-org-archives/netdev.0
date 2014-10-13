From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v4 00/25] virtio: fix spec compliance issues
Date: Mon, 13 Oct 2014 10:48:10 +0300
Message-ID: <1413114332-626-1-git-send-email-mst-v4@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-s390@vger.kernel.org, kvm@vger.kernel.org, linux-scsi@vger.kernel.org,
	Christian Borntraeger <borntraeger@de.ibm.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>, Amit Shah <amit.shah@redhat.com>,
	v9fs-developer@lists.sourceforge.net,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
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

Changes from v4:
	rename virtio_enable_vqs_early() to virtio_device_ready()
Note: Rusty requested we add a BUG_ON in the virtio_ring code.
	This can be done by a separate patch on top.
	Good for bisectability in case BUG_ON starts triggering :)

Rusty, please review this, and consider for this merge window.

This fixes the following virtio spec compliance issues:
1. on restore, drivers use device before setting ACKNOWLEDGE and DRIVER bits
2. on probe, drivers aren't prepared to handle config interrupts
   arriving before probe returns
3. on probe, drivers use device before DRIVER_OK it set

Note that 1 is a clear violation of virtio spec 0.9 and 1.0,
so I am proposing the fix for stable. OTOH 2 is against 1.0 rules but
is a known documented bug in many drivers, so let's fix it going
forward, but it does not seem to be worth it to backport
the changes.

An error handling bugfix for virtio-net and a fix for a
theoretical race condition in virtio scsi is also included.

2 is merely a theoretical race condition, but it seems important
to address to make sure that changes to address 3 do not introduce
instability.

I also included patch to drop scan callback use from virtio
scsi: using this callback creates asymmetry between probe
and resume, and we actually had to add code comments so
people can figure out the flow. Code flow becomes clearer
with the new API.

After this change, the only user of the scan callback is virtio rng.
It's possible to modify it trivially and then drop scan callback
from core, but I'm rather inclined to look at ways to
make some rng core changes so that we don't need to
have so many variables tracking device state.
So this is deferred for now.

Michael S. Tsirkin (24):
  virtio_pci: fix virtio spec compliance on restore
  virtio: unify config_changed handling
  virtio-pci: move freeze/restore to virtio core
  virtio: defer config changed notifications
  virtio_blk: drop config_enable
  virtio-blk: drop config_mutex
  virtio_net: drop config_enable
  virtio-net: drop config_mutex
  virtio_net: minor cleanup
  virtio: add API to enable VQs early
  virtio_net: enable VQs early
  virtio_blk: enable VQs early
  virtio_console: enable VQs early
  9p/trans_virtio: enable VQs early
  virtio_net: fix use after free on allocation failure
  virtio_scsi: move kick event out from virtscsi_init
  virtio_blk: enable VQs early on restore
  virtio_scsi: enable VQs early on restore
  virtio_console: enable VQs early on restore
  virtio_net: enable VQs early on restore
  virtio_scsi: fix race on device removal
  virtio_balloon: enable VQs early on restore
  virtio_scsi: drop scan callback
  virtio-rng: refactor probe error handling

Paolo Bonzini (1):
  virito_scsi: use freezable WQ for events

 include/linux/virtio.h              |  14 +++++
 include/linux/virtio_config.h       |  17 ++++++
 drivers/block/virtio_blk.c          |  40 ++++----------
 drivers/char/hw_random/virtio-rng.c |  15 +++---
 drivers/char/virtio_console.c       |   4 ++
 drivers/misc/mic/card/mic_virtio.c  |   6 +--
 drivers/net/virtio_net.c            |  44 +++++-----------
 drivers/s390/kvm/kvm_virtio.c       |   9 +---
 drivers/s390/kvm/virtio_ccw.c       |   6 +--
 drivers/scsi/virtio_scsi.c          |  42 +++++++++------
 drivers/virtio/virtio.c             | 102 ++++++++++++++++++++++++++++++++++++
 drivers/virtio/virtio_balloon.c     |   2 +
 drivers/virtio/virtio_mmio.c        |   7 +--
 drivers/virtio/virtio_pci.c         |  33 ++----------
 net/9p/trans_virtio.c               |   2 +
 15 files changed, 206 insertions(+), 137 deletions(-)

-- 
MST
