From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net] ravb: Double free on error in ravb_start_xmit()
Date: Sat, 22 Apr 2017 13:46:56 +0300
Message-ID: <20170422104656.jjnooh3or4x3lbw3@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        Yoshihiro Kaneko <ykaneko0929@gmail.com>,
        Masaru Nagai <masaru.nagai.vx@renesas.com>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        Niklas =?iso-8859-1?Q?S=F6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If skb_put_padto() fails then it frees the skb.  I shifted that code
up a bit to make my error handling a little simpler.

Fixes: a0d2f20650e8 ("Renesas Ethernet AVB PTP clock driver")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 8cfc4a54f2dc..3cd7989c007d 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -1516,11 +1516,12 @@ static netdev_tx_t ravb_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		spin_unlock_irqrestore(&priv->lock, flags);
 		return NETDEV_TX_BUSY;
 	}
-	entry = priv->cur_tx[q] % (priv->num_tx_ring[q] * NUM_TX_DESC);
-	priv->tx_skb[q][entry / NUM_TX_DESC] = skb;
 
 	if (skb_put_padto(skb, ETH_ZLEN))
-		goto drop;
+		goto exit;
+
+	entry = priv->cur_tx[q] % (priv->num_tx_ring[q] * NUM_TX_DESC);
+	priv->tx_skb[q][entry / NUM_TX_DESC] = skb;
 
 	buffer = PTR_ALIGN(priv->tx_align[q], DPTR_ALIGN) +
 		 entry / NUM_TX_DESC * DPTR_ALIGN;
