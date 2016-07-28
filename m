From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [RFC v6 0/6] Add virtio transport for AF_VSOCK
Date: Thu, 28 Jul 2016 15:36:29 +0100
Message-ID: <1469716595-13591-1-git-send-email-stefanha@redhat.com>
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	Matt Benjamin <mbenjamin@redhat.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	=?UTF-8?q?Alex=20Benn=C3=A9e?= <alex.bennee@linaro.org>,
	marius vlad <marius.vlad0@gmail.com>, areis@redhat.com,
	Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	Ian Campbell <ian.campbell@docker.com>, ggarcia@abra.uab.cat,
	virtualization@lists.linux-foundation.org,
	Stefan Hajnoczi <stefanha@redhat.com>
To: kvm@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42060 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758665AbcG1Ogj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jul 2016 10:36:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series is based on v4.7.

This RFC is the implementation for the new VIRTIO Socket device.  It is
developed in parallel with the VIRTIO device specification and proves the
design.  Once the specification has been accepted I will send a non-RFC version
of this patch series.

v6:
 * Add VHOST_VSOCK_SET_RUNNING ioctl to start/stop vhost cleanly
 * Add graceful shutdown to avoid port reuse while peer is still closing
   socket [Ian Campbell]
 * Start/stop rx depending on reply packet accounting to bound memory
   allocation if the host is not processing rx packets
 * Use send_pkt_list to defer transmission
 * Use spinlocks instead of mutexes for tx_lock/rx_lock because they are
   used in sections that are not allowed to sleep. [Claudio]
 * 64-bit CIDs in virtio_vsock.h to match virtio-vsock specification
 * Move duplicated send_pkt() logic from vhost and virtio transports
   into virtio_transport_common.ko
 * ...and more, see individual patch changelogs

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

Much of the work was done by Asias He and Gerd Hoffmann a while back.  I have
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

See http://qemu-project.org/Features/VirtioVsock for more info.

Asias He (4):
  VSOCK: Introduce virtio_vsock_common.ko
  VSOCK: Introduce virtio_transport.ko
  VSOCK: Introduce vhost_vsock.ko
  VSOCK: Add Makefile and Kconfig

Stefan Hajnoczi (2):
  VSOCK: transport-specific vsock_transport functions
  VSOCK: defer sock removal to transports

 MAINTAINERS                                        |  13 +
 drivers/vhost/Kconfig                              |  15 +
 drivers/vhost/Makefile                             |   4 +
 drivers/vhost/vsock.c                              | 722 +++++++++++++++
 include/linux/virtio_vsock.h                       | 154 ++++
 include/net/af_vsock.h                             |   6 +
 .../trace/events/vsock_virtio_transport_common.h   | 144 +++
 include/uapi/linux/Kbuild                          |   1 +
 include/uapi/linux/vhost.h                         |   5 +
 include/uapi/linux/virtio_ids.h                    |   1 +
 include/uapi/linux/virtio_vsock.h                  |  94 ++
 net/vmw_vsock/Kconfig                              |  20 +
 net/vmw_vsock/Makefile                             |   6 +
 net/vmw_vsock/af_vsock.c                           |  25 +-
 net/vmw_vsock/virtio_transport.c                   | 624 +++++++++++++
 net/vmw_vsock/virtio_transport_common.c            | 992 +++++++++++++++++++++
 net/vmw_vsock/vmci_transport.c                     |   2 +
 17 files changed, 2822 insertions(+), 6 deletions(-)
 create mode 100644 drivers/vhost/vsock.c
 create mode 100644 include/linux/virtio_vsock.h
 create mode 100644 include/trace/events/vsock_virtio_transport_common.h
 create mode 100644 include/uapi/linux/virtio_vsock.h
 create mode 100644 net/vmw_vsock/virtio_transport.c
 create mode 100644 net/vmw_vsock/virtio_transport_common.c

-- 
2.7.4
