From: ggarcia@abra.uab.cat
Subject: [PATCH v2 0/3] VSOCK: vsockmon virtual device to monitor AF_VSOCK
 sockets.
Date: Sat, 13 Aug 2016 12:21:51 +0200
Message-ID: <20160813102154.14338-1-ggarcia@deic.uab.cat>
Content-Transfer-Encoding: 7BIT
Cc: stefanha@redhat.com, mst@redhat.com,
	Gerard Garcia <ggarcia@abra.uab.cat>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from damascus.uab.es ([158.109.168.135]:24466 "EHLO damascus.uab.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752135AbcHMKWC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Aug 2016 06:22:02 -0400
Received: from damascus.uab.es ([127.0.0.1])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OBU00K48FGNJO10@damascus.uab.es> for
 netdev@vger.kernel.org; Sat, 13 Aug 2016 12:21:59 +0200 (CEST)
Received: from abra.uab.es ([158.109.79.4])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OBU00F8CFGNC350@damascus.uab.es> for
 netdev@vger.kernel.org; Sat, 13 Aug 2016 12:21:59 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerard Garcia <ggarcia@deic.uab.cat>

This patch applies over the mst vhost git repository:
http://git.kernel.org/cgit/linux/kernel/git/mst/vhost.git

v2:
 * Clone skb before transmitting them to vsockmon.
 * Use consume_skb() instead of kfree_skb().
 * Pass skb lifetime responsibility to tap functions.
 * Remove t_hdr member from vsockmon header to avoid problems when/if it
    changes it size if more transports are supported.

This was already been sent as a RFC where several issues where fixed.
This is the summary of changes from the first RFC:

v2:
 * Do not clone skb, instead take ownership before transmitting.
 * Split tap functions from af_vsock.c.
 * Simplify vsockmon header to remove unnecessary padding and
    set little endian byte order.
 * Various simple fixes from the comments received to the first RFC.

Additionally, first pach version changes:
 * Add len field to the vsockmon header to ease parsing.
 * Pack vsockmon header.
 * Various simple fixes and styling.

Overview:

Virtual socket transports operate at kernel level therefore, there is no easy
way to see the traffic exchanged between virtual machines and hypervisors that
communicate using AF_VSOCK sockets. In addition, being able to see the control
messages exchanged by the transports may be useful for debugging and
optimization purposes. This patch adds a virtual device that may be used to see
the traffic exchanged between virtual machines and hypervisors through AF_VSOCK
sockets.

Its structure is based on the nlmon device and this version just targets the
virtio transport, but support for the VMCI transport can be easily implemented.
The vsockmon header contains a generic header and includes the header specific to
the transport. The generic header allows to follow an AF_VSOCK stream without
having to dig into the details of the transport while the transport header
gives more detail which may be useful for troubleshooting and debugging.

Testing:

To set up a vsockmon device:

ip link add type vsockmon
ip link set vsockmon0 up

The Wireshark development version (master branch) includes a vsock dissector
that is capable of parsing packets received through vsockmon. The dissector
needs to be manually selected.

Thanks to Stefan Hajnoczi for his help.

Gerard Garcia (3):
  VSOCK: Add vsockmon tap functions
  VSOCK: Add vsockmon device
  VSOCK: Add virtio vsock vsockmon hooks

 drivers/net/Kconfig           |   8 ++
 drivers/net/Makefile          |   1 +
 drivers/net/vsockmon.c        | 168 ++++++++++++++++++++++++++++++++++++++++++
 drivers/vhost/vsock.c         |  72 ++++++++++++++++++
 include/net/af_vsock.h        |  13 ++++
 include/uapi/linux/Kbuild     |   1 +
 include/uapi/linux/if_arp.h   |   1 +
 include/uapi/linux/vsockmon.h |  38 ++++++++++
 net/vmw_vsock/Makefile        |   2 +-
 net/vmw_vsock/af_vsock_tap.c  | 113 ++++++++++++++++++++++++++++
 10 files changed, 416 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/vsockmon.c
 create mode 100644 include/uapi/linux/vsockmon.h
 create mode 100644 net/vmw_vsock/af_vsock_tap.c

-- 
2.9.1
