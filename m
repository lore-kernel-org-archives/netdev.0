From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Wed, 10 Dec 2014 19:54:05 +1100
Message-ID: <20141210195405.5af40846@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/=ckAssR/iWDt5AO31t3/Vem"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/=ckAssR/iWDt5AO31t3/Vem
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
allyesconfig) failed like this:

drivers/net/ethernet/chelsio/cxgb4vf/built-in.o:(.opd+0x630): multiple defi=
nition of `t4_bar2_sge_qregs'
drivers/net/ethernet/chelsio/cxgb4/built-in.o:(.opd+0x14d0): first defined =
here
drivers/net/ethernet/chelsio/cxgb4vf/built-in.o: In function `.t4_bar2_sge_=
qregs':
(.text+0x9220): multiple definition of `.t4_bar2_sge_qregs'
drivers/net/ethernet/chelsio/cxgb4/built-in.o:(.text+0x24e24): first define=
d here

Caused by commit e85c9a7abfa4 ("cxgb4/cxgb4vf: Add code to calculate T5
BAR2 Offsets for SGE Queue Registers") which added both versions.  :-(

I have applied this fir patch for today (including the subject
typo :-)):

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 10 Dec 2014 19:48:02 +1100
Subject: [PATCH] cxgb4/cxgb4vf: global named must be unique

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      | 2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 4 ++--
 drivers/net/ethernet/chelsio/cxgb4/sge.c        | 2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ether=
net/chelsio/cxgb4/cxgb4.h
index 2c37e1bf253a..a18d33fdb271 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1007,7 +1007,7 @@ int t4_prep_fw(struct adapter *adap, struct fw_info *=
fw_info,
 int t4_prep_adapter(struct adapter *adapter);
=20
 enum t4_bar2_qtype { T4_BAR2_QTYPE_EGRESS, T4_BAR2_QTYPE_INGRESS };
-int t4_bar2_sge_qregs(struct adapter *adapter,
+int cxgb4_t4_bar2_sge_qregs(struct adapter *adapter,
 		      unsigned int qid,
 		      enum t4_bar2_qtype qtype,
 		      u64 *pbar2_qoffset,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/=
ethernet/chelsio/cxgb4/cxgb4_main.c
index c8c5b3d36d4e..1645f59648f0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3815,7 +3815,7 @@ int cxgb4_bar2_sge_qregs(struct net_device *dev,
 			 u64 *pbar2_qoffset,
 			 unsigned int *pbar2_qid)
 {
-	return t4_bar2_sge_qregs(netdev2adap(dev),
+	return cxgb4_t4_bar2_sge_qregs(netdev2adap(dev),
 				 qid,
 				 (qtype =3D=3D CXGB4_BAR2_QTYPE_EGRESS
 				  ? T4_BAR2_QTYPE_EGRESS
@@ -4011,7 +4011,7 @@ static void process_db_drop(struct work_struct *work)
 		unsigned int bar2_qid;
 		int ret;
=20
-		ret =3D t4_bar2_sge_qregs(adap, qid, T4_BAR2_QTYPE_EGRESS,
+		ret =3D cxgb4_t4_bar2_sge_qregs(adap, qid, T4_BAR2_QTYPE_EGRESS,
 					&bar2_qoffset, &bar2_qid);
 		if (ret)
 			dev_err(adap->pdev_dev, "doorbell drop recovery: "
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/etherne=
t/chelsio/cxgb4/sge.c
index f12debd98dac..ebf935a1e352 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2270,7 +2270,7 @@ static void __iomem *bar2_address(struct adapter *ada=
pter,
 	u64 bar2_qoffset;
 	int ret;
=20
-	ret =3D t4_bar2_sge_qregs(adapter, qid, qtype,
+	ret =3D cxgb4_t4_bar2_sge_qregs(adapter, qid, qtype,
 				&bar2_qoffset, pbar2_qid);
 	if (ret)
 		return NULL;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ether=
net/chelsio/cxgb4/t4_hw.c
index 67345c73e570..28d04153f999 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -4031,7 +4031,7 @@ int t4_prep_adapter(struct adapter *adapter)
 }
=20
 /**
- *	t4_bar2_sge_qregs - return BAR2 SGE Queue register information
+ *	cxgb4_t4_bar2_sge_qregs - return BAR2 SGE Queue register information
  *	@adapter: the adapter
  *	@qid: the Queue ID
  *	@qtype: the Ingress or Egress type for @qid
@@ -4055,7 +4055,7 @@ int t4_prep_adapter(struct adapter *adapter)
  *	Write Combining Doorbell Buffer. If the BAR2 Queue ID is not 0,
  *	then these "Inferred Queue ID" register may not be used.
  */
-int t4_bar2_sge_qregs(struct adapter *adapter,
+int cxgb4_t4_bar2_sge_qregs(struct adapter *adapter,
 		      unsigned int qid,
 		      enum t4_bar2_qtype qtype,
 		      u64 *pbar2_qoffset,
--=20
2.1.3

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/=ckAssR/iWDt5AO31t3/Vem
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUiAoyAAoJEMDTa8Ir7ZwV8DoP/2o6KfcdbYMPfzJCKz7TWpkv
1SIMakMwGnVGr5esy6DbVTDh35upKz/1VXzhIoepxpKd0cEFDA8yF4FCkEADUDJQ
EAz7rPD4cKDdiaYgv6sj0fG6yWPP53cQC7aT6Fd4qA0hs2KGVSSUccxah4ZPPRMv
FV+8c43w4LgWr4MqGA2sMOHIaBCliQ8CZn+p5wM+Kij39SeGffPyAkIBinD5Prm2
o+7kLgfyA3ACKtJ8gOrLBBg9MqWgbAXepZVydC2JeD9j3Ax94lZwWfi0f8TIEvRt
jDTTFcYGqYHv1tSQvQijjsN9YcundWLdZNzNT92L7geHJ9AY4jc2zw5WXAthWSmO
8WSIZRDsTeR2giij6wuK8rGIQGvtyXUaLqt/iMne0Z/zg+tgEkXx/lC3yPvHclOr
bBD/N1wnpaBAMBaZKZFoa1ip5s1l3b9wg6lZFefGfOdS+ZPB1Lmm3TaDq2o9WPWc
8dJJXhoz/cEVH4oR8q96vtHg9FCIXiMaUccdlFWO2prIhzcESNLt8eOZ3EuLkhiU
czySy4u39zglijKZfbjIZPuJexMl4fcMB+jXyj/7zFXl8jNudXDR2+WprJd89gNG
EPIbHEoJhJqpfhEg2LRa8/+7xBCVoOn+sAFtEVW2NrMZFw2sJy2CZHKf585nQipc
MyQs4OXVg2wW0i+zt9xk
=t0Mr
-----END PGP SIGNATURE-----

--Sig_/=ckAssR/iWDt5AO31t3/Vem--
