From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH] build some drivers only when compile-testing
Date: Thu, 23 May 2013 15:01:40 +0100
Message-ID: <1369317700.3469.256.camel@deadeye.wl.decadent.org.uk>
References: <1369214326-6558-1-git-send-email-jslaby@suse.cz>
	 <20130523022327.GB6159@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-/YrTbIfb6pF3h+cb9713"
Cc: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>, jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Jeff Mahoney <jeffm-IBi9RG/b67k@public.gmane.org>,
	Alexander Shishkin <alexander.shishkin-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Florian Tobias Schandinat <FlorianSchandinat-Mmb7MZpHnFY@public.gmane.org>,
	linux-geode-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Keller, Jacob E" <jacob.e.keller-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130523022327.GB6159-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-/YrTbIfb6pF3h+cb9713
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-05-22 at 19:23 -0700, Greg Kroah-Hartman wrote:
> On Wed, May 22, 2013 at 11:18:46AM +0200, Jiri Slaby wrote:
> > Some drivers can be built on more platforms than they run on. This
> > causes users and distributors packaging burden when they have to
> > manually deselect some drivers from their allmodconfigs. Or sometimes
> > it is even impossible to disable the drivers without patching the
> > kernel.
> >=20
> > Introduce a new config option COMPILE_TEST and make all those drivers
> > to depend on the platform they run on, or on the COMPILE_TEST option.
> > Now, when users/distributors choose COMPILE_TEST=3Dn they will not have
> > the drivers in their allmodconfig setups, but developers still can
> > compile-test them with COMPILE_TEST=3Dy.
>=20
> I understand the urge, and it's getting hard for distros to handle these
> drivers that just don't work on other architectures, but it's really
> valuable to ensure that they build properly, for those of us that don't
> have many/any cross compilers set up.
>=20
> > Now the drivers where we use this new option:
> > * PTP_1588_CLOCK_PCH: The PCH EG20T is only compatible with Intel Atom
> >   processors so it should depend on x86.
> > * FB_GEODE: Geode is 32-bit only so only enable it for X86_32.
> > * USB_CHIPIDEA_IMX: The OF_DEVICE dependency will be met on powerpc
> >   systems -- which do not actually support the hardware via that
> >   method.
>=20
> This seems ripe to start to get really messy, really quickly.  Shouldn't
> "default configs" handle if this "should" be enabled for a platform or
> not, and let the rest of us just build them with no problems?

Debian aims to provide a consistent feature set across all supported
architectures so far as possible, and I would expect other distributions
to do the same.  I don't believe anyone is coordinating defconfigs
across architectures to ensure that.

Distributions may also have particular requirements from userland that a
distribution-agnostic defconfig obviously doesn't cover.  (Isn't that
why we had the discussion about 'configure for my distribution' some
months back?)

For the driver configuration, what we provide in Debian is closer to
allmodconfig, only with some attempt to exclude those useless drivers.
Dependencies like this would make it easier to do that.

> What problems is this causing you?  Are you running out of space in
> kernel packages with drivers that will never be actually used?

On most x86 systems this isn't going to be an issue.  But if packages
are built natively (as they are for most distributions) then building
useless drivers for some architecture which doesn't have fast processors
available is a waste of precious resources.

This is particularly bad where the architecture doesn't support generic
kernels that boot on a wide range of machines and therefore we must
build many times over.  These unfortunately tend to be among those with
slower processors (ARM[1], MIPS, SH, ...).  Currently, Debian's linux
package takes ~48 hours to build for armel (ARM processors without FPU)
- and that's without building many of the PCI drivers we could for those
platforms which have PCI support.  So that's a minimum of 2 days to
provide a security update across all architectures[2].

[1] I'm aware that ARM is getting better in this regard and most ARMv7
machines are likely to be supportable by a single kernel image soon.
That doesn't mean the whole problem is solved.

[2] We don't always wait for all builds before releasing/announcing an
update; for example <http://www.debian.org/security/2013/dsa-2669>.  But
that's no comfort for those using the slower architecture.

> > +config COMPILE_TEST
> > +     bool "Compile also drivers which will not load" if EXPERT
>=20
> EXPERT is getting to be the "let's hide it here" option, isn't it...

This little detail seems likely to reduce the usefulness of randconfig
as many drivers will become dependent on both EXPERT and COMPILE_TEST
being selected.

> I don't know, if no one else strongly objects, I can be convinced that
> this is needed, but so far, I don't see why it really is, or what this
> is going to help with.

Ben.

--=20
Ben Hutchings
friends: People who know you well, but like you anyway.

--=-/YrTbIfb6pF3h+cb9713
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUZ4hROe/yOyVhhEJAQowLw//aF3B/Qj0C7QD3gq+DQq47c1LAUVFsLPq
T8VpRfvBkjjGurl5Ks3CBcubPo4Nv2Z37AyHCo1aNfMkEV7NOH6/mMeKe6qa5I05
U/fYlxERDGp/bDTvCwjkTFbeud/WKTF1q20chCAaPdnqjpHtzj9wV3vaC94CcwZ9
ZWvtQYpgObUY2t2JIryUd7q2xN1EcIBf2L0nuShsqCBe6KQCCNWfZX8imRy3F61R
JcIdkO/G5lSu5yAFC/K34L538BUFJU5u9gipXXgO9r88+riluvIAakQSTpJagmaB
Yp6Oql3GMFd7hZ3Evv5KeSsc0HnqZyvrePD/Oe4LbZYC8pdLOhBQ02GMQzAP/mF2
JkfwoGzMdD9GoSYdd61Qzqlaez8w0PI9hnLnmX2XKr0wJ3pObh3Rro+QOs/4QBwN
7nH5nJNGtq8pZlLAxDXX3QqvYHBnig5QE9g7223YwPuBDut7TlBbFH07UaZ0wFRQ
g38qXBqQ8TsUDA51evfj204qDmz6P3AN6fUM+4d6ZXGsjlkeakSxWi1zW+v1q/I0
9Fy++morArCRvwh5Bh1BeRhlIG4PlJNjwNYCmSPAYx9eFkTHyTJlmBWgj3K5fTO4
POlQC3LaK+mASEInCA93ij33i9Sj/70V3ix/cx50C7yYGuP2xfQrsOb6OJ2lJgUm
4F0rjNu0gwU=
=40uU
-----END PGP SIGNATURE-----

--=-/YrTbIfb6pF3h+cb9713--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
