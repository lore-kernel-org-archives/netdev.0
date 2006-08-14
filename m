From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] d80211: get rid of the WME bitfield
Date: Mon, 14 Aug 2006 10:15:14 +0200
Message-ID: <44E03112.9070002@sipsolutions.net>
References: <44E02F41.2060300@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkm@devicescape.com>, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:42372 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750796AbWHNIPR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 04:15:17 -0400
To: netdev@vger.kernel.org
In-Reply-To: <44E02F41.2060300@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Somewhere, sometime, someone had to start getting rid of bitfields ;) 
This one seemed an easy target :P

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/wme.c    2006-08-12 10:43:01.809644280 
+0200
+++ wireless-dev/net/d80211/wme.c    2006-08-12 10:51:35.909644280 +0200
@@ -246,15 +246,13 @@ static int wme_qdiscop_enqueue(struct sk
     /* now we know the 1d priority, fill in the QoS header if there is one
      */
     if (WLAN_FC_IS_QOS_DATA(fc)) {
-        struct qos_control *qc = (struct qos_control *)
-            (skb->data + ieee80211_get_hdrlen(fc) - 2);
-        u8 *p = (u8 *) qc;
-        *p++ = 0; /* do this due to gcc's lack of optimization on
-               * bitfield ops */
-        *p = 0;
-        qc->tag1d = skb->priority;
+        /* hard-coded QOS control header length! */
+        u16 *p = (u16 *) (skb->data + ieee80211_get_hdrlen(fc) - 2);
+        u16 qos_hdr = skb->priority & QOS_CONTROL_TAG1D_MASK;
         if (local->wifi_wme_noack_test)
-            qc->ack_policy = 1;
+            qos_hdr |= QOS_CONTROL_ACK_POLICY_NOACK <<
+                    QOS_CONTROL_ACK_POLICY_SHIFT;
+        *p = cpu_to_le16(qos_hdr);
     }
 
     if (unlikely(queue >= local->hw->queues)) {
--- wireless-dev.orig/net/d80211/wme.h    2006-08-12 10:53:18.899644280 
+0200
+++ wireless-dev/net/d80211/wme.h    2006-08-12 10:53:21.629644280 +0200
@@ -24,26 +24,7 @@
 #define QOS_CONTROL_TID_MASK 0x0f
 #define QOS_CONTROL_ACK_POLICY_SHIFT 5
 
-/* This bit field structure should not be used; it can cause compiler to
- * generate unaligned accesses and inefficient code. */
-struct qos_control {
-#if defined(__LITTLE_ENDIAN_BITFIELD)
-    u8    tag1d:3, /* bits 0-2 */
-          reserved1:1,
-        eosp:1,
-        ack_policy:2,
-          reserved2:1;
-#elif defined (__BIG_ENDIAN_BITFIELD)
-    u8    reserved2:1,
-        ack_policy:2,
-        eosp:1,
-        reserved1:1,
-        tag1d:3; /* bits 0-2 */
-#else
-#error    "Please fix <asm/byteorder.h>"
-#endif
-    u8 reserved;
-} __attribute__ ((packed));
+#define QOS_CONTROL_TAG1D_MASK 0x07
 
 ieee80211_txrx_result
 ieee80211_rx_h_parse_qos(struct ieee80211_txrx_data *rx);

