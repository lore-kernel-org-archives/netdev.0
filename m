From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH 2.4.x] IPv6 multicast (MLD,IGMP) code bypasses netfilter hooks
Date: Thu, 4 Dec 2003 14:31:21 +0530
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20031204090121.GD16635@obroa-skai.de.gnumonks.org>
References: <20031122090330.GB2745@obroa-skai.de.gnumonks.org> <20031123154344.3e2b0b1a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="oj4kGyHlBMXGt3Le"
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031123154344.3e2b0b1a.davem@redhat.com>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org


--oj4kGyHlBMXGt3Le
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Nov 23, 2003 at 03:43:22PM -0800, David S. Miller wrote:
> If the fix is simple enough (1 or 2 one-liner changes) and easy
> to verify, I would consider it for 2.6.0
>=20
> I may even look into this myself.

Now that the other Dave's fix has made it in 2.6.0-test11, I have merged
it (untested, but compiles) with 2.4.x.

Dave, would you consider applying this to to 2.4.x ?

Thanks.

Greetings (still from India),
	Harald.

--- linux.old/net/ipv6/mcast.c	2003-11-28 23:55:59.000000000 +0530
+++ linux/net/ipv6/mcast.c	2003-12-04 14:21:42.000000000 +0530
@@ -45,6 +45,9 @@
 #include <linux/init.h>
 #include <linux/proc_fs.h>
=20
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv6.h>
+
 #include <net/sock.h>
 #include <net/snmp.h>
=20
@@ -1262,7 +1265,7 @@
 {
 	struct ipv6hdr *pip6 =3D skb->nh.ipv6h;
 	struct mld2_report *pmr =3D (struct mld2_report *)skb->h.raw;
-	int payload_len, mldlen;
+	int payload_len, mldlen, err;
=20
 	payload_len =3D skb->tail - (unsigned char *)skb->nh.ipv6h -
 		sizeof(struct ipv6hdr);
@@ -1271,8 +1274,10 @@
=20
 	pmr->csum =3D csum_ipv6_magic(&pip6->saddr, &pip6->daddr, mldlen,
 		IPPROTO_ICMPV6, csum_partial(skb->h.raw, mldlen, 0));
-	dev_queue_xmit(skb);
-	ICMP6_INC_STATS(Icmp6OutMsgs);
+	err =3D NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dev,
+		      dev_queue_xmit);
+	if (!err)
+		ICMP6_INC_STATS(Icmp6OutMsgs);
 }
=20
 static int grec_size(struct ifmcaddr6 *pmc, int type, int gdel, int sdel)
@@ -1596,12 +1601,16 @@
 					   IPPROTO_ICMPV6,
 					   csum_partial((__u8 *) hdr, len, 0));
=20
-	dev_queue_xmit(skb);
-	if (type =3D=3D ICMPV6_MGM_REDUCTION)
-		ICMP6_INC_STATS(Icmp6OutGroupMembReductions);
-	else
-		ICMP6_INC_STATS(Icmp6OutGroupMembResponses);
-	ICMP6_INC_STATS(Icmp6OutMsgs);
+	err =3D NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dev,
+		      dev_queue_xmit);
+	if (!err) {
+		if (type =3D=3D ICMPV6_MGM_REDUCTION)
+			ICMP6_INC_STATS(Icmp6OutGroupMembReductions);
+		else
+			ICMP6_INC_STATS(Icmp6OutGroupMembResponses);
+		ICMP6_INC_STATS(Icmp6OutMsgs);
+	}
+
 	return;
=20
 out:

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--oj4kGyHlBMXGt3Le
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQE/zvf2XaXGVTD0i/8RAgyPAJ9pxdEJHaHwVGipMPVP4FtEzYVPAwCfUKNd
t66omr9VmxcY9XO13onkzl0=
=XLO5
-----END PGP SIGNATURE-----

--oj4kGyHlBMXGt3Le--
