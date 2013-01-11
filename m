From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 11 Jan 2013 13:03:43 +1100
Message-ID: <20130111130343.36787155f84ed84387c7286e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__11_Jan_2013_13_03_43_+1100_wa=J4NXvRnnCDN=3"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Yuval Mintz <yuvalmin@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__11_Jan_2013_13_03_43_+1100_wa=J4NXvRnnCDN=3
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c between commit
4864a16ae69d ("bnx2x: Fix fastpath structures when memory allocation
fails") from the net tree and commit 8ca5e17e58c9 ("bnx2x: Support of PF
driver of a VF acquire request") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index f771ddf,00706c4..0000000
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@@ -87,30 -85,33 +85,58 @@@ static inline void bnx2x_move_fp(struc
  }
 =20
  /**
 + * bnx2x_shrink_eth_fp - guarantees fastpath structures stay intact
 + *
 + * @bp:	driver handle
 + * @delta:	number of eth queues which were not allocated
 + */
 +static void bnx2x_shrink_eth_fp(struct bnx2x *bp, int delta)
 +{
 +	int i, cos, old_eth_num =3D BNX2X_NUM_ETH_QUEUES(bp);
 +
 +	/* Queue pointer cannot be re-set on an fp-basis, as moving pointer
 +	 * backward along the array could cause memory to be overriden
 +	 */
 +	for (cos =3D 1; cos < bp->max_cos; cos++) {
 +		for (i =3D 0; i < old_eth_num - delta; i++) {
 +			struct bnx2x_fastpath *fp =3D &bp->fp[i];
 +			int new_idx =3D cos * (old_eth_num - delta) + i;
 +
 +			memcpy(&bp->bnx2x_txq[new_idx], fp->txdata_ptr[cos],
 +			       sizeof(struct bnx2x_fp_txdata));
 +			fp->txdata_ptr[cos] =3D &bp->bnx2x_txq[new_idx];
 +		}
 +	}
 +}
 +
++/**
+  * bnx2x_fill_fw_str - Fill buffer with FW version string.
+  *
+  * @bp:        driver handle
+  * @buf:       character buffer to fill with the fw name
+  * @buf_len:   length of the above buffer
+  *
+  */
+ void bnx2x_fill_fw_str(struct bnx2x *bp, char *buf, size_t buf_len)
+ {
+ 	if (IS_PF(bp)) {
+ 		u8 phy_fw_ver[PHY_FW_VER_LEN];
+=20
+ 		phy_fw_ver[0] =3D '\0';
+ 		bnx2x_get_ext_phy_fw_version(&bp->link_params,
+ 					     phy_fw_ver, PHY_FW_VER_LEN);
+ 		strlcpy(buf, bp->fw_ver, buf_len);
+ 		snprintf(buf + strlen(bp->fw_ver), 32 - strlen(bp->fw_ver),
+ 			 "bc %d.%d.%d%s%s",
+ 			 (bp->common.bc_ver & 0xff0000) >> 16,
+ 			 (bp->common.bc_ver & 0xff00) >> 8,
+ 			 (bp->common.bc_ver & 0xff),
+ 			 ((phy_fw_ver[0] !=3D '\0') ? " phy " : ""), phy_fw_ver);
+ 	} else {
+ 		bnx2x_vf_fill_fw_str(bp, buf, buf_len);
+ 	}
+ }
+=20
  int load_count[2][3] =3D { {0} }; /* per-path: 0-common, 1-port0, 2-port1=
 */
 =20
  /* free skb in the packet ring at pos idx

--Signature=_Fri__11_Jan_2013_13_03_43_+1100_wa=J4NXvRnnCDN=3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQ73L/AAoJEECxmPOUX5FE1ekP+wfCaEBgRA3qQmuFXv9/wDgD
D4Fsv+bdz1OMi9SKe32XSm37CiGDTnxzxwjjDZDdVWcGulHsI7RLMIZPqwlB8rg2
8sb310GIuZaY/RLnMi00q2pTwDT/kHv0DPZOJIU7Ct9712Z7LajMuIT2gS1SLh/F
ZFcXvcD+6ghUzWStE6EvSfVcNQULMY4YBHrexRjqo7VU8z591uWEGGfQmOX0VeRg
ofcoFt6pywKitWydYHz8wXWYTCthk61x70BKPm21z1xdkjgl76E41uoijVXJ/L07
a0FjyXq8QTyaGOkuZwNQM5uN1IdkUHcmSs/saXy2DoeZhIEoqKgazWcElf+0nu1y
wJs2FCewAzx9P6yZeMVem6uk6mWNCk6cXyjBHbOnezBu3yrCxD9Vb9H/PWlIwC7q
ihUJwuf4FOtqQaw1vjcuI6JGmz4JYSc2k+6ND7UiacVAuCA8eJWzJAJTxUxEztSW
VEbDvJgerHvq9W/e6WeorcT1vPUQQHeTaaHI4Bq/cDnwRvJlLuvOyJ5ESRtvILo1
+Vz8Ym5MT+9qHdUDRiHKx4Y8nW5On8t+f4bz1oyDe8yxsCXj/6ZQKQC53y5/hfH4
XvHG1tSqPd+014v1i2iucRMpbU/SDKS3bGSq4iZ9IAX1QKrk86xSM2rmzK1qIAba
6akI3gdOY8yTkdphEycI
=RxCy
-----END PGP SIGNATURE-----

--Signature=_Fri__11_Jan_2013_13_03_43_+1100_wa=J4NXvRnnCDN=3--
