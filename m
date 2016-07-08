From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH v15 net-next 0/1] introduce Hyper-V VM Sockets(hv_sock)
Date: Fri, 8 Jul 2016 07:44:26 +0000
Message-ID: <CO2PR03MB21820CED1742C063048CC9A0BF3C0@CO2PR03MB2182.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Haiyang Zhang <haiyangz@microsoft.com>, Dave Scott <dave.scott@docker.com>
To: "davem@davemloft.net" <davem@davemloft.net>, "gregkh@linuxfoundation.org"
 <gregkh@linuxfoundation.org>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org"
 <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>,
 "apw@canonical.com" <apw@canonical.com>, "jasowang@redhat.com"
 <jasowang@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Cathy Avery
 <cavery@redhat.com>, KY Srinivasan <kys@microsoft.com>, "joe@perches.com"
 <joe@perches.com>, Rolf Neugebauer <rolf.neugebauer@docker.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Language: en-US
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

Hyper-V Sockets (hv_sock) supplies a byte-stream based communication
mechanism between the host and the guest. It's somewhat like TCP over
VMBus, but the transportation layer (VMBus) is much simpler than IP.

With Hyper-V Sockets, applications between the host and the guest can talk
to each other directly by the traditional BSD-style socket APIs.

Hyper-V Sockets is only available on new Windows hosts, like Windows Server
2016. More info is in this article "Make your own integration services":
https://msdn.microsoft.com/en-us/virtualization/hyperv_on_windows/develop/make_mgmt_service

The patch implements the necessary support in the guest side by
introducing a new socket address family AF_HYPERV.

You can also get the patch by:
https://github.com/dcui/linux/commits/decui/hv_sock/net-next/20160708_v15

Note: the VMBus driver side's supporting patches have been in the mainline
tree.

I know the kernel has already had a VM Sockets driver (AF_VSOCK) based
on VMware VMCI (net/vmw_vsock/, drivers/misc/vmw_vmci), and KVM is
proposing AF_VSOCK of virtio version:
http://marc.info/?l=linux-netdev&m=145952064004765&w=2

However, though Hyper-V Sockets may seem conceptually similar to
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
like .notify_recv_init
.notify_recv_pre_block
.notify_recv_pre_dequeue
.notify_recv_post_dequeue
.notify_send_init
.notify_send_pre_block
.notify_send_pre_enqueue
.notify_send_post_enqueue
etc.

So I think we'd better introduce a new address family: AF_HYPERV.

Please review the patch.

Looking forward to your comments, especially comments from David. :-)

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

Changes since v5 (https://lkml.org/lkml/2015/12/24/103):
- addressed the coding style issues (Vitaly Kuznetsov & David Miller, thanks!)
- used a better coding for the per-channel rescind callback (Thank Vitaly!)
- avoided the introduction of new VMBUS driver APIs vmbus_sendpacket_hvsock()
and vmbus_recvpacket_hvsock() and used vmbus_sendpacket()/vmbus_recvpacket()
in the higher level (i.e., the vmsock driver). Thank Vitaly!

Changes since v6 (http://lkml.iu.edu/hypermail/linux/kernel/1601.3/01813.html)
- only a few minor changes of coding style and comments

Changes since v7
- a few minor changes of coding style: thanks, Joe Perches!
- added some lines of comments about GUID/UUID before the struct sockaddr_hv.

Changes since v8
- removed the unnecessary __packed for some definitions: thanks, David!
- hvsock_open_connection:  use offer.u.pipe.user_def[0] to know the connection
and reorganized the function
direction 
- reorganized the code according to suggestions from Cathy Avery: split big
functions into small ones, set .setsockopt and getsockopt to
sock_no_setsockopt/sock_no_getsockopt
- inline'd some small list helper functions

Changes since v9
- minimized struct hvsock_sock by making the send/recv buffers pointers.
   the buffers are allocated by kmalloc() in __hvsock_create() now.
- minimized the sizes of the send/recv buffers and the vmbus ringbuffers.

Changes since v10

1) add module params: send_ring_page, recv_ring_page. They can be used to
enlarge the ringbuffer size to get better performance, e.g.,
# modprobe hv_sock  recv_ring_page=16 send_ring_page=16
By default, recv_ring_page is 3 and send_ring_page is 2.

2) add module param max_socket_number (the default is 1024).
A user can enlarge the number to create more than 1024 hv_sock sockets.
By default, 1024 sockets take about 1024 * (3+2+1+1) * 4KB = 28M bytes.
(Here 1+1 means 1 page for send/recv buffers per connection, respectively.)

3) implement the TODO in hvsock_shutdown().

4) fix a bug in hvsock_close_connection():
   I remove "sk->sk_socket->state = SS_UNCONNECTED;" -- actually this line
is not really useful. For a connection triggered by a host app's connect(),
sk->sk_socket remains NULL before the connection is accepted by the server
app (in Linux VM): see hvsock_accept() -> hvsock_accept_wait() ->
sock_graft(connected, newsock). If the host app exits before the server
app's accept() returns, the host can send a rescind-message to close the
connection and later in the Linux VM's message handler 
i.e. vmbus_onoffer_rescind()), Linux will get a NULL de-referencing crash. 

5) fix a bug in hvsock_open_connection()
  I move the vmbus_set_chn_rescind_callback() to a later place, because
when vmbus_open() fails, hvsock_close_connection() can do nothing and we
count on vmbus_onoffer_rescind() -> vmbus_device_unregister() to clean up
the device.

6) some stylistic modificiation.


Changes since v11:
1) remove the module params as David suggested.

2) use 5 exact pages for VMBus send/recv rings, respectively.
The host side's design of the feature requires 5 exact pages for recv/send
rings respectively -- this is suboptimal considering memory consumption,
however unluckily we have to live with it, before the host comes up with
a new design in the future. :-(

3) remove the per-connection static send/recv buffers
Instead, we allocate and free the buffers dynamically only when we recv/send
data. This means: when a connection is idle, no memory is consumed as
recv/send buffers at all.
Dexuan Cui (1):
  hv_sock: introduce Hyper-V Sockets

Changes since v12:
return ENOMEM on buffer alllocation failure

   Actually "man read/write" says "Other errors may occur, depending on the
object connected to fd". "man send/recv" indeed lists ENOMEM.
   Considering AF_HYPERV is a new socket type, ENOMEM seems OK here.
   In the long run, I think we should add a new API in the VMBus driver,
allowing data copy from VMBus ringbuffer into user mode buffer directly.
This way, we can even eliminate this temporary buffer.

Changes since v13:
fix some coding style issues pointed out by David.

Changes since v14:
Just some stylistic changes addressing comments from Joe Perches and
Olaf Hering -- thank you!
- add a GPL blurb.
- define a new macro PAGE_SIZE_4K and use it to replace PAGE_SIZE
- change sk_to_hvsock/hvsock_to_sk() from macros to inline functions
- remove a not-very-useful pr_err()
- fix some typos in comment and coding style issues.


Dexuan Cui (1):
  hv_sock: introduce Hyper-V Sockets

 MAINTAINERS                 |    2 +
 include/linux/hyperv.h      |   13 +
 include/linux/socket.h      |    4 +-
 include/net/af_hvsock.h     |   78 +++
 include/uapi/linux/hyperv.h |   24 +
 net/Kconfig                 |    1 +
 net/Makefile                |    1 +
 net/hv_sock/Kconfig         |   10 +
 net/hv_sock/Makefile        |    3 +
 net/hv_sock/af_hvsock.c     | 1523 +++++++++++++++++++++++++++++++++++++++++++
 10 files changed, 1658 insertions(+), 1 deletion(-)
 create mode 100644 include/net/af_hvsock.h
 create mode 100644 net/hv_sock/Kconfig
 create mode 100644 net/hv_sock/Makefile
 create mode 100644 net/hv_sock/af_hvsock.c

-- 
2.1.0
