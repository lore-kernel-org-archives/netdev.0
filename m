From: Asias He <asias@redhat.com>
Subject: Re: [RFC 0/5] Introduce VM Sockets virtio transport
Date: Fri, 28 Jun 2013 14:12:57 +0800
Message-ID: <20130628061257.GB30441@hj.localdomain>
References: <1372320004-20502-1-git-send-email-asias@redhat.com>
	<20130627102324.GA20215@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andy King <acking@vmware.com>, kvm@vger.kernel.org,
	Dmitry Torokhov <dtor@vmware.com>, netdev@vger.kernel.org,
	Reilly Grant <grantr@vmware.com>,
	virtualization@lists.linux-foundation.org,
	Pekka Enberg <penberg@kernel.org>, Sasha Levin <sasha.levin@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20130627102324.GA20215@redhat.com>
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

On Thu, Jun 27, 2013 at 01:23:24PM +0300, Michael S. Tsirkin wrote:
> On Thu, Jun 27, 2013 at 03:59:59PM +0800, Asias He wrote:
> > Hello guys,
> > 
> > In commit d021c344051af91 (VSOCK: Introduce VM Sockets), VMware added VM
> > Sockets support. VM Sockets allows communication between virtual
> > machines and the hypervisor. VM Sockets is able to use different
> > hyervisor neutral transport to transfer data. Currently, only VMware
> > VMCI transport is supported. 
> > 
> > This series introduces virtio transport for VM Sockets.
> > 
> > Any comments are appreciated! Thanks!
> > 
> > Code:
> > =========================
> > 1) kernel bits
> >    git://github.com/asias/linux.git vsock
> > 
> > 2) userspace bits:
> >    git://github.com/asias/linux-kvm.git vsock
> > 
> > Howto:
> > =========================
> > Make sure you have these kernel options:
> > 
> >   CONFIG_VSOCKETS=y
> >   CONFIG_VIRTIO_VSOCKETS=y
> >   CONFIG_VIRTIO_VSOCKETS_COMMON=y
> >   CONFIG_VHOST_VSOCK=m
> > 
> > $ git clone git://github.com/asias/linux-kvm.git
> > $ cd linux-kvm/tools/kvm
> > $ co -b vsock origin/vsock
> > $ make
> > $ modprobe vhost_vsock
> > $ ./lkvm run -d os.img -k bzImage --vsock guest_cid
> > 
> > Test:
> > =========================
> > I hacked busybox's http server and wget to run over vsock. Start http
> > server in host and guest, download a 512MB file in guest and host
> > simultaneously for 6000 times. Manged to run the http stress test.
> > 
> > Also, I wrote a small libvsock.so to play the LD_PRELOAD trick and
> > managed to make sshd and ssh work over virito-vsock without modifying
> > the source code.
> > 
> > Draft VM Sockets Virtio Device spec:
> > =========================
> > Appendix K: VM Sockets Device
> > 
> > The virtio VM sockets device is a virtio transport device for VM Sockets. VM
> > Sockets allows communication between virtual machines and the hypervisor.
> > 
> > Configuration:
> > 
> > Subsystem Device ID 13
> > 
> > Virtqueues:
> >     0:controlq; 1:receiveq0; 2:transmitq0 ... 2N+1:receivqN; 2N+2:transmitqN
> > 
> > Feature bits:
> >     Currently, no feature bits are defined.
> > 
> > Device configuration layout:
> > 
> > Two configuration fields are currently defined.
> > 
> >    struct virtio_vsock_config {
> 
> which fields are RW,RO,WO?

All are RO.

> >            __u32 guest_cid;
> 
> Given that cid is like an IP address, 32 bit seems too
> limiting. I would go for a 64 bit one or maybe even 128 bit,
> so that e.g. GUIDs can be used there.
> 
> 
> >            __u32 max_virtqueue_pairs;
> 
> I'd make this little endian.

okay.

> >    } __packed;
> 
> 
> > 
> > The guest_cid field specifies the guest context id which likes the guest IP
> > address. The max_virtqueue_pairs field specifies the maximum number of receive
> > and transmit virtqueue pairs (receiveq0 ...  receiveqN and transmitq0 ...
> > transmitqN respectively; N = max_virtqueue_pairs - 1 ) that can be configured.
> > The driver is free to use only one virtqueue pairs, or it can use more to
> > achieve better performance.
> 
> Don't we need a field for driver to specify the # of VQs?

To make it simple, I want to make the driver use all of the virtqueue
pairs we offered in max_virtqueue_pairs.

> I note packets have no sequence numbers.
> This means that a given stream should only use
> a single VQ in each direction, correct?
> Maybe make this explicit.

Right, let's make it explicit.

> > 
> > Device Initialization:
> > The initialization routine should discover the device's virtqueues.
> > 
> > Device Operation:
> > Packets are transmitted by placing them in the transmitq0..transmitqN, and
> > buffers for incoming packets are placed in the receiveq0..receiveqN. In each
> > case, the packet itself is preceded by a header:
> > 
> >    struct virtio_vsock_hdr {
> 
> Let's make header explicitly little endian and avoid the
> heartburn we have with many other transports.

Sounds good to me.

> >            __u32   src_cid;
> >            __u32   src_port;
> >            __u32   dst_cid;
> >            __u32   dst_port;
> 
> Ports are 32 bit? I guess most applications can't work with >16 bit.
> 
> Also, why put cid's in all packets? They are only needed
> when you create a connection, no? Afterwards port numbers
> can be used.
> 
> >            __u32   len;
> >            __u8    type;
> >            __u8    op;
> >            __u8    shut;
> 
> Please add padding to align all field naturally.

ok.

> >            __u64   fwd_cnt;
> >            __u64   buf_alloc;
> 
> Is a 64 bit counter really needed? 64 bit math
> has portability limitations and performance overhead on many
> architectures.

Good point, but 32 bit tx_cnt and fwd_cnt counter overflow very easily
since it contains the total number of bytes ever transferred. If we can
to use 32 bit counter, we need to figure out how to handle overflow. (64
bit can overflow as well.)

buf_alloc can be 32 bit.

> >    } __packed;
> 
> Packing produces terrible code in many compilers.
> Please avoid packed structures on data path, instead,
> pad structures explicitly to align all fields naturally.

We have packed structures on scsi:

include/linux/virtio_scsi.h

> 
> > 
> > src_cid and dst_cid: specify the source and destination context id.
> > src_port and dst_port: specify the source and destination port.
> > len: specifies the size of the data payload, it could be zero if no data
> > payload is transferred.
> > type: specifies the type of the packet, it can be SOCK_STREAM or SOCK_DGRAM.
> > op: specifies the operation of the packet, it is defined as follows.
> > 
> >    enum {
> >            VIRTIO_VSOCK_OP_INVALID = 0,
> >            VIRTIO_VSOCK_OP_REQUEST = 1,
> >            VIRTIO_VSOCK_OP_NEGOTIATE = 2,
> >            VIRTIO_VSOCK_OP_OFFER = 3,
> >            VIRTIO_VSOCK_OP_ATTACH = 4,
> >            VIRTIO_VSOCK_OP_RW = 5,
> >            VIRTIO_VSOCK_OP_CREDIT = 6,
> >            VIRTIO_VSOCK_OP_RST = 7,
> >            VIRTIO_VSOCK_OP_SHUTDOWN = 8,
> >    };
> > 
> > shut: specifies the shutdown mode when the socket is being shutdown. 1 is for
> > receive shutdown, 2 is for transmit shutdown, 3 is for both receive and transmit
> > shutdown.
> 
> It's only with VIRTIO_VSOCK_OP_SHUTDOWN - how about a generic
> flags field that is interpreted depending on op?

I can rename the shut field as a generic filed depending on op.

> > fwd_cnt: specifies the the number of bytes the receiver has forwarded to userspace.
> > buf_alloc: specifies the size of the receiver's recieve buffer in bytes.
> > 
> > Virtio VM socket connection creation:
> > 1) Client sends VIRTIO_VSOCK_OP_REQUEST to server
> > 2) Server reponses with VIRTIO_VSOCK_OP_NEGOTIATE to client
> > 3) Client sends VIRTIO_VSOCK_OP_OFFER to server
> > 4) Server responses with VIRTIO_VSOCK_OP_ATTACH to client
> 
> What's the reason for a 4 stage setup? Most transports
> make do with 3.
> Also, at what stage can each side get/transmit packets?
> What happens in case of errors at each stage?
> Don't we want to distinguish between errors?
> (E.g. wrong cid, no app listening on port, etc)?

RST is used to handle this kind of errors.

> This also appears to be vulnerable to a variant of
> a syn flood attack (guest attacking host).
> I think we need a cookie hash in there to prevent this.
> 
> 
> Can you describe connection teardown please?
> I see there are RST and SHUTDOWN messages.
> What rules do they obey?

SHUTDOWN follows shutdown (2) system call. I can write more details
about each packet types.

> 
> > 
> > Virtio VM socket credit update:
> > Virtio VM socket uses credit-based flow control. The sender maintains tx_cnt
> > which counts the totoal number of bytes it has sent out, peer_fwd_cnt which
> > counts the totoal number of byes the receiver has forwarded, and peer_buf_alloc
> > which is the size of the receiver's receive buffer. The sender can send no more
> > than the credit the receiver gives to the sender: credit = peer_buf_alloc -
> > (tx_cnt - peer_fwd_cnt). The receiver can send VIRTIO_VSOCK_OP_CREDIT packet to
> > tell sender its current fwd_cnt and buf_alloc value explicitly. However, as an
> > optimization, the fwd_cnt and buf_alloc is always included in the packet header
> > virtio_vsock_hdr.
> > 
> > The guest driver should make the receive virtqueue as fully populated as
> > possible: if it runs out, the performance will suffer.
> > 
> > The controlq is used to control device. Currently, no control operation is
> > defined.
> > 
> > Asias He (5):
> >   VSOCK: Introduce vsock_find_unbound_socket and
> >     vsock_bind_dgram_generic
> >   VSOCK: Introduce virtio-vsock-common.ko
> >   VSOCK: Introduce virtio-vsock.ko
> >   VSOCK: Introduce vhost-vsock.ko
> >   VSOCK: Add Makefile and Kconfig
> > 
> >  drivers/vhost/Kconfig                   |   4 +
> >  drivers/vhost/Kconfig.vsock             |   7 +
> >  drivers/vhost/Makefile                  |   5 +
> >  drivers/vhost/vsock.c                   | 534 +++++++++++++++++
> >  drivers/vhost/vsock.h                   |   4 +
> >  include/linux/virtio_vsock.h            | 200 +++++++
> >  include/uapi/linux/virtio_ids.h         |   1 +
> >  include/uapi/linux/virtio_vsock.h       |  70 +++
> >  net/vmw_vsock/Kconfig                   |  18 +
> >  net/vmw_vsock/Makefile                  |   4 +
> >  net/vmw_vsock/af_vsock.c                |  70 +++
> >  net/vmw_vsock/af_vsock.h                |   2 +
> >  net/vmw_vsock/virtio_transport.c        | 424 ++++++++++++++
> >  net/vmw_vsock/virtio_transport_common.c | 992 ++++++++++++++++++++++++++++++++
> >  14 files changed, 2335 insertions(+)
> >  create mode 100644 drivers/vhost/Kconfig.vsock
> >  create mode 100644 drivers/vhost/vsock.c
> >  create mode 100644 drivers/vhost/vsock.h
> >  create mode 100644 include/linux/virtio_vsock.h
> >  create mode 100644 include/uapi/linux/virtio_vsock.h
> >  create mode 100644 net/vmw_vsock/virtio_transport.c
> >  create mode 100644 net/vmw_vsock/virtio_transport_common.c
> > 
> > -- 
> > 1.8.1.4

-- 
Asias
