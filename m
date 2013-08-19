From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 5/6] bnx2x: Protect against VFs' ndos when SR-IOV is
 disabled
Date: Mon, 19 Aug 2013 09:12:00 +0300
Message-ID: <1376892721-10410-6-git-send-email-yuvalmin@broadcom.com>
References: <1376892721-10410-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1728 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750988Ab3HSGMX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 02:12:23 -0400
In-Reply-To: <1376892721-10410-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

Since SR-IOV can be activated dynamically and iproute2 can be called
asynchronously, the various callbacks need a robust sanity check before
attempting to access the SR-IOV database and members since there are numerous
states in which it can find the driver (e.g., PF is down, sriov was not enabled
yet, VF is down, etc.). 

In many of the states the callback result will be null pointer dereference.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 49 ++++++++++++++---------
 1 file changed, 31 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 44104fb..d414b49 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -3084,8 +3084,9 @@ void bnx2x_disable_sriov(struct bnx2x *bp)
 	pci_disable_sriov(bp->pdev);
 }
 
-static int bnx2x_vf_ndo_sanity(struct bnx2x *bp, int vfidx,
-			       struct bnx2x_virtf *vf)
+static int bnx2x_vf_ndo_prep(struct bnx2x *bp, int vfidx,
+			     struct bnx2x_virtf **vf,
+			     struct pf_vf_bulletin_content **bulletin)
 {
 	if (bp->state != BNX2X_STATE_OPEN) {
 		BNX2X_ERR("vf ndo called though PF is down\n");
@@ -3103,12 +3104,22 @@ static int bnx2x_vf_ndo_sanity(struct bnx2x *bp, int vfidx,
 		return -EINVAL;
 	}
 
-	if (!vf) {
+	/* init members */
+	*vf = BP_VF(bp, vfidx);
+	*bulletin = BP_VF_BULLETIN(bp, vfidx);
+
+	if (!*vf) {
 		BNX2X_ERR("vf ndo called but vf was null. vfidx was %d\n",
 			  vfidx);
 		return -EINVAL;
 	}
 
+	if (!*bulletin) {
+		BNX2X_ERR("vf ndo called but Bulletin Board struct is null. vfidx was %d\n",
+			  vfidx);
+		return -EINVAL;
+	}
+
 	return 0;
 }
 
@@ -3116,17 +3127,19 @@ int bnx2x_get_vf_config(struct net_device *dev, int vfidx,
 			struct ifla_vf_info *ivi)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	struct bnx2x_virtf *vf = BP_VF(bp, vfidx);
-	struct bnx2x_vlan_mac_obj *mac_obj = &bnx2x_vfq(vf, 0, mac_obj);
-	struct bnx2x_vlan_mac_obj *vlan_obj = &bnx2x_vfq(vf, 0, vlan_obj);
-	struct pf_vf_bulletin_content *bulletin = BP_VF_BULLETIN(bp, vfidx);
+	struct bnx2x_virtf *vf = NULL;
+	struct pf_vf_bulletin_content *bulletin = NULL;
+	struct bnx2x_vlan_mac_obj *mac_obj;
+	struct bnx2x_vlan_mac_obj *vlan_obj;
 	int rc;
 
-	/* sanity */
-	rc = bnx2x_vf_ndo_sanity(bp, vfidx, vf);
+	/* sanity and init */
+	rc = bnx2x_vf_ndo_prep(bp, vfidx, &vf, &bulletin);
 	if (rc)
 		return rc;
-	if (!mac_obj || !vlan_obj || !bulletin) {
+	mac_obj = &bnx2x_vfq(vf, 0, mac_obj);
+	vlan_obj = &bnx2x_vfq(vf, 0, vlan_obj);
+	if (!mac_obj || !vlan_obj) {
 		BNX2X_ERR("VF partially initialized\n");
 		return -EINVAL;
 	}
@@ -3183,11 +3196,11 @@ int bnx2x_set_vf_mac(struct net_device *dev, int vfidx, u8 *mac)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	int rc, q_logical_state;
-	struct bnx2x_virtf *vf = BP_VF(bp, vfidx);
-	struct pf_vf_bulletin_content *bulletin = BP_VF_BULLETIN(bp, vfidx);
+	struct bnx2x_virtf *vf = NULL;
+	struct pf_vf_bulletin_content *bulletin = NULL;
 
-	/* sanity */
-	rc = bnx2x_vf_ndo_sanity(bp, vfidx, vf);
+	/* sanity and init */
+	rc = bnx2x_vf_ndo_prep(bp, vfidx, &vf, &bulletin);
 	if (rc)
 		return rc;
 	if (!is_valid_ether_addr(mac)) {
@@ -3249,11 +3262,11 @@ int bnx2x_set_vf_vlan(struct net_device *dev, int vfidx, u16 vlan, u8 qos)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	int rc, q_logical_state;
-	struct bnx2x_virtf *vf = BP_VF(bp, vfidx);
-	struct pf_vf_bulletin_content *bulletin = BP_VF_BULLETIN(bp, vfidx);
+	struct bnx2x_virtf *vf = NULL;
+	struct pf_vf_bulletin_content *bulletin = NULL;
 
-	/* sanity */
-	rc = bnx2x_vf_ndo_sanity(bp, vfidx, vf);
+	/* sanity and init */
+	rc = bnx2x_vf_ndo_prep(bp, vfidx, &vf, &bulletin);
 	if (rc)
 		return rc;
 
-- 
1.8.1.227.g44fe835
