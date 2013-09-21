From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 11/11] sfc: Add static tracepoints to datapath
Date: Sat, 21 Sep 2013 19:36:32 +0100
Message-ID: <1379788592.1681.45.camel@bwh-desktop.uk.level5networks.com>
References: <1379788283.1681.34.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:32657 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752637Ab3IUSgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 14:36:35 -0400
In-Reply-To: <1379788283.1681.34.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These tracepoints support the driver-specific datapath feature tests
we're running internally, though they might be useful for other
purposes.  The skb fields are chosen to cover driver features
implemented now or likely to be added soon.

(Includes a bug fix from Edward Cree.)

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 MAINTAINERS                      |   1 +
 drivers/net/ethernet/sfc/Kconfig |  14 ++++
 drivers/net/ethernet/sfc/efx.c   |   6 ++
 drivers/net/ethernet/sfc/ptp.c   |   3 +
 drivers/net/ethernet/sfc/rx.c    |   3 +
 drivers/net/ethernet/sfc/tx.c    |   3 +
 include/trace/events/sfc.h       | 160 +++++++++++++++++++++++++++++++++++++++
 7 files changed, 190 insertions(+)
 create mode 100644 include/trace/events/sfc.h

diff --git a/MAINTAINERS b/MAINTAINERS
index b6b29c3..663c6e1 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7424,6 +7424,7 @@ M:	Ben Hutchings <bhutchings@solarflare.com>
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	drivers/net/ethernet/sfc/
+F:	include/trace/events/sfc.h
 
 SGI GRU DRIVER
 M:	Dimitri Sivanich <sivanich@sgi.com>
diff --git a/drivers/net/ethernet/sfc/Kconfig b/drivers/net/ethernet/sfc/Kconfig
index 8b71525..15cab77 100644
--- a/drivers/net/ethernet/sfc/Kconfig
+++ b/drivers/net/ethernet/sfc/Kconfig
@@ -36,3 +36,17 @@ config SFC_SRIOV
 	  This enables support for the SFC9000 I/O Virtualization
 	  features, allowing accelerated network performance in
 	  virtualized environments.
+config SFC_TRACING
+	bool "Solarflare datapath tracing"
+	depends on SFC
+	select GENERIC_TRACER
+	default n
+	---help---
+	  Enable tracing of packet RX and TX. If you say yes, sfc will
+	  register with the tracing framework and generate an event
+	  for each skb transferred, which can be dumped using ftrace.
+	  You may need to increase the ftrace ringbuffer size. See the
+	  ftrace documentation for more information.
+
+	  When tracing is not enabled, this option still has some
+	  overhead.
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 07c9bc4..97c2fda 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -30,6 +30,12 @@
 #include "mcdi.h"
 #include "workarounds.h"
 
+/* sparse doesn't like the tracepoint definitions */
+#ifndef __CHECKER__
+#define CREATE_TRACE_POINTS
+#include <trace/events/sfc.h>
+#endif
+
 /**************************************************************************
  *
  * Type name strings
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 03acf57..209c428 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -48,6 +48,7 @@
 #include "io.h"
 #include "farch_regs.h"
 #include "nic.h"
+#include <trace/events/sfc.h>
 
 /* Maximum number of events expected to make up a PTP event */
 #define	MAX_EVENT_FRAGS			3
@@ -343,6 +344,7 @@ static void efx_ptp_deliver_rx_queue(struct sk_buff_head *q)
 
 	while ((skb = skb_dequeue(q))) {
 		local_bh_disable();
+		trace_sfc_receive(skb, false);
 		netif_receive_skb(skb);
 		local_bh_enable();
 	}
@@ -722,6 +724,7 @@ static bool efx_ptp_process_events(struct efx_nic *efx, struct sk_buff_head *q)
 static inline void efx_ptp_process_rx(struct efx_nic *efx, struct sk_buff *skb)
 {
 	local_bh_disable();
+	trace_sfc_receive(skb, false);
 	netif_receive_skb(skb);
 	local_bh_enable();
 }
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 20c46f3..079b08f 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -25,6 +25,7 @@
 #include "nic.h"
 #include "selftest.h"
 #include "workarounds.h"
+#include <trace/events/sfc.h>
 
 /* Preferred number of descriptors to fill at once */
 #define EFX_RX_PREFERRED_BATCH 8U
@@ -459,6 +460,7 @@ efx_rx_packet_gro(struct efx_channel *channel, struct efx_rx_buffer *rx_buf,
 
 	skb_record_rx_queue(skb, channel->rx_queue.core_index);
 
+	trace_sfc_receive(skb, true);
 	gro_result = napi_gro_frags(napi);
 	if (gro_result != GRO_DROP)
 		channel->irq_mod_score += 2;
@@ -623,6 +625,7 @@ static void efx_rx_deliver(struct efx_channel *channel, u8 *eh,
 			return;
 
 	/* Pass the packet up */
+	trace_sfc_receive(skb, false);
 	netif_receive_skb(skb);
 }
 
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 282692c..bc35f44 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -24,6 +24,7 @@
 #include "nic.h"
 #include "workarounds.h"
 #include "ef10_regs.h"
+#include <trace/events/sfc.h>
 
 #ifdef EFX_USE_PIO
 
@@ -525,6 +526,8 @@ netdev_tx_t efx_hard_start_xmit(struct sk_buff *skb,
 
 	EFX_WARN_ON_PARANOID(!netif_device_present(net_dev));
 
+	trace_sfc_transmit(skb, net_dev);
+
 	/* PTP "event" packet */
 	if (unlikely(efx_xmit_with_hwtstamp(skb)) &&
 	    unlikely(efx_ptp_is_ptp_tx(efx, skb))) {
diff --git a/include/trace/events/sfc.h b/include/trace/events/sfc.h
new file mode 100644
index 0000000..a158849
--- /dev/null
+++ b/include/trace/events/sfc.h
@@ -0,0 +1,160 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2013 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+/* sparse doesn't like the tracepoint definitions.  It will complain
+ * about the tracepoint functions being undefined now, but at least it
+ * won't give up after trying to parse this file.
+ */
+#ifndef __CHECKER__
+
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM sfc
+
+#if !defined(TRACE_EVENTS_SFC_H) || defined(TRACE_HEADER_MULTI_READ)
+#define TRACE_EVENTS_SFC_H
+
+#ifndef CONFIG_SFC_TRACING
+#undef TP_PROTO
+#define TP_PROTO(proto...) proto
+#undef TRACE_EVENT
+#define TRACE_EVENT(name, proto, ...)			\
+	static inline void trace_ ## name(proto) {}
+#else
+#include <linux/tracepoint.h>
+#endif
+
+TRACE_EVENT(sfc_receive,
+
+	TP_PROTO(const struct sk_buff *skb, bool gro),
+
+	TP_ARGS(skb, gro),
+
+	TP_STRUCT__entry(
+		__string(	dev_name,		skb->dev->name	)
+		__field(	unsigned int,		napi_id		)
+		__field(	u16,			queue_mapping	)
+		__field(	const void *,		skbaddr		)
+		__field(	bool,			gro		)
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
+		__assign_str(dev_name, skb->dev->name);
+#ifdef CONFIG_NET_LL_RX_POLL
+		__entry->napi_id = skb->napi_id;
+#else
+		__entry->napi_id = 0;
+#endif
+		__entry->queue_mapping = skb->queue_mapping;
+		__entry->skbaddr = skb;
+		__entry->gro = gro;
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
+	TP_printk("dev_name=%s napi_id=%#x queue_mapping=%u skbaddr=%p gro=%d vlan_tagged=%d vlan_proto=0x%04x vlan_tci=0x%04x protocol=0x%04x ip_summed=%d rxhash=0x%08x l4_rxhash=%d len=%u data_len=%u truesize=%u mac_header_valid=%d mac_header=%d nr_frags=%d gso_size=%d gso_type=%#x",
+		  __get_str(dev_name), __entry->napi_id, __entry->queue_mapping,
+		  __entry->skbaddr, __entry->gro, __entry->vlan_tagged,
+		  __entry->vlan_proto, __entry->vlan_tci, __entry->protocol,
+		  __entry->ip_summed, __entry->rxhash, __entry->l4_rxhash,
+		  __entry->len, __entry->data_len, __entry->truesize,
+		  __entry->mac_header_valid, __entry->mac_header,
+		  __entry->nr_frags, __entry->gso_size, __entry->gso_type)
+);
+
+TRACE_EVENT(sfc_transmit,
+
+	TP_PROTO(const struct sk_buff *skb, const struct net_device *net_dev),
+
+	TP_ARGS(skb, net_dev),
+
+	TP_STRUCT__entry(
+		__string(	dev_name,		net_dev->name	)
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
+		__assign_str(dev_name, net_dev->name);
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
+	TP_printk("dev_name=%s queue_mapping=%u skbaddr=%p vlan_tagged=%d vlan_proto=0x%04x vlan_tci=0x%04x protocol=0x%04x ip_summed=%d len=%u data_len=%u network_offset=%d transport_offset_valid=%d transport_offset=%d tx_flags=%d gso_size=%d gso_segs=%d gso_type=%#x",
+		  __get_str(dev_name), __entry->queue_mapping, __entry->skbaddr,
+		  __entry->vlan_tagged, __entry->vlan_proto, __entry->vlan_tci,
+		  __entry->protocol, __entry->ip_summed, __entry->len, __entry->data_len,
+		  __entry->network_offset, __entry->transport_offset_valid,
+		  __entry->transport_offset, __entry->tx_flags,
+		  __entry->gso_size, __entry->gso_segs, __entry->gso_type)
+);
+
+#endif /* TRACE_EVENTS_SFC_H */
+
+#ifdef CONFIG_SFC_TRACING
+#include <trace/define_trace.h>
+#endif
+
+#endif /* __CHECKER__ */

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
