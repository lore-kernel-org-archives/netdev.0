From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next RFC PATCH 0/7] multiqueue support for
	tun/tap
Date: Sun, 14 Aug 2011 02:19:41 -0400 (EDT)
Message-ID: <410484089.165922.1313302781804.JavaMail.root@zmail05.collab.prod.int.phx2.redhat.com>
References: <1313196390.28682.14.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	qemu-devel@nongnu.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	mirq-linux@rere.qmqm.pl, davem@davemloft.net
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <1313196390.28682.14.camel@w-sridhar.beaverton.ibm.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: </archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org



----- Original Message -----
> On Fri, 2011-08-12 at 09:54 +0800, Jason Wang wrote:
> > As multi-queue nics were commonly used for high-end servers,
> > current single queue based tap can not satisfy the
> > requirement of scaling guest network performance as the
> > numbers of vcpus increase. So the following series
> > implements multiple queue support in tun/tap.
> >
> > In order to take advantages of this, a multi-queue capable
> > driver and qemu were also needed. I just rebase the latest
> > version of Krishna's multi-queue virtio-net driver into this
> > series to simplify the test. And for multiqueue supported
> > qemu, you can refer the patches I post in
> > http://www.spinics.net/lists/kvm/msg52808.html. Vhost is
> > also a must to achieve high performance and its code could
> > be used for multi-queue without modification. Alternatively,
> > this series can be also used for Krishna's M:N
> > implementation of multiqueue but I didn't test it.
> >
> > The idea is simple: each socket were abstracted as a queue
> > for tun/tap, and userspace may open as many files as
> > required and then attach them to the devices. In order to
> > keep the ABI compatibility, device creation were still
> > finished in TUNSETIFF, and two new ioctls TUNATTACHQUEUE and
> > TUNDETACHQUEUE were added for user to manipulate the numbers
> > of queues for the tun/tap.
> 
> Is it possible to have tap create these queues automatically when
> TUNSETIFF is called instead of having userspace to do the new
> ioctls. I am just wondering if it is possible to get multi-queue
> to be enabled without any changes to qemu. I guess the number of
> queues
> could be based on the number of vhost threads/guest virtio-net queues.

It's possible but we need at least pass the number of queues
through TUNSETIFF which may break the ABI? And this method
is not flexible as adding new ioctls, consider we may
disable some queues for some reaons such as running a single
queue guest or pxe on an multiple virtio-net backened.

> 
> Also, is it possible to enable multi-queue on the host alone without
> any guest virtio-net changes?

If we use current driver without changes, it can run on host
that multiqueu enabled. But it can not make use all of the
queues.

> 
> Have you done any multiple TCP_RR/UDP_RR testing with small packet
> sizes? 256byte request/response with 50-100 instances?

Not yet, I would do it after I was back from KVM Forum.

> 
> >
> > I've done some basic performance testing of multi queue
> > tap. For tun, I just test it through vpnc.
> >
> > Notes:
> > - Test shows improvement when receving packets from
> > local/external host to guest, and send big packet from guest
> > to local/external host.
> > - Current multiqueue based virtio-net/tap introduce a
> > regression of send small packet (512 byte) from guest to
> > local/external host. I suspect it's the issue of queue
> > selection in both guest driver and tap. Would continue to
> > investigate.
> > - I would post the perforamnce numbers as a reply of this
> > mail.
> >
> > TODO:
> > - solve the issue of packet transmission of small packets.
> > - addressing the comments of virtio-net driver
> > - performance tunning
> >
> > Please review and comment it, Thanks.
> >
> > ---
> >
> > Jason Wang (5):
> >       tuntap: move socket/sock related structures to tun_file
> >       tuntap: categorize ioctl
> >       tuntap: introduce multiqueue related flags
> >       tuntap: multiqueue support
> >       tuntap: add ioctls to attach or detach a file form tap device
> >
> > Krishna Kumar (2):
> >       Change virtqueue structure
> >       virtio-net changes
> >
> >
> >  drivers/net/tun.c | 738 ++++++++++++++++++++++++++-----------------
> >  drivers/net/virtio_net.c | 578 ++++++++++++++++++++++++----------
> >  drivers/virtio/virtio_pci.c | 10 -
> >  include/linux/if_tun.h | 5
> >  include/linux/virtio.h | 1
> >  include/linux/virtio_net.h | 3
> >  6 files changed, 867 insertions(+), 468 deletions(-)
> >
> 
> --
> To unsubscribe from this list: send the line "unsubscribe
> linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at http://www.tux.org/lkml/
