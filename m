From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH V5 0/9] introduce Hyper-V VM Sockets(hvsock
Date: Thu, 24 Dec 2015 06:12:23 -0800
Message-ID: <1450966343-13035-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pebolle@tiscali.nl, dan.carpenter@oracle.com, stefanha@redhat.com
To: gregkh@linuxfoundation.org, davem@davemloft.net,
 stephen@networkplumber.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, driverdev-devel@linuxdriverproject.org,
 olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com, kys@microsoft.com
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

Merry Christmas, everyone!

Changes since v1:
- updated "[PATCH 6/7] hvsock: introduce Hyper-V VM Sockets feature"
- added __init and __exit for the module init/exit functions
- net/hv_sock/Kconfig: "default m" -> "default m if HYPERV"
- MODULE_LICENSE: "Dual MIT/GPL" -> "Dual BSD/GPL" 

Changes since v2:
- fixed various coding issue pointed out by David Miller
- fixed indentation issues
- removed pr_debug in net/hv_sock/af_hvsock.c
- used reverse-Chrismas-tree style for local variables.
- EXPORT_SYMBOL -> EXPORT_SYMBOL_GPL

Changes since v3:
- fixed a few coding issue pointed by Vitaly Kuznetsov and Dan Carpenter
- fixed the ret value in vmbus_recvpacket_hvsock on error
- fixed the style of multi-line comment: vmbus_get_hvsock_rw_status()

Changes since v4 (https://lkml.org/lkml/2015/7/28/404):
- addressed all the comments about V4.
- treat the hvsock offers/channels as special VMBus devices
- add a mechanism to pass hvsock events to the hvsock driver
- fixed some corner cases with proper locking when a connection is closed
- rebased to the latest Greg's tree

Hyper-V VM Sockets (hvsock) is a byte-stream based communication mechanism
between Windowsd 10 (or later) host and a guest. It's kind of TCP over
VMBus, but the transportation layer (VMBus) is much simpler than IP.
With Hyper-V VM Sockets, applications between the host and a guest can
talk with each other directly by the traditional BSD-style socket APIs.

The patchset implements the necessary support in the guest side by adding
the necessary new APIs in the vmbus driver, and introducing a new driver
hv_sock.ko, which implements_a new socket address family AF_HYPERV.

I know the kernel has already had a VM Sockets driver (AF_VSOCK) based
on VMware's VMCI (net/vmw_vsock/, drivers/misc/vmw_vmci), and KVM is
proposing AF_VSOCK of virtio version:
http://thread.gmane.org/gmane.linux.network/365205.

However, though Hyper-V VM Sockets may seem conceptually similar to
AF_VOSCK, there are differences in the transportation layer, and IMO these
make the direct code reusing impractical:

1. In AF_VSOCK, the endpoint type is: <u32 ContextID, u32 Port>, but in
AF_HYPERV, the endpoint type is: <GUID VM_ID, GUID ServiceID>. Here GUID
is 128-bit.

2. AF_VSOCK supports SOCK_DGRAM, while AF_HYPERV doesn't.

3. AF_VSOCK supports some special sock opts, like SO_VM_SOCKETS_BUFFER_SIZE,
SO_VM_SOCKETS_BUFFER_MIN/MAX_SIZE and SO_VM_SOCKETS_CONNECT_TIMEOUT.
These are meaningless to AF_HYPERV.

4. Some AF_VSOCK's VMCI transportation ops are meanless to AF_HYPERV/VMBus,
like    .notify_recv_init
        .notify_recv_pre_block
        .notify_recv_pre_dequeue
        .notify_recv_post_dequeue
        .notify_send_init
        .notify_send_pre_block
        .notify_send_pre_enqueue
        .notify_send_post_enqueue
etc.

So I think we'd better introduce a new address family: AF_HYPERV.

Please review the patchset.

Looking forward to your comments!

Dexuan Cui (9):
  Drivers: hv: vmbus: add a helper function to set a channel's pending
    send size
  Drivers: hv: vmbus: define the new offer type for Hyper-V socket
    (hvsock)
  Drivers: hv: vmbus: define a new VMBus message type for hvsock
  Drivers: hv: ring_buffer: enhance hv_ringbuffer_read() to support
    hvsock
  Drivers: hv: vmbus: add APIs to send/recv hvsock packets
  Drivers: hv: vmbus: add a hvsock flag in struct hv_driver
  Drivers: hv: vmbus: add a mechanism to pass hvsock events to the
    hvsock driver
  Drivers: hv: vmbus: add an API vmbus_hvsock_device_unregister()
  hvsock: introduce Hyper-V VM Sockets feature

 MAINTAINERS                 |    2 +
 drivers/hv/channel.c        |   84 ++-
 drivers/hv/channel_mgmt.c   |   53 +-
 drivers/hv/connection.c     |    4 +-
 drivers/hv/hyperv_vmbus.h   |   13 +-
 drivers/hv/ring_buffer.c    |   54 +-
 drivers/hv/vmbus_drv.c      |    4 +
 include/linux/hyperv.h      |   88 +++
 include/linux/socket.h      |    4 +-
 include/net/af_hvsock.h     |   44 ++
 include/uapi/linux/hyperv.h |   16 +
 net/Kconfig                 |    1 +
 net/Makefile                |    1 +
 net/hv_sock/Kconfig         |   10 +
 net/hv_sock/Makefile        |    3 +
 net/hv_sock/af_hvsock.c     | 1473 +++++++++++++++++++++++++++++++++++++++++++
 16 files changed, 1830 insertions(+), 24 deletions(-)
 create mode 100644 include/net/af_hvsock.h
 create mode 100644 net/hv_sock/Kconfig
 create mode 100644 net/hv_sock/Makefile
 create mode 100644 net/hv_sock/af_hvsock.c

-- 
2.1.4
