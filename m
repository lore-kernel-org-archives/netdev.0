From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the driver-core tree with the net-next
 tree
Date: Mon, 1 Dec 2014 18:19:33 +1100
Message-ID: <20141201181933.6dfaad66@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/ZwIM_HxR9btgh8Y.dkN8p=k"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arend van Spriel <arend@broadcom.com>,
	Felix Fietkau <nbd@openwrt.org>,
	Ben Greear <greearb@candelatech.com>
To: Greg KH <greg@kroah.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/ZwIM_HxR9btgh8Y.dkN8p=k
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Greg,

Today's linux-next merge of the driver-core tree got a conflict in
drivers/net/wireless/ath/ath9k/debug.c between commits 70e535ed0029
("ath9k: clean up debugfs print of reset causes"), 7b8aaead958e
("ath9k: restart hardware after noise floor calibration failure") and
325e18817668 ("ath9k: fix misc debugfs when not using chan context")
from the net-next tree and commit 631bee257bd5 ("ath: use seq_file api
for ath9k debugfs files") from the driver-core tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

Greg, I am not sure why those 2 commits are even in your tree.  Do they
depend on something else in your tree?

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/ath/ath9k/debug.c
index 696e3d5309c6,a1f1614a05c2..000000000000
--- a/drivers/net/wireless/ath/ath9k/debug.c
+++ b/drivers/net/wireless/ath/ath9k/debug.c
@@@ -832,57 -731,42 +731,46 @@@ static int read_file_misc(struct seq_fi
  			continue;
  		ath9k_calculate_iter_data(sc, ctx, &iter_data);
 =20
- 		len +=3D scnprintf(buf + len, sizeof(buf) - len,
- 			"VIFS: CTX %i(%i) AP: %i STA: %i MESH: %i WDS: %i",
- 			i++, (int)(ctx->assigned), iter_data.naps,
- 			iter_data.nstations,
- 			iter_data.nmeshes, iter_data.nwds);
- 		len +=3D scnprintf(buf + len, sizeof(buf) - len,
- 			" ADHOC: %i TOTAL: %hi BEACON-VIF: %hi\n",
- 			iter_data.nadhocs, sc->cur_chan->nvifs, sc->nbcnvifs);
+ 		seq_printf(file,
 -			   "VIF-COUNTS: CTX %i AP: %i STA: %i MESH: %i WDS: %i",
 -			   i++, iter_data.naps, iter_data.nstations,
++			   "VIFS: CTX %i(%i) AP: %i STA: %i MESH: %i WDS: %i",
++			   i++, (int)(ctx->assigned), iter_data.naps,
++			   iter_data.nstations,
+ 			   iter_data.nmeshes, iter_data.nwds);
+ 		seq_printf(file, " ADHOC: %i TOTAL: %hi BEACON-VIF: %hi\n",
+ 			   iter_data.nadhocs, sc->cur_chan->nvifs,
+ 			   sc->nbcnvifs);
  	}
 =20
- 	if (len > sizeof(buf))
- 		len =3D sizeof(buf);
-=20
- 	retval =3D simple_read_from_buffer(user_buf, count, ppos, buf, len);
- 	return retval;
+ 	return 0;
  }
 =20
- static ssize_t read_file_reset(struct file *file, char __user *user_buf,
- 			       size_t count, loff_t *ppos)
+ static int read_file_reset(struct seq_file *file, void *data)
  {
- 	struct ath_softc *sc =3D file->private_data;
+ 	struct ath_softc *sc =3D dev_get_drvdata(file->private);
 +	static const char * const reset_cause[__RESET_TYPE_MAX] =3D {
 +		[RESET_TYPE_BB_HANG] =3D "Baseband Hang",
 +		[RESET_TYPE_BB_WATCHDOG] =3D "Baseband Watchdog",
 +		[RESET_TYPE_FATAL_INT] =3D "Fatal HW Error",
 +		[RESET_TYPE_TX_ERROR] =3D "TX HW error",
 +		[RESET_TYPE_TX_GTT] =3D "Transmit timeout",
 +		[RESET_TYPE_TX_HANG] =3D "TX Path Hang",
 +		[RESET_TYPE_PLL_HANG] =3D "PLL RX Hang",
 +		[RESET_TYPE_MAC_HANG] =3D "MAC Hang",
 +		[RESET_TYPE_BEACON_STUCK] =3D "Stuck Beacon",
 +		[RESET_TYPE_MCI] =3D "MCI Reset",
 +		[RESET_TYPE_CALIBRATION] =3D "Calibration error",
 +	};
- 	char buf[512];
- 	unsigned int len =3D 0;
 +	int i;
 =20
 -	seq_printf(file, "%17s: %2d\n", "Baseband Hang",
 -		   sc->debug.stats.reset[RESET_TYPE_BB_HANG]);
 -	seq_printf(file, "%17s: %2d\n", "Baseband Watchdog",
 -		   sc->debug.stats.reset[RESET_TYPE_BB_WATCHDOG]);
 -	seq_printf(file, "%17s: %2d\n", "Fatal HW Error",
 -		   sc->debug.stats.reset[RESET_TYPE_FATAL_INT]);
 -	seq_printf(file, "%17s: %2d\n", "TX HW error",
 -		   sc->debug.stats.reset[RESET_TYPE_TX_ERROR]);
 -	seq_printf(file, "%17s: %2d\n", "TX Path Hang",
 -		   sc->debug.stats.reset[RESET_TYPE_TX_HANG]);
 -	seq_printf(file, "%17s: %2d\n", "PLL RX Hang",
 -		   sc->debug.stats.reset[RESET_TYPE_PLL_HANG]);
 -	seq_printf(file, "%17s: %2d\n", "MAC Hang",
 -		   sc->debug.stats.reset[RESET_TYPE_MAC_HANG]);
 -	seq_printf(file, "%17s: %2d\n", "Stuck Beacon",
 -		   sc->debug.stats.reset[RESET_TYPE_BEACON_STUCK]);
 -	seq_printf(file, "%17s: %2d\n", "MCI Reset",
 -		   sc->debug.stats.reset[RESET_TYPE_MCI]);
 +	for (i =3D 0; i < ARRAY_SIZE(reset_cause); i++) {
 +		if (!reset_cause[i])
 +		    continue;
 +
- 		len +=3D scnprintf(buf + len, sizeof(buf) - len,
- 				 "%17s: %2d\n", reset_cause[i],
- 				 sc->debug.stats.reset[i]);
++		seq_printf(file, "%17s: %2d\n", reset_cause[i],
++			   sc->debug.stats.reset[i]);
 +	}
 =20
- 	if (len > sizeof(buf))
- 		len =3D sizeof(buf);
-=20
- 	return simple_read_from_buffer(user_buf, count, ppos, buf, len);
+ 	return 0;
  }
 =20
  void ath_debug_stat_tx(struct ath_softc *sc, struct ath_buf *bf,
@@@ -1331,16 -1175,16 +1179,16 @@@ int ath9k_init_debug(struct ath_hw *ah
 =20
  	ath9k_dfs_init_debug(sc);
  	ath9k_tx99_init_debug(sc);
 -	ath9k_spectral_init_debug(sc);
 +	ath9k_cmn_spectral_init_debug(&sc->spec_priv, sc->debug.debugfs_phy);
 =20
- 	debugfs_create_file("dma", S_IRUSR, sc->debug.debugfs_phy, sc,
- 			    &fops_dma);
- 	debugfs_create_file("interrupt", S_IRUSR, sc->debug.debugfs_phy, sc,
- 			    &fops_interrupt);
- 	debugfs_create_file("xmit", S_IRUSR, sc->debug.debugfs_phy, sc,
- 			    &fops_xmit);
- 	debugfs_create_file("queues", S_IRUSR, sc->debug.debugfs_phy, sc,
- 			    &fops_queues);
+ 	debugfs_create_devm_seqfile(sc->dev, "dma", sc->debug.debugfs_phy,
+ 				    read_file_dma);
+ 	debugfs_create_devm_seqfile(sc->dev, "interrupt", sc->debug.debugfs_phy,
+ 				    read_file_interrupt);
+ 	debugfs_create_devm_seqfile(sc->dev, "xmit", sc->debug.debugfs_phy,
+ 				    read_file_xmit);
+ 	debugfs_create_devm_seqfile(sc->dev, "queues", sc->debug.debugfs_phy,
+ 				    read_file_queues);
  	debugfs_create_u32("qlen_bk", S_IRUSR | S_IWUSR, sc->debug.debugfs_phy,
  			   &sc->tx.txq_max_pending[IEEE80211_AC_BK]);
  	debugfs_create_u32("qlen_be", S_IRUSR | S_IWUSR, sc->debug.debugfs_phy,

--Sig_/ZwIM_HxR9btgh8Y.dkN8p=k
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUfBaNAAoJEMDTa8Ir7ZwV+mwP/1TwtGHV4iZ8T1Js+Qj7oL2l
T5Kyt8LBeGOeDi3GNK/tTxIoIzV7ymjqrjZV7Tr+F5cPgyZhRXR7EauWs3oo6x7h
Dh5eVT38h82e3bEnM8QjORz8OIlr9XI2ATaNMTqFz5H8ThWNI7OzYjJNu9jI3td1
/2i4IrFB0snuD71KKfz/G36MRJn/Dfibqu/Into6FVlJxKBZGt7pIke5zu4KUSlw
K3imU/F47E16UYH9sfA4GDCG9Cr4vJpidkOWngj4W15l+YhzBNcOvRlVygRaEm2g
n3TklMwuouxC1ENQWmrGLYmP3fIaJqi26EdZuv23ZjUfDzqBEZi8wi67V1c09+Pz
QnkzLaSRxR5JnGhNCXDw9XopUDHP4hqaQxLWX0bOT/OsbFIHSwCmm45NF/wnaTXx
v5BzsqoMolWOixnAluNZVHpVpUj/s22C13q4MBjBsLkeRD7tUGdxF4rrP9N/sP6M
FLdP/6mL6OFLujzllbzk7hyJKzVROkSKa4PpW009Zpdp6zYdGlVmJsA72RHSoYkh
Q2nQf3/4ugADaZt4C8BpwqR2zrzsoEbQn4V6m5Qzf05F4T3F5GqzMsGe/s3fTz0Q
gzVpvl9R2KNGaCoSix4YF+FN2g/wIsbDz+vYzmyOhjbP8quxCSiTjXEgd13gI1WE
tK9fmcZKXd15bsqzFFR8
=Z4CR
-----END PGP SIGNATURE-----

--Sig_/ZwIM_HxR9btgh8Y.dkN8p=k--
