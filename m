From: Roland Dreier <roland@topspin.com>
Subject: LLTX and netif_stop_queue
Date: Fri, 17 Dec 2004 13:57:40 -0800
Message-ID: <52llbwoaej.fsf@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: netdev@oss.sgi.com, davem@redhat.com
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

While testing my IP-over-InfiniBand driver, I discovered that if a net
device sets NETIF_F_LLTX, it seems the device's hard_start_xmit method
can be called even after a netif_stop_queue().

This is because in the LLTX case, qdisc_restart() holds no locks while
calling hard_start_xmit, so something like the following can happen:

    CPU 1                                CPU 2

    qdisc_restart:
      drop queue lock
      call hard_start_xmit()
        net driver:
          acquire TX lock
          queue packet to HW

                                        acquire queue lock...
                                        qdisc_restart:
                                          drop queue lock
                                          call hard_start_xmit:

          queue full, call netif_stop_queue()
          release TX lock

                                            net driver:
                                              acquire TX lock
                                              queue is already full!

Is my understanding correct?  If so it seems the patch below would
make sense.  (e1000 seems to handle this properly already)

Thanks,
  Roland


Since tg3 and sungem now use lockless TX (NETIF_F_LLTX), it's possible
for their hard_start_xmit method to be called even after they call
netif_stop_queue.  Therefore a full queue no longer indicates a bug --
this patch fixes the comment and removes the KERN_ERR printk.

Signed-off-by: Roland Dreier <roland@topspin.com>

Index: linux-bk/drivers/net/sungem.c
===================================================================
--- linux-bk.orig/drivers/net/sungem.c	2004-12-16 15:56:19.000000000 -0800
+++ linux-bk/drivers/net/sungem.c	2004-12-17 13:46:43.307064457 -0800
@@ -976,12 +976,10 @@
 		return NETDEV_TX_LOCKED;
 	}
 
-	/* This is a hard error, log it. */
+	/* This may happen, since we have NETIF_F_LLTX set */
 	if (TX_BUFFS_AVAIL(gp) <= (skb_shinfo(skb)->nr_frags + 1)) {
 		netif_stop_queue(dev);
 		spin_unlock_irqrestore(&gp->tx_lock, flags);
-		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
-		       dev->name);
 		return NETDEV_TX_BUSY;
 	}
 
Index: linux-bk/drivers/net/tg3.c
===================================================================
--- linux-bk.orig/drivers/net/tg3.c	2004-12-16 15:56:06.000000000 -0800
+++ linux-bk/drivers/net/tg3.c	2004-12-17 13:46:25.952622672 -0800
@@ -3076,12 +3076,10 @@
 		return NETDEV_TX_LOCKED; 
 	} 
 
-	/* This is a hard error, log it. */
+	/* This may happen, since we have NETIF_F_LLTX set */
 	if (unlikely(TX_BUFFS_AVAIL(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
 		netif_stop_queue(dev);
 		spin_unlock_irqrestore(&tp->tx_lock, flags);
-		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
-		       dev->name);
 		return NETDEV_TX_BUSY;
 	}
 
