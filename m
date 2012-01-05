From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Thu, 5 Jan 2012 14:04:05 +1100
Message-ID: <20120105140405.92816482d364abfcf3854d74@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__5_Jan_2012_14_04_05_+1100_6QZJW+EiW.bI.Th="
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__5_Jan_2012_14_04_05_+1100_6QZJW+EiW.bI.Th=
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

Today's linux-next merge of the wireless-next tree got a conflict in
drivers/net/wireless/b43legacy/dma.c between commit 3db1cd5c05f3 ("net:
fix assignment of 0/1 to bool variables") from the net-next tree and
commit 5d07a3d62f63 ("b43legacy: Avoid packet losses in the dma worker
code") from the wireless-next tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/b43legacy/dma.c
index 1ee31c5,aebef75..0000000
--- a/drivers/net/wireless/b43legacy/dma.c
+++ b/drivers/net/wireless/b43legacy/dma.c
@@@ -1186,8 -1180,10 +1180,10 @@@ int b43legacy_dma_tx(struct b43legacy_w
  	if ((free_slots(ring) < SLOTS_PER_PACKET) ||
  	    should_inject_overflow(ring)) {
  		/* This TX ring is full. */
- 		ieee80211_stop_queue(dev->wl->hw, txring_to_priority(ring));
+ 		unsigned int skb_mapping =3D skb_get_queue_mapping(skb);
+ 		ieee80211_stop_queue(dev->wl->hw, skb_mapping);
+ 		dev->wl->tx_queue_stopped[skb_mapping] =3D 1;
 -		ring->stopped =3D 1;
 +		ring->stopped =3D true;
  		if (b43legacy_debug(dev, B43legacy_DBG_DMAVERBOSE))
  			b43legacydbg(dev->wl, "Stopped TX ring %d\n",
  			       ring->index);
@@@ -1285,14 -1293,21 +1293,21 @@@ void b43legacy_dma_handle_txstatus(stru
  	dev->stats.last_tx =3D jiffies;
  	if (ring->stopped) {
  		B43legacy_WARN_ON(free_slots(ring) < SLOTS_PER_PACKET);
- 		ieee80211_wake_queue(dev->wl->hw, txring_to_priority(ring));
 -		ring->stopped =3D 0;
 +		ring->stopped =3D false;
+ 	}
+=20
+ 	if (dev->wl->tx_queue_stopped[ring->queue_prio]) {
+ 		dev->wl->tx_queue_stopped[ring->queue_prio] =3D 0;
+ 	} else {
+ 		/* If the driver queue is running wake the corresponding
+ 		 * mac80211 queue. */
+ 		ieee80211_wake_queue(dev->wl->hw, ring->queue_prio);
  		if (b43legacy_debug(dev, B43legacy_DBG_DMAVERBOSE))
  			b43legacydbg(dev->wl, "Woke up TX ring %d\n",
- 			       ring->index);
+ 				     ring->index);
  	}
-=20
- 	spin_unlock(&ring->lock);
+ 	/* Add work to the queue. */
+ 	ieee80211_queue_work(dev->wl->hw, &dev->wl->tx_work);
  }
 =20
  static void dma_rx(struct b43legacy_dmaring *ring,

--Signature=_Thu__5_Jan_2012_14_04_05_+1100_6QZJW+EiW.bI.Th=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPBRMlAAoJEECxmPOUX5FEnbUP/0GNpT1I5oqPc0RwPiliHTRq
T97vek5Mjc1Y7ENvJl5DnPSda1D5sDVMGuvXR1y1Qnw+LhsyJVYsjnumsR22haFg
+4McRvzLt8E56hePDx+l0rZ56MlFx8vL1Ogf6Wh9UlZ8Ze5aZEyG2EvLa6RzRaFN
Hndf4ZTXfpAKxnFiTCZvR+4jI2tqXEpjyNyoiJZoAgF8FFlvgqZR6M9XjHp117EV
HPQRj+fseiKsWHch+hMlabD70RcR5chX/PT8AaoC/tdRgOHokrPH8AdYIwoEzcAv
5T4xfE9czc/zBfAEOXAI/DYTA0PsuVvXTyYU2+CxF+EID4EKaht5G+VLEwy0AV7v
LUFSFCMLrnCrIW+8GRccOUGqhgBE5JoKVZ0/xrI3NrV08xw9evPfoK5QKNj/eFzt
9QiMbWLK1FXDNvzqmS+CQjwaXqWtIPLy/yT24fAejITvDXMSWLpNIhYFRXXWHYxZ
U+TDNoL0jTIbuTnw34z9WkOYfMWhDc6/W+4HASYRiKP/24oZ/pyfIS3s1oqwmN/K
BdfRCR8YNd6yWNBJ5iyoYNa69Kdd0Xsj8wwmo6kC7KSiU8HV9lrZTWgBUP7PLYDO
opV+nvOnSH2TTQq7hpjVSTOonl+UN8gKf99moVhC/KPIjwRjuMTlsDwNnBsly9SC
ainihfmB7j7dihCAmNOm
=zd4a
-----END PGP SIGNATURE-----

--Signature=_Thu__5_Jan_2012_14_04_05_+1100_6QZJW+EiW.bI.Th=--
