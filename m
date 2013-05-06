From: Antonio Quartulli <antonio@open-mesh.com>
Subject: Using skb->mark outside netfilter  (was: [PATCH 0/3] bridge:
 implement restricted forwarding policy)
Date: Mon, 6 May 2013 20:48:17 +0200
Message-ID: <20130506184817.GA2729@open-mesh.com>
References: <1365442863-32394-1-git-send-email-antonio@open-mesh.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="u3/rZRmxL6MmkK24"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ht1.myhostedexchange.com ([69.50.2.37]:54161 "EHLO
	ht1.hostedexchange.local" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755138Ab3EFSuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 14:50:08 -0400
Content-Disposition: inline
In-Reply-To: <1365442863-32394-1-git-send-email-antonio@open-mesh.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--u3/rZRmxL6MmkK24
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello all,

On Mon, Apr 08, 2013 at 10:41:00 -0700, Antonio Quartulli wrote:
[...]

> The goal we want to achieve by adding this feature consists in selecting a
> subset of the interfaces available on all the hosts participating to the =
mesh
> network and to prevent packets from being forwarded from one of them to a=
nother.
>=20
> Looking again at the "very big switch" abstraction this would allow a mesh
> network administrator to define a sort of "not forwarding policy network =
wide"
> between some of the big switch's port.
>=20

I'm resurrecting this thread because after Jamal's suggestion I decided to
finally drop the idea of introducing such a net flag and focus on a differe=
nt
approach.

The new idea is to use tc to mark packets arriving into the bridge
through a predefined port (chosen by the admin when setting up the tc rule)=
 and
again use tc to drop packets having such mark when they are going out throu=
gh
another predefined port.

Now to extend this mechanism network-wide (remember that the use case is a =
Layer2
mesh network set up with batman-adv) I'm going to introduce a mechanism in
batman-adv itself which is supposed to read and write the skb->mark field
so that the value contained when the packet is leaving one end can be resto=
red
later on the other end of the intra-mesh communication (only if it matches =
a pre
configured one).
This would allow the remote node to perform the same filtering
operation as if the packet was locally generated.

Now my question is (I think David is the one who should probably decide her=
e):
is batman-adv allowed to touch the mark field of the sk_buff structure? Or =
is it
reserved for netfilter purposes only?

In my opinion this field (which survives whatever path the skb follows) is =
the
best option for this task as it allows batman-adv to "communicate" with
tc and possibly netfilter itself (if in the future users would like to perf=
orm
more complicated operations).


To clarify the idea, here you have an ascii art representing a possible set=
up
and how the mark will be read and set:


Scenario:
=3D=3D=3D=3D=3D=3D=3D=3D=3D
- Two mesh nodes configured the same way.
- Packets arriving via eth0 have to be marked with M.
- Packets marked with M should be dropped before going out through eth1.


           +------+
     ------|bridge|----
    |      +------+    |
    |         |        |
   [M]skb     |       [M]skb
 +------+ +------+ +------+     The skb is generated when arriving on eth0 =
and
 | bat0 | | eth1 | | eth0 |     is marked with the value M.
 +------+ +------+ +------+     batman-adv (operating in bat0) recognises t=
he
    |                pkt        mark and spread the information in the mesh
 +------+                       (other than forwarding the packet to the me=
sh).
 |wlan0 |
 +------+
    :bat{pkt}
 ___:_______
/           \
|   MESH    |
\___________/
    :
    :bat{pkt}
 +------+                        batman-adv on the receiving side knows that
 |wlan0 |                        this skb has to be marked and so it writes=
 M
 +------+                        into skb->mark.
    |[]skb		           The skb is now marked and can be dropped as
 +------+ +------+ +------+      instructed.
 | bat0 | | eth1 | | eth0 |
 +------+ +------+ +------+
   [M]skb     |        |
    |         |        |
    |     +------+     |
    ------|bridge|-----
          +------+



Cheers,




--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--u3/rZRmxL6MmkK24
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJRh/rxAAoJEADl0hg6qKeOXY4P/29cyS//qGKrHrklsftDRk/Z
691RckIxwDv2gMj2vuXjPTWBJL9tuRvMuui9ZkVtjt3AblxE0ZRmZCpnGQDi2PwC
TLQ/F2S2zRLKXuKw/0KuqxUMdUbOMaRry1cnwUtbCXNnVObmLZlrN/hdri5TCZdn
D2DFnonZBt0sHgVtmpmgbZ9ZD0217BuP0t5Q7slA/ex+zKRC8U4+QfA+QK41VGBE
ELEZpndrjQwI2gyPgi3wRN4SRa0FCNYPmA5jOysw0pUzSC0JSMUl66g3j3Van9DP
8Qlwx+Pk7EyUACnzmpPGb2+IizngS5ZQ/aybHpbpdPppCU8P1e1zi8B48chN7mS+
JworouiBvNezPQSa49cllOahLIs8jKBJlAhCyJrG1gMgOMu6+/n9OuSXaSxeJG02
41SGshPtj9llfcTeVx1XWegwAFklsmFwr1DoG11rWKF8HlYAKUbqGsaHpeYMQCUd
Dhl1d947eY+CwwXEuKmaCCy8zePl0XGiZtzSVCa1dCuNJbFGQq7jCnHicKB51do/
dq/nbcYhZtFGLXUuzFVlGbqrUnpLAl63sE9TW5u2FU3OwRYmy0nuqIbfwkPLIld2
zwgjnwWMYBCvordkN7M8UG7Jt6tbIu5CKvkJdCV636XX7+Oi8hZx80s/snaV8MO4
CkLm8SnWZb8viyvXvItz
=DIB7
-----END PGP SIGNATURE-----

--u3/rZRmxL6MmkK24--
