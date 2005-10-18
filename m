From: Harald Welte <laforge-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [PATCH] ebtables: Port ebt_[u]log.c to nf[netlink]_log
Date: Tue, 18 Oct 2005 10:58:53 +0200
Message-ID: <20051018085853.GG20338@sunbeam.de.gnumonks.org>
References: <20051007234903.GR4450@rama.customers.eurospot.com> <1129571999.3383.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="G6nVm6DDWH/FONJq"
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1129571999.3383.6.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ebtables-devel>,
	<mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ebtables-devel>,
	<mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ebtables-devel>
List-Id: netdev.vger.kernel.org


--G6nVm6DDWH/FONJq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 17, 2005 at 05:59:59PM +0000, Bart De Schuymer wrote:
> Op za, 08-10-2005 te 01:49 +0200, schreef Harald Welte:
> > Hi Bart!
> >=20
> > The patch below is totally untested (though it compiles), and updates
> > ebtables to resemble the behaviour that we now have in ipv4 (and ipv6):
> > {ip,ip6,eb}tables just tell the nf_log core that they want to log a
> > packet, the mechanism (syslog, nfnetlink_log, ...) is actually decided
> > by nf_log.
> >=20
> > By default, everything will behave like before.
> >=20
> > Please review, and test that ebt_log and ebt_ulog are still working as
> > expected.  Thanks!
>=20
> Sorry for the late reply, some hardware problems got in the way.

no problem, I probably hold the record of delayed responses, so I can
understand that completely ;)

> Apart from the comments below, the patch is fine by me (I tested both).

great.

> > +	nf_log_packet(PF_BRIDGE, hooknr, skb, in, out, &li, info->prefix);
>=20
> Should be ebt_log_packet

why is that?  nf_log_packet() is a function provided by the netfilter
core in net/netfilter/.  Do you want an ebt_log_packet() wrapper function t=
hat just calls
nf_log_packet() ?

> >  {
> > -	return ebt_register_watcher(&log);
> > +	int ret;
> > +
> > +	ret =3D ebt_register_watcher(&log);
> > +	if (ret < 0)
> > +		return ret;
> > +	if (nf_log_register(PF_BRIDGE, &ebt_log_logger) < 0) {
> > +		printk(KERN_WARNING "ebt_log: not logging via system console "
> > +		       "since somebody else already registered for PF_INET\n");
> > +		/* wecannot make module load fail here, since otherwise=20
> > +		 * ebtables userspace would abort */
> > +	}
>=20
> Since we're using PF_BRIDGE instead of PF_INET now, this if construct
> can be replaced by a simple call to nf_log_register.

No, I think we only fix the comment (state PF_BRIDGE in the comment) but
leave it like it is.

The issues is, when (in chronological order)

1) someone starts their logging daemon (e.g. ulogd2)
2) the daemon is configured to nf_log_register() for PF_BRIDGE
3) then the ruleset is loaded, which automatically modprobe's ebt_log.ko
4) ebt_log wants to nf_log_register() for PF_BRIDGE

I think we should print some message to syslog to tell the use (once)
that logging will not be done via the system console, even though he
uses the "log" watcher (which traditionally always logged via syslog).

Comments?

--=20
- Harald Welte <laforge-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--G6nVm6DDWH/FONJq
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFDVLlNXaXGVTD0i/8RApTfAJ9PCRWAyCfrRHGpYidTjD4RtZyqWgCeK6Ir
55etc3je4r1v/oTq+Na/gdk=
=TMIJ
-----END PGP SIGNATURE-----

--G6nVm6DDWH/FONJq--


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
