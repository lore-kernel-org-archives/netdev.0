From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH V2] Add flow control to the portmapper
Date: Mon, 25 Jul 2016 08:22:14 +0300
Message-ID: <20160725052214.GY20674@leon.nu>
References: <1468869810-64420-1-git-send-email-shiraz.saleem@intel.com>
 <20160719054006.GF20674@leon.nu>
 <20160719145024.GA69464@ssaleem-MOBL4.amr.corp.intel.com>
 <20160719173253.GL20674@leon.nu>
 <20160721024750.GA52712@ssaleem-MOBL4.amr.corp.intel.com>
 <20160721172942.GW20674@leon.nu>
 <04ea01d1e377$4824a6f0$d86df4d0$@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KC8n6y+EC4k2kdZR"
Cc: 'Shiraz Saleem' <shiraz.saleem-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, 'Mustafa Ismail' <mustafa.ismail-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <04ea01d1e377$4824a6f0$d86df4d0$@opengridcomputing.com>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--KC8n6y+EC4k2kdZR
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 21, 2016 at 12:42:42PM -0500, Steve Wise wrote:
> >=20
> > On Wed, Jul 20, 2016 at 09:47:50PM -0500, Shiraz Saleem wrote:
> > > On Tue, Jul 19, 2016 at 08:32:53PM +0300, Leon Romanovsky wrote:
> > > > On Tue, Jul 19, 2016 at 09:50:24AM -0500, Shiraz Saleem wrote:
> > > > > On Tue, Jul 19, 2016 at 08:40:06AM +0300, Leon Romanovsky wrote:
> > > > > >
> > > > > > You are the one user of this new inline function.
> > > > > > Why don't you directly call to netlink_unicast() in your ibnl_u=
nicast()
> > > > > > without messing with widely visible header file?
> > > > >
> > > > > Since there is a non-blocking version of nlmsg_unicast(), the ide=
a is
> > > > > to make a blocking version available to others as well as maintain
> > > > > consistency of existing code.
> > > > >
> > > >
> > > > In such way, please provide patch series which will convert all oth=
er
> > > > users to this new call.
> > > >
> > > > =E2=9E=9C  linux-rdma git:(master) grep -rI netlink_unicast * | gre=
p -I 0
> > > > kernel/audit.c: err =3D netlink_unicast(audit_sock, skb, audit_nlk_=
portid, 0);
> > > > kernel/audit.c:         netlink_unicast(aunet->nlsk, skb, dest->por=
tid, 0);
> > > > kernel/audit.c: netlink_unicast(aunet->nlsk , reply->skb, reply->po=
rtid, 0);
> > > > kernel/audit.c: return netlink_unicast(audit_sock, skb, audit_nlk_p=
ortid, 0);
> > > > samples/connector/cn_test.c:    netlink_unicast(nls, skb, 0, 0);
> > >
> > > These usages of netlink_unicast() with blocking are not the same as t=
he new
> > > nlmsg_unicast_block() function.
> >=20
> > Really?
> > Did you look in the code?
> > Let's take first function from that grep output
> >=20
> > 414         err =3D netlink_unicast(audit_sock, skb, audit_nlk_portid, =
0);
> > 415         if (err < 0) {
> > 			... do something ...
> > 437         } else
> > 			... do something else ...
> >=20
> > which fits nicely with your proposal.
> >
>=20
> The key is to ensure that places calling a blocking service are never cal=
led in a non-blocking context.   Leon, do you know if the new sites are alw=
ays safe to block? =20
>=20
> In general, I think blocking due to sockbuf flow control vs dropping or r=
etrying is a good thing for all the users in the rdam core, assuming they a=
re safe to block.

Steve,
Sorry for my slow response,

I afraid that you was misled by the author of the proposed patch who did
two logical changes in one patch. One is move from non-blocking mode to
blocking mode which is fine enough after justification was added. And
the second change is introduction of general inline function in common
header file (include/net/netlink.h) with one caller only.

This second change is in question and I'm not feeling comfortable by
half done work.

>=20
> =20
> > +static inline int nlmsg_unicast_block(struct sock *sk, struct sk_buff =
*skb, u32
> > portid)
> > +{
> > +       int err;
> > +
> > +       err =3D netlink_unicast(sk, skb, portid, 0);
> > +       if (err > 0)
> > +               err =3D 0;
> > +
> > +       return err;
> > +}
> >=20
> >=20
> > > You can't drop in nlmsg_unicast_block() in
> > > place of netlink_unicast() in these places. I'm not going to introduc=
e code
> > > which modifies old behavior.
> >=20
> > Again, you aren't changing any behaviour.
>=20
> Potential block/sleep is a change.  But if we can conclude that these add=
itional sites are safe to block, then probably its ok to just go ahead and =
use the blocking service everywhere.

These potential sites has the same blocking call now netlink_unicast(... , =
=2E.. , ... , 0),
the difference and question if they can handle normalized return value from=
 new nlmsg_unicast_block
function. I'm convinced that the answer is yes.

--KC8n6y+EC4k2kdZR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXlaIGAAoJEORje4g2clinPH8P/3jGGXNwqhV7WAjOGxkm+uXW
PZJ7hgHvIhT8y3LkavvkKl17YQhbFl06jzn2QG9P21014RYu67cIr+KLPsJO2yQv
Iaz7619HFYKMMqhtd9NZwSY3gE6oSaq0TQZ12umfex//08U+ApnpLmZN5UiEp3cz
aD4/28J1UwvVFOwcr25WGHzCsyJr/oxXVCXfOsZw6VwVNv8s9eN9lzcsOqx5Z9Ay
E6kvYVPnOmwvI9l9yrarilnV5o+lAIQAVrmMAVxLce5Caqck7ckMHuXOZzktNdQp
PQxi+4MQ7VIMyb/Oxjc/hkNrRQRIhjihn0oeVrUNzaj9DoAJxFVUKEXxDtlMg99h
CE76/6WWJtoSCGZxAr31kjEe0uaxmy6RjDd2lA/FVaYyRj9d5N5P9M5qNLkKbbjA
FI2q3chri7EpMLdCGb0NzmdYTcaJsBeLDt24oJoHvewfGdwFXlCcY2STVnRP32cS
a9l7tpPHQl7vyJHd5lxaRtvXnOwUn8syrx2C+Dlfs9Vkn31ovhI2EcpWO71sLKL4
ZDc5lkShaKxJjZyzjzylIrO71bbzCocnK7e8Hz4lzczL7SO5cK7siiC3n7AR9hbv
RYFZOp21+7PO/NzPXkId1DIViMLqK9yKhqRFY+T8wDOyG0JytrjtxO2YBHBpf2uf
E1epIhH8Vw9HqK7aeiYS
=LA4+
-----END PGP SIGNATURE-----

--KC8n6y+EC4k2kdZR--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
