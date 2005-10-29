From: Eugene Surovegin <ebs@ebshome.net>
Subject: [PATCH 1/3] PPC 44x EMAC driver: add 440SPe support
Date: Sat, 29 Oct 2005 12:43:14 -0700
Message-ID: <20051029194314.GB1865@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-embedded@ozlabs.org
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

For some reason, the hardware designers made the polarity of one bit
in the 440SPe's PHY interface register the opposite of all other PPC
440 chips.  To handle this, abstract our access to this bit and do the
right thing based on the configured CPU type.

Signed-off-by: Roland Dreier <rolandd@cisco.com>
Signed-off-by: Eugene Surovegin <ebs@ebshome.net>
---

 drivers/net/ibm_emac/ibm_emac.h      |   21 ++++++++++++++++++++-
 drivers/net/ibm_emac/ibm_emac_core.c |   13 +++++++------
 drivers/net/ibm_emac/ibm_emac_mal.h  |    3 ++-
 3 files changed, 29 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ibm_emac/ibm_emac.h b/drivers/net/ibm_emac/ibm_emac.h
index 28c476f..d3166da 100644
--- a/drivers/net/ibm_emac/ibm_emac.h
+++ b/drivers/net/ibm_emac/ibm_emac.h
@@ -26,7 +26,7 @@
 /* This is a simple check to prevent use of this driver on non-tested SoCs */
 #if !defined(CONFIG_405GP) && !defined(CONFIG_405GPR) && !defined(CONFIG_405EP) && \
     !defined(CONFIG_440GP) && !defined(CONFIG_440GX) && !defined(CONFIG_440SP) && \
-    !defined(CONFIG_440EP) && !defined(CONFIG_NP405H)
+    !defined(CONFIG_440EP) && !defined(CONFIG_NP405H) && !defined(CONFIG_440SPE)
 #error	"Unknown SoC. Please, check chip user manual and make sure EMAC defines are OK"
 #endif
 
@@ -246,6 +246,25 @@ struct emac_regs {
 #define EMAC_STACR_PCDA_SHIFT		5
 #define EMAC_STACR_PRA_MASK		0x1f
 
+/*
+ * For the 440SPe, AMCC inexplicably changed the polarity of
+ * the "operation complete" bit in the MII control register.
+ */
+#if defined(CONFIG_440SPE)
+static inline int emac_phy_done(u32 stacr)
+{
+	return !(stacr & EMAC_STACR_OC);
+};
+#define EMAC_STACR_START 		EMAC_STACR_OC
+
+#else /* CONFIG_440SPE */
+static inline int emac_phy_done(u32 stacr)
+{
+	return stacr & EMAC_STACR_OC;
+};
+#define EMAC_STACR_START 		0
+#endif /* !CONFIG_440SPE */
+
 /* EMACx_TRTR */
 #if !defined(CONFIG_IBM_EMAC4)
 #define EMAC_TRTR_SHIFT			27
diff --git a/drivers/net/ibm_emac/ibm_emac_core.c b/drivers/net/ibm_emac/ibm_emac_core.c
index 943fbd1..48239e1 100644
--- a/drivers/net/ibm_emac/ibm_emac_core.c
+++ b/drivers/net/ibm_emac/ibm_emac_core.c
@@ -546,7 +546,7 @@ static int __emac_mdio_read(struct ocp_e
 
 	/* Wait for management interface to become idle */
 	n = 10;
-	while (!(in_be32(&p->stacr) & EMAC_STACR_OC)) {
+	while (!emac_phy_done(in_be32(&p->stacr))) {
 		udelay(1);
 		if (!--n)
 			goto to;
@@ -556,11 +556,12 @@ static int __emac_mdio_read(struct ocp_e
 	out_be32(&p->stacr,
 		 EMAC_STACR_BASE(emac_opb_mhz()) | EMAC_STACR_STAC_READ |
 		 (reg & EMAC_STACR_PRA_MASK)
-		 | ((id & EMAC_STACR_PCDA_MASK) << EMAC_STACR_PCDA_SHIFT));
+		 | ((id & EMAC_STACR_PCDA_MASK) << EMAC_STACR_PCDA_SHIFT)
+		 | EMAC_STACR_START);
 
 	/* Wait for read to complete */
 	n = 100;
-	while (!((r = in_be32(&p->stacr)) & EMAC_STACR_OC)) {
+	while (!emac_phy_done(r = in_be32(&p->stacr))) {
 		udelay(1);
 		if (!--n)
 			goto to;
@@ -594,7 +595,7 @@ static void __emac_mdio_write(struct ocp
 
 	/* Wait for management interface to be idle */
 	n = 10;
-	while (!(in_be32(&p->stacr) & EMAC_STACR_OC)) {
+	while (!emac_phy_done(in_be32(&p->stacr))) {
 		udelay(1);
 		if (!--n)
 			goto to;
@@ -605,11 +606,11 @@ static void __emac_mdio_write(struct ocp
 		 EMAC_STACR_BASE(emac_opb_mhz()) | EMAC_STACR_STAC_WRITE |
 		 (reg & EMAC_STACR_PRA_MASK) |
 		 ((id & EMAC_STACR_PCDA_MASK) << EMAC_STACR_PCDA_SHIFT) |
-		 (val << EMAC_STACR_PHYD_SHIFT));
+		 (val << EMAC_STACR_PHYD_SHIFT) | EMAC_STACR_START);
 
 	/* Wait for write to complete */
 	n = 100;
-	while (!(in_be32(&p->stacr) & EMAC_STACR_OC)) {
+	while (!emac_phy_done(in_be32(&p->stacr))) {
 		udelay(1);
 		if (!--n)
 			goto to;
diff --git a/drivers/net/ibm_emac/ibm_emac_mal.h b/drivers/net/ibm_emac/ibm_emac_mal.h
index 15b0bda..fb6dfe1 100644
--- a/drivers/net/ibm_emac/ibm_emac_mal.h
+++ b/drivers/net/ibm_emac/ibm_emac_mal.h
@@ -34,7 +34,8 @@
 #if defined(CONFIG_405GP) || defined(CONFIG_405GPR) || defined(CONFIG_405EP) || \
     defined(CONFIG_440EP) || defined(CONFIG_NP405H)
 #define MAL_VERSION		1
-#elif defined(CONFIG_440GP) || defined(CONFIG_440GX) || defined(CONFIG_440SP)
+#elif defined(CONFIG_440GP) || defined(CONFIG_440GX) || defined(CONFIG_440SP) || \
+      defined(CONFIG_440SPE)
 #define MAL_VERSION		2
 #else
 #error "Unknown SoC, please check chip manual and choose MAL 'version'"
