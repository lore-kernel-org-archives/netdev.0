From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.9-rc1-mm4 2/4] r8169: hint for Tx flow control
Date: Fri, 10 Sep 2004 00:48:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909224817.GA10144@electric-eye.fr.zoreil.com>
References: <20040909224539.GA9629@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040909224539.GA9629@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

return 1 in start_xmit() when the required descriptors are not available
and wait for more room.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-140 drivers/net/r8169.c
--- linux-2.6.9-rc1/drivers/net/r8169.c~r8169-140	2004-09-08 22:02:53.000000000 +0200
+++ linux-2.6.9-rc1-fr/drivers/net/r8169.c	2004-09-08 22:04:04.000000000 +0200
@@ -1768,15 +1768,16 @@ static int rtl8169_start_xmit(struct sk_
 	dma_addr_t mapping;
 	u32 status, len;
 	u32 opts1;
+	int ret = 0;
 	
 	if (unlikely(TX_BUFFS_AVAIL(tp) < skb_shinfo(skb)->nr_frags)) {
 		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
 		       dev->name);
-		return 1;
+		goto err_stop;
 	}
 
 	if (unlikely(le32_to_cpu(txd->opts1) & DescOwn))
-		goto err_drop;
+		goto err_stop;
 
 	opts1 = DescOwn | rtl8169_tx_csum(skb);
 
@@ -1826,10 +1827,11 @@ static int rtl8169_start_xmit(struct sk_
 	}
 
 out:
-	return 0;
+	return ret;
 
-err_drop:
-	dev_kfree_skb(skb);
+err_stop:
+	netif_stop_queue(dev);
+	ret = 1;
 err_update_stats:
 	tp->stats.tx_dropped++;
 	goto out;

_
