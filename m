From: Ivan Mikhaylov <ivan@ru.ibm.com>
Subject: Re: [PATCH] ethtool: add new emac_regs struct from driver, add new
 chip types.
Date: Fri, 25 Sep 2015 08:15:45 +0400
Message-ID: <20150925081545.26cbb101@fr-ThinkPad-W520>
References: <20150923144634.2ea2bce9@fr-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>
To: Ivan Mikhaylov <ivan@ru.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150923144634.2ea2bce9@fr-ThinkPad-W520>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* add new version of emac_regs struct from driver structure perspective
  and passing size from actual struct size, not from memory area variable
  which set in dts file.
* add three types of network chips for new struct : emac, emac4, emac4sync.
* add emac4sync processing in print_emac_regs.
* this commit fixing problem with output of MII sections for new driver versions.

Signed-off-by: Ivan Mikhaylov <ivan@ru.ibm.com>
---
 ibm_emac.c |  161 ++++++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 125 insertions(+), 36 deletions(-)

diff --git a/ibm_emac.c b/ibm_emac.c
index e128e48..75cb560 100644
--- a/ibm_emac.c
+++ b/ibm_emac.c
@@ -22,6 +22,10 @@
 #define EMAC_ETHTOOL_REGS_RGMII		0x00000002
 #define EMAC_ETHTOOL_REGS_TAH		0x00000004
 
+#define EMAC_VERSION			3
+#define EMAC4_VERSION			4
+#define EMAC4SYNC_VERSION		5
+
 struct emac_ethtool_regs_hdr {
 	u32 components;
 };
@@ -32,35 +36,78 @@ struct emac_ethtool_regs_subhdr {
 };
 
 struct emac_regs {
-	u32 mr0;
-	u32 mr1;
-	u32 tmr0;
-	u32 tmr1;
-	u32 rmr;
-	u32 isr;
-	u32 iser;
-	u32 iahr;
-	u32 ialr;
-	u32 vtpid;
-	u32 vtci;
-	u32 ptr;
-	u32 iaht1;
-	u32 iaht2;
-	u32 iaht3;
-	u32 iaht4;
-	u32 gaht1;
-	u32 gaht2;
-	u32 gaht3;
-	u32 gaht4;
+	/* Common registers across all EMAC implementations. */
+	u32 mr0;			/* Special 	*/
+	u32 mr1;			/* Reset 	*/
+	u32 tmr0;			/* Special 	*/
+	u32 tmr1;			/* Special 	*/
+	u32 rmr;			/* Reset 	*/
+	u32 isr;			/* Always 	*/
+	u32 iser;			/* Reset 	*/
+	u32 iahr;			/* Reset, R, T 	*/
+	u32 ialr;			/* Reset, R, T 	*/
+	u32 vtpid;			/* Reset, R, T 	*/
+	u32 vtci;			/* Reset, R, T 	*/
+	u32 ptr;			/* Reset,    T 	*/
+	union {
+		/* Registers unique to EMAC4 implementations */
+		struct {
+			u32 iaht1;	/* Reset, R	*/
+			u32 iaht2;	/* Reset, R	*/
+			u32 iaht3;	/* Reset, R	*/
+			u32 iaht4;	/* Reset, R	*/
+			u32 gaht1;	/* Reset, R	*/
+			u32 gaht2;	/* Reset, R	*/
+			u32 gaht3;	/* Reset, R	*/
+			u32 gaht4;	/* Reset, R	*/
+		} emac4;
+		/* Registers unique to EMAC4SYNC implementations */
+		struct {
+			u32 mahr;	/* Reset, R, T  */
+			u32 malr;	/* Reset, R, T  */
+			u32 mmahr;	/* Reset, R, T  */
+			u32 mmalr;	/* Reset, R, T  */
+			u32 rsvd0[4];
+		} emac4sync;
+	} u0;
+	/* Common registers across all EMAC implementations. */
 	u32 lsah;
 	u32 lsal;
-	u32 ipgvr;
-	u32 stacr;
-	u32 trtr;
-	u32 rwmr;
+	u32 ipgvr;			/* Reset,    T 	*/
+	u32 stacr;			/* Special 	*/
+	u32 trtr;			/* Special 	*/
+	u32 rwmr;			/* Reset 	*/
 	u32 octx;
 	u32 ocrx;
-	u32 ipcr;
+	union {
+		/* Registers unique to EMAC4 implementations */
+		struct {
+			u32 ipcr;
+		} emac4;
+		/* Registers unique to EMAC4SYNC implementations */
+		struct {
+			u32 rsvd1;
+			u32 revid;
+			u32 rsvd2[2];
+			u32 iaht1;	/* Reset, R     */
+			u32 iaht2;	/* Reset, R     */
+			u32 iaht3;	/* Reset, R     */
+			u32 iaht4;	/* Reset, R     */
+			u32 iaht5;	/* Reset, R     */
+			u32 iaht6;	/* Reset, R     */
+			u32 iaht7;	/* Reset, R     */
+			u32 iaht8;	/* Reset, R     */
+			u32 gaht1;	/* Reset, R     */
+			u32 gaht2;	/* Reset, R     */
+			u32 gaht3;	/* Reset, R     */
+			u32 gaht4;	/* Reset, R     */
+			u32 gaht5;	/* Reset, R     */
+			u32 gaht6;	/* Reset, R     */
+			u32 gaht7;	/* Reset, R     */
+			u32 gaht8;	/* Reset, R     */
+			u32 tpc;	/* Reset, T     */
+		} emac4sync;
+	} u1;
 };
 
 struct mal_regs {
@@ -113,6 +160,16 @@ static void *print_emac_regs(void *buf)
 	struct emac_regs *p = (struct emac_regs *)(hdr + 1);
 	void *res = p + 1;
 
+	if (!((hdr->version == EMAC_VERSION) ||
+		(hdr->version == EMAC4_VERSION) ||
+		(hdr->version == EMAC4SYNC_VERSION)))
+	{
+		printf("This driver version doesn't support information\n"
+			" output for EMAC area, please update it or use older\n"
+			" ethtool version\n");
+		return res;
+	}
+
 	printf("EMAC%d Registers\n", hdr->index);
 	printf("-----------------\n");
 	printf("MR0   = 0x%08x MR1  = 0x%08x RMR = 0x%08x\n"
@@ -121,8 +178,6 @@ static void *print_emac_regs(void *buf)
 	       "TRTR  = 0x%08x RWMR = 0x%08x\n"
 	       "IAR   = %04x%08x\n"
 	       "LSA   = %04x%08x\n"
-	       "IAHT  = 0x%04x 0x%04x 0x%04x 0x%04x\n"
-	       "GAHT  = 0x%04x 0x%04x 0x%04x 0x%04x\n"
 	       "VTPID = 0x%04x VTCI = 0x%04x\n"
 	       "IPGVR = 0x%04x STACR = 0x%08x\n"
 	       "OCTX  = 0x%08x OCRX = 0x%08x\n",
@@ -132,15 +187,49 @@ static void *print_emac_regs(void *buf)
 	       p->trtr, p->rwmr,
 	       p->iahr, p->ialr,
 	       p->lsah, p->lsal,
-	       p->iaht1, p->iaht2, p->iaht3, p->iaht4,
-	       p->gaht1, p->gaht2, p->gaht3, p->gaht4,
-	       p->vtpid, p->vtci, p->ipgvr, p->stacr, p->octx, p->ocrx);
-
-	if (hdr->version)
-		printf(" IPCR = 0x%08x\n\n", p->ipcr);
-	else {
-		printf("\n\n");
-		res -= sizeof(u32);
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
+
+		printf(" IPCR = 0x%08x\n\n", p->u1.emac4.ipcr);
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
