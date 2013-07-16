From: <sarveshwar.bandi@emulex.com>
Subject: [PATCH net] be2net: Fix to avoid hardware workaround when not needed
Date: Tue, 16 Jul 2013 12:44:02 +0530
Message-ID: <458bdd84-53ce-489e-b134-f435c5fd6a50@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:29519 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973Ab3GPHNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 03:13:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

Hardware workaround requesting hardware to skip vlan insertion is necessary
only when umc or qnq is enabled. Enabling this workaround in other scenarios
could cause controller to stall.

Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2df48bb..181edb5 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -782,16 +782,22 @@ static struct sk_buff *be_insert_vlan_in_pkt(struct be_adapter *adapter,
 
 	if (vlan_tx_tag_present(skb))
 		vlan_tag = be_get_tx_vlan_tag(adapter, skb);
-	else if (qnq_async_evt_rcvd(adapter) && adapter->pvid)
-		vlan_tag = adapter->pvid;
+
+	if (qnq_async_evt_rcvd(adapter) && adapter->pvid) {
+		if (!vlan_tag)
+			vlan_tag = adapter->pvid;
+		/* f/w workaround to set skip_hw_vlan = 1, informs the F/W to
+		 * skip VLAN insertion
+		 */
+		if (skip_hw_vlan)
+			*skip_hw_vlan = true;
+	}
 
 	if (vlan_tag) {
 		skb = __vlan_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 		if (unlikely(!skb))
 			return skb;
 		skb->vlan_tci = 0;
-		if (skip_hw_vlan)
-			*skip_hw_vlan = true;
 	}
 
 	/* Insert the outer VLAN, if any */
-- 
1.7.9.5
