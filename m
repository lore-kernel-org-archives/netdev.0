From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net v2 02/03] vxlan: handle skb_clone failure
Date: Mon, 10 Jun 2013 13:12:30 -0700
Message-ID: <20130610131230.486f43fc@nehalam.linuxnetplumber.net>
References: <20130610195822.888424947@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:61052 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999Ab3FJUMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 16:12:39 -0400
Received: by mail-pb0-f51.google.com with SMTP id um15so7645231pbc.10
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 13:12:38 -0700 (PDT)
In-Reply-To: <20130610195822.888424947@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_clone can fail if out of memory. Just skip the fanout.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
The multi-destination was added in 3.10, does not need to goto stable

--- a/drivers/net/vxlan.c	2013-06-06 08:29:07.890429399 -0700
+++ b/drivers/net/vxlan.c	2013-06-06 09:38:52.723669153 -0700
@@ -1198,9 +1198,11 @@ static netdev_tx_t vxlan_xmit(struct sk_
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
