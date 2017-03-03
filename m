From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net 5/7] bnx2x: do not rollback VF MAC/VLAN filters we did not configure
Date: Fri,  3 Mar 2017 17:08:32 +0100
Message-ID: <20170303160834.4125-6-mschmidt@redhat.com>
References: <20170303160834.4125-1-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54010 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752122AbdCCQIx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Mar 2017 11:08:53 -0500
In-Reply-To: <20170303160834.4125-1-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On failure to configure a VF MAC/VLAN filter we should not attempt to
rollback filters that we failed to configure with -EEXIST.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 8 +++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h | 1 +
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 9f0f851774..2068bb8f54 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -434,7 +434,9 @@ static int bnx2x_vf_mac_vlan_config(struct bnx2x *bp,
 
 	/* Add/Remove the filter */
 	rc = bnx2x_config_vlan_mac(bp, &ramrod);
-	if (rc && rc != -EEXIST) {
+	if (rc == -EEXIST)
+		return 0;
+	if (rc) {
 		BNX2X_ERR("Failed to %s %s\n",
 			  filter->add ? "add" : "delete",
 			  (filter->type == BNX2X_VF_FILTER_VLAN_MAC) ?
@@ -444,6 +446,8 @@ static int bnx2x_vf_mac_vlan_config(struct bnx2x *bp,
 		return rc;
 	}
 
+	filter->applied = true;
+
 	return 0;
 }
 
@@ -471,6 +475,8 @@ int bnx2x_vf_mac_vlan_config_list(struct bnx2x *bp, struct bnx2x_virtf *vf,
 		BNX2X_ERR("Managed only %d/%d filters - rolling back\n",
 			  i, filters->count + 1);
 		while (--i >= 0) {
+			if (!filters->filters[i].applied)
+				continue;
 			filters->filters[i].add = !filters->filters[i].add;
 			bnx2x_vf_mac_vlan_config(bp, vf, qid,
 						 &filters->filters[i],
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
index 7a6d406f4c..888d0b6632 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -114,6 +114,7 @@ struct bnx2x_vf_mac_vlan_filter {
 	(BNX2X_VF_FILTER_MAC | BNX2X_VF_FILTER_VLAN) /*shortcut*/
 
 	bool add;
+	bool applied;
 	u8 *mac;
 	u16 vid;
 };
-- 
2.9.3
