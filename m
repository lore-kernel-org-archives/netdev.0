From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v3 0/4] Add virtio transport for AF_VSOCK
Date: Wed,  9 Dec 2015 20:03:49 +0800
Message-ID: <1449662633-26623-1-git-send-email-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stefan Hajnoczi <stefanha@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Matt Benjamin <mbenjamin@redhat.com>,
	Christoffer Dall <christoffer.dall@linaro.org>, matt.ma@linaro.org
To: kvm@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

Note: the virtio-vsock device specification is currently under review but not
yet finalized.  Please review this code but don't merge until I send an update
when the spec is finalized.  Thanks!

v3:
 * Remove unnecessary 3-way handshake, just do REQUEST/RESPONSE instead
   of REQUEST/RESPONSE/ACK
 * Remove SOCK_DGRAM support and focus on SOCK_STREAM first
   (also drop v2 Patch 1, it's only needed for SOCK_DGRAM)
 * Only allow host->guest connections (same security model as latest
   VMware)
 * Don't put vhost vsock driver into staging
 * Add missing Kconfig dependencies (Arnd Bergmann <arnd@arndb.de>)
 * Remove unneeded variable used to store return value
   (Fengguang Wu <fengguang.wu@intel.com> and Julia Lawall
   <julia.lawall@lip6.fr>)

v2:
 * Rebased onto Linux v4.4-rc2
 * vhost: Refuse to assign reserved CIDs
 * vhost: Refuse guest CID if already in use
 * vhost: Only accept correctly addressed packets (no spoofing!)
 * vhost: Support flexible rx/tx descriptor layout
 * vhost: Add missing total_tx_buf decrement
 * virtio_transport: Fix total_tx_buf accounting
 * virtio_transport: Add virtio_transport global mutex to prevent races
 * common: Notify other side of SOCK_STREAM disconnect (fixes shutdown
   semantics)
 * common: Avoid recursive mutex_lock(tx_lock) for write_space (fixes deadlock)
 * common: Define VIRTIO_VSOCK_TYPE_STREAM/DGRAM hardware interface constants
 * common: Define VIRTIO_VSOCK_SHUTDOWN_RCV/SEND hardware interface constants
 * common: Fix peer_buf_alloc inheritance on child socket

This patch series adds a virtio transport for AF_VSOCK (net/vmw_vsock/).
AF_VSOCK is designed for communication between virtual machines and
hypervisors.  It is currently only implemented for VMware's VMCI transport.

This series implements the proposed virtio-vsock device specification from
here:
http://permalink.gmane.org/gmane.comp.emulators.virtio.devel/980

Most of the work was done by Asias He and Gerd Hoffmann a while back.  I have
picked up the series again.

The QEMU userspace changes are here:
https://github.com/stefanha/qemu/commits/vsock

Why virtio-vsock?
-----------------
Guest<->host communication is currently done over the virtio-serial device.
This makes it hard to port sockets API-based applications and is limited to
static ports.

virtio-vsock uses the sockets API so that applications can rely on familiar
SOCK_STREAM semantics.  Applications on the host can easily connect to guest
agents because the sockets API allows multiple connections to a listen socket
(unlike virtio-serial).  This simplifies the guest<->host communication and
eliminates the need for extra processes on the host to arbitrate virtio-serial
ports.

Overview
--------
This series adds 3 pieces:

1. virtio_transport_common.ko - core virtio vsock code that uses vsock.ko

2. virtio_transport.ko - guest driver

3. drivers/vhost/vsock.ko - host driver

Howto
-----
The following kernel options are needed:
  CONFIG_VSOCKETS=y
  CONFIG_VIRTIO_VSOCKETS=y
  CONFIG_VIRTIO_VSOCKETS_COMMON=y
  CONFIG_VHOST_VSOCK=m

Launch QEMU as follows:
  # qemu ... -device vhost-vsock-pci,id=vhost-vsock-pci0,guest-cid=3

Guest and host can communicate via AF_VSOCK sockets.  The host's CID (address)
is 2 and the guest must be assigned a CID (3 in the example above).

Status
------
This patch series implements the latest draft specification.  Please review.

Asias He (4):
  VSOCK: Introduce virtio-vsock-common.ko
  VSOCK: Introduce virtio-vsock.ko
  VSOCK: Introduce vhost-vsock.ko
  VSOCK: Add Makefile and Kconfig

 drivers/vhost/Kconfig                   |  10 +
 drivers/vhost/Makefile                  |   4 +
 drivers/vhost/vsock.c                   | 628 +++++++++++++++++++++++
 drivers/vhost/vsock.h                   |   4 +
 include/linux/virtio_vsock.h            | 203 ++++++++
 include/uapi/linux/virtio_ids.h         |   1 +
 include/uapi/linux/virtio_vsock.h       |  87 ++++
 net/vmw_vsock/Kconfig                   |  18 +
 net/vmw_vsock/Makefile                  |   2 +
 net/vmw_vsock/virtio_transport.c        | 466 +++++++++++++++++
 net/vmw_vsock/virtio_transport_common.c | 854 ++++++++++++++++++++++++++++++++
 11 files changed, 2277 insertions(+)
 create mode 100644 drivers/vhost/vsock.c
 create mode 100644 drivers/vhost/vsock.h
 create mode 100644 include/linux/virtio_vsock.h
 create mode 100644 include/uapi/linux/virtio_vsock.h
 create mode 100644 net/vmw_vsock/virtio_transport.c
 create mode 100644 net/vmw_vsock/virtio_transport_common.c

-- 
2.5.0
