From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net 3/4] be2net: Fix skb double free in be_xmit_wrokarounds() failure path
Date: Mon, 3 Mar 2014 14:25:07 +0530
Message-ID: <fe604946-bca2-4ac1-ba99-21fe6bb7dc24@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>,
	Vasundhara Volam <vasundhara.volam@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:39716 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753830AbaCCI4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 03:56:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

skb_padto(), skb_share_check() and __vlan_put_tag() routines free
skb when they return an error. This patch fixes be_xmit_workarounds()
to not free skb again in such cases.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 9e6d678..a9da6f9 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -927,7 +927,7 @@ static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
 	 */
 	if (unlikely(!BEx_chip(adapter) && skb->len <= 32)) {
 		if (skb_padto(skb, 36))
-			goto tx_drop;
+			goto err;
 		skb->len = 36;
 	}
 
@@ -959,7 +959,7 @@ static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
 	    vlan_tx_tag_present(skb)) {
 		skb = be_insert_vlan_in_pkt(adapter, skb, skip_hw_vlan);
 		if (unlikely(!skb))
-			goto tx_drop;
+			goto err;
 	}
 
 	/* HW may lockup when VLAN HW tagging is requested on
@@ -981,12 +981,13 @@ static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
 	    be_vlan_tag_tx_chk(adapter, skb)) {
 		skb = be_insert_vlan_in_pkt(adapter, skb, skip_hw_vlan);
 		if (unlikely(!skb))
-			goto tx_drop;
+			goto err;
 	}
 
 	return skb;
 tx_drop:
 	dev_kfree_skb_any(skb);
+err:
 	return NULL;
 }
 
-- 
1.5.6.1
