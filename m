From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH v2] drivers: net: xgene: Rewrite loop in xgene_enet_ecc_init()
Date: Wed, 22 Oct 2014 09:39:41 +0200
Message-ID: <1413963581-24019-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>,
	Iyappan Subramanian <isubramanian@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c: In function =E2=80=98=
xgene_enet_ecc_init=E2=80=99:
drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c:126: warning: =E2=80=98=
data=E2=80=99 may be used uninitialized in this function

Depending on the arbitrary value on the stack, the loop may terminate
too early, and cause a bogus -ENODEV failure.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
v2: Rewrite the loop instead of pre-initializing data.

 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c b/driver=
s/net/ethernet/apm/xgene/xgene_enet_sgmac.c
index e6d24c2101982444..2a497b38ed420495 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
@@ -127,17 +127,15 @@ static int xgene_enet_ecc_init(struct xgene_enet_=
pdata *p)
 	int i;
=20
 	xgene_enet_wr_diag_csr(p, ENET_CFG_MEM_RAM_SHUTDOWN_ADDR, 0);
-	for (i =3D 0; i < 10 && data !=3D ~0U ; i++) {
+	for (i =3D 0; i < 10; i++) {
 		usleep_range(100, 110);
 		data =3D xgene_enet_rd_diag_csr(p, ENET_BLOCK_MEM_RDY_ADDR);
+		if (data =3D=3D ~0U)
+			return 0;
 	}
=20
-	if (data !=3D ~0U) {
-		netdev_err(ndev, "Failed to release memory from shutdown\n");
-		return -ENODEV;
-	}
-
-	return 0;
+	netdev_err(ndev, "Failed to release memory from shutdown\n");
+	return -ENODEV;
 }
=20
 static void xgene_enet_config_ring_if_assoc(struct xgene_enet_pdata *p=
)
--=20
1.9.1
