From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next v3 10/27] benet: use __vlan_hwaccel helpers
Date: Wed,  4 Jan 2017 00:11:08 +0100 (CET)
Message-ID: <8a9f0d12b69ee4e25fefc4872575d5cf31441bb8.1483484748.git.mirq-linux@rere.qmqm.pl>
References: <cover.1483484748.git.mirq-linux@rere.qmqm.pl> <49348df8468691f6065a7a3c8c10dd076612d587.1483475202.git.mirq-linux@rere.qmqm.pl>
        <CACZ4nhsUxWYvM5HoASHb7-m2uZtnk3DN6cQigp+cObyLqPJXdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Ajit Khaparde <ajit.khaparde@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:36512 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761776AbdACXLK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 18:11:10 -0500
In-Reply-To: <CACZ4nhsUxWYvM5HoASHb7-m2uZtnk3DN6cQigp+cObyLqPJXdA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
v3: fix adapter->pvid handling

 drivers/net/ethernet/emulex/benet/be_main.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 7e1633bf5a22..cd12c9a7664b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1035,30 +1035,35 @@ static struct sk_buff *be_insert_vlan_in_pkt(struct be_adapter *adapter,
 					     struct be_wrb_params
 					     *wrb_params)
 {
+	bool insert_vlan = false;
 	u16 vlan_tag = 0;
 
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (unlikely(!skb))
 		return skb;
 
-	if (skb_vlan_tag_present(skb))
+	if (skb_vlan_tag_present(skb)) {
 		vlan_tag = be_get_tx_vlan_tag(adapter, skb);
+		insert_vlan = true;
+	}
 
 	if (qnq_async_evt_rcvd(adapter) && adapter->pvid) {
-		if (!vlan_tag)
+		if (!insert_vlan) {
 			vlan_tag = adapter->pvid;
+			insert_vlan = true;
+		}
 		/* f/w workaround to set skip_hw_vlan = 1, informs the F/W to
 		 * skip VLAN insertion
 		 */
 		BE_WRB_F_SET(wrb_params->features, VLAN_SKIP_HW, 1);
 	}
 
-	if (vlan_tag) {
+	if (insert_vlan) {
 		skb = vlan_insert_tag_set_proto(skb, htons(ETH_P_8021Q),
 						vlan_tag);
 		if (unlikely(!skb))
 			return skb;
-		skb->vlan_tci = 0;
+		__vlan_hwaccel_clear_tag(skb);
 	}
 
 	/* Insert the outer VLAN, if any */
-- 
2.11.0
