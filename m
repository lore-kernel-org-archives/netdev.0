From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 05/18] d80211:  get rid of WME bitfield
Date: Mon, 21 Aug 2006 09:41:12 +0200
Message-ID: <20060821075159.740408530@sipsolutions.net>
References: <20060821074107.648561364@sipsolutions.net>
Mime-Version: 1.0
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:49344 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030320AbWHUICA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 04:02:00 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=d80211-wme-bitfield.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch gets rid of the endian-ness dependent bitfield
used for WME. It cleans up wme includes and adds some necessary
includes in other files that got them implicitly through wme.h

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/wme.c	2006-08-20 14:56:17.418192788 +0200
+++ wireless-dev/net/d80211/wme.c	2006-08-20 14:56:19.058192788 +0200
@@ -12,7 +12,9 @@
 #include <linux/skbuff.h>
 #include <linux/module.h>
 #include <linux/if_arp.h>
+#include <linux/types.h>
 #include <net/ip.h>
+#include <net/pkt_sched.h>
 
 #include <net/d80211.h>
 #include "ieee80211_i.h"
@@ -246,15 +248,15 @@ static int wme_qdiscop_enqueue(struct sk
 	/* now we know the 1d priority, fill in the QoS header if there is one
 	 */
 	if (WLAN_FC_IS_QOS_DATA(fc)) {
-		struct qos_control *qc = (struct qos_control *)
-			(skb->data + ieee80211_get_hdrlen(fc) - 2);
-		u8 *p = (u8 *) qc;
-		*p++ = 0; /* do this due to gcc's lack of optimization on
-			   * bitfield ops */
-		*p = 0;
-		qc->tag1d = skb->priority;
+		u8 *p = skb->data + ieee80211_get_hdrlen(fc) - 2;
+		u8 qos_hdr = skb->priority & QOS_CONTROL_TAG1D_MASK;
 		if (local->wifi_wme_noack_test)
-			qc->ack_policy = 1;
+			qos_hdr |= QOS_CONTROL_ACK_POLICY_NOACK <<
+					QOS_CONTROL_ACK_POLICY_SHIFT;
+		/* qos header is 2 bytes, second reserved */
+		*p = qos_hdr;
+		p++;
+		*p = 0;
 	}
 
 	if (unlikely(queue >= local->hw->queues)) {
--- wireless-dev.orig/net/d80211/wme.h	2006-08-20 14:56:09.068192788 +0200
+++ wireless-dev/net/d80211/wme.h	2006-08-20 14:56:19.058192788 +0200
@@ -11,10 +11,8 @@
 #ifndef _WME_H
 #define _WME_H
 
-#include <asm/byteorder.h>
 #include <linux/netdevice.h>
-#include <linux/types.h>
-#include <net/pkt_sched.h>
+#include "ieee80211_i.h"
 
 #define QOS_CONTROL_LEN 2
 
@@ -24,26 +22,7 @@
 #define QOS_CONTROL_TID_MASK 0x0f
 #define QOS_CONTROL_ACK_POLICY_SHIFT 5
 
-/* This bit field structure should not be used; it can cause compiler to
- * generate unaligned accesses and inefficient code. */
-struct qos_control {
-#if defined(__LITTLE_ENDIAN_BITFIELD)
-	u8	tag1d:3, /* bits 0-2 */
-  		reserved1:1,
-		eosp:1,
-		ack_policy:2,
-  		reserved2:1;
-#elif defined (__BIG_ENDIAN_BITFIELD)
-	u8	reserved2:1,
-		ack_policy:2,
-		eosp:1,
-		reserved1:1,
-		tag1d:3; /* bits 0-2 */
-#else
-#error	"Please fix <asm/byteorder.h>"
-#endif
-	u8 reserved;
-} __attribute__ ((packed));
+#define QOS_CONTROL_TAG1D_MASK 0x07
 
 ieee80211_txrx_result
 ieee80211_rx_h_parse_qos(struct ieee80211_txrx_data *rx);
--- wireless-dev.orig/net/d80211/fifo_qdisc.c	2006-08-20 14:56:09.098192788 +0200
+++ wireless-dev/net/d80211/fifo_qdisc.c	2006-08-20 14:56:19.058192788 +0200
@@ -13,6 +13,7 @@
 #include <linux/config.h>
 #include <linux/version.h>
 #include <linux/netdevice.h>
+#include <net/pkt_sched.h>
 #include <net/d80211.h>
 #include "ieee80211_i.h"
 #include "wme.h"
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-20 14:56:18.438192788 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-20 14:56:19.058192788 +0200
@@ -18,6 +18,7 @@
 #include <linux/etherdevice.h>
 #include <linux/if_arp.h>
 #include <linux/wireless.h>
+#include <linux/rtnetlink.h>
 #include <net/iw_handler.h>
 #include <linux/compiler.h>
 

--
