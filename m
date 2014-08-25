From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: [PATCH v6 1/4] net: moxa: clear DESC1 on ndo_start_xmit()
Date: Mon, 25 Aug 2014 16:22:11 +0200
Message-ID: <1408976531-15589-1-git-send-email-jonas.jensen@gmail.com>
References: <1408544322-32023-1-git-send-email-jonas.jensen@gmail.com>
Cc: davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, f.fainelli@gmail.com,
	eric.dumazet@gmail.com, mirqus@gmail.com,
	Jonas Jensen <jonas.jensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408544322-32023-1-git-send-email-jonas.jensen@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TX buffer length is not cleared on ndo_start_xmit().
Failing to do so can bug/hang the controller and
cause TX interrupts to stop altogether.

Remove the readl() and compute a new value for DESC1.

Addresses https://bugzilla.kernel.org/show_bug.cgi?id=69031

Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
---

Notes:
    Changes since v5:
    
    1. remove readl(desc + TX_REG_OFFSET_DESC1) in moxart_mac_start_xmit()
    2. compute entirely new values for DESC1
    3. set TX_DESC1_END if (tx_head == TX_DESC_NUM_MASK)
    
    Applies to next-20140825

 drivers/net/ethernet/moxa/moxart_ether.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 5020fd4..eed70d9 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -346,10 +346,9 @@ static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		len = ETH_ZLEN;
 	}
 
-	txdes1 = readl(desc + TX_REG_OFFSET_DESC1);
-	txdes1 |= TX_DESC1_LTS | TX_DESC1_FTS;
-	txdes1 &= ~(TX_DESC1_FIFO_COMPLETE | TX_DESC1_INTR_COMPLETE);
-	txdes1 |= (len & TX_DESC1_BUF_SIZE_MASK);
+	txdes1 = TX_DESC1_LTS | TX_DESC1_FTS | (len & TX_DESC1_BUF_SIZE_MASK);
+	if (tx_head == TX_DESC_NUM_MASK)
+		txdes1 |= TX_DESC1_END;
 	writel(txdes1, desc + TX_REG_OFFSET_DESC1);
 	writel(TX_DESC0_DMA_OWN, desc + TX_REG_OFFSET_DESC0);
 
-- 
1.8.2.1
