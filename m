From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] skb: Augment skb_copy_datagram_iovec TRACE_EVENT to dump
	more info
Date: Fri, 28 Aug 2009 16:33:14 -0400
Message-ID: <20090828203314.GA30417@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, mingo@elte.hu, rostedt@goodmis.org,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54662 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753081AbZH1UdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 16:33:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all-
	As promised in our previous discussion, I've augmented the
skb_copy_datagram_iovec TRACE_EVENT to dump out the info I was previously
gathering in the ftrace module thats been removed.  This patch gives me
everything I need.  Tested and working by me

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Neil


 skb.h |   26 +++++++++++++++++++++++---
 1 file changed, 23 insertions(+), 3 deletions(-)


diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
index 4b2be6d..45b9a3f 100644
--- a/include/trace/events/skb.h
+++ b/include/trace/events/skb.h
@@ -7,6 +7,7 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/tracepoint.h>
+#include <net/sock.h>
 
 /*
  * Tracepoint for free an sk_buff:
@@ -42,16 +43,35 @@ TRACE_EVENT(skb_copy_datagram_iovec,
 	TP_ARGS(skb, len),
 
 	TP_STRUCT__entry(
-		__field(	const void *,		skbaddr		)
+		__field(	const struct sk_buff *,	skb		)
 		__field(	int,			len		)
+		__field(	int,			anid		)
+		__field(	int,			cnid		)
+		__field(	int,			rx_queue	)
+		__dynamic_array(char,		name,	IFNAMSIZ	)
 	),
 
 	TP_fast_assign(
-		__entry->skbaddr = skb;
+		struct net_device *dev = NULL;
+		__entry->skb = skb;
 		__entry->len = len;
+		__entry->anid = page_to_nid(virt_to_page(skb->data));
+		__entry->cnid = cpu_to_node(smp_processor_id());
+		__entry->rx_queue = skb->queue_mapping;
+		if (skb->sk) {
+			dev = dev_get_by_index(sock_net(skb->sk), skb->iif);
+		}
+		if (dev) {
+			__assign_str(name, dev->name);
+			dev_put(dev);
+		} else {
+			__assign_str(name, "Unknown");
+		}
 	),
 
-	TP_printk("skbaddr=%p len=%d", __entry->skbaddr, __entry->len)
+	TP_printk("skb=%p anid=%d cnid=%d len=%d rx_queue=%d name=%s",
+			__entry->skb, __entry->anid, __entry->cnid,
+			__entry->len, __entry->rx_queue, __get_str(name))
 );
 
 #endif /* _TRACE_SKB_H */
