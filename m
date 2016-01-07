From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [RFC v4 0/5] Add virtio transport for AF_VSOCK
Date: Thu, 7 Jan 2016 16:34:35 +0800
Message-ID: <20160107083435.GI12971@stefanha-x1.localdomain>
References: <1450775258-18287-1-git-send-email-stefanha@redhat.com>
 <568A2577.2020104@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Li7ckgedzMh1NgdW"
Cc: Stefan Hajnoczi <stefanha@redhat.com>, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Matt Benjamin <mbenjamin@redhat.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	matt.ma@linaro.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35319 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252AbcAGIel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 03:34:41 -0500
Content-Disposition: inline
In-Reply-To: <568A2577.2020104@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Li7ckgedzMh1NgdW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jan 04, 2016 at 03:55:35PM +0800, Jason Wang wrote:
>=20
>=20
> On 12/22/2015 05:07 PM, Stefan Hajnoczi wrote:
> > This series is based on v4.4-rc2 and the "virtio: make find_vqs()
> > checkpatch.pl-friendly" patch I recently submitted.
> >
> > v4:
> >  * Addressed code review comments from Alex Bennee
> >  * MAINTAINERS file entries for new files
> >  * Trace events instead of pr_debug()
> >  * RST packet is sent when there is no listen socket
> >  * Allow guest->host connections again (began discussing netfilter supp=
ort with
> >    Matt Benjamin instead of hard-coding security policy in virtio-vsock=
 code)
> >  * Many checkpatch.pl cleanups (will be 100% clean in v5)
> >
> > v3:
> >  * Remove unnecessary 3-way handshake, just do REQUEST/RESPONSE instead
> >    of REQUEST/RESPONSE/ACK
> >  * Remove SOCK_DGRAM support and focus on SOCK_STREAM first
> >    (also drop v2 Patch 1, it's only needed for SOCK_DGRAM)
> >  * Only allow host->guest connections (same security model as latest
> >    VMware)
> >  * Don't put vhost vsock driver into staging
> >  * Add missing Kconfig dependencies (Arnd Bergmann <arnd@arndb.de>)
> >  * Remove unneeded variable used to store return value
> >    (Fengguang Wu <fengguang.wu@intel.com> and Julia Lawall
> >    <julia.lawall@lip6.fr>)
> >
> > v2:
> >  * Rebased onto Linux v4.4-rc2
> >  * vhost: Refuse to assign reserved CIDs
> >  * vhost: Refuse guest CID if already in use
> >  * vhost: Only accept correctly addressed packets (no spoofing!)
> >  * vhost: Support flexible rx/tx descriptor layout
> >  * vhost: Add missing total_tx_buf decrement
> >  * virtio_transport: Fix total_tx_buf accounting
> >  * virtio_transport: Add virtio_transport global mutex to prevent races
> >  * common: Notify other side of SOCK_STREAM disconnect (fixes shutdown
> >    semantics)
> >  * common: Avoid recursive mutex_lock(tx_lock) for write_space (fixes d=
eadlock)
> >  * common: Define VIRTIO_VSOCK_TYPE_STREAM/DGRAM hardware interface con=
stants
> >  * common: Define VIRTIO_VSOCK_SHUTDOWN_RCV/SEND hardware interface con=
stants
> >  * common: Fix peer_buf_alloc inheritance on child socket
> >
> > This patch series adds a virtio transport for AF_VSOCK (net/vmw_vsock/).
> > AF_VSOCK is designed for communication between virtual machines and
> > hypervisors.  It is currently only implemented for VMware's VMCI transp=
ort.
> >
> > This series implements the proposed virtio-vsock device specification f=
rom
> > here:
> > http://permalink.gmane.org/gmane.comp.emulators.virtio.devel/980
> >
> > Most of the work was done by Asias He and Gerd Hoffmann a while back.  =
I have
> > picked up the series again.
> >
> > The QEMU userspace changes are here:
> > https://github.com/stefanha/qemu/commits/vsock
> >
> > Why virtio-vsock?
> > -----------------
> > Guest<->host communication is currently done over the virtio-serial dev=
ice.
> > This makes it hard to port sockets API-based applications and is limite=
d to
> > static ports.
> >
> > virtio-vsock uses the sockets API so that applications can rely on fami=
liar
> > SOCK_STREAM semantics.  Applications on the host can easily connect to =
guest
> > agents because the sockets API allows multiple connections to a listen =
socket
> > (unlike virtio-serial).  This simplifies the guest<->host communication=
 and
> > eliminates the need for extra processes on the host to arbitrate virtio=
-serial
> > ports.
> >
> > Overview
> > --------
> > This series adds 3 pieces:
> >
> > 1. virtio_transport_common.ko - core virtio vsock code that uses vsock.=
ko
> >
> > 2. virtio_transport.ko - guest driver
> >
> > 3. drivers/vhost/vsock.ko - host driver
>=20
> Have a (dumb maybe) question after a quick glance at the codes:
>=20
> Is there any chance to reuse existed virtio-net/vhost-net codes? For
> example, using virito-net instead of a new device as a transport in
> guest and using vhost-net (especially consider it uses a socket as
> backend) in host. Maybe just a new virtio-net header type for vsock. I'm
> asking since I don't see any blocker for doing this.

virtio-net is an Ethernet device with best-effort delivery while
virtio-vsock is guaranteed delivery.  That's the fundamental difference
at the protocol level.

At the driver level AF_VSOCK isn't supposed to have a netdev or
user-visible network interface that can be misconfigured by the guest
administrator.

Trying to make the existing virtio-net device work for this use case is
probably nastier than using a dedicated device since lot of the
virtio-net configuration space and control features don't make sense for
AF_VSOCK.

Stefan

--Li7ckgedzMh1NgdW
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJWjiMbAAoJEJykq7OBq3PIknoH/13Kxls+dRhYDF/3ejzmU6xY
WLETn67MHHUrqrSRU7sTgCwc/oaUAEPIYWMvEnD1pVjmkSzghGMI1OK11p+pA9T0
8S1WMwKUPxOEKzvHPEc7IhTgXzOQVmum5EkCDKwykbXZZqiEfHFFgpIqwDlyKpjj
YMdAQU1V0zLW1xLNteDwrsWtLruBcnkOnZ1HnhN0d4WEeTfH6u7OJLYOuF8jO8yh
iYBqi1MA2WeKYVA2pAcfpW891nAoMCqpAUZLZOM3CV8y8RcCUc4HsPt52i1j9swK
n2Ue2TsD/wyexYsbZAV8laRr+CezMWDwkwHcaVmZ3EL5A3TDo7VH1kcxr4UYWb0=
=eVWJ
-----END PGP SIGNATURE-----

--Li7ckgedzMh1NgdW--
