From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/4] bnx2: Call pci_enable_msix() with actual
 number of vectors.
Date: Mon, 19 Jul 2010 17:15:03 -0700
Message-ID: <1279584905-15084-2-git-send-email-mchan@broadcom.com>
References: <1279584905-15084-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?utf-8?q?Breno=20Leit=C3=A3o?= <leitao@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2069 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757826Ab0GTALw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 20:11:52 -0400
In-Reply-To: <1279584905-15084-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on original patch by Breno Leit=C3=A3o <leitao@linux.vnet.ibm.com=
>.

Allocate the actual number of vectors and make use of fewer vectors
if pci_enable_msix() returns > 0.  We must allocate one additional
vector for the cnic driver.

Cc: Breno Leit=C3=A3o <leitao@linux.vnet.ibm.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   24 ++++++++++++++++++++----
 drivers/net/bnx2.h |    9 ++++++---
 2 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index deb7f83..d44ecc3 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -864,7 +864,7 @@ bnx2_alloc_mem(struct bnx2 *bp)
 	bnapi->hw_rx_cons_ptr =3D
 		&bnapi->status_blk.msi->status_rx_quick_consumer_index0;
 	if (bp->flags & BNX2_FLAG_MSIX_CAP) {
-		for (i =3D 1; i < BNX2_MAX_MSIX_VEC; i++) {
+		for (i =3D 1; i < bp->irq_nvecs; i++) {
 			struct status_block_msix *sblk;
=20
 			bnapi =3D &bp->bnx2_napi[i];
@@ -6152,7 +6152,7 @@ bnx2_free_irq(struct bnx2 *bp)
 static void
 bnx2_enable_msix(struct bnx2 *bp, int msix_vecs)
 {
-	int i, rc;
+	int i, total_vecs, rc;
 	struct msix_entry msix_ent[BNX2_MAX_MSIX_VEC];
 	struct net_device *dev =3D bp->dev;
 	const int len =3D sizeof(bp->irq_tbl[0].name);
@@ -6171,13 +6171,29 @@ bnx2_enable_msix(struct bnx2 *bp, int msix_vecs=
)
 		msix_ent[i].vector =3D 0;
 	}
=20
-	rc =3D pci_enable_msix(bp->pdev, msix_ent, BNX2_MAX_MSIX_VEC);
+	total_vecs =3D msix_vecs;
+#ifdef BCM_CNIC
+	total_vecs++;
+#endif
+	rc =3D -ENOSPC;
+	while (total_vecs >=3D BNX2_MIN_MSIX_VEC) {
+		rc =3D pci_enable_msix(bp->pdev, msix_ent, total_vecs);
+		if (rc <=3D 0)
+			break;
+		if (rc > 0)
+			total_vecs =3D rc;
+	}
+
 	if (rc !=3D 0)
 		return;
=20
+	msix_vecs =3D total_vecs;
+#ifdef BCM_CNIC
+	msix_vecs--;
+#endif
 	bp->irq_nvecs =3D msix_vecs;
 	bp->flags |=3D BNX2_FLAG_USING_MSIX | BNX2_FLAG_ONE_SHOT_MSI;
-	for (i =3D 0; i < BNX2_MAX_MSIX_VEC; i++) {
+	for (i =3D 0; i < total_vecs; i++) {
 		bp->irq_tbl[i].vector =3D msix_ent[i].vector;
 		snprintf(bp->irq_tbl[i].name, len, "%s-%d", dev->name, i);
 		bp->irq_tbl[i].handler =3D bnx2_msi_1shot;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index b9af6bc..2104c10 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6637,9 +6637,12 @@ struct flash_spec {
=20
 #define BNX2_MAX_MSIX_HW_VEC	9
 #define BNX2_MAX_MSIX_VEC	9
-#define BNX2_BASE_VEC		0
-#define BNX2_TX_VEC		1
-#define BNX2_TX_INT_NUM	(BNX2_TX_VEC << BNX2_PCICFG_INT_ACK_CMD_INT_NU=
M_SHIFT)
+#ifdef BCM_CNIC
+#define BNX2_MIN_MSIX_VEC	2
+#else
+#define BNX2_MIN_MSIX_VEC	1
+#endif
+
=20
 struct bnx2_irq {
 	irq_handler_t	handler;
--=20
1.6.4.GIT


