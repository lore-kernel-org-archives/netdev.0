From: Willy Tarreau <w@1wt.eu>
Subject: Re: NFS/TCP/IPv6 acting strangely in 4.2
Date: Wed, 16 Sep 2015 09:31:15 +0200
Message-ID: <20150916073115.GB29740@1wt.eu>
References: <20150911113839.GO21084@n2100.arm.linux.org.uk> <1442386435.3756.282.camel@vitec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>,
	"anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Damien =?iso-8859-1?Q?Th=E9bault?= <damien.thebault@vitec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:13339 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753064AbbIPHcL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2015 03:32:11 -0400
Content-Disposition: inline
In-Reply-To: <1442386435.3756.282.camel@vitec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Sep 16, 2015 at 06:53:57AM +0000, Damien Th=E9bault wrote:
> On Fri, 2015-09-11 at 12:38 +0100, Russell King - ARM Linux wrote:
> > I have a recent Marvell Armada 388 board here which uses the mvneta
> > driver.  I'm seeing some weird effects with NFS with it acting as a
> > client.
>=20
> Hello,
>=20
> I'm upgrading a Marvelle Armada 370 board using the mvneta driver fro=
m
> 4.0 to 4.2 and noticed issues with NFS booting.
> Basically, most of the time init returns with an error code, or
> programs segfault or throw illegal instructions.
>=20
> Since it worked fine on 4.0 I bisected until I found commit
> a84e32894191cfcbffa54180d78d7d4654d56c20 "net: mvneta: fix refilling
> for Rx DMA buffers".
>=20
> If I revert this commit, everything seems to get back to normal.
> Could you try it ? The two issues look very similar.

I'm not sure but I'm seeing that the accounting was changed by this
patch without being certain of the implications; if the revert above
works, it would be nice to try to only apply this just to see if
that's indeed an accounting error or not :

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethern=
et/marvell/mvneta.c
index 62e48bc..4205867 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1463,6 +1463,7 @@ static int mvneta_rx(struct mvneta_port *pp, int =
rx_todo,
 {
 	struct net_device *dev =3D pp->dev;
 	int rx_done;
+	int missed =3D 0;
 	u32 rcvd_pkts =3D 0;
 	u32 rcvd_bytes =3D 0;
=20
@@ -1527,6 +1528,7 @@ static int mvneta_rx(struct mvneta_port *pp, int =
rx_todo,
 		if (err) {
 			netdev_err(dev, "Linux processing - Can't refill\n");
 			rxq->missed++;
+			missed++;
 			goto err_drop_frame;
 		}
=20
@@ -1561,7 +1563,7 @@ static int mvneta_rx(struct mvneta_port *pp, int =
rx_todo,
 	}
=20
 	/* Update rxq management counters */
-	mvneta_rxq_desc_num_update(pp, rxq, rx_done, rx_done);
+	mvneta_rxq_desc_num_update(pp, rxq, rx_done, rx_done - missed);
=20
 	return rx_done;
 }

Regards,
Willy
