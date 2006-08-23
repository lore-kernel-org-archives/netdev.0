From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [PATCH] d80211: add ieee80211_stop_queues()
Date: Wed, 23 Aug 2006 12:30:52 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F0165B5C6@dhost002-46.dex002.intermedia.net>
References: <200608231344.20438.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linville@tuxdriver.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:32408 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S965143AbWHWTai convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:30:38 -0400
Content-class: urn:content-classes:message
in-reply-to: <200608231344.20438.mb@bu3sch.de>
To: "Michael Buesch" <mb@bu3sch.de>, "Jiri Benc" <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One question - in most hardware implementations today the queues are DMA
rings. In this case the right length of the queue is determined by the
interrupt/tx_softirq latency required to keep the queue from becoming
empty. With 802.11 there are large differences in the time it takes to
transmit different frames - a full size 1Mbit frame vs. a short 54Mbit
frame. Would it be worth optimizing the DMA queue length to be a
function of the amount of time rather than number of frames?

Simon


-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Michael Buesch
Sent: Wednesday, August 23, 2006 4:44 AM
To: Jiri Benc
Cc: linville@tuxdriver.com; netdev@vger.kernel.org
Subject: [PATCH] d80211: add ieee80211_stop_queues()

Add ieee80211_stop_queues() to stop all queues with a single call.
I will submit a patch for bcm43xx to use this function as soon as this
got merged.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-dev/include/net/d80211.h
===================================================================
--- wireless-dev.orig/include/net/d80211.h	2006-08-19
18:26:05.000000000 +0200
+++ wireless-dev/include/net/d80211.h	2006-08-23 13:38:41.000000000
+0200
@@ -826,6 +826,15 @@
 void ieee80211_start_queues(struct net_device *dev);
 
 /**
+ * ieee80211_stop_queues - stop all queues
+ * @dev: pointer to $struct net_device as obtained from
+ *       ieee80211_alloc_hw().
+ *
+ * Drivers should use this function instead of netif_stop_queue.
+ */
+void ieee80211_stop_queues(struct net_device *dev);
+
+/**
  * ieee80211_get_mc_list_item - iteration over items in multicast list
  * @dev: pointer to &struct net_device as obtained from
  *	ieee80211_alloc_hw().
Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-19
18:26:05.000000000 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-23 13:41:34.000000000
+0200
@@ -4690,6 +4690,15 @@
 		clear_bit(IEEE80211_LINK_STATE_XOFF, &local->state[i]);
}
 
+void ieee80211_stop_queues(struct net_device *dev) {
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	int i;
+
+	for (i = 0; i < local->hw->queues; i++)
+		ieee80211_stop_queue(dev, i);
+}
+
 void * ieee80211_dev_hw_data(struct net_device *dev)  {
 	struct ieee80211_local *local = dev->ieee80211_ptr; @@ -4819,6
+4828,7 @@  EXPORT_SYMBOL(ieee80211_wake_queue);
 EXPORT_SYMBOL(ieee80211_stop_queue);
 EXPORT_SYMBOL(ieee80211_start_queues);
+EXPORT_SYMBOL(ieee80211_stop_queues);
 EXPORT_SYMBOL(ieee80211_dev_hw_data);
 EXPORT_SYMBOL(ieee80211_dev_stats);
 EXPORT_SYMBOL(ieee80211_get_hw_conf);

--
Greetings Michael.
-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
