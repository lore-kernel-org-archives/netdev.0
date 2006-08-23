From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 5/21] d80211: get rid of WME bitfield
Date: Wed, 23 Aug 2006 21:24:13 +0200 (CEST)
Message-ID: <20060823192413.E4153483A5@silver.suse.cz>
References: <20060823212316.333159079.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:27600 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965114AbWHWTYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:24:13 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060823212316.333159079.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>

This patch gets rid of the endian-ness dependent bitfield
used for WME. It cleans up wme includes and adds some necessary
includes in other files that got them implicitly through wme.h

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/fifo_qdisc.c |    1 +
 net/d80211/ieee80211.c  |    1 +
 net/d80211/wme.c        |   18 ++++++++++--------
 net/d80211/wme.h        |   25 ++-----------------------
 4 files changed, 14 insertions(+), 31 deletions(-)

94df2a4b3e67e47058b8f58b4705edb9ed7b447a
diff --git a/net/d80211/fifo_qdisc.c b/net/d80211/fifo_qdisc.c
index 0748a2e..a89a839 100644
--- a/net/d80211/fifo_qdisc.c
+++ b/net/d80211/fifo_qdisc.c
@@ -13,6 +13,7 @@
 #include <linux/config.h>
 #include <linux/version.h>
 #include <linux/netdevice.h>
+#include <net/pkt_sched.h>
 #include <net/d80211.h>
 #include "ieee80211_i.h"
 #include "wme.h"
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 04c791d..05a88f1 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -18,6 +18,7 @@ #include <linux/skbuff.h>
 #include <linux/etherdevice.h>
 #include <linux/if_arp.h>
 #include <linux/wireless.h>
+#include <linux/rtnetlink.h>
 #include <net/iw_handler.h>
 #include <linux/compiler.h>
 
diff --git a/net/d80211/wme.c b/net/d80211/wme.c
index 8f1862c..b1ff066 100644
--- a/net/d80211/wme.c
+++ b/net/d80211/wme.c
@@ -12,7 +12,9 @@ #include <linux/netdevice.h>
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
diff --git a/net/d80211/wme.h b/net/d80211/wme.h
index 44a2c33..90add6e 100644
--- a/net/d80211/wme.h
+++ b/net/d80211/wme.h
@@ -11,10 +11,8 @@
 #ifndef _WME_H
 #define _WME_H
 
-#include <asm/byteorder.h>
 #include <linux/netdevice.h>
-#include <linux/types.h>
-#include <net/pkt_sched.h>
+#include "ieee80211_i.h"
 
 #define QOS_CONTROL_LEN 2
 
@@ -24,26 +22,7 @@ #define QOS_CONTROL_ACK_POLICY_NOACK 1
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
-- 
1.3.0

