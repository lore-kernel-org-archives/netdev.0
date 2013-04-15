From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] packet: move hw/sw timestamp extraction into a small helper
Date: Mon, 15 Apr 2013 13:41:42 +0200
Message-ID: <45719bcd37c3f11eea24c2a72c09abd9907a5072.1366022623.git.dborkman@redhat.com>
References: <cover.1366022623.git.dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Willem de Bruijn <willemb@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24231 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589Ab3DOLlq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Apr 2013 07:41:46 -0400
In-Reply-To: <cover.1366022623.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces a small helper function, that is used by AF_PACKET.
Based on the flags that are passed, it extracts the packet timestamp in
the receive path. This is merely a refactoring to remove some duplicate
code in tpacket_rcv(), make it more readable, and to enable others to use
this function as well.

Cc: Willem de Bruijn <willemb@google.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/skbuff.h | 20 ++++++++++++++++++++
 net/packet/af_packet.c | 38 ++++----------------------------------
 2 files changed, 24 insertions(+), 34 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index e27d1c7..d0d436f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -33,6 +33,7 @@
 #include <linux/dma-mapping.h>
 #include <linux/netdev_features.h>
 #include <net/flow_keys.h>
+#include <linux/net_tstamp.h>
 
 /* Don't change this without changing skb_csum_unnecessary! */
 #define CHECKSUM_NONE 0
@@ -739,6 +740,25 @@ static inline struct skb_shared_hwtstamps *skb_hwtstamps(struct sk_buff *skb)
 	return &skb_shinfo(skb)->hwtstamps;
 }
 
+static inline struct timespec skb_get_tstamp(struct sk_buff *skb,
+					     unsigned int flags)
+{
+	struct skb_shared_hwtstamps *ts = skb_hwtstamps(skb);
+
+	if ((flags & SOF_TIMESTAMPING_SYS_HARDWARE) && ts->syststamp.tv64)
+		return ktime_to_timespec(ts->syststamp);
+	else if ((flags & SOF_TIMESTAMPING_RAW_HARDWARE) && ts->hwtstamp.tv64)
+		return ktime_to_timespec(ts->hwtstamp);
+	else if (skb->tstamp.tv64)
+		return ktime_to_timespec(skb->tstamp);
+	else {
+		struct timespec tc;
+
+		getnstimeofday(&tc);
+		return tc;
+	}
+}
+
 /**
  *	skb_queue_empty - check if a queue is empty
  *	@list: queue head
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 77d71f8..2a2a62e 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1681,9 +1681,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	unsigned long status = TP_STATUS_USER;
 	unsigned short macoff, netoff, hdrlen;
 	struct sk_buff *copy_skb = NULL;
-	struct timeval tv;
 	struct timespec ts;
-	struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
 
 	if (skb->pkt_type == PACKET_LOOPBACK)
 		goto drop;
@@ -1767,24 +1765,16 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	skb_copy_bits(skb, 0, h.raw + macoff, snaplen);
 
+	ts = skb_get_tstamp(skb, po->tp_tstamp);
+
 	switch (po->tp_version) {
 	case TPACKET_V1:
 		h.h1->tp_len = skb->len;
 		h.h1->tp_snaplen = snaplen;
 		h.h1->tp_mac = macoff;
 		h.h1->tp_net = netoff;
-		if ((po->tp_tstamp & SOF_TIMESTAMPING_SYS_HARDWARE)
-				&& shhwtstamps->syststamp.tv64)
-			tv = ktime_to_timeval(shhwtstamps->syststamp);
-		else if ((po->tp_tstamp & SOF_TIMESTAMPING_RAW_HARDWARE)
-				&& shhwtstamps->hwtstamp.tv64)
-			tv = ktime_to_timeval(shhwtstamps->hwtstamp);
-		else if (skb->tstamp.tv64)
-			tv = ktime_to_timeval(skb->tstamp);
-		else
-			do_gettimeofday(&tv);
-		h.h1->tp_sec = tv.tv_sec;
-		h.h1->tp_usec = tv.tv_usec;
+		h.h1->tp_sec = ts.tv_sec;
+		h.h1->tp_usec = ts.tv_nsec / NSEC_PER_USEC;
 		hdrlen = sizeof(*h.h1);
 		break;
 	case TPACKET_V2:
@@ -1792,16 +1782,6 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 		h.h2->tp_snaplen = snaplen;
 		h.h2->tp_mac = macoff;
 		h.h2->tp_net = netoff;
-		if ((po->tp_tstamp & SOF_TIMESTAMPING_SYS_HARDWARE)
-				&& shhwtstamps->syststamp.tv64)
-			ts = ktime_to_timespec(shhwtstamps->syststamp);
-		else if ((po->tp_tstamp & SOF_TIMESTAMPING_RAW_HARDWARE)
-				&& shhwtstamps->hwtstamp.tv64)
-			ts = ktime_to_timespec(shhwtstamps->hwtstamp);
-		else if (skb->tstamp.tv64)
-			ts = ktime_to_timespec(skb->tstamp);
-		else
-			getnstimeofday(&ts);
 		h.h2->tp_sec = ts.tv_sec;
 		h.h2->tp_nsec = ts.tv_nsec;
 		if (vlan_tx_tag_present(skb)) {
@@ -1822,16 +1802,6 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 		h.h3->tp_snaplen = snaplen;
 		h.h3->tp_mac = macoff;
 		h.h3->tp_net = netoff;
-		if ((po->tp_tstamp & SOF_TIMESTAMPING_SYS_HARDWARE)
-				&& shhwtstamps->syststamp.tv64)
-			ts = ktime_to_timespec(shhwtstamps->syststamp);
-		else if ((po->tp_tstamp & SOF_TIMESTAMPING_RAW_HARDWARE)
-				&& shhwtstamps->hwtstamp.tv64)
-			ts = ktime_to_timespec(shhwtstamps->hwtstamp);
-		else if (skb->tstamp.tv64)
-			ts = ktime_to_timespec(skb->tstamp);
-		else
-			getnstimeofday(&ts);
 		h.h3->tp_sec  = ts.tv_sec;
 		h.h3->tp_nsec = ts.tv_nsec;
 		hdrlen = sizeof(*h.h3);
-- 
1.7.11.7
