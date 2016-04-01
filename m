From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [RFC v5 0/5] Add virtio transport for AF_VSOCK
Date: Fri,  1 Apr 2016 15:23:02 +0100
Message-ID: <1459520587-12337-1-git-send-email-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: marius vlad <marius.vlad0@gmail.com>, Stefan Hajnoczi <stefanha@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Ian Campbell <ian.campbell@docker.com>,
	Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>,
	Matt Benjamin <mbenjamin@redhat.com>, Greg Kurz <gkurz@linux.vnet.ibm.com>,
	virtualization@lists.linux-foundation.org,
	Christoffer Dall <christoffer.dall@linaro.org>
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

This series is based on Michael Tsirkin's vhost branch (v4.5-rc6).

I'm about to process Claudio Imbrenda's locking fixes for virtio-vsock but
first I want to share the latest version of the code.  Several people are
playing with vsock now so sharing the latest code should avoid duplicate work.

v5:
 * Transport reset event for live migration support
 * Reorder virtqueues, drop unused ctrl virtqueue
 * Switch to a free virtio device ID
 * More small changes, see patches for individual items

v4:
 * Addressed code review comments from Alex Bennee
 * MAINTAINERS file entries for new files
 * Trace events instead of pr_debug()
 * RST packet is sent when there is no listen socket
 * Allow guest->host connections again (began discussing netfilter support with
   Matt Benjamin instead of hard-coding security policy in virtio-vsock code)
 * Many checkpatch.pl cleanups (will be 100% clean in v5)

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

Asias He (4):
  VSOCK: Introduce virtio_vsock_common.ko
  VSOCK: Introduce virtio_transport.ko
  VSOCK: Introduce vhost_vsock.ko
  VSOCK: Add Makefile and Kconfig

Stefan Hajnoczi (1):
  VSOCK: transport-specific vsock_transport functions

 MAINTAINERS                                        |  13 +
 drivers/vhost/Kconfig                              |  15 +
 drivers/vhost/Makefile                             |   4 +
 drivers/vhost/vsock.c                              | 694 +++++++++++++++++
 drivers/vhost/vsock.h                              |   5 +
 include/linux/virtio_vsock.h                       | 167 ++++
 include/net/af_vsock.h                             |   3 +
 .../trace/events/vsock_virtio_transport_common.h   | 144 ++++
 include/uapi/linux/virtio_ids.h                    |   1 +
 include/uapi/linux/virtio_vsock.h                  |  94 +++
 net/vmw_vsock/Kconfig                              |  19 +
 net/vmw_vsock/Makefile                             |   2 +
 net/vmw_vsock/af_vsock.c                           |   9 +
 net/vmw_vsock/virtio_transport.c                   | 584 ++++++++++++++
 net/vmw_vsock/virtio_transport_common.c            | 838 +++++++++++++++++++++
 15 files changed, 2592 insertions(+)
 create mode 100644 drivers/vhost/vsock.c
 create mode 100644 drivers/vhost/vsock.h
 create mode 100644 include/linux/virtio_vsock.h
 create mode 100644 include/trace/events/vsock_virtio_transport_common.h
 create mode 100644 include/uapi/linux/virtio_vsock.h
 create mode 100644 net/vmw_vsock/virtio_transport.c
 create mode 100644 net/vmw_vsock/virtio_transport_common.c

-- 
2.5.5
