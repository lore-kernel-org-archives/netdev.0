From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v5 0/3] VSOCK: vsockmon virtual device to monitor AF_VSOCK sockets.
Date: Fri, 21 Apr 2017 10:10:43 +0100
Message-ID: <20170421091046.5599-1-stefanha@redhat.com>
Cc: Zhu Yanjun <zyjzyj2000@gmail.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Gerard Garcia <ggarcia@abra.uab.cat>,
        Jorgen Hansen <jhansen@vmware.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38680 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1037028AbdDUJLC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Apr 2017 05:11:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v5:
 * Change vsock_deliver_tap() API to avoid unnecessary skb creation
   [Jorgen]
 * Fix skb leak when no taps are registered [Jorgen]
 * s/cpu_to_le16(pkt->hdr.op)/le16_to_cpu(pkt->hdr.op)/ [Michael]
 * Add af_vsock_tap.c and vsockmon.[ch] to MAINTAINERS
 * checkpatch.pl and sparse fixes

v4:
 * Add explicit reserved padding field to struct af_vsockmon_hdr and
   drop __attribute__((packed)) [Michael, DaveM]
 * Call synchronize_net() before module_put() [Michael]

v3:
 * Hook virtio_transport.c (guest driver), not just drivers/vhost/vsock.c (host
   driver)
 * Fix DEFAULT_MTU macro definition [Zhu Yanjun]
 * Rename af_vsockmon_hdr->t field ->transport for clarity
 * Update .ndo_get_stats64() return type since it has changed
 * Include missing <linux/module.h> header in af_vsock_tap.c

This is a continuation of Gerard Garcia's work on the vsockmon packet capture
interface for AF_VSOCK.  Packet capture is an essential feature for network
communication.  Gerard began addressing this feature gap in his Google Summer
of Code 2016 project.  I have cleaned up, rebased, and retested the v2 series
he posted previously.

The design follows the nlmon packet capture interface closely.  This is because
vsock has the same problem as netlink: there is no netdev on which packets can
be captured.  The nlmon driver is a synthetic netdev purely for the purpose of
enabling packet capture.  We follow the same approach here with vsockmon.

See include/uapi/linux/vsockmon.h in this series for details on the packet
layout.

How to try it:

1. Build tcpdump with vsockmon patches:

  $ git clone -b vsock https://github.com/stefanha/libpcap
  $ (cd libcap && ./configure && make)
  $ git clone -b vsock https://github.com/stefanha/tcpdump
  $ (cd tcpdump && ./configure && make)

2. Build nc-vsock (a netcat-like tool):

  $ git clone https://github.com/stefanha/nc-vsock
  $ (cd nc-vsock && make)

3. Launch a virtual machine:

  # modprobe vhost_vsock
  # qemu-system-x86_64 -M accel=kvm -m 1024 -cpu host \
      -drive if=virtio,file=test.img,format=raw \
      -device vhost-vsock-pci,guest-cid=3

  (Assumes guest is running a kernel with this patch)

4. Capture AF_VSOCK traffic in guest and/or host:

  # modprobe vsockmon
  # ip link add type vsockmon
  # ip link set vsockmon0 up
  # tcpdump -i vsockmon0 -vvv

5. Communicate!

  (host)$ nc-vsock -l 1234
  (guest)$ nc-vsock 2 1234

Gerard Garcia (3):
  VSOCK: Add vsockmon tap functions
  VSOCK: Add vsockmon device
  VSOCK: Add virtio vsock vsockmon hooks

 MAINTAINERS                             |   3 +
 drivers/net/Makefile                    |   1 +
 net/vmw_vsock/Makefile                  |   2 +-
 include/linux/virtio_vsock.h            |   1 +
 include/net/af_vsock.h                  |  13 +++
 include/uapi/linux/if_arp.h             |   1 +
 include/uapi/linux/vsockmon.h           |  60 +++++++++++
 drivers/net/vsockmon.c                  | 170 ++++++++++++++++++++++++++++++++
 drivers/vhost/vsock.c                   |   8 ++
 net/vmw_vsock/af_vsock_tap.c            | 114 +++++++++++++++++++++
 net/vmw_vsock/virtio_transport.c        |   3 +
 net/vmw_vsock/virtio_transport_common.c |  64 ++++++++++++
 drivers/net/Kconfig                     |   8 ++
 include/uapi/linux/Kbuild               |   1 +
 14 files changed, 448 insertions(+), 1 deletion(-)
 create mode 100644 include/uapi/linux/vsockmon.h
 create mode 100644 drivers/net/vsockmon.c
 create mode 100644 net/vmw_vsock/af_vsock_tap.c

-- 
2.9.3
