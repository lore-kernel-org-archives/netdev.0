From: Harald Welte <laforge@gnumonks.org>
Subject: Re: ICMP broken in 2.6.13-rc5
Date: Sat, 6 Aug 2005 18:17:56 +0200
Message-ID: <20050806161756.GD4420@rama.de.gnumonks.org>
References: <20050803115015.GA32133@tentacle.sectorb.msk.ru>
	<20050805174325.GC13345@rama.de.gnumonks.org>
	<20050805220815.GA28653@tentacle.sectorb.msk.ru>
	<20050806091337.GB4479@rama.de.gnumonks.org>
	<20050806092543.GA596@tentacle.sectorb.msk.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="yRA+Bmk8aPhU85Qt"
Cc: akpm@osdl.org, netdev@vger.kernel.org,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "Vladimir B. Savkin" <master@sectorb.msk.ru>
Content-Disposition: inline
In-Reply-To: <20050806092543.GA596@tentacle.sectorb.msk.ru>
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


--yRA+Bmk8aPhU85Qt
Content-Type: multipart/mixed; boundary="OZkY3AIuv2LYvjdk"
Content-Disposition: inline


--OZkY3AIuv2LYvjdk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Aug 06, 2005 at 01:25:43PM +0400, Vladimir B. Savkin wrote:
> On Sat, Aug 06, 2005 at 11:13:37AM +0200, Harald Welte wrote:
> > On Sat, Aug 06, 2005 at 02:08:15AM +0400, Vladimir B. Savkin wrote:
> > > I found that it really is NOTRACK who cause? bogus ICMP errors.
> >=20
> > Well, this means that your ICMP errors need to be NAT'ed but they
> > cannot, since the original connection causing the ICMP error did not go
> > through connection tracking.
>=20
> How so, when there are no NAT rules that can match either source packets
> or ICMP errors?

Ok, I re-thought.  Given the following assumptions (combined from your
three mails):

1) tcp/udp packets are matched by NOTRACK
2) icmp errors for packets in '1' are matched by NOTRACK
3) there are no NAT rules that affect the packets in '1' and '2'

I see a case where packets get corrupted within iptable_nat.  Please try
the attached (untested) patch attached to my mail.

Still, my initial comments about this being an invalid setup upholds.
The NAT code needs to see all packets/connections in order to learn
about used port/ip tuples.  Otherwise, when allocating a tuple, it could
reuse a tuple that is already used by a non-NAT'ed connection.

So using nat in combination with NOTRACK should be prevented.  I'll hack
up a patch for that, too.

--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--OZkY3AIuv2LYvjdk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="untracked.diff"
Content-Transfer-Encoding: quoted-printable

[NETFILTER] don't try to do any NAT on untracked connections

With the introduction of 'rustynat' in 2.6.11, the old tricks of preventing
NAT of 'untracked' connections (e.g. NOTRACK target in 'raw' table) are no
longer sufficient.  The ip_conntrack_untracked.status |=3D IPS_NAT_DONE_MASK
effectively prevents iteration of the 'nat' table, but doesn't prevent
nat_packet() to be executed.  Since nr_manips is gone in 'rustynat',
nat_packet() now implicitly thinks that it has to do NAT on the packet.

This patch fixes that problem by explicitly checking for
ip_conntrack_untracked in ip_nat_fn().

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit c16fd4ffed6349d0888cd97a75d04394dac42021
tree b4f0e73c7c36f3a52b23593c40f1f49353ba67e3
parent 4d08142e287f852db3f4bfd614f2d73521bd7f07
author Harald Welte <laforge@netfilter.org> Sa, 06 Aug 2005 18:11:00 +0200
committer Harald Welte <laforge@netfilter.org> Sa, 06 Aug 2005 18:11:00 +02=
00

 net/ipv4/netfilter/ip_nat_standalone.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip=
_nat_standalone.c
--- a/net/ipv4/netfilter/ip_nat_standalone.c
+++ b/net/ipv4/netfilter/ip_nat_standalone.c
@@ -100,6 +100,10 @@ ip_nat_fn(unsigned int hooknum,
 		return NF_ACCEPT;
 	}
=20
+	/* Don't try to NAT if this packet is not conntracked */
+	if (ct =3D=3D &ip_conntrack_untracked)
+		return NF_ACCEPT;
+
 	switch (ctinfo) {
 	case IP_CT_RELATED:
 	case IP_CT_RELATED+IP_CT_IS_REPLY:

--OZkY3AIuv2LYvjdk--

--yRA+Bmk8aPhU85Qt
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC9OKzXaXGVTD0i/8RApw7AJoCyL7knTh5PHyxk3LdtxKzntRFlgCePg99
UdnDB4ux8Q5pbvZJGAwWRPA=
=TMGE
-----END PGP SIGNATURE-----

--yRA+Bmk8aPhU85Qt--
