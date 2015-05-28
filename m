From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Thu, 28 May 2015 17:55:50 -0400
Message-ID: <1432850150.114391.56.camel@redhat.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
	 <1432647280.28905.107.camel@redhat.com> <55671309.6080303@mellanox.com>
	 <1432822057.114391.26.camel@redhat.com> <55674077.5040707@mellanox.com>
	 <20150528174337.GA10448@obsidianresearch.com>
	 <1432837360.114391.35.camel@redhat.com>
	 <CAJ3xEMh2T5-56rFxWVdct2uAZYW1ZrKivWfS45V-mvhAfwyGaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-3d9mg4yGupUgpYH1dXPJ"
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJ3xEMh2T5-56rFxWVdct2uAZYW1ZrKivWfS45V-mvhAfwyGaA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-3d9mg4yGupUgpYH1dXPJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-05-28 at 22:05 +0300, Or Gerlitz wrote:
> On Thu, May 28, 2015 at 9:22 PM, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote=
:
>=20
> >> I don't think that is what Doug said.
>=20
> > Indeed.  There is no need to scrap things, but if the design as it
> > stands, and the intended means of creating objects for use in
> > containers, is going to result in an unworkable network, then we have t=
o
> > re-evaluate how the container constructs are created, and that then has
> > possible consequences for how we would get from an incoming packet to
> > the proper container.
>=20
> To be precise, do we agree that the issue here isn't "in the design as
> it stands" but rather in a problem we found in the intended way of
> assigning IP addresses through DHCP for the containers?

No, I would say the problem *is* in the design.  But the problem is the
selected means of identifying the netdev to get to the namespace (and
the proposed means of creating non-default namespace devices to exist in
the container), not the namespace design itself.

> > I'm not trying to stop the "support train" here, but at the same time,
> > if the train is headed for a bridge that's out....
>=20
> So what's your concrete saying here? where should we go from here?

This excerpt is from the commit log of patch 3/12:

The IB device and port, together with the P_Key and the IP address should
be enough to uniquely identify the ULP net device.

The problem here is that this is wrong.  If we allow more than one
device per pkey with the same GUID, then DHCP breaks, which is bad in
and of itself, but it also breaks ipv6 link local addressing.  Which
means that this hunk in patch 4/12:

+#if IS_ENABLED(CONFIG_IPV6)
+       case AF_INET6:
+               if (ipv6_chk_addr(net, &addr_in6->sin6_addr, dev, 1))
+                       return true;
+
+               break;
+#endif

can now be tricked into returning true for incorrect devices.

Where do we go from here?

First, I'm inclined to say we should modify the add_child portion of
IPoIB to refuse to add links to a PKey if that GUID is already present
on that PKey.  You could then use different PKeys on the default GUID
for separate namespaces.  If you need separate namespaces on the same
PKey, then enable alias GUIDs for use on the local adapter and require
one GUID per namespace on the same PKey.

Then I'm inclined to say that we should map for namespaces using device,
port, guid/gid, pkey.  And in this situation, since a unique guid/gid on
any given pkey maps to a unique dhcp identifier and a unique ipv6
lladdr, this becomes freely interchangeable with device, port, pkey,
address mappings that this patchset was built around.

--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD


--=-3d9mg4yGupUgpYH1dXPJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJVZ47mAAoJELgmozMOVy/d9HMQALnYL5QrMkgE7G8D+4DYLzs7
ICOLHQ6YEtaWSXNBSkyhNMqSbWY9UCzXFng0fybK0NNfg14V/8OhwbttiurvDn8c
g5/apz5gs/NYgUCvZkY4B8IXzY1j6lXtqwVhNswfU4tjWWp7qEM3jCNPn1psScGV
1a+11vSvb/PjcQ8jPCBJnmWd4/gAnYMm1LT2kACj3YP7TLQWVChlHv2115tB8reF
xGo4alteM/9qFl4VvWpqpZ4dWP6Z4U3PiticBzEKwONZswEOsRpLu6tCwgKv32M0
NKHsr5U4+1i3b2xr9w2fI2zyI1TuzwFEa1MncjkKr67UdtE+IwLopT6cucgGepUQ
Vhej3ZuWu3sDxTgBisG+9nSgtAqxf1WGwl5lRSgMS8SEZEHKe00q9FuAVXiJYbRc
8+JlNvcUT8kYc5SV6pJb3V4Ta0Lc1xW7UeGRO8Q87RWYP8TGecx0LUT198C2+W3F
wMvRSeIFaaXO/TIuiM5Vi3FojtgBq7zvaedz5ksi9JzIHLJHNy9gyk9jg0nFIaA8
4QDq3itk/hZd10dBdbZGqleWrRyK7GqwMvnfMgyFrKQkjCofmW1eX76aoP1IDbm2
NH+/yRU2kmgYjabngH1UL1O5w23X/teVKsjVJrKEJOrk5bj8ud0F9oixNhaexPIk
ULxgfFF81sGSADbW50sc
=pLXe
-----END PGP SIGNATURE-----

--=-3d9mg4yGupUgpYH1dXPJ--

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
