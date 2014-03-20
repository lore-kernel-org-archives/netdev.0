From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH 1/3] bridge: preserve random init MAC address
Date: Thu, 20 Mar 2014 03:05:40 +0100
Message-ID: <20140320020540.GF28801@wotan.suse.de>
References: <1394680527-28970-1-git-send-email-mcgrof@do-not-panic.com> <1394680527-28970-2-git-send-email-mcgrof@do-not-panic.com> <20140318201056.7b876394@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Rgf3q3z9SdmXC6oT"
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, xen-devel@lists.xenproject.org,
	bridge@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140318201056.7b876394@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Rgf3q3z9SdmXC6oT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 18, 2014 at 08:10:56PM -0700, Stephen Hemminger wrote:
> On Wed, 12 Mar 2014 20:15:25 -0700
> "Luis R. Rodriguez" <mcgrof@do-not-panic.com> wrote:
>=20
> > As it is now if you add create a bridge it gets started
> > with a random MAC address and if you then add a net_device
> > as a slave but later kick it out you end up with a zero
> > MAC address. Instead preserve the original random MAC
> > address and use it.
>=20
> What is supposed to happen is that the recalculate chooses
> the lowest MAC address of the slaves. If there are no slaves
> it might as well just calculate a new random value. There is
> not great merit in preserving the original defunct address.
>=20
> Or something like this
> --- a/net/bridge/br_stp_if.c	2014-02-12 08:21:56.733857356 -0800
> +++ b/net/bridge/br_stp_if.c	2014-03-18 20:09:09.334388826 -0700
> @@ -235,6 +235,9 @@ bool br_stp_recalculate_bridge_id(struct
>  			addr =3D p->dev->dev_addr;
> =20
>  	}
> +
> +	if (addr =3D=3D br_mac_zero)
> +		return false;  /* keep original address */
> =20
>  	if (ether_addr_equal(br->bridge_id.addr, addr))
>  		return false;	/* no change */
>=20
> that just keeps the old value.

The old value could be a port which got root blocked, I think
it can be confusing to see that happen. Either way feel free to
make the call, I'll provide more details below on perhaps one reason
to keep the original MAC address.

> The bridge is in a meaningless state when there are no ports,

Some virtualization topologies may want a backend with no link (or
perhaps one which is dynamic, with the option to have none) to the
internet but just a bridge so guests sharing the bridge can talk to=20
each other. In this case bridging can be used only to link the
batch of guests.

In this case the bridge simply acts as a switch, but also can be used as the
interface for DHCP, for example. In such a case the guests will be doing
ARP to get to the DHCP server. There's a flurry of ways one can try to get
all this meshed together including enablign an ARP proxy but I'm looking
at ways to optimize this further -- but I'd like to address the current
usage cases first.

> and when the first port is added back it will be used as the
> new bridge id.

Sure. Let me know how you think we should proceed with this patch based
on the above.

  Luis

--Rgf3q3z9SdmXC6oT
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)

iQIcBAEBAgAGBQJTKkz0AAoJEPep4JnvMe6zIjQQAIaPp0PA7yP7u0xd9zfXEk6D
Wu8DWiwDpRFzUiXwzG0YP8D5uyorvKTfsgb+7HUYbswbkOxa5HdwCrggT63+SPb8
+d4UqH8nQTCx0yRXU52UFb6kAwyaNGrd5TiGZgwVSE2XzO2S7+Epjcjm+nwnfX63
v7j410NCswB7rMYHiyGDWTIFWMoEy31f/xDPs+hSTVIXbCrg84D2kP0wIlULKsa9
Q1U4GyPRK5o6AATOsZHzcwnzNNgaTNtOYh1tOcOm7+Xl7cY/HCKjKar0M730CuDU
ltni1SN0DeIjPqzrXnLZPRdKfa73/CAIacrADVkr8SqtZPHmQSN1L2NHSGZrRRl3
32otSLedC4nilbKdF199fIj0HrJwp/ik4vZjfYPjjZTxr9bBlZBfbgOOFbO8Xc3h
4koN4wkTf9/MainQL/2NVC1QCmh00tJ/CabkuN/sFAYFPJd7ykECHMbXQol/w66v
lvaEEk27oig1JXMcu1x9a7sn1n3YmCsnnV/E04sfBULKVhflsK2Keuy2z5TeXLjR
93b1+QrJIdaUJt9CQkgxO7Kzjs4azMRpLl/7/uB8X6SuAOJyhmKbrxPhR6PAbdD8
uqBUbAFwKiKEEgPKEjZ5KnyBrUXGiASVRqOjYYGOiscFHQfqWawf9lzZXjsJps/4
u7Z/zpcajDEKowIpYtr3
=v79u
-----END PGP SIGNATURE-----

--Rgf3q3z9SdmXC6oT--
