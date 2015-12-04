From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 0/5] Add virtio transport for AF_VSOCK
Date: Fri, 4 Dec 2015 09:45:04 +0200
Message-ID: <20151204074504.GA21363@redhat.com>
References: <1449038643-25971-1-git-send-email-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Matt Benjamin <mbenjamin@redhat.com>,
	Christoffer Dall <christoffer.dall@linaro.org>, matt.ma@linaro.org
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1449038643-25971-1-git-send-email-stefanha@redhat.com>
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

On Wed, Dec 02, 2015 at 02:43:58PM +0800, Stefan Hajnoczi wrote:
> v2:
>  * Rebased onto Linux v4.4-rc2
>  * vhost: Refuse to assign reserved CIDs
>  * vhost: Refuse guest CID if already in use
>  * vhost: Only accept correctly addressed packets (no spoofing!)
>  * vhost: Support flexible rx/tx descriptor layout
>  * vhost: Add missing total_tx_buf decrement
>  * virtio_transport: Fix total_tx_buf accounting
>  * virtio_transport: Add virtio_transport global mutex to prevent races
>  * common: Notify other side of SOCK_STREAM disconnect (fixes shutdown
>    semantics)
>  * common: Avoid recursive mutex_lock(tx_lock) for write_space (fixes deadlock)
>  * common: Define VIRTIO_VSOCK_TYPE_STREAM/DGRAM hardware interface constants
>  * common: Define VIRTIO_VSOCK_SHUTDOWN_RCV/SEND hardware interface constants
>  * common: Fix peer_buf_alloc inheritance on child socket
> 
> This patch series adds a virtio transport for AF_VSOCK (net/vmw_vsock/).
> AF_VSOCK is designed for communication between virtual machines and
> hypervisors.  It is currently only implemented for VMware's VMCI transport.
> 
> This series implements the proposed virtio-vsock device specification from
> here:
> http://comments.gmane.org/gmane.comp.emulators.virtio.devel/855
> 
> Most of the work was done by Asias He and Gerd Hoffmann a while back.  I have
> picked up the series again.
> 
> The QEMU userspace changes are here:
> https://github.com/stefanha/qemu/commits/vsock
> 
> Why virtio-vsock?
> -----------------
> Guest<->host communication is currently done over the virtio-serial device.
> This makes it hard to port sockets API-based applications and is limited to
> static ports.
> 
> virtio-vsock uses the sockets API so that applications can rely on familiar
> SOCK_STREAM and SOCK_DGRAM semantics.  Applications on the host can easily
> connect to guest agents because the sockets API allows multiple connections to
> a listen socket (unlike virtio-serial).  This simplifies the guest<->host
> communication and eliminates the need for extra processes on the host to
> arbitrate virtio-serial ports.
> 
> Overview
> --------
> This series adds 3 pieces:
> 
> 1. virtio_transport_common.ko - core virtio vsock code that uses vsock.ko
> 
> 2. virtio_transport.ko - guest driver
> 
> 3. drivers/vhost/vsock.ko - host driver
> 
> Howto
> -----
> The following kernel options are needed:
>   CONFIG_VSOCKETS=y
>   CONFIG_VIRTIO_VSOCKETS=y
>   CONFIG_VIRTIO_VSOCKETS_COMMON=y
>   CONFIG_VHOST_VSOCK=m
> 
> Launch QEMU as follows:
>   # qemu ... -device vhost-vsock-pci,id=vhost-vsock-pci0,guest-cid=3
> 
> Guest and host can communicate via AF_VSOCK sockets.  The host's CID (address)
> is 2 and the guest is automatically assigned a CID (use VMADDR_CID_ANY (-1) to
> bind to it).
> 
> Status
> ------
> There are a few design changes I'd like to make to the virtio-vsock device:
> 
> 1. The 3-way handshake isn't necessary over a reliable transport (virtqueue).
>    Spoofing packets is also impossible so the security aspects of the 3-way
>    handshake (including syn cookie) add nothing.  The next version will have a
>    single operation to establish a connection.

It's hard to discuss without seeing the details, but we do need to
slow down guests that are flooding host with socket creation requests.
The handshake is a simple way for hypervisor to defer
such requests until it has resources without
breaking things.

> 2. Credit-based flow control doesn't work for SOCK_DGRAM since multiple clients
>    can transmit to the same listen socket.  There is no way for the clients to
>    coordinate buffer space with each other fairly.  The next version will drop
>    credit-based flow control for SOCK_DGRAM and only rely on best-effort
>    delivery.  SOCK_STREAM still has guaranteed delivery.

I suspect in the end we will need a measure of fairness even
if you drop packets. And recovering from packet loss is
hard enough that not many applications do it correctly.
I suggest disabling SOCK_DGRAM for now.

> 3. In the next version only the host will be able to establish connections
>    (i.e. to connect to a guest agent).  This is for security reasons since
>    there is currently no ability to provide host services only to certain
>    guests.  This also matches how AF_VSOCK works on modern VMware hypervisors.


I see David merged this one already, but above planned changes are
userspace and hypervisor/guest visible.

Once this is upstream and userspace/guests start relying on it,
we'll be stuck supporting this version in addition to
whatever we really want, with no easy way to even test it.

Might it not be better to defer enabling this upstream until the interface is
finalized?


> Asias He (5):
>   VSOCK: Introduce vsock_find_unbound_socket and
>     vsock_bind_dgram_generic
>   VSOCK: Introduce virtio-vsock-common.ko
>   VSOCK: Introduce virtio-vsock.ko
>   VSOCK: Introduce vhost-vsock.ko
>   VSOCK: Add Makefile and Kconfig
> 
>  drivers/vhost/Kconfig                   |    4 +
>  drivers/vhost/Kconfig.vsock             |    7 +
>  drivers/vhost/Makefile                  |    4 +
>  drivers/vhost/vsock.c                   |  631 +++++++++++++++
>  drivers/vhost/vsock.h                   |    4 +
>  include/linux/virtio_vsock.h            |  209 +++++
>  include/net/af_vsock.h                  |    2 +
>  include/uapi/linux/virtio_ids.h         |    1 +
>  include/uapi/linux/virtio_vsock.h       |   89 +++
>  net/vmw_vsock/Kconfig                   |   18 +
>  net/vmw_vsock/Makefile                  |    2 +
>  net/vmw_vsock/af_vsock.c                |   70 ++
>  net/vmw_vsock/virtio_transport.c        |  466 +++++++++++
>  net/vmw_vsock/virtio_transport_common.c | 1272 +++++++++++++++++++++++++++++++
>  14 files changed, 2779 insertions(+)
>  create mode 100644 drivers/vhost/Kconfig.vsock
>  create mode 100644 drivers/vhost/vsock.c
>  create mode 100644 drivers/vhost/vsock.h
>  create mode 100644 include/linux/virtio_vsock.h
>  create mode 100644 include/uapi/linux/virtio_vsock.h
>  create mode 100644 net/vmw_vsock/virtio_transport.c
>  create mode 100644 net/vmw_vsock/virtio_transport_common.c
> 
> -- 
> 2.5.0
