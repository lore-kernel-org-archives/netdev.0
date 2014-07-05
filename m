From: Asias He <asias.hejun@gmail.com>
Subject: [RFC V2 0/7] Introduce VM Sockets virtio transport
Date: Sat,  5 Jul 2014 11:23:09 +0800
Message-ID: <cover.1404529115.git.asias.hejun@gmail.com>
To: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:65386 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753964AbaGEDXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2014 23:23:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello guys,

This was V2 of the virtio-vsock back in last October. I do not have time to
work on it since then. People are asking the latest status of virtio-vsock from
time to time, so I'm sending out the code for people who are interested in.
Feel free to grab the code and work on it if you want.




In commit d021c344051af91 (VSOCK: Introduce VM Sockets), VMware added VM
Sockets support. VM Sockets allows communication between virtual
machines and the hypervisor. VM Sockets is able to use different
hyervisor neutral transport to transfer data. Currently, only VMware
VMCI transport is supported.

This series introduces virtio transport for VM Sockets.

Changes since v1:

- DGRAM fgramentation
- DGRAM credit support
- SYN cookie support
- 32 bit tx_cnt, fwd_cnt and buf_alloc
- 3-way instead of 4-way connection creation
- various bug fixes

Code:
=========================
1) kernel bits
   git://github.com/asias/linux.git vsock

2) userspace bits:
   git://github.com/asias/linux-kvm.git vsock

Howto:
=========================
Make sure you have these kernel options:

  CONFIG_VSOCKETS=y
  CONFIG_VIRTIO_VSOCKETS=y
  CONFIG_VIRTIO_VSOCKETS_COMMON=y
  CONFIG_VHOST_VSOCK=m

$ git clone git://github.com/asias/linux-kvm.git
$ cd linux-kvm/tools/kvm
$ co -b vsock origin/vsock
$ make
$ modprobe vhost_vsock
$ ./lkvm run -d os.img -k bzImage --vsock guest_cid

Test:
=========================
I hacked busybox's http server and wget to run over vsock. Start http
server in host and guest, download a 512MB file in guest and host
simultaneously for 6000 times. Manged to run the http stress test.

Also, I wrote a small libvsock.so to play the LD_PRELOAD trick and
managed to make sshd and ssh work over virito-vsock without modifying
the source code.

Draft VM Sockets Virtio Device spec:
=========================
Appendix K: VM Sockets Device

The virtio VM sockets device is a virtio transport device for VM Sockets. VM
Sockets allows communication between virtual machines and the hypervisor.

Configuration:

Subsystem Device ID 13

Virtqueues:
    0:controlq; 1:receiveq0; 2:transmitq0 ... 2N+1:receivqN; 2N+2:transmitqN

Feature bits:
    Currently, no feature bits are defined.

Device configuration layout:

Two configuration fields are currently defined.

   struct virtio_vsock_config {
           __le32 guest_cid;
           __le32 max_virtqueue_pairs;

   };

The guest_cid field specifies the guest context id which likes the guest IP
address. The max_virtqueue_pairs field specifies the maximum number of receive
and transmit virtqueue pairs (receiveq0 ...  receiveqN and transmitq0 ...
transmitqN respectively; N = max_virtqueue_pairs - 1 ) that can be configured.
The driver is free to use only one virtqueue pairs, or it can use more to
achieve better performance.

Device Initialization:
The initialization routine should discover the device's virtqueues.

Device Operation:
Packets are transmitted by placing them in the transmitq0..transmitqN, and
buffers for incoming packets are placed in the receiveq0..receiveqN. In each
case, the packet itself is preceded by a header:

   struct virtio_vsock_hdr {
           __le32  src_cid;
           __le32  src_port;
           __le32  dst_cid;
           __le32  dst_port;
           __le32  len;
           __le16  type;
           __le16  op;
           __le32  flags;
           __le32  buf_alloc;
           __le32  fwd_cnt;
   };

src_cid and dst_cid: specify the source and destination context id.

src_port and dst_port: specify the source and destination port.

len: specifies the size of the data payload, it could be zero if no data
payload is transferred. When the payload is for SOCK_DGRAM, the upper 16 bits
of len specifies the totoal length of the datagram, the lower 16 bits of len
specifies the length of this pkt. When the payload is for SOCK_STREAM,
len specifies the length of the pkt.

type: specifies the type of the packet, it can be SOCK_STREAM or SOCK_DGRAM.

op: specifies the operation of the packet, it is defined as follows.

   enum {
           VIRTIO_VSOCK_OP_INVALID = 0,
           VIRTIO_VSOCK_OP_REQUEST = 1,
           VIRTIO_VSOCK_OP_RESPONSE = 2,
           VIRTIO_VSOCK_OP_ACK = 3,
           VIRTIO_VSOCK_OP_RW = 4,
           VIRTIO_VSOCK_OP_CREDIT = 5,
           VIRTIO_VSOCK_OP_WANTCREDIT = 6,
           VIRTIO_VSOCK_OP_RST = 7,
           VIRTIO_VSOCK_OP_SHUTDOWN = 8,
   };

/*FIXME*/
flags: has different meanings for differentdifferent operations. 

  When op is VIRTIO_VSOCK_OP_REQUEST or VIRTIO_VSOCK_OP_RESPONSE or
  VIRTIO_VSOCK_OP_ACK, flags specifies the cookie for connection creation.
  
  When op is VIRTIO_VSOCK_OP_RW, if the pkt is for SOCK_DGRAM, the upper 16 bits of flags
  specifies dgram_id of this datagram, the lower 16 bits specifies the offset of
  this pkt in this datagram. if the pkt is for SOCK_STREAM, flags is not defined.
  
  When op is VIRTIO_VSOCK_OP_CREDIT or VIRTIO_VSOCK_OP_WANTCREDIT or
  VIRTIO_VSOCK_OP_RST, flags is not defined.
  
  When op is VIRTIO_VSOCK_OP_SHUTDOWN, flags specifies the shutdown mode when the
  socket is being shutdown. 1 is for receive shutdown, 2 is for transmit
  shutdown, 3 is for both receive and transmit shutdown.

fwd_cnt: specifies the the number of bytes the receiver has forwarded to
userspace.

buf_alloc: specifies the size of the receiver's recieve buffer in bytes.

Virtio VM socket connection creation:
1) Client sends VIRTIO_VSOCK_OP_REQUEST to server
2) Server responses with VIRTIO_VSOCK_OP_RESPONSE to client
3) Client responses with VIRTIO_VSOCK_OP_ATTACH to server

Virtio VM socket credit update:
Virtio VM socket uses credit-based flow control. The sender maintains tx_cnt
which counts the totoal number of bytes it has sent out, peer_fwd_cnt which
counts the totoal number of byes the receiver has forwarded, and peer_buf_alloc
which is the size of the receiver's receive buffer. The sender can send no more
than the credit the receiver gives to the sender: credit = peer_buf_alloc -
(tx_cnt - peer_fwd_cnt). The receiver can send VIRTIO_VSOCK_OP_CREDIT packet to
tell sender its current fwd_cnt and buf_alloc value explicitly. However, as an
optimization, the fwd_cnt and buf_alloc is always included in the packet header
virtio_vsock_hdr.

Virtio VM socket syn cookie:
When a server receives a VIRTIO_VSOCK_OP_REQUEST pkt from client, it does not
allocate the resouces immediately. It calculates a secret cookie and sends a
VIRTIO_VSOCK_OP_RESPONSE pkt to client. When a client receives a
VIRTIO_VSOCK_OP_RESPONSE pkt, it sends a VIRTIO_VSOCK_OP_ACK pkt to server.
When the server receives the VIRTIO_VSOCK_OP_ACK pkt, it checks the cookie to
make sure the cookie is sent by the server. If the check is passed, the
connection is created. If the check is not passed, the pkt is dropped and no
connection is created.

Virtio VM socket SOCK_DGRAM frgamentation:
The maximum datagram supported is 64KB. The maximum rx buffer is 4KB. If a
datagram is larger than the maximum rx buffer, the datagram is fragmented into
multiple small 4KB pkt.

The guest driver should make the receive virtqueue as fully populated as
possible: if it runs out, the performance will suffer.

The controlq is used to control device. Currently, no control operation is
defined.

Asias He (7):
  VSOCK: Introduce vsock_find_unbound_socket and
    vsock_bind_dgram_generic
  VSOCK: Add dgram_skb to vsock_sock
  VSOCK: Introduce virtio-vsock-common.ko
  VSOCK: Introduce virtio-vsock.ko
  VSOCK: Introduce vhost-vsock.ko
  VSOCK: Add Makefile and Kconfig
  Disable debug

 drivers/vhost/Kconfig                              |    4 +
 drivers/vhost/Kconfig.vsock                        |    7 +
 drivers/vhost/Makefile                             |    4 +
 drivers/vhost/vsock.c                              |  572 +++++++++
 drivers/vhost/vsock.h                              |    4 +
 include/linux/virtio_vsock.h                       |  207 ++++
 include/net/af_vsock.h                             |    3 +
 include/uapi/linux/virtio_ids.h                    |    1 +
 .../uapi/linux/{virtio_ids.h => virtio_vsock.h}    |   78 +-
 net/vmw_vsock/Kconfig                              |   18 +
 net/vmw_vsock/Makefile                             |    2 +
 net/vmw_vsock/af_vsock.c                           |   71 ++
 net/vmw_vsock/virtio_transport.c                   |  448 +++++++
 net/vmw_vsock/virtio_transport_common.c            | 1220 ++++++++++++++++++++
 14 files changed, 2618 insertions(+), 21 deletions(-)
 create mode 100644 drivers/vhost/Kconfig.vsock
 create mode 100644 drivers/vhost/vsock.c
 create mode 100644 drivers/vhost/vsock.h
 create mode 100644 include/linux/virtio_vsock.h
 copy include/uapi/linux/{virtio_ids.h => virtio_vsock.h} (50%)
 create mode 100644 net/vmw_vsock/virtio_transport.c
 create mode 100644 net/vmw_vsock/virtio_transport_common.c

-- 
1.9.3
