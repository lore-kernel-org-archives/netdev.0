From: Jiri Benc <jbenc@suse.cz>
Subject: [incomplete 2/5] bcm43xx-d80211: per-queue TX flow control
Date: Mon, 12 Jun 2006 21:16:03 +0200 (CEST)
Message-ID: <20060612191603.6025C4838C@silver.suse.cz>
References: <20060612211454.409884000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mbuesch@freenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:1959 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932087AbWFLTOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2006 15:14:49 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060612211454.409884000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an attempt to fix bcm43xx driver. It is for DMA mode only and
incomplete even for that mode - ieee80211_hw->tx() callback should return
NETDEV_TX_* constants which is not completely fixed by this patch.

---
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c  |    6 +++++-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |    1 +
 2 files changed, 6 insertions(+), 1 deletion(-)

--- dscape.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
+++ dscape/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
@@ -778,13 +778,16 @@ int bcm43xx_dma_tx(struct bcm43xx_privat
 		 * recognizes if the device queue is full and does
 		 * not send data anymore.
 		 */
+		ieee80211_stop_queue(bcm->net_dev, 0);
 		printk(KERN_ERR PFX "DMA queue overflow\n");
-		return -ENOMEM;
+		return NETDEV_TX_BUSY;
 	}
 
 	err = dma_tx_fragment(ring, skb, ctl);
 	if (likely(!err))
 		ring->nr_tx_packets++;
+	if (free_slots(ring) < SLOTS_PER_PACKET)
+		ieee80211_stop_queue(bcm->net_dev, 0);
 
 	return err;
 }
@@ -833,6 +836,7 @@ void bcm43xx_dma_handle_xmitstatus(struc
 		slot = next_slot(ring, slot);
 	}
 	bcm->stats.last_tx = jiffies;
+	ieee80211_wake_queue(bcm->net_dev, 0);
 }
 
 void bcm43xx_dma_get_tx_stats(struct bcm43xx_private *bcm,
--- dscape.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ dscape/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -3737,6 +3737,7 @@ static int bcm43xx_init_board(struct bcm
 	bcm43xx_security_init(bcm);
 	bcm43xx_measure_channel_change_time(bcm);
 	ieee80211_update_hw(bcm->net_dev, bcm->ieee);
+	ieee80211_start_queues(bcm->net_dev);
 	ieee80211_netif_oper(bcm->net_dev, NETIF_ATTACH);
 	ieee80211_netif_oper(bcm->net_dev, NETIF_START);
 	ieee80211_netif_oper(bcm->net_dev, NETIF_WAKE);
