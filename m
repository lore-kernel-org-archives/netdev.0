From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 02/10] vxlan: handle skb_clone failure
Date: Tue,  4 Jun 2013 21:24:06 -0700
Message-ID: <1370406254-6341-2-git-send-email-stephen@networkplumber.org>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:34497 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973Ab3FEEYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 00:24:22 -0400
Received: by mail-pd0-f181.google.com with SMTP id bv13so1237125pdb.12
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 21:24:21 -0700 (PDT)
In-Reply-To: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_clone can fail if out of memory. Just skip the fanout.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
Does not impact stable, this was introduced by the multiple
destination code.
---
 drivers/net/vxlan.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 536082a..9085c81 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1197,9 +1197,11 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 		struct sk_buff *skb1;
 
 		skb1 = skb_clone(skb, GFP_ATOMIC);
-		rc1 = vxlan_xmit_one(skb1, dev, rdst, did_rsc);
-		if (rc == NETDEV_TX_OK)
-			rc = rc1;
+		if (skb1) {
+			rc1 = vxlan_xmit_one(skb1, dev, rdst, did_rsc);
+			if (rc == NETDEV_TX_OK)
+				rc = rc1;
+		}
 	}
 
 	rc1 = vxlan_xmit_one(skb, dev, rdst0, did_rsc);
-- 
1.7.10.4
