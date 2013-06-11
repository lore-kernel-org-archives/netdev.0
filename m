From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH v3 net 2/5] vxlan: handle skb_clone failure
Date: Mon, 10 Jun 2013 17:37:24 -0700
Message-ID: <20130610173724.46437629@nehalam.linuxnetplumber.net>
References: <20130611002547.346603375@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:34221 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754380Ab3FKAhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 20:37:48 -0400
Received: by mail-pd0-f181.google.com with SMTP id 14so5307495pdj.26
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 17:37:48 -0700 (PDT)
In-Reply-To: <20130611002547.346603375@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_clone can fail if out of memory. Just skip the fanout.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
v3 - no change

Needs be in -net. Not needed for stable.

--- a/drivers/net/vxlan.c	2013-06-10 15:04:59.239993130 -0700
+++ b/drivers/net/vxlan.c	2013-06-10 15:06:15.186973784 -0700
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
