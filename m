From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 2/3] net: Add net_dev_start_xmit trace event,
 exposing more skb fields
Date: Fri, 10 Jan 2014 22:17:03 +0000
Message-ID: <1389392223.2025.125.camel@bwh-desktop.uk.level5networks.com>
References: <1389392139.2025.123.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:23266 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753722AbaAJWRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 17:17:07 -0500
In-Reply-To: <1389392139.2025.123.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing net/net_dev_xmit trace event provides little information
about the skb that has been passed to the driver, and it is not
simple to add more since the skb may already have been freed at
the point the event is emitted.

Add a separate trace event before the skb is passed to the driver,
including most fields that are likely to be interesting for debugging
driver datapath behaviour.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/trace/events/net.h | 58 ++++++++++++++++++++++++++++++++++++++++++++++
 net/core/dev.c             |  2 ++
 2 files changed, 60 insertions(+)

diff --git a/include/trace/events/net.h b/include/trace/events/net.h
index f99645d05a8f..0b61f2abee4c 100644
--- a/include/trace/events/net.h
+++ b/include/trace/events/net.h
@@ -6,9 +6,67 @@
 
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
+#include <linux/if_vlan.h>
 #include <linux/ip.h>
 #include <linux/tracepoint.h>
 
+TRACE_EVENT(net_dev_start_xmit,
+
+	TP_PROTO(const struct sk_buff *skb, const struct net_device *dev),
+
+	TP_ARGS(skb, dev),
+
+	TP_STRUCT__entry(
+		__string(	name,			dev->name	)
+		__field(	u16,			queue_mapping	)
+		__field(	const void *,		skbaddr		)
+		__field(	bool,			vlan_tagged	)
+		__field(	u16,			vlan_proto	)
+		__field(	u16,			vlan_tci	)
+		__field(	u16,			protocol	)
+		__field(	u8,			ip_summed	)
+		__field(	unsigned int,		len		)
+		__field(	unsigned int,		data_len	)
+		__field(	int,			network_offset	)
+		__field(	bool,			transport_offset_valid)
+		__field(	int,			transport_offset)
+		__field(	u8,			tx_flags	)
+		__field(	u16,			gso_size	)
+		__field(	u16,			gso_segs	)
+		__field(	u16,			gso_type	)
+	),
+
+	TP_fast_assign(
+		__assign_str(name, dev->name);
+		__entry->queue_mapping = skb->queue_mapping;
+		__entry->skbaddr = skb;
+		__entry->vlan_tagged = vlan_tx_tag_present(skb);
+		__entry->vlan_proto = ntohs(skb->vlan_proto);
+		__entry->vlan_tci = vlan_tx_tag_get(skb);
+		__entry->protocol = ntohs(skb->protocol);
+		__entry->ip_summed = skb->ip_summed;
+		__entry->len = skb->len;
+		__entry->data_len = skb->data_len;
+		__entry->network_offset = skb_network_offset(skb);
+		__entry->transport_offset_valid =
+			skb_transport_header_was_set(skb);
+		__entry->transport_offset = skb_transport_offset(skb);
+		__entry->tx_flags = skb_shinfo(skb)->tx_flags;
+		__entry->gso_size = skb_shinfo(skb)->gso_size;
+		__entry->gso_segs = skb_shinfo(skb)->gso_segs;
+		__entry->gso_type = skb_shinfo(skb)->gso_type;
+	),
+
+	TP_printk("dev=%s queue_mapping=%u skbaddr=%p vlan_tagged=%d vlan_proto=0x%04x vlan_tci=0x%04x protocol=0x%04x ip_summed=%d len=%u data_len=%u network_offset=%d transport_offset_valid=%d transport_offset=%d tx_flags=%d gso_size=%d gso_segs=%d gso_type=%#x",
+		  __get_str(name), __entry->queue_mapping, __entry->skbaddr,
+		  __entry->vlan_tagged, __entry->vlan_proto, __entry->vlan_tci,
+		  __entry->protocol, __entry->ip_summed, __entry->len,
+		  __entry->data_len, 
+		  __entry->network_offset, __entry->transport_offset_valid,
+		  __entry->transport_offset, __entry->tx_flags,
+		  __entry->gso_size, __entry->gso_segs, __entry->gso_type)
+);
+
 TRACE_EVENT(net_dev_xmit,
 
 	TP_PROTO(struct sk_buff *skb,
diff --git a/net/core/dev.c b/net/core/dev.c
index 41bb08f1ec99..82b3c0fa0ea7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2596,6 +2596,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			dev_queue_xmit_nit(skb, dev);
 
 		skb_len = skb->len;
+		trace_net_dev_start_xmit(skb, dev);
 		rc = ops->ndo_start_xmit(skb, dev);
 		trace_net_dev_xmit(skb, rc, dev, skb_len);
 		if (rc == NETDEV_TX_OK)
@@ -2614,6 +2615,7 @@ gso:
 			dev_queue_xmit_nit(nskb, dev);
 
 		skb_len = nskb->len;
+		trace_net_dev_start_xmit(nskb, dev);
 		rc = ops->ndo_start_xmit(nskb, dev);
 		trace_net_dev_xmit(nskb, rc, dev, skb_len);
 		if (unlikely(rc != NETDEV_TX_OK)) {


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
