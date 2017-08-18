From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH] vsock: only load vmci transport on VMware hypervisor by
 default
Date: Fri, 18 Aug 2017 16:37:16 +0100
Message-ID: <20170818153716.GB17572@stefanha-x1.localdomain>
References: <KL1P15301MB0008F70D4E5248AB7A296CE3BF830@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170817135559.GG5539@stefanha-x1.localdomain>
 <04460E3B-B213-4090-96CD-00CEEBE6AC32@vmware.com>
 <KL1P15301MB0008A67BF969A47309CFA992BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="JYK4vJDZwFMowpUq"
Cc: "Jorgen S. Hansen" <jhansen@vmware.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
        KY Srinivasan <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        George Zhang <georgezhang@vmware.com>,
        Michal Kubecek <mkubecek@suse.cz>, Asias He <asias@redhat.com>,
        Vitaly Kuznetsov <vkuznets@redhat.com>,
        Cathy Avery <cavery@redhat.com>,
        "jasowang@redhat.com" <jasowang@redhat.com>,
        Rolf Neugebauer <rolf.neugebauer@docker.com>,
        Dave Scott <dave.scott@docker.com>,
        Marcelo Cerri <marcelo.cerri@canonical.com>,
        "apw@canonical.com" <apw@canonical.com>,
To: Dexuan Cui <decui@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <KL1P15301MB0008A67BF969A47309CFA992BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--JYK4vJDZwFMowpUq
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 18, 2017 at 03:07:30AM +0000, Dexuan Cui wrote:
> > From: Jorgen S. Hansen [mailto:jhansen@vmware.com]
> > Sent: Thursday, August 17, 2017 08:17
> > >
> > > Putting aside nested virtualization, I want to load the transport (vm=
ci,
> > > Hyper-V, vsock) for which there is paravirtualized hardware present
> > > inside the guest.
> >=20
> > Good points. Completely agree that this is the desired behavior for a g=
uest.
> >=20
> >=20
> > > It's a little tricker on the host side (doesn't matter for Hyper-V and
> > > probably also doesn't for VMware) because the host-side driver is a
> > > software device with no hardware backing it.  In KVM we assume the
> > > vhost_vsock.ko kernel module will be loaded sufficiently early.
> >=20
> > Since the vmci driver is currently tied to PF_VSOCK it hasn=E2=80=99t b=
een a problem,
> > but on the host side the VMCI driver has no hardware backing it either,=
 so
> > when we move to a more appropriate solution, this will be an issue for =
VMCI as
> > well. I=E2=80=99ll check our shipped products, but they most likely ass=
ume that if an
> > upstreamed vmci module is present, it will be loaded automatically.
>=20
> Hyper-V Sockets is a standard feature of VMBus v4.0, so we can easily know
> we can and should load iff vmbus_proto_version >=3D VERSION_WIN10.
>=20
> > > Things get trickier with nested virtualization because the VM might w=
ant
> > > to talk to its host but also to its nested VMs.  The simple way of
> > > fixing this would be to allow two transports loaded simultaneously and
> > > route traffic destined to CID 2 to the host transport and all other
> > > traffic to the guest transport.
>=20
> This sounds like a little tricky to me.
> CID is not really used by us, because we only support guest<->host commun=
ication,
> and don't support guest<->guest communication. The Hyper-V host references
> every VM by VmID (which is invisible to the VM), and a VM can only talk t=
o the
> host via this feature.

Applications running inside the guest should use VMADDR_CID_HOST (2) to
connect to the host, even on Hyper-V.

By the way, we should collaborate on a test suite and a vsock(7) man
page that documents the semantics of AF_VSOCK sockets.  This way our
transports will have the same behavior and AF_VSOCK applications will
work on all 3 hypervisors.

Not all features need to be supported.  For example, VMCI supports
SOCK_DGRAM while Hyper-V and virtio do not.  But features that are
available should behave identically.

> > This is close to the routing the VMCI driver does in a nested environme=
nt, but
> > that is with the assumption that there is only one type of transport. H=
aving two
> > different transports would require that we delay resolving the transpor=
t type
> > until the socket endpoint has been bound to an address. Things get tric=
kier if
> > listening sockets use VMADDR_CID_ANY - if only one transport is present=
, this
> > would allow the socket to accept connections from both guests and outer=
 host,
> > but with multiple transports that won=E2=80=99t work, since we can=E2=
=80=99t associate a socket
> > with a transport until the socket is bound.
> >=20
> > >
> > > Perhaps we should discuss these cases a bit more to figure out how to
> > > avoid conflicts over MODULE_ALIAS_NETPROTO(PF_VSOCK).
> >=20
> > Agreed.
>=20
> Can we use the 'protocol' parameter in the socket() function:
> int socket(int domain, int type, int protocol)=20
>=20
> IMO currently the 'protocol' is not really used.
> I think we can modify __vsock_core_init() to allow multiple transport lay=
ers to
>  be registered, and we can define different 'protocol' numbers for
> VMware/KVM/Hyper-V, and ask the application to explicitly specify what sh=
ould
> be used. Considering compatibility, we can use the default transport in a=
 given
> VM depending on the underlying hypervisor.=20

I think AF_VSOCK should hide the transport from users/applications.
Think of same-on-same nested virtualization: VMware-on-VMware or
KVM-on-KVM.  In that case specifying VMCI or virtio doesn't help.

We'd still need to distinguish between "to guest" and "to host"
(currently VMCI has code to do this but virtio does not).

The natural place to distinguish the destination is when dealing with
the sockaddr in connect(), bind(), etc.

Stefan

--JYK4vJDZwFMowpUq
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZlwmsAAoJEJykq7OBq3PIAdcH/3OXAVGfEiJ5qNOtcZ+BCN8z
9aFPmtGyWtpleahYhwOiwt2K9Nu+U22qAShghzi1iwhZ1cPZH+HNdfCht5DgZ9Dh
hPj5ZoOYaVW/ffI+XyrCzWONDDt+HA2k0/mZ2K/eJTPcmydyhgJ8/1rNsy+Nl73I
5VQW87UUvh3MMzUgJ98gg8WLzZdmZDFO7e/wMQrMdmRQd3hIy+ZT+k2riE27+p3+
dRNaiO6MRGYEtS3QHbb0bmbijg42c84edLaoWE9b34f+1FMUQ2DpAI11a9YLV6yY
5QbBnHbDpJaAWsMTF4y5G346CJuttfhw5qQfLuY29XMraPQi6KCVSxve+ZBopdU=
=PXGS
-----END PGP SIGNATURE-----

--JYK4vJDZwFMowpUq--
