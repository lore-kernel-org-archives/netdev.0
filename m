From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2010-12-22
Date: Wed, 22 Dec 2010 14:52:09 -0500
Message-ID: <20101222195209.GD10046@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Three more fixes intended for 2.6.37...

The one from Johannes Berg avoids a NULL pointer dereference in the mesh
code.  The one from Johannes Stezenbach fixes bug 24892, which is a
lock-up caused by rt2x00.  Finally, you probably recognize the one from
Meelis Roos which removes some log spam coming from hostap.  These have
all spent several days in linux-next without any adverse effects.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 227fb925d3d3c5e565c1f1323a530564509195f2:

  MAINTAINERS: email address change (2010-12-21 19:58:15 -0800)

are available in the git repository at:
  ssh://master.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Johannes Berg (1):
      mac80211: fix mesh forwarding

Johannes Stezenbach (1):
      mac80211/rt2x00: add ieee80211_tx_status_ni()

Meelis Roos (1):
      hostap: remove netif_stop_queue from init

 drivers/net/wireless/hostap/hostap_main.c |    1 -
 drivers/net/wireless/rt2x00/rt2800pci.c   |    1 +
 drivers/net/wireless/rt2x00/rt2x00.h      |    1 +
 drivers/net/wireless/rt2x00/rt2x00dev.c   |    9 ++++++---
 include/net/mac80211.h                    |   28 ++++++++++++++++++++++++----
 net/mac80211/rx.c                         |    5 ++++-
 6 files changed, 36 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index 25a2722..1d9aed6 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -891,7 +891,6 @@ void hostap_setup_dev(struct net_device *dev, local_info_t *local,
 
 	SET_ETHTOOL_OPS(dev, &prism2_ethtool_ops);
 
-	netif_stop_queue(dev);
 }
 
 static int hostap_enable_hostapd(local_info_t *local, int rtnl_locked)
diff --git a/drivers/net/wireless/rt2x00/rt2800pci.c b/drivers/net/wireless/rt2x00/rt2800pci.c
index b267395..09a6790 100644
--- a/drivers/net/wireless/rt2x00/rt2800pci.c
+++ b/drivers/net/wireless/rt2x00/rt2800pci.c
@@ -912,6 +912,7 @@ static int rt2800pci_probe_hw(struct rt2x00_dev *rt2x00dev)
 	__set_bit(DRIVER_REQUIRE_DMA, &rt2x00dev->flags);
 	__set_bit(DRIVER_REQUIRE_L2PAD, &rt2x00dev->flags);
 	__set_bit(DRIVER_REQUIRE_TXSTATUS_FIFO, &rt2x00dev->flags);
+	__set_bit(DRIVER_REQUIRE_TASKLET_CONTEXT, &rt2x00dev->flags);
 	if (!modparam_nohwcrypt)
 		__set_bit(CONFIG_SUPPORT_HW_CRYPTO, &rt2x00dev->flags);
 	__set_bit(DRIVER_SUPPORT_LINK_TUNING, &rt2x00dev->flags);
diff --git a/drivers/net/wireless/rt2x00/rt2x00.h b/drivers/net/wireless/rt2x00/rt2x00.h
index 94fe589..ab43e7c 100644
--- a/drivers/net/wireless/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/rt2x00/rt2x00.h
@@ -664,6 +664,7 @@ enum rt2x00_flags {
 	DRIVER_REQUIRE_COPY_IV,
 	DRIVER_REQUIRE_L2PAD,
 	DRIVER_REQUIRE_TXSTATUS_FIFO,
+	DRIVER_REQUIRE_TASKLET_CONTEXT,
 
 	/*
 	 * Driver features
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index 5ba79b9..d019830 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -390,9 +390,12 @@ void rt2x00lib_txdone(struct queue_entry *entry,
 	 * through a mac80211 library call (RTS/CTS) then we should not
 	 * send the status report back.
 	 */
-	if (!(skbdesc_flags & SKBDESC_NOT_MAC80211))
-		ieee80211_tx_status(rt2x00dev->hw, entry->skb);
-	else
+	if (!(skbdesc_flags & SKBDESC_NOT_MAC80211)) {
+		if (test_bit(DRIVER_REQUIRE_TASKLET_CONTEXT, &rt2x00dev->flags))
+			ieee80211_tx_status(rt2x00dev->hw, entry->skb);
+		else
+			ieee80211_tx_status_ni(rt2x00dev->hw, entry->skb);
+	} else
 		dev_kfree_skb_any(entry->skb);
 
 	/*
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 9fdf982..365359b 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -2024,8 +2024,8 @@ static inline void ieee80211_rx_ni(struct ieee80211_hw *hw,
  *
  * This function may not be called in IRQ context. Calls to this function
  * for a single hardware must be synchronized against each other. Calls
- * to this function and ieee80211_tx_status_irqsafe() may not be mixed
- * for a single hardware.
+ * to this function, ieee80211_tx_status_ni() and ieee80211_tx_status_irqsafe()
+ * may not be mixed for a single hardware.
  *
  * @hw: the hardware the frame was transmitted by
  * @skb: the frame that was transmitted, owned by mac80211 after this call
@@ -2034,13 +2034,33 @@ void ieee80211_tx_status(struct ieee80211_hw *hw,
 			 struct sk_buff *skb);
 
 /**
+ * ieee80211_tx_status_ni - transmit status callback (in process context)
+ *
+ * Like ieee80211_tx_status() but can be called in process context.
+ *
+ * Calls to this function, ieee80211_tx_status() and
+ * ieee80211_tx_status_irqsafe() may not be mixed
+ * for a single hardware.
+ *
+ * @hw: the hardware the frame was transmitted by
+ * @skb: the frame that was transmitted, owned by mac80211 after this call
+ */
+static inline void ieee80211_tx_status_ni(struct ieee80211_hw *hw,
+					  struct sk_buff *skb)
+{
+	local_bh_disable();
+	ieee80211_tx_status(hw, skb);
+	local_bh_enable();
+}
+
+/**
  * ieee80211_tx_status_irqsafe - IRQ-safe transmit status callback
  *
  * Like ieee80211_tx_status() but can be called in IRQ context
  * (internally defers to a tasklet.)
  *
- * Calls to this function and ieee80211_tx_status() may not be mixed for a
- * single hardware.
+ * Calls to this function, ieee80211_tx_status() and
+ * ieee80211_tx_status_ni() may not be mixed for a single hardware.
  *
  * @hw: the hardware the frame was transmitted by
  * @skb: the frame that was transmitted, owned by mac80211 after this call
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 54fb4a0e..b01e467 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1788,9 +1788,11 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data *rx)
 
 			fwd_skb = skb_copy(skb, GFP_ATOMIC);
 
-			if (!fwd_skb && net_ratelimit())
+			if (!fwd_skb && net_ratelimit()) {
 				printk(KERN_DEBUG "%s: failed to clone mesh frame\n",
 						   sdata->name);
+				goto out;
+			}
 
 			fwd_hdr =  (struct ieee80211_hdr *) fwd_skb->data;
 			memcpy(fwd_hdr->addr2, sdata->vif.addr, ETH_ALEN);
@@ -1828,6 +1830,7 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data *rx)
 		}
 	}
 
+ out:
 	if (is_multicast_ether_addr(hdr->addr1) ||
 	    sdata->dev->flags & IFF_PROMISC)
 		return RX_CONTINUE;
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
