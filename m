From: Antonio Quartulli <antonio@open-mesh.com>
Subject: Re: [RFC net] bridge: clean the nf_bridge status when forwarding the
 skb
Date: Fri, 27 Sep 2013 00:01:43 +0200
Message-ID: <20130926220143.GC1228@open-mesh.com>
References: <1380226790-513-1-git-send-email-antonio@meshcoding.com>
 <20130926141021.3cde0f0f@nehalam.linuxnetplumber.net>
 <20130926211648.GB1228@open-mesh.com>
 <20130926143248.2799b4ea@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="+nBD6E3TurpgldQp"
Cc: "David S. Miller" <davem@davemloft.net>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp01.online.nl ([194.134.41.31]:40277 "EHLO smtp01.online.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754390Ab3IZWBz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Sep 2013 18:01:55 -0400
Content-Disposition: inline
In-Reply-To: <20130926143248.2799b4ea@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--+nBD6E3TurpgldQp
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 26, 2013 at 02:32:48PM -0700, Stephen Hemminger wrote:
> > > > diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
> > > > index 4b81b14..65864bc 100644
> > > > --- a/net/bridge/br_forward.c
> > > > +++ b/net/bridge/br_forward.c
> > > > @@ -49,6 +49,11 @@ int br_dev_queue_push_xmit(struct sk_buff *skb)
> > > >  	} else {
> > > >  		skb_push(skb, ETH_HLEN);
> > > >  		br_drop_fake_rtable(skb);
> > > > +
> > > > +		/* clean the NF bridge data */
> > > > +		nf_bridge_put(skb->nf_bridge);
> > > > +		skb->nf_bridge =3D NULL;
> > > > +
> > > >  		dev_queue_xmit(skb);
> > > >  	}
> > > > =20
> >=20
> > Regarding CONFIG_BRIDGE_NETFILTER you are right, thanks.
> >=20
> > >=20
> > > I think the header will also be garbage if bridge on bridge with netf=
ilter is used.
> > > See nf_bridge_save_header.
> >=20
> > What header are you referring to? nf_bridge_save_header() saves the hea=
der in
> > skb->nf_bridge->data, which is freed during nf_bridge_put() (assuming
> > ->use reached 0).
> >=20
> >=20
>=20
> If bridge is stacked the original ether header will get overwritten by th=
e second
> call to save_header.

Sorry, but I am not getting what you mean (I am new to the code and it is l=
ate here..):
save_header() will store the Ethernet header in nf_bridge->data for
later recover (if needed).

By freeing nf_bridge I also destroy this header copy.

When the skb enters the second bridge, save_header() will save again the he=
ader
in nf_bridge->data. But I don't see how this can create a problem.

The problem I had before this patch comes from the fact that
nf_bridge_copy_header() is invoked in the second bridge with the nf_bridge =
state
of the first. This was overwriting my the packet Ethernet header with what =
the
first invocation of save_header() stored in nf_bridge->data.

But by unsetting nf_bridge I think I am preventing this from happening agai=
n.
no?

--=20
Antonio Quartulli

--+nBD6E3TurpgldQp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJSRK7HAAoJEADl0hg6qKeOdyEP/Ajutc26gsOEBdqDtqtGDH5p
FWdlE585xINkXgfMHMQ9Cmh/H9p1QSmLVrk2HvSb6eBsHNZQYg3IkHRNv2qm3508
XAMQ/3TcUpiHqrxnOPPw+hguXsPypNSbfce3nYwP70iNZbA8gnO7K7F1pxwQyOu3
31hXZamQNgR5dgEivF7NJ8/DWqKOUfyFI589SFfJhnJwgiizyDF3oRoKUzljQoO4
ORfsTaO0hSbR+NOdy8VkEoG/rqBeoFFQDb+k/ULyYLKM3LMRjDwCuCfD9447a/7V
WmB7mOUeuXNdAr1ZeC1cDbuvjUux4yEQtYKHtp5uvWgCJJCfko3eLKpE3WzFv069
AnW9xi1N3X6x4XS2JSPlst19oDZlNyhZeT2Z9DM94tOj4h7UwfDkdzEZqhu1NX2R
7DQmrXbyu3EbgBtDpgR4ydQMk2X/+Gw70xneIRVRBPUHm7+sbIDymtaza2bsw/h/
Ut/Ms56IcRLhuRDcSIBFHdHhVdR8OwpCtA+NqXbr1YHhqOc0JZXigEEhasExcm9E
dlVx/FdPvY4BWUHlHqbBKdBpsA0UgkA0JprordFidna6nsUUnhMe0VXWgAuqM9tt
UlLHNMOCUIOGZo8lenKNFCUKi/yP3+5bCxwHvwTU+kI7FinpKZKaUKVfrzEC6EpS
06uIqHXxRLGo862VKgWt
=IRa1
-----END PGP SIGNATURE-----

--+nBD6E3TurpgldQp--
