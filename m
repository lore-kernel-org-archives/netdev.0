From: Thomas Bleher <bleher@informatik.uni-muenchen.de>
Subject: Re: [RFC] SECMARK 1.1
Date: Wed, 17 May 2006 15:36:54 +0200
Message-ID: <20060517133653.GA7327@thorium.jmh.mhn.de>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei>
	<Pine.LNX.4.64.0605140133560.5506@d.namei>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/04w6evG8XlLl3ft"
Cc: Daniel J Walsh <dwalsh@redhat.com>, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org,
	"David S. Miller" <davem@davemloft.net>, selinux@tycho.nsa.gov,
	Stephen Smalley <sds@tycho.nsa.gov>, Patrick McHardy <kaber@trash.net>,
	Karl MacMillan <kmacmillan@tresys.com>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: James Morris <jmorris@namei.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0605140133560.5506@d.namei>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

* James Morris <jmorris@namei.org> [2006-05-14 08:03]:
> Included below is an incremental patch against the initial secmark postin=
g=20
> last week: http://thread.gmane.org/gmane.linux.network/34927/focus=3D34927
>=20
> This posting to gather feedback on changes made since then primarily to=
=20
> address concerns raised by Karl MacMillan on providing fine-grained=20
> assurances for network applications which pass connections (e.g. xinetd).
>=20
> If all looks ok, I'll rebase the entire patchset (also merging elements=
=20
> from the patch below back into other patches), and submit it for inclusio=
n=20
> in 2.6.18.  As it touches a bunch of networking code, it may be best to=
=20
> aim for Dave's tree, although it could also go into -mm.
>=20
> Anyway, the way the issue has been addressed is to implement something=20
> similar to CONNMARK, but specific to this useage scenario and dealing wit=
h=20
> security markings instead of network markings.
>=20
> In a nutshell:
>=20
> 1. A --track option was added to the SECMARK target, which causes the=20
>    security mark being applied to the packet to also be applied to a new
>    secmark field on the conntrack (only if it is unmarked).
>=20
> 2. A new CONNSECMARK target was added which copies the secmark value to=
=20
>    packets.
>=20
> This allows all packets on a connection (or related to it) to be marked=
=20
> with the same security label, so that they can be explicitly=20
> differentiated.
>=20
> This also turns out to simplify the SELinux policy, while the xtables=20
> implementation has been designed to remain as simple as possible (e.g. it=
=20
> only copies lables to packets, and has no options).
>=20
> So, here's an example of per-packet network policy for vsftpd with the ne=
w=20
> code:
>=20
>   allow ftpd_t ftpd_packet_t:packet { recv send };
>=20
> Assuming it doesn't do DNS lookups, that's it in terms of access control=
=20
> rules for packets.  This covers all established and related packets,=20
> including ICMP and the FTP data connetion.
>=20
> (see the full policy at=20
> http://people.redhat.com/jmorris/selinux/secmark/policy/ftpd_tracked/ftpd=
_tracked.te)
>=20
> In terms of iptables rules, the only real change is that we need to add=
=20
> CONNSECMARK rules for all incoming and outgoing packets (assuming you wan=
t=20
> this for all services, otherwise, use iptables selectors to apply=20
> CONNSECMARK on a per-service basis).  Here's an example for the above:
>=20
> #
> # Accept incoming connections, label SYN packets, and copy
> # labels to connections.
> #
> $IPT -A SEL_INPUT -p tcp --dport 21 -m state --state NEW -j SEL_FTPD
> $IPT -A SEL_FTPD -j SECMARK --selctx system_u:object_r:ftpd_packet_t:s0 -=
-track
> $IPT -A SEL_FTPD -j ACCEPT

This all looks very nice - Thank You!
Just one question: does the code canonicalize the security label? It
would be nice if the same rules could be used on MLS and non-MLS
systems.

Thomas

>=20
> #
> # Copy connection labels to established and related packets.
> #
> $IPT -A SEL_INPUT -m state --state ESTABLISHED,RELATED -j CONNSECMARK
> $IPT -A SEL_OUTPUT -m state --state ESTABLISHED,RELATED -j CONNSECMARK
>=20
>=20
> It should be easy to modularize the iptables rules and distribute them=20
> with policy modules, and I'd recommend always generating them with some=
=20
> script or macro.
>=20
> Everything needed to get this running (including iptables patches) is at:
> http://people.redhat.com/jmorris/selinux/secmark/
>=20
> I've also added a patch at the site which adds a kernel boot param to=20
> determine whether to use the old or new packet controls, although I'm=20
> still not sure whether it's justified adding this stuff to the kernel whe=
n=20
> it can be set at runtime during early boot.
>=20
> Please review and let me know if there any further issues.
[Code snipped]

--/04w6evG8XlLl3ft
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD4DBQFEayb1D9qpeVMU938RAmtKAJi7LgvAjZiLDoxDcbVnjA7hmLHGAJ0Zpo+w
2WvB/yTnthxz4lmEHJExjA==
=J9ft
-----END PGP SIGNATURE-----

--/04w6evG8XlLl3ft--
