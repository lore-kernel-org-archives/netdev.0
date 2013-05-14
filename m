From: <sarveshwar.bandi@emulex.com>
Subject: [PATCH net] be2net: Avoid double insertion of vlan tags.
Date: Tue, 14 May 2013 11:58:20 +0530
Message-ID: <99cc7c56-50d0-448a-8792-5661cdf030d9@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:40713 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751177Ab3ENG0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 02:26:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

Fix to avoid double insertion of  vlan tags into the packet while
handling an asic workaroud (issue introduced by net next Commit bc0c340)

Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index a444110..ca2967b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -780,26 +780,18 @@ static struct sk_buff *be_insert_vlan_in_pkt(struct be_adapter *adapter,
 	if (unlikely(!skb))
 		return skb;
 
-	if (vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb))
 		vlan_tag = be_get_tx_vlan_tag(adapter, skb);
-		skb = __vlan_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
-		if (skb)
-			skb->vlan_tci = 0;
-	}
-
-	if (qnq_async_evt_rcvd(adapter) && adapter->pvid) {
-		if (!vlan_tag)
-			vlan_tag = adapter->pvid;
-		if (skip_hw_vlan)
-			*skip_hw_vlan = true;
-	}
+	else if (qnq_async_evt_rcvd(adapter) && adapter->pvid)
+		vlan_tag = adapter->pvid;
 
 	if (vlan_tag) {
 		skb = __vlan_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 		if (unlikely(!skb))
 			return skb;
-
 		skb->vlan_tci = 0;
+		if (skip_hw_vlan)
+			*skip_hw_vlan = true;
 	}
 
 	/* Insert the outer VLAN, if any */
-- 
1.7.9.5
