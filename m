From: Tom Parkin <tparkin@katalix.com>
Subject: Re: Network namespace bugs in L2TP
Date: Thu, 13 Dec 2012 16:56:01 +0000
Message-ID: <20121213165601.GA2423@raven>
References: <20121212155105.GB2790@raven>
 <87k3snnjh7.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FCuugMFkClbJLl1L"
Cc: netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:47808 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753702Ab2LMQ4G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 11:56:06 -0500
Content-Disposition: inline
In-Reply-To: <87k3snnjh7.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 12, 2012 at 11:44:36AM -0800, Eric W. Biederman wrote:
> Tom Parkin <tparkin@katalix.com> writes:
> >  1. Why do we need to change the namespace of the socket created in
> >     l2tp_tunnel_sock_create?  So far as I can tell, sock_create
> >     defaults to the namespace of the calling process.  Is the issue
> >     here that this code may run from a work queue or similar?
>=20
> Something similar.  At the very least l2tp_tunnel_create which calls
> l2tp_tunnel_sock_create gets called from netlink.  The network namespace
> of a socket is not necessarily the same as the network namespace of the
> process that uses that socket.
>=20
> So since current is not necessarily the right network namespace we need
> push the desired network namespace of the socket down into
> l2tp_tunnel_sock_create and use that when creating the socket.

Ah, I see.  I hadn't appreciated that a process might swap between
namespaces.

I think that raises a question in the case of the L2TP tunnel sockets,
though.  Currently l2tp_tunnel_sock_create uses the namespace of the
current process for the socket.  The alternative is to pass in the
desired namespace from l2tp_tunnel_create -- and this makes sense, I
think.

However, when l2tp_tunnel_create is called from the netlink code, the
namespace passed is that of the netlink socket.  At the risk of sounding
silly, what's the benefit of using the netlink socket namespace over the
process namespace in this case?

> >  2. You mentioned the need to keep track of sockets allocated within a
> >     namespace in order to be able to clean them up when the namespace
> >     is deleted.  Should we be keeping a list of sockets we create and
> >     then destroying them in the namespace pernet_ops exit function?
>=20
> I think the issue that I was referring to and certainly the issue I am
> thinking about is the issue where normal sockets hold a reference to a
> network namespace and keep the network namespace alive.  Today l2tp uses
> sock_create when creating a socket, and as such I think it pins it
> current network namespace.  So I believe we can effectively have a
> reference counting loop with l2tp sockets pinning the network namespace
> and the network namespace keeping the l2tp device alive which keeps the
> l2tp socket alive.

OK, so presumably the way this would usually work is that a process
creates sockets, and when the process exits those sockets go away.
When all the processes in the namespace have exited, the namespace
can close because there are no sockets holding it open.  Is that
right?

If that's correct, then I suppose the issue with the L2TP tunnel socket
for an unmanaged tunnel is that it isn't owned by a process, per-se.
So there's no obvious way to get rid of it, apart from sending a
netlink message to tell the kernel to tear it down.

But that doesn't seem too unreasonable.  A user would have to take
explicit action to create an L2TP tunnel socket, and it might seem
reasonable for that socket to keep the namespace alive until the user
explicitly tears it down again.

> I don't remeber the specifics of l2tp as it creates some sockets, and
> has other sockets passed in, and as such has rules that are not at all
> normal.

Ack.  Sockets are created in the kernel code for "unmanaged" tunnels,
which don't run the control protocol over the top -- they're just for
data encapsulation/de-encapsulation.  "Managed" tunnels have a
userspace process looking after all the L2TP configuration and
control/keepalive protocol, and in this case the daemon handles the
creation of the tunnel socket.

Thanks,
Tom
--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--FCuugMFkClbJLl1L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJQygihAAoJEJSMBmUKuovQl9kH/3UF+aMnNSYFmPPXH2fqcwtT
p7Y1A7KYqpSr02CgWvxsQlYTyUbBdLVl5/mcZqEH/cdZGoVHm3HNZwECPEVzQlfh
dN1wT2lC1MfNY21lFgEu1fcXTOomYRrT0ad1pWHtaQjcjtOc3Doxm0ViOiSaEZGB
O76+IEtXvKNRIzVNVPRI0SRmIhuSC0GpJSGKT22nX5NbJY0QT/qwAojJZKTISR2a
8G6w+OYEG2R42VRgUSXGTp8yfxiEo4xoUfO7GsHTA/slegRz5jlYxzBzLdx8xGnF
A0yRDcujEEVvHyDPPgiQW2rDuOOaQ8VNgytN1Zi8hlsrRCLcz8FJlL0/6ZGK2F0=
=rZA/
-----END PGP SIGNATURE-----

--FCuugMFkClbJLl1L--
