From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 02/20] net: bnx2x: slight optimization of addr compare
Date: Fri, 27 Dec 2013 14:48:13 +0800
Message-ID: <52BD22AD.3090702@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Ariel Elior <ariele@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the possibly more efficient ether_addr_equal or
ether_addr_equal_unaligned to instead of memcmp.

Cc: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c    | 10 ++++------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c  |  2 +-
 3 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 32c92ab..a83c67c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -663,7 +663,7 @@ static int bnx2x_check_mac_add(struct bnx2x *bp,
 
 	/* Check if a requested MAC already exists */
 	list_for_each_entry(pos, &o->head, link)
-		if (!memcmp(data->mac.mac, pos->u.mac.mac, ETH_ALEN) &&
+		if (ether_addr_equal(data->mac.mac, pos->u.mac.mac) &&
 		    (data->mac.is_inner_mac == pos->u.mac.is_inner_mac))
 			return -EEXIST;
 
@@ -696,8 +696,7 @@ static int bnx2x_check_vlan_mac_add(struct bnx2x *bp,
 
 	list_for_each_entry(pos, &o->head, link)
 		if ((data->vlan_mac.vlan == pos->u.vlan_mac.vlan) &&
-		    (!memcmp(data->vlan_mac.mac, pos->u.vlan_mac.mac,
-				  ETH_ALEN)) &&
+		    (ether_addr_equal_unaligned(data->vlan_mac.mac, pos->u.vlan_mac.mac)) &&
 		    (data->vlan_mac.is_inner_mac ==
 		     pos->u.vlan_mac.is_inner_mac))
 			return -EEXIST;
@@ -716,7 +715,7 @@ static struct bnx2x_vlan_mac_registry_elem *
 	DP(BNX2X_MSG_SP, "Checking MAC %pM for DEL command\n", data->mac.mac);
 
 	list_for_each_entry(pos, &o->head, link)
-		if ((!memcmp(data->mac.mac, pos->u.mac.mac, ETH_ALEN)) &&
+		if ((ether_addr_equal(data->mac.mac, pos->u.mac.mac)) &&
 		    (data->mac.is_inner_mac == pos->u.mac.is_inner_mac))
 			return pos;
 
@@ -751,8 +750,7 @@ static struct bnx2x_vlan_mac_registry_elem *
 
 	list_for_each_entry(pos, &o->head, link)
 		if ((data->vlan_mac.vlan == pos->u.vlan_mac.vlan) &&
-		    (!memcmp(data->vlan_mac.mac, pos->u.vlan_mac.mac,
-			     ETH_ALEN)) &&
+		    (ether_addr_equal_unaligned(data->vlan_mac.mac, pos->u.vlan_mac.mac)) &&
 		    (data->vlan_mac.is_inner_mac ==
 		     pos->u.vlan_mac.is_inner_mac))
 			return pos;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 2e46c28..040276b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -3605,7 +3605,7 @@ enum sample_bulletin_result bnx2x_sample_bulletin(struct bnx2x *bp)
 
 	/* the mac address in bulletin board is valid and is new */
 	if (bulletin.valid_bitmap & 1 << MAC_ADDR_VALID &&
-	    memcmp(bulletin.mac, bp->old_bulletin.mac, ETH_ALEN)) {
+	    !ether_addr_equal(bulletin.mac, bp->old_bulletin.mac)) {
 		/* update new mac to net device */
 		memcpy(bp->dev->dev_addr, bulletin.mac, ETH_ALEN);
 	}
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index efa8a15..4d2ae15 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -1702,7 +1702,7 @@ static void bnx2x_vf_mbx_set_q_filters(struct bnx2x *bp,
 
 		/* ...and only the mac set by the ndo */
 		if (filters->n_mac_vlan_filters == 1 &&
-		    memcmp(filters->filters->mac, bulletin->mac, ETH_ALEN)) {
+		    !ether_addr_equal(filters->filters->mac, bulletin->mac)) {
 			BNX2X_ERR("VF[%d] requested the addition of a mac address not matching the one configured by set_vf_mac ndo\n",
 				  vf->abs_vfid);
 
-- 
1.8.0
