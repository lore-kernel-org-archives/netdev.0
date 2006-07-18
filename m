From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] ieee80211: Make ieee80211_rx_any usable
Date: Tue, 18 Jul 2006 21:38:05 +0100 (BST)
Message-ID: <20060718203805.5E8258DEF39@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:5714 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932390AbWGRUiB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 16:38:01 -0400
To: linville@tuxdriver.com
Cc: johannes@sipsolutions.net
Cc: zaitcev@redhat.com
Cc: vda@ilport.com.ua
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ieee80211_rx_any is new to 2.6.18-rc1, even though it appears this function
was never completed:

http://lists.sipsolutions.net/pipermail/softmac-dev/2006-February/000103.html

This patch changes ieee80211_rx_any to always claim the skb, which avoids
further driver complexity and the possibility of leaking management frames.
It also exports the function so that people can actually use it.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
Acked-by: Johannes Berg <johannes@sipsolutions.net>

Index: linux/include/net/ieee80211.h
===================================================================
--- linux.orig/include/net/ieee80211.h
+++ linux/include/net/ieee80211.h
@@ -1259,6 +1259,8 @@ extern int ieee80211_tx_frame(struct iee
 			      int total_len, int encrypt_mpdu);
 
 /* ieee80211_rx.c */
+extern void ieee80211_rx_any(struct ieee80211_device *ieee,
+		     struct sk_buff *skb, struct ieee80211_rx_stats *stats);
 extern int ieee80211_rx(struct ieee80211_device *ieee, struct sk_buff *skb,
 			struct ieee80211_rx_stats *rx_stats);
 /* make sure to set stats->len */
Index: linux/net/ieee80211/ieee80211_rx.c
===================================================================
--- linux.orig/net/ieee80211/ieee80211_rx.c
+++ linux/net/ieee80211/ieee80211_rx.c
@@ -779,33 +779,44 @@ int ieee80211_rx(struct ieee80211_device
 	return 0;
 }
 
-/* Filter out unrelated packets, call ieee80211_rx[_mgt] */
-int ieee80211_rx_any(struct ieee80211_device *ieee,
+/* Filter out unrelated packets, call ieee80211_rx[_mgt]
+ * This function takes over the skb, it should not be used again after calling
+ * this function. */
+void ieee80211_rx_any(struct ieee80211_device *ieee,
 		     struct sk_buff *skb, struct ieee80211_rx_stats *stats)
 {
 	struct ieee80211_hdr_4addr *hdr;
 	int is_packet_for_us;
 	u16 fc;
 
-	if (ieee->iw_mode == IW_MODE_MONITOR)
-		return ieee80211_rx(ieee, skb, stats) ? 0 : -EINVAL;
+	if (ieee->iw_mode == IW_MODE_MONITOR) {
+		if (!ieee80211_rx(ieee, skb, stats))
+			dev_kfree_skb_irq(skb);
+		return;
+	}
+
+	if (skb->len < sizeof(struct ieee80211_hdr))
+		goto drop_free;
 
 	hdr = (struct ieee80211_hdr_4addr *)skb->data;
 	fc = le16_to_cpu(hdr->frame_ctl);
 
 	if ((fc & IEEE80211_FCTL_VERS) != 0)
-		return -EINVAL;
+		goto drop_free;
 		
 	switch (fc & IEEE80211_FCTL_FTYPE) {
 	case IEEE80211_FTYPE_MGMT:
+		if (skb->len < sizeof(struct ieee80211_hdr_3addr))
+			goto drop_free;
 		ieee80211_rx_mgt(ieee, hdr, stats);
-		return 0;
+		dev_kfree_skb_irq(skb);
+		return;
 	case IEEE80211_FTYPE_DATA:
 		break;
 	case IEEE80211_FTYPE_CTL:
-		return 0;
+		return;
 	default:
-		return -EINVAL;
+		return;
 	}
 
 	is_packet_for_us = 0;
@@ -849,8 +860,14 @@ int ieee80211_rx_any(struct ieee80211_de
 	}
 
 	if (is_packet_for_us)
-		return (ieee80211_rx(ieee, skb, stats) ? 0 : -EINVAL);
-	return 0;
+		if (!ieee80211_rx(ieee, skb, stats))
+			dev_kfree_skb_irq(skb);
+	return;
+
+drop_free:
+	dev_kfree_skb_irq(skb);
+	ieee->stats.rx_dropped++;
+	return;
 }
 
 #define MGMT_FRAME_FIXED_PART_LENGTH		0x24
@@ -1730,5 +1747,6 @@ void ieee80211_rx_mgt(struct ieee80211_d
 	}
 }
 
+EXPORT_SYMBOL_GPL(ieee80211_rx_any);
 EXPORT_SYMBOL(ieee80211_rx_mgt);
 EXPORT_SYMBOL(ieee80211_rx);
