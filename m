From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: [PATCH 1/2] [NIU] Determine the # of ports from the card's VPD data.
Date: Wed, 23 Apr 2008 11:15:03 -0700
Message-ID: <480F7CA7.4000602@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Matheos Worku <Matheos.Worku@Sun.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:59820 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753952AbYDWSQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 14:16:31 -0400
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m3NIGVs4013502
	for <netdev@vger.kernel.org>; Wed, 23 Apr 2008 11:16:31 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0JZS00G01I10R700@fe-sfbay-09.sun.com>
 (original mail from Matheos.Worku@Sun.COM) for netdev@vger.kernel.org; Wed,
 23 Apr 2008 11:16:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Matheos Worku <matheos.worku@sun.com>
---
  drivers/net/niu.c |   57 
++++++++++++++++++++++++++++++++++++++++++----------
  drivers/net/niu.h |   11 +++++++++-
  2 files changed, 56 insertions(+), 12 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 7565c2d..c1fcd07 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6773,6 +6773,28 @@ static int __devinit 
niu_phy_type_prop_decode(struct niu *np,
  	return 0;
  }

+#define NIU_BMD_MATCHES(np, md_str) \
+  (!strncmp(np->vpd.board_model, md_str, strlen(md_str)))
+
+static int niu_pci_vpd_get_nports(struct niu *np)
+{
+	int ports = 0;
+
+	if ((NIU_BMD_MATCHES(np, NIU_QGC_LP_BM_STR)) ||
+		(NIU_BMD_MATCHES(np, NIU_QGC_PEM_BM_STR)) ||
+		(NIU_BMD_MATCHES(np, NIU_ALONSO_BM_STR))) {
+		ports = 4;
+	} else if ((NIU_BMD_MATCHES(np, NIU_2XGF_LP_BM_STR)) ||
+			   (NIU_BMD_MATCHES(np, NIU_2XGF_PEM_BM_STR)) ||
+			   (NIU_BMD_MATCHES(np, NIU_FOXXY_BM_STR)) ||
+			   (NIU_BMD_MATCHES(np, NIU_2XGF_MRVL_BM_STR))) {
+		ports = 2;
+	}
+
+	return (ports);
+}
+
+
  static void __devinit niu_pci_vpd_validate(struct niu *np)
  {
  	struct net_device *dev = np->dev;
@@ -6976,6 +6998,7 @@ static int __devinit niu_pci_probe_sprom(struct 
niu *np)
  	return 0;
  }

+
  static int __devinit niu_get_and_validate_port(struct niu *np)
  {
  	struct niu_parent *parent = np->parent;
@@ -6987,11 +7010,15 @@ static int __devinit 
niu_get_and_validate_port(struct niu *np)
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
+				/* fall back to SPROM as last resort. will fail on most cards*/
+				parent->num_ports = nr64(ESPC_NUM_PORTS_MACS) &
+					ESPC_NUM_PORTS_MACS_VAL;
+
+				if (!parent->num_ports)
+					return -ENODEV;
+			}
  		}
  	}

@@ -7733,15 +7760,16 @@ static int __devinit niu_get_invariants(struct 
niu *np)

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

@@ -7753,10 +7781,17 @@ static int __devinit niu_get_invariants(struct 
niu *np)
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
index 336aed0..0343c08 100644
--- a/drivers/net/niu.h
+++ b/drivers/net/niu.h
@@ -2936,6 +2936,16 @@ struct rx_ring_info {
  #define MAC_NUM_HASH		16

  #define NIU_MAX_MTU		9216
+/* vpd strings */
+
+#define	NIU_QGC_LP_BM_STR	"501-7606"
+#define	NIU_2XGF_LP_BM_STR	"501-7283"
+#define	NIU_QGC_PEM_BM_STR	"501-7765"
+#define	NIU_2XGF_PEM_BM_STR	"501-7626"
+#define	NIU_ALONSO_BM_STR	"373-0202"
+#define	NIU_ALONSO_MODEL_STR	"SUNW,CP3220"
+#define	NIU_FOXXY_BM_STR	"501-7961"
+#define	NIU_2XGF_MRVL_BM_STR	"SK-6E82"

  #define NIU_VPD_MIN_MAJOR	3
  #define NIU_VPD_MIN_MINOR	4
@@ -3233,7 +3243,6 @@ struct niu {
  	struct timer_list		timer;
  	const struct niu_phy_ops	*phy_ops;
  	int				phy_addr;
-
  	struct niu_link_config		link_config;

  	struct work_struct		reset_task;
-- 1.5.2

