From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 3/3] vxlan: handle skb_clone failure
Date: Mon, 17 Jun 2013 12:09:59 -0700
Message-ID: <1371496199-5424-4-git-send-email-stephen@networkplumber.org>
References: <1371496199-5424-1-git-send-email-stephen@networkplumber.org>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:59459 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309Ab3FQTKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 15:10:09 -0400
Received: by mail-pa0-f45.google.com with SMTP id bi5so3163071pad.18
        for <netdev@vger.kernel.org>; Mon, 17 Jun 2013 12:10:08 -0700 (PDT)
In-Reply-To: <1371496199-5424-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If skb_clone fails if out of memory then just skip the fanout.

Problem was introduced in 3.10 with:
  commit 6681712d67eef14c4ce793561c3231659153a320
  Author: David Stevens <dlstevens@us.ibm.com>
  Date:   Fri Mar 15 04:35:51 2013 +0000

    vxlan: generalize forwarding tables

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vxlan.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 15a73ec..dda997a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1161,9 +1161,11 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
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
