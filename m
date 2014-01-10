From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 3/3] net: Add trace events for all receive entry
 points, exposing more skb fields
Date: Fri, 10 Jan 2014 22:17:24 +0000
Message-ID: <1389392244.2025.126.camel@bwh-desktop.uk.level5networks.com>
References: <1389392139.2025.123.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:23278 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753722AbaAJWR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 17:17:27 -0500
In-Reply-To: <1389392139.2025.123.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing net/netif_rx and net/netif_receive_skb trace events
provide little information about the skb, nor do they indicate how it
entered the stack.

Add trace events at entry of each of the exported functions, including
most fields that are likely to be interesting for debugging driver
datapath behaviour.  Split netif_rx() and netif_receive_skb() so that
internal calls are not traced.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/trace/events/net.h | 100 +++++++++++++++++++++++++++++++++++++++++++++
 net/core/dev.c             | 100 +++++++++++++++++++++++++++------------------
 2 files changed, 161 insertions(+), 39 deletions(-)

diff --git a/include/trace/events/net.h b/include/trace/events/net.h
index 0b61f2abee4c..731907c35051 100644
--- a/include/trace/events/net.h
+++ b/include/trace/events/net.h
@@ -136,6 +136,106 @@ DEFINE_EVENT(net_dev_template, netif_rx,
 
 	TP_ARGS(skb)
 );
+
+DECLARE_EVENT_CLASS(net_dev_rx_verbose_template,
+
+	TP_PROTO(const struct sk_buff *skb),
+
+	TP_ARGS(skb),
+
+	TP_STRUCT__entry(
+		__string(	name,			skb->dev->name	)
+		__field(	unsigned int,		napi_id		)
+		__field(	u16,			queue_mapping	)
+		__field(	const void *,		skbaddr		)
+		__field(	bool,			vlan_tagged	)
+		__field(	u16,			vlan_proto	)
+		__field(	u16,			vlan_tci	)
+		__field(	u16,			protocol	)
+		__field(	u8,			ip_summed	)
+		__field(	u32,			rxhash		)
+		__field(	bool,			l4_rxhash	)
+		__field(	unsigned int,		len		)
+		__field(	unsigned int,		data_len	)
+		__field(	unsigned int,		truesize	)
+		__field(	bool,			mac_header_valid)
+		__field(	int,			mac_header	)
+		__field(	unsigned char,		nr_frags	)
+		__field(	u16,			gso_size	)
+		__field(	u16,			gso_type	)
+	),
+
+	TP_fast_assign(
+		__assign_str(name, skb->dev->name);
+#ifdef CONFIG_NET_RX_BUSY_POLL
+		__entry->napi_id = skb->napi_id;
+#else
+		__entry->napi_id = 0;
+#endif
+		__entry->queue_mapping = skb->queue_mapping;
+		__entry->skbaddr = skb;
+		__entry->vlan_tagged = vlan_tx_tag_present(skb);
+		__entry->vlan_proto = ntohs(skb->vlan_proto);
+		__entry->vlan_tci = vlan_tx_tag_get(skb);
+		__entry->protocol = ntohs(skb->protocol);
+		__entry->ip_summed = skb->ip_summed;
+		__entry->rxhash = skb->rxhash;
+		__entry->l4_rxhash = skb->l4_rxhash;
+		__entry->len = skb->len;
+		__entry->data_len = skb->data_len;
+		__entry->truesize = skb->truesize;
+		__entry->mac_header_valid = skb_mac_header_was_set(skb);
+		__entry->mac_header = skb_mac_header(skb) - skb->data;
+		__entry->nr_frags = skb_shinfo(skb)->nr_frags;
+		__entry->gso_size = skb_shinfo(skb)->gso_size;
+		__entry->gso_type = skb_shinfo(skb)->gso_type;
+	),
+
+	TP_printk("dev=%s napi_id=%#x queue_mapping=%u skbaddr=%p vlan_tagged=%d vlan_proto=0x%04x vlan_tci=0x%04x protocol=0x%04x ip_summed=%d rxhash=0x%08x l4_rxhash=%d len=%u data_len=%u truesize=%u mac_header_valid=%d mac_header=%d nr_frags=%d gso_size=%d gso_type=%#x",
+		  __get_str(name), __entry->napi_id, __entry->queue_mapping,
+		  __entry->skbaddr, __entry->vlan_tagged, __entry->vlan_proto,
+		  __entry->vlan_tci, __entry->protocol, __entry->ip_summed,
+		  __entry->rxhash, __entry->l4_rxhash, __entry->len,
+		  __entry->data_len, __entry->truesize,
+		  __entry->mac_header_valid, __entry->mac_header,
+		  __entry->nr_frags, __entry->gso_size, __entry->gso_type)
+);
+
+DEFINE_EVENT(net_dev_rx_verbose_template, napi_gro_frags_entry,
+
+	TP_PROTO(const struct sk_buff *skb),
+
+	TP_ARGS(skb)
+);
+
+DEFINE_EVENT(net_dev_rx_verbose_template, napi_gro_receive_entry,
+
+	TP_PROTO(const struct sk_buff *skb),
+
+	TP_ARGS(skb)
+);
+
+DEFINE_EVENT(net_dev_rx_verbose_template, netif_receive_skb_entry,
+
+	TP_PROTO(const struct sk_buff *skb),
+
+	TP_ARGS(skb)
+);
+
+DEFINE_EVENT(net_dev_rx_verbose_template, netif_rx_entry,
+
+	TP_PROTO(const struct sk_buff *skb),
+
+	TP_ARGS(skb)
+);
+
+DEFINE_EVENT(net_dev_rx_verbose_template, netif_rx_ni_entry,
+
+	TP_PROTO(const struct sk_buff *skb),
+
+	TP_ARGS(skb)
+);
+
 #endif /* _TRACE_NET_H */
 
 /* This part must be outside protection */
diff --git a/net/core/dev.c b/net/core/dev.c
index 82b3c0fa0ea7..02979938cd42 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -147,6 +147,8 @@ struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
 struct list_head ptype_all __read_mostly;	/* Taps */
 static struct list_head offload_base __read_mostly;
 
+static int netif_rx_internal(struct sk_buff *skb);
+
 /*
  * The @dev_base_head list is protected by @dev_base_lock and the rtnl
  * semaphore.
@@ -1698,7 +1700,7 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 	skb_scrub_packet(skb, true);
 	skb->protocol = eth_type_trans(skb, dev);
 
-	return netif_rx(skb);
+	return netif_rx_internal(skb);
 }
 EXPORT_SYMBOL_GPL(dev_forward_skb);
 
@@ -3219,22 +3221,7 @@ enqueue:
 	return NET_RX_DROP;
 }
 
-/**
- *	netif_rx	-	post buffer to the network code
- *	@skb: buffer to post
- *
- *	This function receives a packet from a device driver and queues it for
- *	the upper (protocol) levels to process.  It always succeeds. The buffer
- *	may be dropped during processing for congestion control or by the
- *	protocol layers.
- *
- *	return values:
- *	NET_RX_SUCCESS	(no congestion)
- *	NET_RX_DROP     (packet was dropped)
- *
- */
-
-int netif_rx(struct sk_buff *skb)
+static int netif_rx_internal(struct sk_buff *skb)
 {
 	int ret;
 
@@ -3270,14 +3257,38 @@ int netif_rx(struct sk_buff *skb)
 	}
 	return ret;
 }
+
+/**
+ *	netif_rx	-	post buffer to the network code
+ *	@skb: buffer to post
+ *
+ *	This function receives a packet from a device driver and queues it for
+ *	the upper (protocol) levels to process.  It always succeeds. The buffer
+ *	may be dropped during processing for congestion control or by the
+ *	protocol layers.
+ *
+ *	return values:
+ *	NET_RX_SUCCESS	(no congestion)
+ *	NET_RX_DROP     (packet was dropped)
+ *
+ */
+
+int netif_rx(struct sk_buff *skb)
+{
+	trace_netif_rx_entry(skb);
+
+	return netif_rx_internal(skb);
+}
 EXPORT_SYMBOL(netif_rx);
 
 int netif_rx_ni(struct sk_buff *skb)
 {
 	int err;
 
+	trace_netif_rx_ni_entry(skb);
+
 	preempt_disable();
-	err = netif_rx(skb);
+	err = netif_rx_internal(skb);
 	if (local_softirq_pending())
 		do_softirq();
 	preempt_enable();
@@ -3662,22 +3673,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	return ret;
 }
 
-/**
- *	netif_receive_skb - process receive buffer from network
- *	@skb: buffer to process
- *
- *	netif_receive_skb() is the main receive data processing function.
- *	It always succeeds. The buffer may be dropped during processing
- *	for congestion control or by the protocol layers.
- *
- *	This function may only be called from softirq context and interrupts
- *	should be enabled.
- *
- *	Return values (usually ignored):
- *	NET_RX_SUCCESS: no congestion
- *	NET_RX_DROP: packet was dropped
- */
-int netif_receive_skb(struct sk_buff *skb)
+static int netif_receive_skb_internal(struct sk_buff *skb)
 {
 	net_timestamp_check(netdev_tstamp_prequeue, skb);
 
@@ -3703,6 +3699,28 @@ int netif_receive_skb(struct sk_buff *skb)
 #endif
 	return __netif_receive_skb(skb);
 }
+
+/**
+ *	netif_receive_skb - process receive buffer from network
+ *	@skb: buffer to process
+ *
+ *	netif_receive_skb() is the main receive data processing function.
+ *	It always succeeds. The buffer may be dropped during processing
+ *	for congestion control or by the protocol layers.
+ *
+ *	This function may only be called from softirq context and interrupts
+ *	should be enabled.
+ *
+ *	Return values (usually ignored):
+ *	NET_RX_SUCCESS: no congestion
+ *	NET_RX_DROP: packet was dropped
+ */
+int netif_receive_skb(struct sk_buff *skb)
+{
+	trace_netif_receive_skb_entry(skb);
+
+	return netif_receive_skb_internal(skb);
+}
 EXPORT_SYMBOL(netif_receive_skb);
 
 /* Network device is going away, flush any packets still pending
@@ -3764,7 +3782,7 @@ static int napi_gro_complete(struct sk_buff *skb)
 	}
 
 out:
-	return netif_receive_skb(skb);
+	return netif_receive_skb_internal(skb);
 }
 
 /* napi->gro_list contains packets ordered by age.
@@ -3959,7 +3977,7 @@ static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 {
 	switch (ret) {
 	case GRO_NORMAL:
-		if (netif_receive_skb(skb))
+		if (netif_receive_skb_internal(skb))
 			ret = GRO_DROP;
 		break;
 
@@ -3984,6 +4002,8 @@ static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 
 gro_result_t napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
+	trace_napi_gro_receive_entry(skb);
+
 	return napi_skb_finish(dev_gro_receive(napi, skb), skb);
 }
 EXPORT_SYMBOL(napi_gro_receive);
@@ -4017,7 +4037,7 @@ static gro_result_t napi_frags_finish(struct napi_struct *napi, struct sk_buff *
 {
 	switch (ret) {
 	case GRO_NORMAL:
-		if (netif_receive_skb(skb))
+		if (netif_receive_skb_internal(skb))
 			ret = GRO_DROP;
 		break;
 
@@ -4056,6 +4076,8 @@ gro_result_t napi_gro_frags(struct napi_struct *napi)
 	if (!skb)
 		return GRO_DROP;
 
+	trace_napi_gro_frags_entry(skb);
+
 	return napi_frags_finish(napi, skb, dev_gro_receive(napi, skb));
 }
 EXPORT_SYMBOL(napi_gro_frags);
@@ -6592,11 +6614,11 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 
 	/* Process offline CPU's input_pkt_queue */
 	while ((skb = __skb_dequeue(&oldsd->process_queue))) {
-		netif_rx(skb);
+		netif_rx_internal(skb);
 		input_queue_head_incr(oldsd);
 	}
 	while ((skb = __skb_dequeue(&oldsd->input_pkt_queue))) {
-		netif_rx(skb);
+		netif_rx_internal(skb);
 		input_queue_head_incr(oldsd);
 	}
 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
