From: Tom Parkin <tparkin@katalix.com>
Subject: Re: Network namespace bugs in L2TP
Date: Thu, 20 Dec 2012 13:52:54 +0000
Message-ID: <20121220135254.GA2450@raven>
References: <20121212155105.GB2790@raven>
 <87k3snnjh7.fsf@xmission.com>
 <20121213165601.GA2423@raven>
 <87r4mt4um7.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="k+w/mQv8wyuph6w0"
Cc: netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:59004 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751994Ab2LTNxB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 08:53:01 -0500
Content-Disposition: inline
In-Reply-To: <87r4mt4um7.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--k+w/mQv8wyuph6w0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Eric,

On Thu, Dec 13, 2012 at 11:31:12AM -0800, Eric W. Biederman wrote:
> Tom Parkin <tparkin@katalix.com> writes:
>=20
> > On Wed, Dec 12, 2012 at 11:44:36AM -0800, Eric W. Biederman wrote:
> >> Tom Parkin <tparkin@katalix.com> writes:
> > I think that raises a question in the case of the L2TP tunnel sockets,
> > though.  Currently l2tp_tunnel_sock_create uses the namespace of the
> > current process for the socket.  The alternative is to pass in the
> > desired namespace from l2tp_tunnel_create -- and this makes sense, I
> > think.
> >
> > However, when l2tp_tunnel_create is called from the netlink code, the
> > namespace passed is that of the netlink socket.  At the risk of sounding
> > silly, what's the benefit of using the netlink socket namespace over the
> > process namespace in this case?
>=20
> Using the netlink socket namespace ensure that if the netlink socket is
> passed between processes the semantics of sending messages down the
> netlink socket don't change.
>=20
> There is another thread on netdev discussing another variant of this
> right now.  For some cases it is just a waste of resources to have one
> copy of a daemon per network namespace.  In which case a controlling
> daemon will open one netlink socket per network namespace and send
> commands down the appropriate socket for the network namespace the
> daemon wishes to control.

Yes, I saw that other thread.  Thanks for the clarification on this
point.

> > But that doesn't seem too unreasonable.  A user would have to take
> > explicit action to create an L2TP tunnel socket, and it might seem
> > reasonable for that socket to keep the namespace alive until the user
> > explicitly tears it down again.
>=20
> Sending a netlink message to tear down the socket is not unreasonable.
>=20
> Having a reference counting loop such that it is possible to close all
> other sockets and all other references to a network namespace and not
> have the network namespace go away because the L2TP tunnel socket holds
> a reference to the unreachable and unuusable network namespace is
> unreasonable.
>=20
> We handle this with arp and icmp control sockets by not creating a
> reference count.  And having a pernet cleanup routing clean up those
> sockets.  Assuming I am right about the reference counting loop being
> possible this is something to look at.

Yep, OK.  I hadn't appreciated the namespace could become inaccessible!

I've done some digging and I believe there is an issue with the
reference counting for the unmanaged tunnel sockets -- certainly I am
able to leak netns resources here.

I've been working on a patchset which I hope will address these issues
in l2tp_core.  I'm stress testing it now and hope to post to netdev
soon for review.

Thanks again for your help.

Tom
--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--k+w/mQv8wyuph6w0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJQ0xg2AAoJEJSMBmUKuovQdRwH/0dCOzspnx8lp/EKxAHdNsBH
FS4p0z0/jXW1xeMhD4XK5rlQN6vujhBAh9xoWsTo1iAbAH+XSkiZHHgdsf0pbi9T
mfJ2qbkIYYjVkkgDXw4Nih3vrea9kT2zvnf4WpswSCUITl7yd6rf48HN0F1SRIuO
qvU8VAl4U8CeE0VHhlxaIg4ikQGVZPetvKh3m0r0OPSSjhHqnwG2YR8GMZlkWVVX
ER5m3tSyubfXYPUEkywbA75U+CJbcBkbbF/YUgZMOX2TsWFT7lhwD6Z+wVxanTKW
Iyx0YSHw2OpcaBH+XQkSZgq78KTh/H9RDWH+ZF+e+YArT9L0n24iEt2br4eiZP4=
=0/aK
-----END PGP SIGNATURE-----

--k+w/mQv8wyuph6w0--
