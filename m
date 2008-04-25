From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [NIU] Determine the # of ports from the card's VPD
 data.
Date: Thu, 24 Apr 2008 21:03:35 -0700 (PDT)
Message-ID: <20080424.210335.178416128.davem@davemloft.net>
References: <200804231811.m3NIBhQl043628@sr1-umpk-33.sfbay.sun.com>
	<20080423.182848.74720455.davem@davemloft.net>
	<4810E315.8080303@sun.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matheos.Worku@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38159
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750848AbYDYEDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 00:03:36 -0400
In-Reply-To: <4810E315.8080303@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matheos Worku <Matheos.Worku@Sun.COM>
Date: Thu, 24 Apr 2008 12:44:21 -0700

> Thanks a lot for the feedback.
> The board model contains a HW dash version number which changes with HW 
> change. Need to ignore  the - version number.
> A new patch, using a small function as you suggested is attached.

Thanks for the explanation and the updated patch.

I still had to correct a few trailing-whitespace and coding
style issues, but I took care of them so don't worry about it.

This is the actual patch I commited, thanks again.

niu: Determine the # of ports from the card's VPD data

[ Fix minor whitespace and coding style stuff... -DaveM ]

Signed-off-by: Matheos Worku <matheos.worku@sun.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 7565c2d..c7c173c 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6773,6 +6773,37 @@ static int __devinit niu_phy_type_prop_decode(struct niu *np,
 	return 0;
 }
 
+/* niu board models have a trailing dash version incremented
+ * with HW rev change. Need to ingnore the  dash version while
+ * checking for match
+ *
+ * for example, for the 10G card the current vpd.board_model
+ * is 501-5283-04, of which -04 is the  dash version and have
+ * to be ignored
+ */
+static int niu_board_model_match(struct niu *np, const char *model)
+{
+	return !strncmp(np->vpd.board_model, model, strlen(model));
+}
+
+static int niu_pci_vpd_get_nports(struct niu *np)
+{
+	int ports = 0;
+
+	if ((niu_board_model_match(np, NIU_QGC_LP_BM_STR)) ||
+	    (niu_board_model_match(np, NIU_QGC_PEM_BM_STR)) ||
+	    (niu_board_model_match(np, NIU_ALONSO_BM_STR))) {
+		ports = 4;
+	} else if ((niu_board_model_match(np, NIU_2XGF_LP_BM_STR)) ||
+		   (niu_board_model_match(np, NIU_2XGF_PEM_BM_STR)) ||
+		   (niu_board_model_match(np, NIU_FOXXY_BM_STR)) ||
+		   (niu_board_model_match(np, NIU_2XGF_MRVL_BM_STR))) {
+		ports = 2;
+	}
+
+	return ports;
+}
+
 static void __devinit niu_pci_vpd_validate(struct niu *np)
 {
 	struct net_device *dev = np->dev;
@@ -6987,11 +7018,17 @@ static int __devinit niu_get_and_validate_port(struct niu *np)
 		if (parent->plat_type == PLAT_TYPE_NIU) {
 			parent->num_ports = 2;
 		} else {
-			parent->num_ports = nr64(ESPC_NUM_PORTS_MACS) &
-				ESPC_NUM_PORTS_MACS_VAL;
-
-			if (!parent->num_ports)
-				parent->num_ports = 4;
+			parent->num_ports = niu_pci_vpd_get_nports(np);
+			if (!parent->num_ports) {
+				/* Fall back to SPROM as last resort.
+				 * This will fail on most cards.
+				 */
+				parent->num_ports = nr64(ESPC_NUM_PORTS_MACS) &
+					ESPC_NUM_PORTS_MACS_VAL;
+
+				if (!parent->num_ports)
+					return -ENODEV;
+			}
 		}
 	}
 
@@ -7733,15 +7770,16 @@ static int __devinit niu_get_invariants(struct niu *np)
 
 	have_props = !err;
 
-	err = niu_get_and_validate_port(np);
-	if (err)
-		return err;
-
 	err = niu_init_mac_ipp_pcs_base(np);
 	if (err)
 		return err;
 
-	if (!have_props) {
+	if (have_props) {
+		err = niu_get_and_validate_port(np);
+		if (err)
+			return err;
+
+	} else  {
 		if (np->parent->plat_type == PLAT_TYPE_NIU)
 			return -EINVAL;
 
@@ -7753,10 +7791,17 @@ static int __devinit niu_get_invariants(struct niu *np)
 			niu_pci_vpd_fetch(np, offset);
 		nw64(ESPC_PIO_EN, 0);
 
-		if (np->flags & NIU_FLAGS_VPD_VALID)
+		if (np->flags & NIU_FLAGS_VPD_VALID) {
 			niu_pci_vpd_validate(np);
+			err = niu_get_and_validate_port(np);
+			if (err)
+				return err;
+		}
 
 		if (!(np->flags & NIU_FLAGS_VPD_VALID)) {
+			err = niu_get_and_validate_port(np);
+			if (err)
+				return err;
 			err = niu_pci_probe_sprom(np);
 			if (err)
 				return err;
diff --git a/drivers/net/niu.h b/drivers/net/niu.h
index 336aed0..35e9afb 100644
--- a/drivers/net/niu.h
+++ b/drivers/net/niu.h
@@ -2937,6 +2937,15 @@ struct rx_ring_info {
 
 #define NIU_MAX_MTU		9216
 
+/* VPD strings */
+#define	NIU_QGC_LP_BM_STR	"501-7606"
+#define	NIU_2XGF_LP_BM_STR	"501-7283"
+#define	NIU_QGC_PEM_BM_STR	"501-7765"
+#define	NIU_2XGF_PEM_BM_STR	"501-7626"
+#define	NIU_ALONSO_BM_STR	"373-0202"
+#define	NIU_FOXXY_BM_STR	"501-7961"
+#define	NIU_2XGF_MRVL_BM_STR	"SK-6E82"
+
 #define NIU_VPD_MIN_MAJOR	3
 #define NIU_VPD_MIN_MINOR	4
 
