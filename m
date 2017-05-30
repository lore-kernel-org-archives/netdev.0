From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/7] net: dsa: free orig skb on rcv if reallocated
Date: Tue, 30 May 2017 10:21:28 -0400
Message-ID: <20170530142131.23568-5-vivien.didelot@savoirfairelinux.com>
References: <20170530142131.23568-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:43380 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751263AbdE3OXp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 10:23:45 -0400
In-Reply-To: <20170530142131.23568-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the receive function of a tagger reallocated the SKB, the original
SKB is currently not freed. Fix this and free it on both copy or error.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 98173a3f6fd1..0b6f2c7d7d1c 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -209,11 +209,12 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (!skb)
 		return 0;
 
+	/* Receive function may have to reallocate the original SKB */
 	nskb = dst->tag_ops->rcv(skb, dev);
-	if (!nskb) {
+	if (nskb != skb)
 		kfree_skb(skb);
+	if (!nskb)
 		return 0;
-	}
 
 	skb = nskb;
 	skb_push(skb, ETH_HLEN);
-- 
2.13.0
