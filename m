From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: [RFC 0/5] Introduce VM Sockets virtio transport
Date: Thu, 27 Jun 2013 15:03:01 -0400
Message-ID: <51CC8C65.10409@oracle.com>
References: <1372320004-20502-1-git-send-email-asias@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Andy King <acking@vmware.com>, kvm@vger.kernel.org,
	Dmitry Torokhov <dtor@vmware.com>, netdev@vger.kernel.org,
	Reilly Grant <grantr@vmware.com>,
	virtualization@lists.linux-foundation.org,
	Pekka Enberg <penberg@kernel.org>, "Michael S. Tsirkin" <mst@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Asias He <asias@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1372320004-20502-1-git-send-email-asias@redhat.com>
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

Hi Asias,

Looks nice! Some comments inline below (I've removed anything that mst already
commented on).

On 06/27/2013 03:59 AM, Asias He wrote:
> Hello guys,
>
> In commit d021c344051af91 (VSOCK: Introduce VM Sockets), VMware added VM
> Sockets support. VM Sockets allows communication between virtual
> machines and the hypervisor. VM Sockets is able to use different
> hyervisor neutral transport to transfer data. Currently, only VMware
> VMCI transport is supported.
>
> This series introduces virtio transport for VM Sockets.
>
> Any comments are appreciated! Thanks!
>
> Code:
> =========================
> 1) kernel bits
>     git://github.com/asias/linux.git vsock
>
> 2) userspace bits:
>     git://github.com/asias/linux-kvm.git vsock
>
> Howto:
> =========================
> Make sure you have these kernel options:
>
>    CONFIG_VSOCKETS=y
>    CONFIG_VIRTIO_VSOCKETS=y
>    CONFIG_VIRTIO_VSOCKETS_COMMON=y
>    CONFIG_VHOST_VSOCK=m
>
> $ git clone git://github.com/asias/linux-kvm.git
> $ cd linux-kvm/tools/kvm
> $ co -b vsock origin/vsock
> $ make
> $ modprobe vhost_vsock
> $ ./lkvm run -d os.img -k bzImage --vsock guest_cid
>
> Test:
> =========================
> I hacked busybox's http server and wget to run over vsock. Start http
> server in host and guest, download a 512MB file in guest and host
> simultaneously for 6000 times. Manged to run the http stress test.
>
> Also, I wrote a small libvsock.so to play the LD_PRELOAD trick and
> managed to make sshd and ssh work over virito-vsock without modifying
> the source code.

Why did it require hacking in the first place? Does running with kvmtool
and just doing regular networking over virtio-net running on top of vsock
achieves the same goal?

> Draft VM Sockets Virtio Device spec:
> =========================
> Appendix K: VM Sockets Device
>
> The virtio VM sockets device is a virtio transport device for VM Sockets. VM
> Sockets allows communication between virtual machines and the hypervisor.
>
> Configuration:
>
> Subsystem Device ID 13
>
> Virtqueues:
>      0:controlq; 1:receiveq0; 2:transmitq0 ... 2N+1:receivqN; 2N+2:transmitqN

controlq is "defined but not used", is there something in mind for it? if not,
does it make sense keeping it here? we can always re-add it to the end just
like in virtio-net.

> Feature bits:
>      Currently, no feature bits are defined.
>
> Device configuration layout:
>
> Two configuration fields are currently defined.
>
>     struct virtio_vsock_config {
>             __u32 guest_cid;
>             __u32 max_virtqueue_pairs;
>     } __packed;
>
> The guest_cid field specifies the guest context id which likes the guest IP
> address. The max_virtqueue_pairs field specifies the maximum number of receive
> and transmit virtqueue pairs (receiveq0 ...  receiveqN and transmitq0 ...
> transmitqN respectively; N = max_virtqueue_pairs - 1 ) that can be configured.
> The driver is free to use only one virtqueue pairs, or it can use more to
> achieve better performance.

How does the driver tell the device how many vqs it's planning on actually using?
or is it assumed that all of them are in use?

>
> Device Initialization:
> The initialization routine should discover the device's virtqueues.
>
> Device Operation:
> Packets are transmitted by placing them in the transmitq0..transmitqN, and
> buffers for incoming packets are placed in the receiveq0..receiveqN. In each
> case, the packet itself is preceded by a header:
>
>     struct virtio_vsock_hdr {
>             __u32   src_cid;
>             __u32   src_port;
>             __u32   dst_cid;
>             __u32   dst_port;
>             __u32   len;
>             __u8    type;
>             __u8    op;
>             __u8    shut;
>             __u64   fwd_cnt;
>             __u64   buf_alloc;
>     } __packed;
>
> src_cid and dst_cid: specify the source and destination context id.
> src_port and dst_port: specify the source and destination port.
> len: specifies the size of the data payload, it could be zero if no data
> payload is transferred.
> type: specifies the type of the packet, it can be SOCK_STREAM or SOCK_DGRAM.
> op: specifies the operation of the packet, it is defined as follows.
>
>     enum {
>             VIRTIO_VSOCK_OP_INVALID = 0,
>             VIRTIO_VSOCK_OP_REQUEST = 1,
>             VIRTIO_VSOCK_OP_NEGOTIATE = 2,
>             VIRTIO_VSOCK_OP_OFFER = 3,
>             VIRTIO_VSOCK_OP_ATTACH = 4,
>             VIRTIO_VSOCK_OP_RW = 5,
>             VIRTIO_VSOCK_OP_CREDIT = 6,
>             VIRTIO_VSOCK_OP_RST = 7,
>             VIRTIO_VSOCK_OP_SHUTDOWN = 8,
>     };
>
> shut: specifies the shutdown mode when the socket is being shutdown. 1 is for
> receive shutdown, 2 is for transmit shutdown, 3 is for both receive and transmit
> shutdown.
> fwd_cnt: specifies the the number of bytes the receiver has forwarded to userspace.

For the previous packet? For the entire session? Reading ahead makes it clear but
it's worth mentioning here the context just to make it easy for implementers.

> buf_alloc: specifies the size of the receiver's recieve buffer in bytes.
						  receive

> Virtio VM socket connection creation:
> 1) Client sends VIRTIO_VSOCK_OP_REQUEST to server
> 2) Server reponses with VIRTIO_VSOCK_OP_NEGOTIATE to client
> 3) Client sends VIRTIO_VSOCK_OP_OFFER to server
> 4) Server responses with VIRTIO_VSOCK_OP_ATTACH to client
>
> Virtio VM socket credit update:
> Virtio VM socket uses credit-based flow control. The sender maintains tx_cnt
> which counts the totoal number of bytes it has sent out, peer_fwd_cnt which
		   total
> counts the totoal number of byes the receiver has forwarded, and peer_buf_alloc
	     total
> which is the size of the receiver's receive buffer. The sender can send no more
> than the credit the receiver gives to the sender: credit = peer_buf_alloc -


Thanks,
Sasha
