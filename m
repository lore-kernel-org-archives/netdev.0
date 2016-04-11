From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC v5 0/5] Add virtio transport for AF_VSOCK
Date: Mon, 11 Apr 2016 15:54:08 +0300
Message-ID: <20160411154517-mutt-send-email-mst@redhat.com>
References: <1459520587-12337-1-git-send-email-stefanha@redhat.com>
	<1460129705.1749.25.camel@docker.com>
	<20160411104548.GA12826@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: marius vlad <marius.vlad0@gmail.com>, Stefan Hajnoczi <stefanha@redhat.com>,
	kvm@vger.kernel.org, netdev@vger.kernel.org,
	Ian Campbell <ian.campbell@docker.com>,
	Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>,
	Matt Benjamin <mbenjamin@redhat.com>, Greg Kurz <gkurz@linux.vnet.ibm.com>,
	virtualization@lists.linux-foundation.org,
	Christoffer Dall <christoffer.dall@linaro.org>
To: Stefan Hajnoczi <stefanha@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20160411104548.GA12826@stefanha-x1.localdomain>
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

On Mon, Apr 11, 2016 at 11:45:48AM +0100, Stefan Hajnoczi wrote:
> On Fri, Apr 08, 2016 at 04:35:05PM +0100, Ian Campbell wrote:
> > On Fri, 2016-04-01 at 15:23 +0100, Stefan Hajnoczi wrote:
> > > This series is based on Michael Tsirkin's vhost branch (v4.5-rc6).
> > > =

> > > I'm about to process Claudio Imbrenda's locking fixes for virtio-vsoc=
k but
> > > first I want to share the latest version of the code.=A0=A0Several pe=
ople are
> > > playing with vsock now so sharing the latest code should avoid duplic=
ate work.
> > =

> > Thanks for this, I've been using it in my project and it mostly seems
> > fine.
> > =

> > One wrinkle I came across, which I'm not sure if it is by design or a
> > problem is that I can see this sequence coming from the guest (with
> > other activity in between):
> > =

> > =A0 =A0 1) OP_SHUTDOWN w/ flags =3D=3D SHUTDOWN_RX
> > =A0=A0=A0=A02) OP_SHUTDOWN w/ flags =3D=3D SHUTDOWN_TX
> > =A0=A0=A0=A03) OP_SHUTDOWN w/ flags =3D=3D SHUTDOWN_TX|SHUTDOWN_RX
> > =

> > I orignally had my backend close things down at #2, however this meant
> > that when #3 arrived it was for a non-existent socket (or, worse, an
> > active one if the ports got reused). I checked v5 of the spec
> > proposal[0] which says:
> >     If these bits are set and there are no more virtqueue buffers
> >     pending the socket is disconnected.
> > =

> > but I'm not entirely sure if this behaviour contradicts this or not
> > (the bits have both been set at #2, but not at the same time).
> > =

> > BTW, how does one tell if there are no more virtqueue buffers pending
> > or not while processing the op?
> =

> #2 is odd.  The shutdown bits are sticky so they cannot be cleared once
> set.  I would have expected just #1 and #3.  The behavior you observe
> look like a bug.
> =

> The spec text does not convey the meaning of OP_SHUTDOWN well.
> OP_SHUTDOWN SHUTDOWN_TX|SHUTDOWN_RX means no further rx/tx is possible
> for this connection.  "there are no more virtqueue buffers pending the
> socket" really means that this isn't an immediate close from the
> perspective of the application.  If the application still has unread rx
> buffers then the socket stays readable until the rx data has been fully
> read.

Yes but you also wrote:
	If these bits are set and there are no more virtqueue buffers
	pending the socket is disconnected.

how does remote know that there are no buffers pending and so it's safe
to reuse the same source/destination address now?  Maybe destination
should send RST at that point?



> > Another thing I noticed, which is really more to do with the generic
> > AF_VSOCK bits than anything to do with your patches is that there is no
> > limitations on which vsock ports a non-privileged user can bind to and
> > relatedly that there is no netns support so e.g. users in unproivileged
> > containers can bind to any vsock port and talk to the host, which might
> > be undesirable. For my use for now I just went with the big hammer
> > approach of denying access from anything other than init_net
> > namespace[1] while I consider what the right answer is.
> =

> From the vhost point of view each netns should have its own AF_VSOCK
> namespace.  This way two containers could act as "the host" (CID 2) for
> their respective guests.


I wonder how this interacts with the disconnect on migration
idea that you discussed. Specifically, socket has to stay connected
