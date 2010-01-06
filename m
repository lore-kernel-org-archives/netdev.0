From: Daniel Borkmann <danborkmann@googlemail.com>
Subject: [PATCH] netpoll: allow execution of multiple rx_hooks per interface
Date: Wed, 06 Jan 2010 21:54:45 +0100
Message-ID: <4B44F895.9080205@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD8659B9C58439AE254984C4B"
Cc: Jeff Moyer <jmoyer@redhat.com>, netdev@vger.kernel.org,
	netdev@oss.sgi.com, David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932791Ab0AFUzK@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD8659B9C58439AE254984C4B
Content-Type: multipart/mixed;
 boundary="------------050202060500050105010501"

This is a multi-part message in MIME format.
--------------050202060500050105010501
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi,

this patch allows the registration and _execution_ of multiple netpoll
rx_hooks per interface. Currently, it is possible to register multiple
netpoll structures to one interface, _but_ only one single rx_hook (from
the netpoll struct that has been registered last) can be executed, which
was an oversight in the implementation [1].
So, this patch fixes it. I've sucessfully tested it within 2.6.32.2 with
the registration of multiple rx_hook clients for several times. I'd
appreciate comments / feedback.

Thanks,
Daniel

[1] http://lwn.net/Articles/140852/

--------------050202060500050105010501
Content-Type: text/x-patch;
 name="netpoll_multiple_rx_hooks.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="netpoll_multiple_rx_hooks.patch"

Signed-off-by: Daniel Borkmann <danborkmann@googlemail.com>

diff -Nur a/include/linux/netpoll.h b/include/linux/netpoll.h
--- a/include/linux/netpoll.h	2010-01-05 23:52:58.000000000 +0100
+++ b/include/linux/netpoll.h	2010-01-06 00:12:54.000000000 +0100
@@ -21,6 +21,7 @@
 	__be32 local_ip, remote_ip;
 	u16 local_port, remote_port;
 	u8 remote_mac[ETH_ALEN];
+	struct netpoll *next; /* rx list for net device */
 };
=20
 struct netpoll_info {
diff -Nur a/net/core/netpoll.c b/net/core/netpoll.c
--- a/net/core/netpoll.c	2010-01-05 23:53:07.000000000 +0100
+++ b/net/core/netpoll.c	2010-01-06 20:44:59.000000000 +0100
@@ -493,13 +493,13 @@
=20
 int __netpoll_rx(struct sk_buff *skb)
 {
-	int proto, len, ulen;
+	int proto, len, ulen, hits;
 	struct iphdr *iph;
 	struct udphdr *uh;
 	struct netpoll_info *npi =3D skb->dev->npinfo;
-	struct netpoll *np =3D npi->rx_np;
+	struct netpoll **np =3D &npi->rx_np;
=20
-	if (!np)
+	if (!(*np))
 		goto out;
 	if (skb->dev->type !=3D ARPHRD_ETHER)
 		goto out;
@@ -551,16 +551,23 @@
 		goto out;
 	if (checksum_udp(skb, uh, ulen, iph->saddr, iph->daddr))
 		goto out;
-	if (np->local_ip && np->local_ip !=3D iph->daddr)
-		goto out;
-	if (np->remote_ip && np->remote_ip !=3D iph->saddr)
-		goto out;
-	if (np->local_port && np->local_port !=3D ntohs(uh->dest))
-		goto out;
=20
-	np->rx_hook(np, ntohs(uh->source),
-		    (char *)(uh+1),
-		    ulen - sizeof(struct udphdr));
+	for (hits =3D 0; (*np) !=3D NULL; np =3D &((*np)->next)) {
+		if ((*np)->local_ip && (*np)->local_ip !=3D iph->daddr)
+			continue;
+		if ((*np)->remote_ip && (*np)->remote_ip !=3D iph->saddr)
+			continue;
+		if ((*np)->local_port && (*np)->local_port !=3D ntohs(uh->dest))
+			continue;
+
+		(*np)->rx_hook((*np), ntohs(uh->source),
+			       (char *)(uh+1),
+			       ulen - sizeof(struct udphdr));
+		hits++;
+	}
+
+	if (!hits)
+		goto out;
=20
 	kfree_skb(skb);
 	return 1;
@@ -679,6 +686,45 @@
 	return -1;
 }
=20
+static int netpoll_rx_list_register(struct netpoll **np_head,
+				    struct netpoll *np)
+{
+	while ((*np_head) !=3D NULL) {
+		if ((*np_head) =3D=3D np)
+			return -EEXIST;
+		np_head =3D &((*np_head)->next);
+	}
+
+	np->next =3D *np_head;
+	rcu_assign_pointer(*np_head, np);
+	return 0;
+}
+
+static int netpoll_rx_list_unregister(struct netpoll **np_head,
+				      struct netpoll *np)
+{
+	while ((*np_head) !=3D NULL) {
+		if ((*np_head) =3D=3D np) {
+			rcu_assign_pointer(*np_head, np->next);
+			return 0;
+		}
+		np_head =3D &((*np_head)->next);
+	}
+	return -ENOENT;
+}
+
+static void netpoll_rx_list_nullify(struct netpoll **np_head)
+{
+	struct netpoll *np =3D NULL;
+
+	while ((*np_head) !=3D NULL) {
+		np =3D (*np_head);
+		np_head =3D &((*np_head)->next);
+		np->dev =3D NULL;
+		np->next =3D NULL;
+	}
+}
+
 int netpoll_setup(struct netpoll *np)
 {
 	struct net_device *ndev =3D NULL;
@@ -695,6 +741,7 @@
 		return -ENODEV;
 	}
=20
+	np->next =3D NULL;
 	np->dev =3D ndev;
 	if (!ndev->npinfo) {
 		npinfo =3D kmalloc(sizeof(*npinfo), GFP_KERNEL);
@@ -785,7 +832,7 @@
 	if (np->rx_hook) {
 		spin_lock_irqsave(&npinfo->rx_lock, flags);
 		npinfo->rx_flags |=3D NETPOLL_RX_ENABLED;
-		npinfo->rx_np =3D np;
+		netpoll_rx_list_register(&npinfo->rx_np, np);
 		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 	}
=20
@@ -801,9 +848,14 @@
 	return 0;
=20
  release:
-	if (!ndev->npinfo)
+	if (!ndev->npinfo) {
+		spin_lock_irqsave(&npinfo->rx_lock, flags);
+		netpoll_rx_list_nullify(&npinfo->rx_np);
+		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
+
 		kfree(npinfo);
-	np->dev =3D NULL;
+	}
+
 	dev_put(ndev);
 	return err;
 }
@@ -823,10 +875,11 @@
 	if (np->dev) {
 		npinfo =3D np->dev->npinfo;
 		if (npinfo) {
-			if (npinfo->rx_np =3D=3D np) {
+			if (npinfo->rx_np) {
 				spin_lock_irqsave(&npinfo->rx_lock, flags);
-				npinfo->rx_np =3D NULL;
-				npinfo->rx_flags &=3D ~NETPOLL_RX_ENABLED;
+				netpoll_rx_list_unregister(&npinfo->rx_np, np);
+				if (!npinfo->rx_np)
+					npinfo->rx_flags &=3D ~NETPOLL_RX_ENABLED;
 				spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 			}
=20
@@ -845,7 +898,10 @@
 		dev_put(np->dev);
 	}
=20
+	np->next =3D NULL;
 	np->dev =3D NULL;
+
+	synchronize_rcu();
 }
=20
 int netpoll_trap(void)

--------------050202060500050105010501--

--------------enigD8659B9C58439AE254984C4B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAktE+JUACgkQ5AxJm1m3CC/1tQCeI8R1h+rAfArWSy/65XdJZ82o
uuUAniI8xCRGNGXLErG6ZSYw7menKlWa
=cMPw
-----END PGP SIGNATURE-----

--------------enigD8659B9C58439AE254984C4B--
