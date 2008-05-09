From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: [PATCH 1/1] [NIU] Redo the fix for getting # of  ports from EEPROM
Date: Thu, 08 May 2008 17:20:51 -0700
Message-ID: <482398E3.9000206@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:56425 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754099AbYEIAU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 20:20:29 -0400
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m490KSx5018255
	for <netdev@vger.kernel.org>; Thu, 8 May 2008 17:20:29 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0K0K00301RJC6800@fe-sfbay-09.sun.com>
 (original mail from Matheos.Worku@Sun.COM) for netdev@vger.kernel.org; Thu,
 08 May 2008 17:20:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Matheos <matheos.worku@sun.com>
---
  drivers/net/niu.c |   47 +++++++++++++++++++++--------------------------
  drivers/net/niu.h |    9 +++++++++
  2 files changed, 30 insertions(+), 26 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 57cfd72..c07930c 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -7008,31 +7008,20 @@ static int __devinit 
niu_phy_type_prop_decode(struct niu *np,
  	return 0;
  }

-/* niu board models have a trailing dash version incremented
- * with HW rev change. Need to ingnore the  dash version while
- * checking for match
- *
- * for example, for the 10G card the current vpd.board_model
- * is 501-5283-04, of which -04 is the  dash version and have
- * to be ignored
- */
-static int niu_board_model_match(struct niu *np, const char *model)
-{
-	return !strncmp(np->vpd.board_model, model, strlen(model));
-}
-
  static int niu_pci_vpd_get_nports(struct niu *np)
  {
  	int ports = 0;

-	if ((niu_board_model_match(np, NIU_QGC_LP_BM_STR)) ||
-	    (niu_board_model_match(np, NIU_QGC_PEM_BM_STR)) ||
-	    (niu_board_model_match(np, NIU_ALONSO_BM_STR))) {
+	if ((!strcmp(np->vpd.model, NIU_QGC_LP_MDL_STR)) ||
+	    (!strcmp(np->vpd.model, NIU_QGC_PEM_MDL_STR)) ||
+	    (!strcmp(np->vpd.model, NIU_MARAMBA_MDL_STR)) ||
+	    (!strcmp(np->vpd.model, NIU_KIMI_MDL_STR)) ||
+	    (!strcmp(np->vpd.model, NIU_ALONSO_MDL_STR))) {
  		ports = 4;
-	} else if ((niu_board_model_match(np, NIU_2XGF_LP_BM_STR)) ||
-		   (niu_board_model_match(np, NIU_2XGF_PEM_BM_STR)) ||
-		   (niu_board_model_match(np, NIU_FOXXY_BM_STR)) ||
-		   (niu_board_model_match(np, NIU_2XGF_MRVL_BM_STR))) {
+	} else if ((!strcmp(np->vpd.model, NIU_2XGF_LP_MDL_STR)) ||
+		   (!strcmp(np->vpd.model, NIU_2XGF_PEM_MDL_STR)) ||
+		   (!strcmp(np->vpd.model, NIU_FOXXY_MDL_STR)) ||
+		   (!strcmp(np->vpd.model, NIU_2XGF_MRVL_MDL_STR))) {
  		ports = 2;
  	}

@@ -7053,8 +7042,8 @@ static void __devinit niu_pci_vpd_validate(struct 
niu *np)
  		return;
  	}

-	if (!strcmp(np->vpd.model, "SUNW,CP3220") ||
-	    !strcmp(np->vpd.model, "SUNW,CP3260")) {
+	if (!strcmp(np->vpd.model, NIU_ALONSO_MDL_STR) ||
+	    !strcmp(np->vpd.model, NIU_KIMI_MDL_STR)) {
  		np->flags |= NIU_FLAGS_10G;
  		np->flags &= ~NIU_FLAGS_FIBER;
  		np->flags |= NIU_FLAGS_XCVR_SERDES;
@@ -7065,7 +7054,7 @@ static void __devinit niu_pci_vpd_validate(struct 
niu *np)
  		}
  		if (np->flags & NIU_FLAGS_10G)
  			 np->mac_xcvr = MAC_XCVR_XPCS;
-	} else if (niu_board_model_match(np, NIU_FOXXY_BM_STR)) {
+	} else if (!strcmp(np->vpd.model, NIU_FOXXY_MDL_STR)) {
  		np->flags |= (NIU_FLAGS_10G | NIU_FLAGS_FIBER |
  			      NIU_FLAGS_HOTPLUG_PHY);
  	} else if (niu_phy_type_prop_decode(np, np->vpd.phy_type)) {
@@ -7541,8 +7530,8 @@ static int __devinit walk_phys(struct niu *np, 
struct niu_parent *parent)
  	u32 val;
  	int err;

-	if (!strcmp(np->vpd.model, "SUNW,CP3220") ||
-	    !strcmp(np->vpd.model, "SUNW,CP3260")) {
+	if (!strcmp(np->vpd.model, NIU_ALONSO_MDL_STR) ||
+	    !strcmp(np->vpd.model, NIU_KIMI_MDL_STR)) {
  		num_10g = 0;
  		num_1g = 2;
  		parent->plat_type = PLAT_TYPE_ATCA_CP3220;
@@ -7551,7 +7540,7 @@ static int __devinit walk_phys(struct niu *np, 
struct niu_parent *parent)
  		       phy_encode(PORT_TYPE_1G, 1) |
  		       phy_encode(PORT_TYPE_1G, 2) |
  		       phy_encode(PORT_TYPE_1G, 3));
-	} else if (niu_board_model_match(np, NIU_FOXXY_BM_STR)) {
+	} else if (!strcmp(np->vpd.model, NIU_FOXXY_MDL_STR)) {
  		num_10g = 2;
  		num_1g = 0;
  		parent->num_ports = 2;
@@ -7946,6 +7935,7 @@ static int __devinit niu_get_of_props(struct niu *np)
  	struct device_node *dp;
  	const char *phy_type;
  	const u8 *mac_addr;
+	const char *model;
  	int prop_len;

  	if (np->parent->plat_type == PLAT_TYPE_NIU)
@@ -8000,6 +7990,11 @@ static int __devinit niu_get_of_props(struct niu *np)

  	memcpy(dev->dev_addr, dev->perm_addr, dev->addr_len);

+	model = of_get_property(dp, "model", &prop_len);
+
+	if (model)
+	  strcpy(np->vpd.model, model);
+
  	return 0;
  #else
  	return -EINVAL;
diff --git a/drivers/net/niu.h b/drivers/net/niu.h
index 97ffbe1..12fd570 100644
--- a/drivers/net/niu.h
+++ b/drivers/net/niu.h
@@ -2946,6 +2946,15 @@ struct rx_ring_info {
  #define	NIU_ALONSO_BM_STR	"373-0202"
  #define	NIU_FOXXY_BM_STR	"501-7961"
  #define	NIU_2XGF_MRVL_BM_STR	"SK-6E82"
+#define	NIU_QGC_LP_MDL_STR	"SUNW,pcie-qgc"
+#define	NIU_2XGF_LP_MDL_STR	"SUNW,pcie-2xgf"
+#define	NIU_QGC_PEM_MDL_STR	"SUNW,pcie-qgc-pem"
+#define	NIU_2XGF_PEM_MDL_STR	"SUNW,pcie-2xgf-pem"
+#define	NIU_ALONSO_MDL_STR	"SUNW,CP3220"
+#define	NIU_KIMI_MDL_STR	"SUNW,CP3260"
+#define	NIU_MARAMBA_MDL_STR	"SUNW,pcie-neptune"
+#define	NIU_FOXXY_MDL_STR	"SUNW,pcie-rfem"
+#define	NIU_2XGF_MRVL_MDL_STR	"SysKonnect,pcie-2xgf"

  #define NIU_VPD_MIN_MAJOR	3
  #define NIU_VPD_MIN_MINOR	4
-- 
1.5.2


