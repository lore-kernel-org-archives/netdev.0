From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NETIF_F_LLTX for devices 2
Date: 12 Sep 2004 13:34:30 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095010469.2344.215.camel@jzny.localdomain>
References: <E1C4wYe-0005qT-00@gondolin.me.apana.org.au>
	 <20040908072408.GI27886@wotan.suse.de>
	 <1094629677.1089.155.camel@jzny.localdomain>
	 <20040908134713.1bcd46d3.davem@davemloft.net>
	 <1094823215.1121.129.camel@jzny.localdomain>
	 <20040911142116.GL4431@wotan.suse.de>
	 <1094933731.2343.109.camel@jzny.localdomain>
	 <20040911174535.2acbb957.davem@davemloft.net>
	 <20040912100114.GB11484@havoc.gtf.org>
	 <20040912102529.GA27096@wotan.suse.de>
	 <20040912161604.GA23366@havoc.gtf.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-jHLccdGWjrFFQhCmzeiA"
Cc: Andi Kleen <ak@suse.de>, "David S. Miller" <davem@davemloft.net>,
        herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20040912161604.GA23366@havoc.gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-jHLccdGWjrFFQhCmzeiA
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2004-09-12 at 12:16, Jeff Garzik wrote:

> 
> Thanks, but still need a patch for return value constants, otherwise you
> are compounding rather than addressing a current problem.

Something along the lines of attached patch?
Francois needs to update the doc and you need someone to get the
janitors enthusiastic (i just updated e1000)

cheers,
jamal


--=-jHLccdGWjrFFQhCmzeiA
Content-Disposition: attachment; filename=andi-patch
Content-Type: text/plain; name=andi-patch; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- 269-rc1-bk17/include/linux/netdevice.h	2004/09/12 16:58:13	1.1
+++ 269-rc1-bk17/include/linux/netdevice.h	2004/09/12 17:10:45
@@ -73,6 +73,11 @@
 
 #define MAX_ADDR_LEN	32		/* Largest hardware address length */
 
+/* Driver transmit return codes */
+#define NETDEV_TX_OK 0		/* driver took care of packet */
+#define NETDEV_TX_BUSY 1	/* driver tx path was busy*/
+#define NETDEV_TX_LOCKED -1	/* driver tx lock was already taken */
+
 /*
  *	Compute the worst case header length according to the protocols
  *	used.
--- 269-rc1-bk17/net/sched/sch_generic.c	2004/09/12 16:55:03	1.1
+++ 269-rc1-bk17/net/sched/sch_generic.c	2004/09/12 17:08:52
@@ -139,13 +139,8 @@
 				if (netdev_nit)
 					dev_queue_xmit_nit(skb, dev);
 
-				/* hard_start_xmit returns: 
-				   0  device not ready
-				   1  everything ok
-				   -1 didn't get device lock (for LLTX)
-				*/ 
 				ret = dev->hard_start_xmit(skb, dev);
-				if (ret == 0) { 
+				if (ret == NETDEV_TX_OK) { 
 					if (!nolock) {
 						dev->xmit_lock_owner = -1;
 						spin_unlock(&dev->xmit_lock);
@@ -153,10 +148,11 @@
 					spin_lock(&dev->queue_lock);
 					return -1;
 				}
-				if (ret == -1 && nolock)
+				if (ret == NETDEV_TX_LOCKED && nolock)
 					goto collision; 
 			}
 
+			/* NETDEV_TX_BUSY - we need to requeue */
 			/* Release the driver */
 			if (!nolock) { 
 				dev->xmit_lock_owner = -1;
@@ -176,7 +172,7 @@
 		   3. device is buggy (ppp)
 		 */
 
-	requeue:
+requeue:
 		q->ops->requeue(skb, q);
 		netif_schedule(dev);
 		return 1;
--- 269-rc1-bk17/drivers/net/e1000/e1000_main.c	2004/09/12 17:05:58	1.1
+++ 269-rc1-bk17/drivers/net/e1000/e1000_main.c	2004/09/12 17:07:30
@@ -1778,7 +1778,7 @@
 
 	if(unlikely(skb->len <= 0)) {
 		dev_kfree_skb_any(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 #ifdef NETIF_F_TSO
@@ -1817,7 +1817,7 @@
  	if (!spin_trylock(&adapter->tx_lock)) { 
  		/* Collision - tell upper layer to requeue */ 
  		local_irq_restore(flags); 
- 		return -1; 
+ 		return NETDEV_TX_LOCKED; 
  	} 
 
 	/* need: count + 2 desc gap to keep tail from touching
@@ -1825,7 +1825,7 @@
 	if(E1000_DESC_UNUSED(&adapter->tx_ring) < count + 2) {
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&adapter->tx_lock, flags);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	if(unlikely(adapter->hw.mac_type == e1000_82547)) {
@@ -1833,7 +1833,7 @@
 			netif_stop_queue(netdev);
 			mod_timer(&adapter->tx_fifo_stall_timer, jiffies);
 			spin_unlock_irqrestore(&adapter->tx_lock, flags);
-			return 1;
+			return NETDEV_TX_BUSY;
 		}
 	}
 
@@ -1856,7 +1856,7 @@
 	netdev->trans_start = jiffies;
 
 	spin_unlock_irqrestore(&adapter->tx_lock, flags);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /**

--=-jHLccdGWjrFFQhCmzeiA--
