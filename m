From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 -- bad patch
Date: Wed, 26 Nov 2003 08:57:20 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031126085720.A30194@electric-eye.fr.zoreil.com>
References: <20031122183001.GA16993@gtf.org> <20031124000939.A456@electric-eye.fr.zoreil.com> <20031126004550.A25408@electric-eye.fr.zoreil.com> <3FC3F9E8.7040403@mcve.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="OXfL5xGRrasGEqWY"
Cc: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Brad House <brad@gentoo.org>
Content-Disposition: inline
In-Reply-To: <3FC3F9E8.7040403@mcve.com>; from brad@mcve.com on Tue, Nov 25, 2003 at 07:55:04PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Brad House <brad@mcve.com> :
> it appears as though the
> r8169-start-xmit-fixes.patch
> is the culprit for the system lockups ...
> After reverting that patch, it went back to vanilla behavior.

Could you replace it with the attached version of
r8169-start-xmit-fixes.patch ?

--
Ueimor

--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-start-xmit-fixes.patch"


rtl8169_start_xmit fixes:
- it forgot to update stats if the skb couldn't be expanded;
- it didn't free it either if the descriptor was not available.


 drivers/net/r8169.c |   30 ++++++++++++++++++------------
 1 files changed, 18 insertions(+), 12 deletions(-)

diff -puN drivers/net/r8169.c~r8169-start-xmit-fixes drivers/net/r8169.c
--- linux-2.6.0-test9/drivers/net/r8169.c~r8169-start-xmit-fixes	2003-11-26 08:29:40.000000000 +0100
+++ linux-2.6.0-test9-fr/drivers/net/r8169.c	2003-11-26 08:31:25.000000000 +0100
@@ -918,11 +918,13 @@ rtl8169_start_xmit(struct sk_buff *skb, 
 	struct rtl8169_private *tp = dev->priv;
 	void *ioaddr = tp->mmio_addr;
 	int entry = tp->cur_tx % NUM_TX_DESC;
+	u32 len = skb->len;
 
-	if (skb->len < ETH_ZLEN) {
+	if (unlikely(skb->len < ETH_ZLEN)) {
 		skb = skb_padto(skb, ETH_ZLEN);
-		if (skb == NULL)
-			return 0;
+		if (!skb)
+			goto err_update_stats;
+		len = ETH_ZLEN;
 	}
 	
 	spin_lock_irq(&tp->lock);
@@ -930,21 +932,17 @@ rtl8169_start_xmit(struct sk_buff *skb, 
 	if ((tp->TxDescArray[entry].status & OWNbit) == 0) {
 		tp->Tx_skbuff[entry] = skb;
 		tp->TxDescArray[entry].buf_addr = virt_to_bus(skb->data);
-		if (entry != (NUM_TX_DESC - 1))
-			tp->TxDescArray[entry].status =
-			    (OWNbit | FSbit | LSbit) | ((skb->len > ETH_ZLEN) ?
-							skb->len : ETH_ZLEN);
-		else
-			tp->TxDescArray[entry].status =
-			    (OWNbit | EORbit | FSbit | LSbit) |
-			    ((skb->len > ETH_ZLEN) ? skb->len : ETH_ZLEN);
 
+		tp->TxDescArray[entry].status = OWNbit | FSbit | LSbit | len |
+				(EORbit * !((entry + 1) % NUM_TX_DESC));
+			
 		RTL_W8(TxPoll, 0x40);	//set polling bit
 
 		dev->trans_start = jiffies;
 
 		tp->cur_tx++;
-	}
+	} else
+		goto err_drop;
 
 	spin_unlock_irq(&tp->lock);
 
@@ -952,7 +950,15 @@ rtl8169_start_xmit(struct sk_buff *skb, 
 		netif_stop_queue(dev);
 	}
 
+out:
 	return 0;
+
+err_drop:
+	spin_unlock_irq(&tp->lock);
+	dev_kfree_skb(skb);
+err_update_stats:
+	tp->stats.tx_dropped++;
+	goto out;
 }
 
 static void

_

--OXfL5xGRrasGEqWY--
