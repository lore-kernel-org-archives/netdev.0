From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [RFC 0/6] Add virtio transport for AF_VSOCK
Date: Wed, 27 May 2015 18:05:54 +0100
Message-ID: <1432746360-14940-1-git-send-email-stefanha@redhat.com>
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Stefan Hajnoczi <stefanha@redhat.com>
To: kvm@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40662 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753404AbbE0RGd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2015 13:06:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds a virtio transport for AF_VSOCK (net/vmw_vsock/).
AF_VSOCK is designed for communication between virtual machines and
hypervisors.  It is currently only implemented for VMware's VMCI transport.

This series implements the proposed virtio-vsock device specification from
here:
http://comments.gmane.org/gmane.comp.emulators.virtio.devel/855

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
SOCK_STREAM and SOCK_DGRAM semantics.  Applications on the host can easily
connect to guest agents because the sockets API allows multiple connections to
a listen socket (unlike virtio-serial).  This simplifies the guest<->host
communication and eliminates the need for extra processes on the host to
arbitrate virtio-serial ports.

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
  # qemu ... -device vhost-vsock-pci,id=vhost-vsock-pci0

Guest and host can communicate via AF_VSOCK sockets.  The host's CID (address)
is 2 and the guest is automatically assigned a CID (use VMADDR_CID_ANY (-1) to
bind to it).

Status
------
I am auditing and testing the code, while iterating the virtio device
specification.  There is scope to change both the implementation (these
patches) and the virtio device specification.

TODO:
 * Flexible virtqueue descriptor layout
 * Avoid Linux-specific constants in packet headers (SOCK_STREAM/SOCK_DGRAM)
 * Send RST if there is no listening SOCK_STREAM socket
 * Add missing input validation for packet headers and vhost ioctls

Asias He (6):
  VSOCK: Introduce vsock_find_unbound_socket and
    vsock_bind_dgram_generic
  Add dgram_skb to vsock_sock
  VSOCK: Introduce virtio-vsock-common.ko
  VSOCK: Introduce virtio-vsock.ko
  VSOCK: Introduce vhost-vsock.ko
  VSOCK: Add Makefile and Kconfig

 drivers/vhost/Kconfig                   |    4 +
 drivers/vhost/Kconfig.vsock             |    7 +
 drivers/vhost/Makefile                  |    4 +
 drivers/vhost/vsock.c                   |  596 +++++++++++++++
 drivers/vhost/vsock.h                   |    4 +
 include/linux/virtio_vsock.h            |  207 +++++
 include/net/af_vsock.h                  |    3 +
 include/uapi/linux/virtio_ids.h         |    1 +
 include/uapi/linux/virtio_vsock.h       |   80 ++
 net/vmw_vsock/Kconfig                   |   18 +
 net/vmw_vsock/Makefile                  |    2 +
 net/vmw_vsock/af_vsock.c                |   71 ++
 net/vmw_vsock/virtio_transport.c        |  450 +++++++++++
 net/vmw_vsock/virtio_transport_common.c | 1248 +++++++++++++++++++++++++++++++
 14 files changed, 2695 insertions(+)
 create mode 100644 drivers/vhost/Kconfig.vsock
 create mode 100644 drivers/vhost/vsock.c
 create mode 100644 drivers/vhost/vsock.h
 create mode 100644 include/linux/virtio_vsock.h
 create mode 100644 include/uapi/linux/virtio_vsock.h
 create mode 100644 net/vmw_vsock/virtio_transport.c
 create mode 100644 net/vmw_vsock/virtio_transport_common.c

-- 
2.4.1
