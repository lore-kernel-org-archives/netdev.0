From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 2/2] drivers: net: xgene: fix: Coalescing values for v2 hardware
Date: Mon, 31 Oct 2016 16:00:27 -0700
Message-ID: <1477954827-9951-3-git-send-email-isubramanian@apm.com>
References: <1477954827-9951-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Iyappan Subramanian <isubramanian@apm.com>,
        Toan Le <toanle@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:32824 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947895AbcJaXAU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 19:00:20 -0400
Received: by mail-oi0-f51.google.com with SMTP id 128so59561873oih.0
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 16:00:20 -0700 (PDT)
In-Reply-To: <1477954827-9951-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changing the interrupt trigger region id to 2 and the
corresponding threshold set0/set1 values to 8/16.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Toan Le <toanle@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |  2 ++
 drivers/net/ethernet/apm/xgene/xgene_enet_ring2.c | 12 +++++++-----
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index 8456337..06e598c 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -55,8 +55,10 @@ enum xgene_enet_rm {
 #define PREFETCH_BUF_EN		BIT(21)
 #define CSR_RING_ID_BUF		0x000c
 #define CSR_PBM_COAL		0x0014
+#define CSR_PBM_CTICK0		0x0018
 #define CSR_PBM_CTICK1		0x001c
 #define CSR_PBM_CTICK2		0x0020
+#define CSR_PBM_CTICK3		0x0024
 #define CSR_THRESHOLD0_SET1	0x0030
 #define CSR_THRESHOLD1_SET1	0x0034
 #define CSR_RING_NE_INT_MODE	0x017c
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_ring2.c b/drivers/net/ethernet/apm/xgene/xgene_enet_ring2.c
index 2b76732..af51dd5 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_ring2.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_ring2.c
@@ -30,7 +30,7 @@ static void xgene_enet_ring_init(struct xgene_enet_desc_ring *ring)
 		ring_cfg[0] |= SET_VAL(X2_INTLINE, ring->id & RING_BUFNUM_MASK);
 		ring_cfg[3] |= SET_BIT(X2_DEQINTEN);
 	}
-	ring_cfg[0] |= SET_VAL(X2_CFGCRID, 1);
+	ring_cfg[0] |= SET_VAL(X2_CFGCRID, 2);
 
 	addr >>= 8;
 	ring_cfg[2] |= QCOHERENT | SET_VAL(RINGADDRL, addr);
@@ -192,13 +192,15 @@ static u32 xgene_enet_ring_len(struct xgene_enet_desc_ring *ring)
 
 static void xgene_enet_setup_coalescing(struct xgene_enet_desc_ring *ring)
 {
-	u32 data = 0x7777;
+	u32 data = 0x77777777;
 
 	xgene_enet_ring_wr32(ring, CSR_PBM_COAL, 0x8e);
+	xgene_enet_ring_wr32(ring, CSR_PBM_CTICK0, data);
 	xgene_enet_ring_wr32(ring, CSR_PBM_CTICK1, data);
-	xgene_enet_ring_wr32(ring, CSR_PBM_CTICK2, data << 16);
-	xgene_enet_ring_wr32(ring, CSR_THRESHOLD0_SET1, 0x40);
-	xgene_enet_ring_wr32(ring, CSR_THRESHOLD1_SET1, 0x80);
+	xgene_enet_ring_wr32(ring, CSR_PBM_CTICK2, data);
+	xgene_enet_ring_wr32(ring, CSR_PBM_CTICK3, data);
+	xgene_enet_ring_wr32(ring, CSR_THRESHOLD0_SET1, 0x08);
+	xgene_enet_ring_wr32(ring, CSR_THRESHOLD1_SET1, 0x10);
 }
 
 struct xgene_ring_ops xgene_ring2_ops = {
-- 
1.9.1
