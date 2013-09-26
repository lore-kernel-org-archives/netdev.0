From: Antonio Quartulli <antonio@open-mesh.com>
Subject: Re: [RFC net] bridge: clean the nf_bridge status when
 forwarding the skb
Date: Thu, 26 Sep 2013 23:16:48 +0200
Message-ID: <20130926211648.GB1228@open-mesh.com>
References: <1380226790-513-1-git-send-email-antonio@meshcoding.com>
	<20130926141021.3cde0f0f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="GID0FwUMdk1T2AWN"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20130926141021.3cde0f0f@nehalam.linuxnetplumber.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--GID0FwUMdk1T2AWN
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 26, 2013 at 02:10:21PM -0700, Stephen Hemminger wrote:
> On Thu, 26 Sep 2013 22:19:50 +0200
> Antonio Quartulli <antonio@meshcoding.com> wrote:
>=20
> > From: Antonio Quartulli <antonio@open-mesh.com>
> >=20
> > Even if enslaving a bridge interface into another bridge is
> > forbidden, it is still possible to create a chain of
> > virtual interfaces including two distinct bridges.
> >=20
> > In this case, the skb entering the second bridge could have
> > the nf_bridge field already set due to a previous operation
> > and consequently lead to a wrong processing of the packet
> > itself.
> >=20
> > To prevent this behaviour release and set to NULL the
> > nf_bridge field of the skb when exiting the bridge interface.
> >=20
> > Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
> > ---
> >=20
> > I am not sure if this is a wanted behaviour or a real BUG. I found this
> > "misbehaviour" while testing batman-adv with the following configuratio=
n:
> >=20
> > - br0 (bridge interface) having bat0 and eth0 as slaves
> > - bat0 (which is a virtual interface provided by the batman-adv module =
and that
> >   works similarly to a bridge - to some extends) having br1 as slave
> > - br1 (second bridge interface) having eth1 as slave
> >=20
> > Then follow these events:
> > - a broadcast packet arrives on eth0
> > - the skb enters br0 and skb->nf_bridge gets initialised and used
> > - the skb enters bat0 and the packet *gets encapsulated in the batman-a=
dv packet
> >   which adds a batman-adv header and another Ethernet header*
> > - the skb enters br1 and gets ruined because nf_bridge_maybe_copy_heade=
r() (in
> >   br_dev_queue_push_xmit()) will try to restore an header that does not=
 make
> >   sense anymore.
> >=20
> > With this patch the nf_bridge gets de-initialised before exiting br0 and
> > therefore it is processed properly inside br1: nf_bridge_maybe_copy_hea=
der()
> > does not take place at all because nf_bridge is never initialised (the =
packet is
> > non-IP since it is a batman-adv packet)
> >=20
> > To the developers of the bridge module I would like to ask:
> > 1) is skb->nf_bridge allowed to be non NULL when entering br_dev_xmit()=
 ? If so,
> >    when is this supposed to happen?
> >=20
> > 2) do you think this patch is logically correct but the nf_bridge relea=
se should
> >    be done in batman-adv since it is the one re-encapsulating the packe=
t?
> >=20
> >=20
> > I hope I have made the problem clear.
> >=20
> > Best regards,
> >=20
> >=20
> >  net/bridge/br_forward.c | 5 +++++
> >  1 file changed, 5 insertions(+)
> >=20
> > diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
> > index 4b81b14..65864bc 100644
> > --- a/net/bridge/br_forward.c
> > +++ b/net/bridge/br_forward.c
> > @@ -49,6 +49,11 @@ int br_dev_queue_push_xmit(struct sk_buff *skb)
> >  	} else {
> >  		skb_push(skb, ETH_HLEN);
> >  		br_drop_fake_rtable(skb);
> > +
> > +		/* clean the NF bridge data */
> > +		nf_bridge_put(skb->nf_bridge);
> > +		skb->nf_bridge =3D NULL;
> > +
> >  		dev_queue_xmit(skb);
> >  	}
> > =20

Regarding CONFIG_BRIDGE_NETFILTER you are right, thanks.

>=20
> I think the header will also be garbage if bridge on bridge with netfilte=
r is used.
> See nf_bridge_save_header.

What header are you referring to? nf_bridge_save_header() saves the header =
in
skb->nf_bridge->data, which is freed during nf_bridge_put() (assuming
->use reached 0).


--=20
Antonio Quartulli

--GID0FwUMdk1T2AWN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJSRKRAAAoJEADl0hg6qKeORW8P/0S53Vg0UCkc5V2xCiaeyzQH
kK+vW/CjVLCnoDkX80wBSaO4K0N7X+BAcX9J1KlMrLNXAp9tSygz37JazAWdFttP
zVoCV5nat9f3jO5SSbqEAUEgYEFCG2sGobjPFyBqSF1C1MI7pMmPO1GctsFfnBCu
Pm8JRCXZYjkED/ArlvXKzE4HU6p7ZzlAgqOOoGCF7C+MCu3aMjRZWjBWzZUgkrAy
YHAeg9p2gQ6t0gVlSN1yfmc4xCgw5pDk7hI8ICsmvYrs2vumtHSTDjwqfqy06AFf
SNUMcD06sYRfYYh982tcbnmZf4BdR9sd1qR+DUsnkbO7hGSAC1gWHZ+fVDSOnGOe
PwFxxyPQ76ziWAUHFFtxR4ua94L15moQfn7TIt8s5cUnIIiggWillI7oeA845+B1
dLJfBDebZ6CErd96E9s6MGFluS/Qxcvw+DSzgV0PtGl2ZHIhhHvTsS6gf4gnWL8B
cXSFnvX3SFrtQy2lyDrMhRwrbqVpA2yxXwpRrRr6nJzv1SHBP10Eiblr0pGNut4+
KnpeHVkpQhs4BTb6MyIU6TEpgLjQgZ/7k6yyAPSQyY3203avaqn+02GDKwrQ9NCF
nAOEBKt2kYc7bzhVWanxnDyObag3SuD29H7k+4CunMTQGifFjjjhZf7phmLFVCLT
fKsdO/jmPHhXGoRgiW/G
=8a6J
-----END PGP SIGNATURE-----

--GID0FwUMdk1T2AWN--
