From: Ivan Mikhaylov <ivan@ru.ibm.com>
Subject: [PATCH v2 2/2] ethtool: add versioning for emac chips
Date: Wed, 5 Aug 2015 15:08:29 +0400
Message-ID: <20150805150829.2a0dee72@fr-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* add three types of network chips : emac, emac4, emac4sync
* add emac4sync processing in print_emac_regs

Signed-off-by: Ivan Mikhaylov <ivan@ru.ibm.com>
---
 ibm_emac.c |   56 +++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 45 insertions(+), 11 deletions(-)

diff --git a/ibm_emac.c b/ibm_emac.c
index da6c28e..b3140d0 100644
--- a/ibm_emac.c
+++ b/ibm_emac.c
@@ -22,6 +22,10 @@
 #define EMAC_ETHTOOL_REGS_RGMII		0x00000002
 #define EMAC_ETHTOOL_REGS_TAH		0x00000004
 
+#define EMAC_VERSION			0
+#define EMAC4_VERSION			1
+#define EMAC4SYNC_VERSION		2
+
 struct emac_ethtool_regs_hdr {
 	u32 components;
 };
@@ -164,8 +168,6 @@ static void *print_emac_regs(void *buf)
 	       "TRTR  = 0x%08x RWMR = 0x%08x\n"
 	       "IAR   = %04x%08x\n"
 	       "LSA   = %04x%08x\n"
-	       "IAHT  = 0x%04x 0x%04x 0x%04x 0x%04x\n"
-	       "GAHT  = 0x%04x 0x%04x 0x%04x 0x%04x\n"
 	       "VTPID = 0x%04x VTCI = 0x%04x\n"
 	       "IPGVR = 0x%04x STACR = 0x%08x\n"
 	       "OCTX  = 0x%08x OCRX = 0x%08x\n",
@@ -175,17 +177,49 @@ static void *print_emac_regs(void *buf)
 	       p->trtr, p->rwmr,
 	       p->iahr, p->ialr,
 	       p->lsah, p->lsal,
-	       p->u0.emac4.iaht1, p->u0.emac4.iaht2, p->u0.emac4.iaht3,
-	       p->u0.emac4.iaht4,
-	       p->u0.emac4.gaht1, p->u0.emac4.gaht2, p->u0.emac4.gaht3,
-	       p->u0.emac4.gaht4,
-	       p->vtpid, p->vtci, p->ipgvr, p->stacr, p->octx, p->ocrx);
+	       p->vtpid, p->vtci,
+	       p->ipgvr, p->stacr, p->octx, p->ocrx);
+
+	if (hdr->version == EMAC4SYNC_VERSION) {
+		printf("MAHR  = 0x%08x MALR  = 0x%08x MMAHR = 0x%08x\n"
+			"MMALR  = 0x%08x REVID  = 0x%08x\n",
+			p->u0.emac4sync.mahr, p->u0.emac4sync.malr,
+			p->u0.emac4sync.mmahr, p->u0.emac4sync.mmalr,
+			p->u1.emac4sync.revid);
+
+		printf("IAHT  = 0x%04x 0x%04x 0x%04x 0x%04x\n",
+			p->u1.emac4sync.iaht1, p->u1.emac4sync.iaht2,
+			p->u1.emac4sync.iaht3, p->u1.emac4sync.iaht4);
+		printf("        0x%04x 0x%04x 0x%04x 0x%04x\n",
+			p->u1.emac4sync.iaht5, p->u1.emac4sync.iaht6,
+			p->u1.emac4sync.iaht7, p->u1.emac4sync.iaht8);
+
+
+		printf("GAHT  = 0x%04x 0x%04x 0x%04x 0x%04x\n",
+			p->u1.emac4sync.gaht1, p->u1.emac4sync.gaht2,
+			p->u1.emac4sync.gaht3, p->u1.emac4sync.gaht4);
+		printf("        0x%04x 0x%04x 0x%04x 0x%04x\n\n",
+			p->u1.emac4sync.gaht5, p->u1.emac4sync.gaht6,
+			p->u1.emac4sync.gaht7, p->u1.emac4sync.gaht8);
+
+	} else if (hdr->version == EMAC4_VERSION) {
+		printf("IAHT  = 0x%04x 0x%04x 0x%04x 0x%04x\n",
+			p->u0.emac4.iaht1, p->u0.emac4.iaht2,
+			p->u0.emac4.iaht3, p->u0.emac4.iaht4);
+
+		printf("GAHT  = 0x%04x 0x%04x 0x%04x 0x%04x\n",
+			p->u0.emac4.gaht1, p->u0.emac4.gaht2,
+			p->u0.emac4.gaht3, p->u0.emac4.gaht4);
 
-	if (hdr->version)
 		printf(" IPCR = 0x%08x\n\n", p->u1.emac4.ipcr);
-	else {
-		printf("\n\n");
-		res -= sizeof(u32);
+	} else if (hdr->version == EMAC_VERSION) {
+		printf("IAHT  = 0x%04x 0x%04x 0x%04x 0x%04x\n",
+			p->u0.emac4.iaht1, p->u0.emac4.iaht2,
+			p->u0.emac4.iaht3, p->u0.emac4.iaht4);
+
+		printf("GAHT  = 0x%04x 0x%04x 0x%04x 0x%04x\n",
+			p->u0.emac4.gaht1, p->u0.emac4.gaht2,
+			p->u0.emac4.gaht3, p->u0.emac4.gaht4);
 	}
 	return res;
 }
-- 
1.7.9.5
