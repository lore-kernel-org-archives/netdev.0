From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] net: atheros: atl1: Use common error handling code in
 atl1_xmit_frame()
Date: Sat, 28 Oct 2017 16:32:55 +0200
Message-ID: <4b3b7535-6ea0-b4fe-404a-de800b838e4f@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Chris Snook <chris.snook@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Geliang Tang <geliangtang@gmail.com>,
        Jay Cliburn <jcliburn@gmail.com>,
        Philippe Reynes <tremyfr@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Language: en-GB
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 28 Oct 2017 16:22:30 +0200

Add a jump target so that a bit of exception handling can be better reused
at the end of this function.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/atheros/atlx/atl1.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 83d2db2abb45..030dac9c06aa 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -2424,17 +2424,13 @@ static netdev_tx_t atl1_xmit_frame(struct sk_buff *skb,
 	}
 
 	tso = atl1_tso(adapter, skb, ptpd);
-	if (tso < 0) {
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
-	}
+	if (tso < 0)
+		goto free_skb;
 
 	if (!tso) {
 		ret_val = atl1_tx_csum(adapter, skb, ptpd);
-		if (ret_val < 0) {
-			dev_kfree_skb_any(skb);
-			return NETDEV_TX_OK;
-		}
+		if (ret_val < 0)
+			goto free_skb;
 	}
 
 	atl1_tx_map(adapter, skb, ptpd);
@@ -2442,6 +2438,10 @@ static netdev_tx_t atl1_xmit_frame(struct sk_buff *skb,
 	atl1_update_mailbox(adapter);
 	mmiowb();
 	return NETDEV_TX_OK;
+
+free_skb:
+	dev_kfree_skb_any(skb);
+	return NETDEV_TX_OK;
 }
 
 static int atl1_rings_clean(struct napi_struct *napi, int budget)
-- 
2.14.3

