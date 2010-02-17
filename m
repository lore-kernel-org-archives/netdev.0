From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH net-next-2.6 1/4] be2net: a mini optimization in
 rx_compl_process() code
Date: Wed, 17 Feb 2010 17:04:22 +0530
Message-ID: <20100217113422.GA19674@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:23124 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752385Ab0BQLeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:34:37 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce unlikely() for skb alloc failure and vlanf checks...

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index cbfaa3f..7bf1900 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -768,16 +768,8 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 	u32 vlanf, vid;
 	u8 vtm;
 
-	vlanf = AMAP_GET_BITS(struct amap_eth_rx_compl, vtp, rxcp);
-	vtm = AMAP_GET_BITS(struct amap_eth_rx_compl, vtm, rxcp);
-
-	/* vlanf could be wrongly set in some cards.
-	 * ignore if vtm is not set */
-	if ((adapter->cap & 0x400) && !vtm)
-		vlanf = 0;
-
 	skb = netdev_alloc_skb_ip_align(adapter->netdev, BE_HDR_LEN);
-	if (!skb) {
+	if (unlikely(!skb)) {
 		if (net_ratelimit())
 			dev_warn(&adapter->pdev->dev, "skb alloc failed\n");
 		be_rx_compl_discard(adapter, rxcp);
@@ -795,7 +787,15 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 	skb->protocol = eth_type_trans(skb, adapter->netdev);
 	skb->dev = adapter->netdev;
 
-	if (vlanf) {
+	vlanf = AMAP_GET_BITS(struct amap_eth_rx_compl, vtp, rxcp);
+	vtm = AMAP_GET_BITS(struct amap_eth_rx_compl, vtm, rxcp);
+
+	/* vlanf could be wrongly set in some cards.
+	 * ignore if vtm is not set */
+	if ((adapter->cap & 0x400) && !vtm)
+		vlanf = 0;
+
+	if (unlikely(vlanf)) {
 		if (!adapter->vlan_grp || adapter->vlans_added == 0) {
 			kfree_skb(skb);
 			return;
-- 
1.6.3.3

