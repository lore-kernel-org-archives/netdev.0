From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 3/5] net: mvneta: do not schedule in mvneta_tx_timeout
Date: Sun, 12 Jan 2014 17:38:53 +0000
Message-ID: <1389548333.3720.73.camel@deadeye.wl.decadent.org.uk>
References: <1389519069-1619-1-git-send-email-w@1wt.eu>
	 <1389519069-1619-4-git-send-email-w@1wt.eu>
	 <1389545391.3720.56.camel@deadeye.wl.decadent.org.uk>
	 <20140112165548.GC16576@1wt.eu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-v1LO8aoVD9vMYNyRKdPr"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:41065 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751214AbaALRjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 12:39:05 -0500
In-Reply-To: <20140112165548.GC16576@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-v1LO8aoVD9vMYNyRKdPr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

[Putting another hat on]

On Sun, 2014-01-12 at 17:55 +0100, Willy Tarreau wrote:
> Hi Ben,
>=20
> On Sun, Jan 12, 2014 at 04:49:51PM +0000, Ben Hutchings wrote:
> (...)
> > > So for now, let's simply ignore these timeouts generally caused by bu=
gs
> > > only.
> >=20
> > No, don't ignore them.  Schedule a work item to reset the device.  (And
> > remember to cancel it when stopping the device.)
>=20
> OK I can try to do that. Could you recommend me one driver which does thi=
s
> successfully so that I can see exactly what needs to be taken care of ?

sfc does it, though the reset logic there is more complicated than you
would need.

I think this will DTRT, but it's compile-tested only.  I have been given
an OpenBlocks AX3 but haven't set it up yet.

Ben.

---
mvneta: Defer restart from TX watchdog handler to work item

A restart requires sleeping, but the watchdog handler runs in atomic
context.

The work item can race with down-ing of the interface, so take the RTNL
lock and do nothing if the interface is already down.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/m=
arvell/mvneta.c
index d5f0d72..a91dcc2 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -234,6 +234,7 @@ struct mvneta_port {
 	struct mvneta_tx_queue *txqs;
 	struct timer_list tx_done_timer;
 	struct net_device *dev;
+	struct work_struct restart_work;
=20
 	u32 cause_rx_tx;
 	struct napi_struct napi;
@@ -2231,8 +2232,22 @@ static void mvneta_tx_timeout(struct net_device *dev=
)
 	struct mvneta_port *pp =3D netdev_priv(dev);
=20
 	netdev_info(dev, "tx timeout\n");
-	mvneta_stop_dev(pp);
-	mvneta_start_dev(pp);
+
+	/* defer mvneta_restart(), as we're in atomic context here */
+	schedule_work(&pp->restart_work);
+}
+
+static void mvneta_restart(struct work_struct *work)
+{
+	struct mvneta_port *pp =3D
+		container_of(work, struct mvneta_port, restart_work);
+
+	rtnl_lock();
+	if (netif_running(pp->dev)) {
+		mvneta_stop_dev(pp);
+		mvneta_start_dev(pp);
+	}
+	rtnl_unlock();
 }
=20
 /* Return positive if MTU is valid */
@@ -2792,6 +2807,8 @@ static int mvneta_probe(struct platform_device *pdev)
=20
 	pp =3D netdev_priv(dev);
=20
+	INIT_WORK(&pp->restart_work, mvneta_restart);
+
 	u64_stats_init(&pp->tx_stats.syncp);
 	u64_stats_init(&pp->rx_stats.syncp);
=20
@@ -2890,6 +2907,7 @@ static int mvneta_remove(struct platform_device *pdev=
)
 	struct mvneta_port *pp =3D netdev_priv(dev);
=20
 	unregister_netdev(dev);
+	cancel_work_sync(&pp->restart_work);
 	mvneta_deinit(pp);
 	clk_disable_unprepare(pp->clk);
 	iounmap(pp->base);

--=20
Ben Hutchings
Quantity is no substitute for quality, but it's the only one we've got.

--=-v1LO8aoVD9vMYNyRKdPr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUtLTLee/yOyVhhEJAQo1hg/7Bwkh60t705+nlGu0plkNqaLWCkToujeA
4MQYPPape6zXsA4uVFINzBKuatcwwWKAokX0/PEPsDTjbeYmnRn6jtenYNojEIyP
DgKu1hsrRJ0EE5uMiih7K/LWPO3lnAQYpd2ondzZpcpOdHbFLD7ygbNuuhelEZ1F
MArzz0Hqp4V1Ws9Zma5ojuwTg+8zlLf9N3l+Wa7ohcZOvyLYGeFwQu96FtDTgYF9
W7SDHW0IunbFL/gR+f3/CCCd0jMd0CAAnEOkTXhhjVbTRBDbfbbSLlSUFccz3zvu
Nz9TGV1LRErsSRuGjCT1DoUlbvDEZd1a+ybaZMzBTQJn7rdbf7vGeCMw8XonQuJT
f9pSpzy/xRjqqAo8iz6+ebshadCHYET/o4xoxw5X8gJB7zu3yeGWIVA0ACF33BlO
28YbKUIYTjIfpHIbvk5JWNPyKS5KsSo0TgokNSOVPik3E1QifkvVmXDRJjXZkEKy
CNtBl9d48nFMYEcvQy5b0CCeAJGXkRgTGs4ECWYsrVwtycvcsoe5lKXjZ9mnTOed
eHavgVkcV2E1XkI/E1VWPdzoBoBC6cnhFlFDJXIe+0NmS8U+CNUaU0KnSASMUax6
jFU2lWDMXHEtjzZZzkyKLDfdg+QdgJ7dF5iuF+d+eIRZx4WJovF/g8ANI19NhlJ0
bF7UlJdbVKg=
=hkx8
-----END PGP SIGNATURE-----

--=-v1LO8aoVD9vMYNyRKdPr--
