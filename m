From: leitao@linux.vnet.ibm.com
Subject: [PATCH] bnx2: Enable MSI-X even if the amount of vectors is smaller than BNX2_MAX_MSIX_VEC
Date: Tue, 13 Jul 2010 15:42:46 -0500
Message-ID: <1279053766-8079-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?utf-8?q?Breno=20Leit=C3=A3o?= <leitao@linux.vnet.ibm.com>
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:54569 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754110Ab0GMSn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 14:43:28 -0400
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp02.br.ibm.com (8.14.4/8.13.1) with ESMTP id o6DIkh6X029129
	for <netdev@vger.kernel.org>; Tue, 13 Jul 2010 15:46:43 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6DIhMVv3895398
	for <netdev@vger.kernel.org>; Tue, 13 Jul 2010 15:43:23 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6DIh94A000667
	for <netdev@vger.kernel.org>; Tue, 13 Jul 2010 15:43:10 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46irst of all, the function bnx2_enable_msix() has the msix_vecs param=
eter,
but it's not used to request the amount of vectors. Currently the drive=
rs is
always requesting BNX2_MAX_MSIX_VEC vectors, even when the msix_vecs is
different from it.

Also, if the amount of available vectors are smaller than BNX2_MAX_MSIX=
_VEC,
the MSI-X is disabled, which is something bad.

So, this patch tries to fix both issues. Now if the available amount of=
 vectors
is smaller than the requested amount, the driver re-request the current=
 available
amount and proceed with these vectors.

Signed-off-by: Breno Leit=C3=A3o <leitao@linux.vnet.ibm.com>
---
 drivers/net/bnx2.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 1174322..70ee664 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -860,7 +860,7 @@ bnx2_alloc_mem(struct bnx2 *bp)
 	bnapi->hw_rx_cons_ptr =3D
 		&bnapi->status_blk.msi->status_rx_quick_consumer_index0;
 	if (bp->flags & BNX2_FLAG_MSIX_CAP) {
-		for (i =3D 1; i < BNX2_MAX_MSIX_VEC; i++) {
+		for (i =3D 1; i < bp->irq_nvecs; i++) {
 			struct status_block_msix *sblk;
=20
 			bnapi =3D &bp->bnx2_napi[i];
@@ -4886,7 +4886,7 @@ bnx2_init_chip(struct bnx2 *bp)
 	bnx2_reg_wr_ind(bp, BNX2_RBUF_CONFIG3, BNX2_RBUF_CONFIG3_VAL(mtu));
=20
 	memset(bp->bnx2_napi[0].status_blk.msi, 0, bp->status_stats_size);
-	for (i =3D 0; i < BNX2_MAX_MSIX_VEC; i++)
+	for (i =3D 0; i < bp->irq_nvecs; i++)
 		bp->bnx2_napi[i].last_status_idx =3D 0;
=20
 	bp->idle_chk_status_idx =3D 0xffff;
@@ -5007,7 +5007,7 @@ bnx2_clear_ring_states(struct bnx2 *bp)
 	struct bnx2_rx_ring_info *rxr;
 	int i;
=20
-	for (i =3D 0; i < BNX2_MAX_MSIX_VEC; i++) {
+	for (i =3D 0; i < bp->irq_nvecs; i++) {
 		bnapi =3D &bp->bnx2_napi[i];
 		txr =3D &bnapi->tx_ring;
 		rxr =3D &bnapi->rx_ring;
@@ -6148,13 +6148,15 @@ bnx2_enable_msix(struct bnx2 *bp, int msix_vecs=
)
 		msix_ent[i].vector =3D 0;
 	}
=20
-	rc =3D pci_enable_msix(bp->pdev, msix_ent, BNX2_MAX_MSIX_VEC);
-	if (rc !=3D 0)
-		return;
+	do {
+		rc =3D pci_enable_msix(bp->pdev, msix_ent, msix_vecs);
+		if (rc > 0)
+			msix_vecs =3D rc;
+	} while (rc > 0);
=20
 	bp->irq_nvecs =3D msix_vecs;
 	bp->flags |=3D BNX2_FLAG_USING_MSIX | BNX2_FLAG_ONE_SHOT_MSI;
-	for (i =3D 0; i < BNX2_MAX_MSIX_VEC; i++) {
+	for (i =3D 0; i < msix_vecs; i++) {
 		bp->irq_tbl[i].vector =3D msix_ent[i].vector;
 		snprintf(bp->irq_tbl[i].name, len, "%s-%d", dev->name, i);
 		bp->irq_tbl[i].handler =3D bnx2_msi_1shot;
--=20
1.6.0.2

