From: Sven Anders <anders@anduras.de>
Subject: Re: Possible bug in bonding driver (with VLAN in ALB mode)
Date: Wed, 22 Oct 2008 16:34:45 +0200
Message-ID: <48FF3A05.1010408@anduras.de>
References: <48FE0EEB.7050503@anduras.de> <1830.1224612755@death.nxdomain.ibm.com> <48FE51C5.2010800@anduras.de> <4231.1224629540@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig409B65E9D0D4F960CA91AC8E"
To: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metropolitan.anduras.de ([80.237.200.159]:55241 "EHLO
	metropolitan.anduras.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751746AbYJVOex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 10:34:53 -0400
In-Reply-To: <4231.1224629540@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig409B65E9D0D4F960CA91AC8E
Content-Type: multipart/mixed;
 boundary="------------050801080107040209000505"

This is a multi-part message in MIME format.
--------------050801080107040209000505
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Jay Vosburgh schrieb:
> Sven Anders <anders@anduras.de> wrote:
>=20
>> Any other ideas?
>=20
> 	Try this; I actually tested this one and it seems to not crash
> my system.  This is against the current mainline, so you might have to
> apply it by hand on your older kernel.

Ok, it did not crash, but... (see comments below)

> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_=
alb.c
> index 3d39278..4fb78b0 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -341,14 +341,15 @@ static void rlb_update_entry_from_arp(struct bond=
ing *bond, struct arp_pkt *arp)
> =20
>  static int rlb_arp_recv(struct sk_buff *skb, struct net_device *bond_d=
ev, struct packet_type *ptype, struct net_device *orig_dev)
>  {
> -	struct bonding *bond =3D bond_dev->priv;
> +	struct bonding *bond;
>  	struct arp_pkt *arp =3D (struct arp_pkt *)skb->data;
>  	int res =3D NET_RX_DROP;
> =20
>  	if (dev_net(bond_dev) !=3D &init_net)
>  		goto out;
> =20
> -	if (!(bond_dev->flags & IFF_MASTER))
> +	if (!(bond_dev->priv_flags & IFF_BONDING) ||
> +	    !(bond_dev->flags & IFF_MASTER))
>  		goto out;
>  	if (!arp) {

This did not work, because the VLAN interface did not have the
BONDING flag set.

> @@ -363,6 +364,7 @@ static int rlb_arp_recv(struct sk_buff *skb, struct=
 net_device *bond_dev, struct
> =20
>  	if (arp->op_code =3D=3D htons(ARPOP_REPLY)) {
>  		/* update rx hash table for this ARP */
> +		bond =3D bond_dev->priv;
>  		rlb_update_entry_from_arp(bond, arp);
>  		dprintk("Server received an ARP Reply from client\n");
>  	}

To make this work, even for the VLAN interfaces, I had to get the
stored "bond" from the "packet_type"'s private data.
Instead I used here:

     bond =3D ptype->af_packet_priv;
     if (!bond) goto out;

> @@ -813,7 +815,7 @@ static int rlb_initialize(struct bonding *bond)
> =20
>  	/*initialize packet type*/
>  	pk_type->type =3D __constant_htons(ETH_P_ARP);
> -	pk_type->dev =3D bond->dev;
> +	pk_type->dev =3D NULL;
>  	pk_type->func =3D rlb_arp_recv;
> =20
>  	/* register to receive ARPs */

Additionally, here I store the "bond" to the private data:

    pk_type->dev =3D NULL;
    pk_type->func =3D rlb_arp_recv;
    pk_type->af_packet_priv =3D bond;

With these fixes, it worked!
That means: Receive load balancing with VLANs works.

Certainly, this is only a test bugfix only, because it does not
work with more than one active bond. Any ideas how to implement
this correctly? Do we have to use an "dev_add_pack()" for each
VLAN we are adding?

What troubles me is, that nobody since the addition of VLAN support
to bonding in 2004 had this problem before. Did this (ever) work in
one older version of the bonding driver?

Regards
 Sven

--=20
 Sven Anders <anders@anduras.de>                 () Ascii Ribbon Campaign=

                                                 /\ Support plain text e-=
mail
 ANDURAS service solutions AG
 Innstra=DFe 71 - 94036 Passau - Germany
 Web: www.anduras.de - Tel: +49 (0)851-4 90 50-0 - Fax: +49 (0)851-4 90 5=
0-55

Rechtsform: Aktiengesellschaft - Sitz: Passau - Amtsgericht Passau HRB 60=
32
Mitglieder des Vorstands: Sven Anders, Marcus Junker
Vorsitzender des Aufsichtsrats: Mark Peters

--------------050801080107040209000505
Content-Type: text/x-vcard; charset=utf-8;
 name="anders.vcf"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="anders.vcf"

begin:vcard
fn:Sven Anders
n:Anders;Sven
org:ANDURAS AG;Research and Development
adr;quoted-printable:;;Innstra=3DC3=3D9Fe 71;Passau;Bavaria;94036;Germany=

email;internet:anders@anduras.de
title:Dipl. Inf.
tel;work:++49 (0)851 / 490 50 -0
tel;fax:++49 (0)851 / 590 50 - 55
x-mozilla-html:FALSE
url:http://www.anduras.de
version:2.1
end:vcard


--------------050801080107040209000505--

--------------enig409B65E9D0D4F960CA91AC8E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFI/zoI5lKZ7Feg4EcRAhrAAJwO1c2mfeL0cfwXW9U4L8RAiT9ZdwCgngMx
pYytdrTWMit3pMOgRImWNac=
=2DVf
-----END PGP SIGNATURE-----

--------------enig409B65E9D0D4F960CA91AC8E--
