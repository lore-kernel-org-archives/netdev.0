From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH] wimax/i2400m: support extended data RX protocol (no need to reallocate skbs)
Date: Sun,  1 Mar 2009 01:42:52 -0800
Message-ID: <1235900574-15319-6-git-send-email-inaky@linux.intel.com>
References: <1235900574-15319-1-git-send-email-inaky@linux.intel.com>
 <1235900574-15319-2-git-send-email-inaky@linux.intel.com>
 <1235900574-15319-3-git-send-email-inaky@linux.intel.com>
 <1235900574-15319-4-git-send-email-inaky@linux.intel.com>
 <1235900574-15319-5-git-send-email-inaky@linux.intel.com>
Cc: netdev@vger.kernel.org
To: wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 076-076-148-181.pdx.net ([76.76.148.181]:33368 "EHLO
	inaky-mobl3" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753250AbZCAJm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Mar 2009 04:42:58 -0500
In-Reply-To: <1235900574-15319-5-git-send-email-inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Newer i2400m firmwares (>= v1.4) extend the data RX protocol so that
each packet has a 16 byte header. This header is mainly used to
implement host reordeing (which is addressed in later commits).

However, this header also allows us to overwrite it (once data has
been extracted) with an Ethernet header and deliver to the networking
stack without having to reallocate the skb (as it happened in fw <=
v1.3) to make room for it.

- control.c: indicate the device [dev_initialize()] that the driver
  wants to use the extended data RX protocol. Also involves adding the
  definition of the needed data types in include/linux/wimax/i2400m.h.

- rx.c: handle the new payload type for the extended RX data
  protocol. Prepares the skb for delivery to
  netdev.c:i2400m_net_erx().

- netdev.c: Introduce i2400m_net_erx() that adds the fake ethernet
  address to a prepared skb and delivers it to the networking
  stack.

- cleanup: in most instances in rx.c, the variable 'single' was
  renamed to 'single_last' for it better conveys its meaning.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/control.c |    9 +++
 drivers/net/wimax/i2400m/i2400m.h  |    2 +
 drivers/net/wimax/i2400m/netdev.c  |  104 ++++++++++++++++++++++++--------
 drivers/net/wimax/i2400m/rx.c      |  117 +++++++++++++++++++++++++++++++++---
 include/linux/wimax/i2400m.h       |   35 +++++++++++
 5 files changed, 234 insertions(+), 33 deletions(-)

diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
index c3968b2..4073c3e 100644
--- a/drivers/net/wimax/i2400m/control.c
+++ b/drivers/net/wimax/i2400m/control.c
@@ -1311,6 +1311,7 @@ int i2400m_dev_initialize(struct i2400m *i2400m)
 	struct device *dev = i2400m_dev(i2400m);
 	struct i2400m_tlv_config_idle_parameters idle_params;
 	struct i2400m_tlv_config_idle_timeout idle_timeout;
+	struct i2400m_tlv_config_d2h_data_format df;
 	const struct i2400m_tlv_hdr *args[9];
 	unsigned argc = 0;
 
@@ -1333,6 +1334,14 @@ int i2400m_dev_initialize(struct i2400m *i2400m)
 			args[argc++] = &idle_timeout.hdr;
 		}
 	}
+	if (i2400m_ge_v1_4(i2400m)) {
+		df.hdr.type =
+			cpu_to_le16(I2400M_TLV_CONFIG_D2H_DATA_FORMAT);
+		df.hdr.length = cpu_to_le16(
+			sizeof(df) - sizeof(df.hdr));
+		df.format = 1;
+		args[argc++] = &df.hdr;
+	}
 	result = i2400m_set_init_config(i2400m, args, argc);
 	if (result < 0)
 		goto error;
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 0c60d5c..125c305 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -593,6 +593,8 @@ extern void i2400m_tx_release(struct i2400m *);
 
 extern void i2400m_net_rx(struct i2400m *, struct sk_buff *, unsigned,
 			  const void *, int);
+extern void i2400m_net_erx(struct i2400m *, struct sk_buff *,
+			   enum i2400m_cs);
 enum i2400m_pt;
 extern int i2400m_tx(struct i2400m *, const void *, size_t, enum i2400m_pt);
 
diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index be8be4d..2bdd0cd 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -28,13 +28,12 @@
  * space and from the other side. The world is (sadly) configured to
  * take in only Ethernet devices...
  *
- * Because of this, currently there is an copy-each-rxed-packet
- * overhead on the RX path. Each IP packet has to be reallocated to
- * add an ethernet header (as there is no space in what we get from
- * the device). This is a known drawback and coming versions of the
- * device's firmware are being changed to add header space that can be
- * used to insert the ethernet header without having to reallocate and
- * copy.
+ * Because of this, when using firmwares <= v1.3, there is an
+ * copy-each-rxed-packet overhead on the RX path. Each IP packet has
+ * to be reallocated to add an ethernet header (as there is no space
+ * in what we get from the device). This is a known drawback and
+ * firmwares >= 1.4 add header space that can be used to insert the
+ * ethernet header without having to reallocate and copy.
  *
  * TX error handling is tricky; because we have to FIFO/queue the
  * buffers for transmission (as the hardware likes it aggregated), we
@@ -67,7 +66,9 @@
  * i2400m_tx_timeout      Called when the device times out
  *
  * i2400m_net_rx          Called by the RX code when a data frame is
- *                        available.
+ *                        available (firmware <= 1.3)
+ * i2400m_net_erx         Called by the RX code when a data frame is
+ *                        available (firmware >= 1.4).
  * i2400m_netdev_setup    Called to setup all the netdev stuff from
  *                        alloc_netdev.
  */
@@ -396,30 +397,18 @@ void i2400m_tx_timeout(struct net_device *net_dev)
  * Create a fake ethernet header
  *
  * For emulating an ethernet device, every received IP header has to
- * be prefixed with an ethernet header.
- *
- * What we receive has (potentially) many IP packets concatenated with
- * no ETH_HLEN bytes prefixed. Thus there is no space for an eth
- * header.
- *
- * We would have to reallocate or do ugly fragment tricks in order to
- * add it.
- *
- * But what we do is use the header space of the RX transaction
- * (*msg_hdr) as we don't need it anymore; then we'll point all the
- * data skbs there, as they share the same backing store.
- *
- * We only support IPv4 for v3 firmware.
+ * be prefixed with an ethernet header. Fake it with the given
+ * protocol.
  */
 static
 void i2400m_rx_fake_eth_header(struct net_device *net_dev,
-			       void *_eth_hdr)
+			       void *_eth_hdr, int protocol)
 {
 	struct ethhdr *eth_hdr = _eth_hdr;
 
 	memcpy(eth_hdr->h_dest, net_dev->dev_addr, sizeof(eth_hdr->h_dest));
 	memset(eth_hdr->h_source, 0, sizeof(eth_hdr->h_dest));
-	eth_hdr->h_proto = cpu_to_be16(ETH_P_IP);
+	eth_hdr->h_proto = cpu_to_be16(protocol);
 }
 
 
@@ -432,6 +421,13 @@ void i2400m_rx_fake_eth_header(struct net_device *net_dev,
  * @buf: pointer to the buffer containing the data
  * @len: buffer's length
  *
+ * This is only used now for the v1.3 firmware. It will be deprecated
+ * in >= 2.6.31.
+ *
+ * Note that due to firmware limitations, we don't have space to add
+ * an ethernet header, so we need to copy each packet. Firmware
+ * versions >= v1.4 fix this [see i2400m_net_erx()].
+ *
  * We just clone the skb and set it up so that it's skb->data pointer
  * points to "buf" and it's length.
  *
@@ -478,7 +474,7 @@ void i2400m_net_rx(struct i2400m *i2400m, struct sk_buff *skb_rx,
 		memcpy(skb_put(skb, buf_len), buf, buf_len);
 	}
 	i2400m_rx_fake_eth_header(i2400m->wimax_dev.net_dev,
-				  skb->data - ETH_HLEN);
+				  skb->data - ETH_HLEN, ETH_P_IP);
 	skb_set_mac_header(skb, -ETH_HLEN);
 	skb->dev = i2400m->wimax_dev.net_dev;
 	skb->protocol = htons(ETH_P_IP);
@@ -493,6 +489,64 @@ error_skb_realloc:
 		i2400m, buf, buf_len);
 }
 
+
+/*
+ * i2400m_net_erx - pass a network packet to the stack (extended version)
+ *
+ * @i2400m: device descriptor
+ * @skb: the skb where the packet is - the skb should be set to point
+ *     at the IP packet; this function will add ethernet headers if
+ *     needed.
+ * @cs: packet type
+ *
+ * This is only used now for firmware >= v1.4. Note it is quite
+ * similar to i2400m_net_rx() (used only for v1.3 firmware).
+ *
+ * This function is normally run from a thread context. However, we
+ * still use netif_rx() instead of netif_receive_skb() as was
+ * recommended in the mailing list. Reason is in some stress tests
+ * when sending/receiving a lot of data we seem to hit a softlock in
+ * the kernel's TCP implementation [aroudn tcp_delay_timer()]. Using
+ * netif_rx() took care of the issue.
+ *
+ * This is, of course, still open to do more research on why running
+ * with netif_receive_skb() hits this softlock. FIXME.
+ */
+void i2400m_net_erx(struct i2400m *i2400m, struct sk_buff *skb,
+		    enum i2400m_cs cs)
+{
+	struct net_device *net_dev = i2400m->wimax_dev.net_dev;
+	struct device *dev = i2400m_dev(i2400m);
+	int protocol;
+
+	d_fnstart(2, dev, "(i2400m %p skb %p [%zu] cs %d)\n",
+		  i2400m, skb, skb->len, cs);
+	switch(cs) {
+	case I2400M_CS_IPV4_0:
+	case I2400M_CS_IPV4:
+		protocol = ETH_P_IP;
+		i2400m_rx_fake_eth_header(i2400m->wimax_dev.net_dev,
+					  skb->data - ETH_HLEN, ETH_P_IP);
+		skb_set_mac_header(skb, -ETH_HLEN);
+		skb->dev = i2400m->wimax_dev.net_dev;
+		skb->protocol = htons(ETH_P_IP);
+		net_dev->stats.rx_packets++;
+		net_dev->stats.rx_bytes += skb->len;
+		break;
+	default:
+		dev_err(dev, "ERX: BUG? CS type %u unsupported\n", cs);
+		goto error;
+
+	}
+	d_printf(3, dev, "ERX: receiving %d bytes to the network stack\n",
+		 skb->len);
+	d_dump(4, dev, skb->data, skb->len);
+	netif_rx_ni(skb);	/* see notes in function header */
+error:
+	d_fnend(2, dev, "(i2400m %p skb %p [%zu] cs %d) = void\n",
+		i2400m, skb, skb->len, cs);
+}
+
 static const struct net_device_ops i2400m_netdev_ops = {
 	.ndo_open = i2400m_open,
 	.ndo_stop = i2400m_stop,
diff --git a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
index c62b8c5..cd52506 100644
--- a/drivers/net/wimax/i2400m/rx.c
+++ b/drivers/net/wimax/i2400m/rx.c
@@ -69,6 +69,22 @@
  * See tx.c for a deeper description on alignment requirements and
  * other fun facts of it.
  *
+ * DATA PACKETS
+ *
+ * In firmwares <= v1.3, data packets have no header for RX, but they
+ * do for TX (currently unused).
+ *
+ * In firmware >= 1.4, RX packets have an extended header (16
+ * bytes). This header conveys information for management of host
+ * reordering of packets (the device offloads storage of the packets
+ * for reordering to the host).
+ *
+ * Currently this information is not used as the current code doesn't
+ * enable host reordering.
+ *
+ * The header is used as dummy space to emulate an ethernet header and
+ * thus be able to act as an ethernet device without having to reallocate.
+ *
  * ROADMAP
  *
  * i2400m_rx
@@ -76,6 +92,8 @@
  *   i2400m_rx_pl_descr_check
  *   i2400m_rx_payload
  *     i2400m_net_rx
+ *     i2400m_rx_edata
+ *       i2400m_net_erx
  *     i2400m_rx_ctl
  *       i2400m_msg_size_check
  *       i2400m_report_hook_work    [in a workqueue]
@@ -264,8 +282,6 @@ error_check:
 }
 
 
-
-
 /*
  * Receive and send up a trace
  *
@@ -314,32 +330,112 @@ error_check:
 	return;
 }
 
+/*
+ * Receive and send up an extended data packet
+ *
+ * @i2400m: device descriptor
+ * @skb_rx: skb that contains the extended data packet
+ * @single_last: 1 if the payload is the only one or the last one of
+ *     the skb.
+ * @payload: pointer to the packet's data inside the skb
+ * @size: size of the payload
+ *
+ * Starting in v1.4 of the i2400m's firmware, the device can send data
+ * packets to the host in an extended format that; this incudes a 16
+ * byte header (struct i2400m_pl_edata_hdr). Using this header's space
+ * we can fake ethernet headers for ethernet device emulation without
+ * having to copy packets around.
+ *
+ * This function handles said path.
+ */
+static
+void i2400m_rx_edata(struct i2400m *i2400m, struct sk_buff *skb_rx,
+		     unsigned single_last, const void *payload, size_t size)
+{
+	struct device *dev = i2400m_dev(i2400m);
+	const struct i2400m_pl_edata_hdr *hdr = payload;
+	struct net_device *net_dev = i2400m->wimax_dev.net_dev;
+	struct sk_buff *skb;
+	enum i2400m_cs cs;
+	unsigned reorder_needed;
+
+	d_fnstart(4, dev, "(i2400m %p skb_rx %p single %u payload %p "
+		  "size %zu)\n", i2400m, skb_rx, single_last, payload, size);
+	if (size < sizeof(*hdr)) {
+		dev_err(dev, "ERX: HW BUG? message with short header (%zu "
+			"vs %zu bytes expected)\n", size, sizeof(*hdr));
+		goto error;
+	}
+	reorder_needed = le32_to_cpu(hdr->reorder & I2400M_REORDER_NEEDED);
+	cs = hdr->cs;
+	if (reorder_needed) {
+		dev_err(dev, "ERX: HW BUG? reorder needed, it was disabled\n");
+		goto error;
+	}
+	/* ok, so now decide if we want to clone or reuse the skb,
+	 * pull and trim it so the beginning is the space for the eth
+	 * header and pass it to i2400m_net_erx() for the stack */
+	if (single_last) {
+		skb = skb_get(skb_rx);
+		d_printf(3, dev, "ERX: reusing single payload skb %p\n", skb);
+	} else {
+		skb = skb_clone(skb_rx, GFP_KERNEL);
+		d_printf(3, dev, "ERX: cloning %p\n", skb);
+		if (skb == NULL) {
+			dev_err(dev, "ERX: no memory to clone skb\n");
+			net_dev->stats.rx_dropped++;
+			goto error_skb_clone;
+		}
+	}
+	/* now we have to pull and trim so that the skb points to the
+	 * beginning of the IP packet; the netdev part will add the
+	 * ethernet header as needed. */
+	BUILD_BUG_ON(ETH_HLEN > sizeof(*hdr));
+	skb_pull(skb, payload + sizeof(*hdr) - (void *) skb->data);
+	skb_trim(skb, (void *) skb_end_pointer(skb) - payload + sizeof(*hdr));
+	i2400m_net_erx(i2400m, skb, cs);
+error_skb_clone:
+error:
+	d_fnend(4, dev, "(i2400m %p skb_rx %p single %u payload %p "
+		"size %zu) = void\n", i2400m, skb_rx, single_last, payload, size);
+	return;
+}
+
+
+
 
 /*
  * Act on a received payload
  *
  * @i2400m: device instance
  * @skb_rx: skb where the transaction was received
- * @single: 1 if there is only one payload, 0 otherwise
+ * @single_last: 1 this is the only payload or the last one (so the
+ *     skb can be reused instead of cloned).
  * @pld: payload descriptor
  * @payload: payload data
  *
  * Upon reception of a payload, look at its guts in the payload
- * descriptor and decide what to do with it.
+ * descriptor and decide what to do with it. If it is a single payload
+ * skb or if the last skb is a data packet, the skb will be referenced
+ * and modified (so it doesn't have to be cloned).
  */
 static
 void i2400m_rx_payload(struct i2400m *i2400m, struct sk_buff *skb_rx,
-		       unsigned single, const struct i2400m_pld *pld,
+		       unsigned single_last, const struct i2400m_pld *pld,
 		       const void *payload)
 {
 	struct device *dev = i2400m_dev(i2400m);
 	size_t pl_size = i2400m_pld_size(pld);
 	enum i2400m_pt pl_type = i2400m_pld_type(pld);
 
+	d_printf(7, dev, "RX: received payload type %u, %zu bytes\n",
+		 pl_type, pl_size);
+	d_dump(8, dev, payload, pl_size);
+
 	switch (pl_type) {
 	case I2400M_PT_DATA:
 		d_printf(3, dev, "RX: data payload %zu bytes\n", pl_size);
-		i2400m_net_rx(i2400m, skb_rx, single, payload, pl_size);
+		i2400m_net_rx(i2400m, skb_rx, single_last, payload, pl_size);
 		break;
 	case I2400M_PT_CTRL:
 		i2400m_rx_ctl(i2400m, skb_rx, payload, pl_size);
@@ -347,6 +443,10 @@ void i2400m_rx_payload(struct i2400m *i2400m, struct sk_buff *skb_rx,
 	case I2400M_PT_TRACE:
 		i2400m_rx_trace(i2400m, payload, pl_size);
 		break;
+	case I2400M_PT_EDATA:
+		d_printf(3, dev, "ERX: data payload %zu bytes\n", pl_size);
+		i2400m_rx_edata(i2400m, skb_rx, single_last, payload, pl_size);
+		break;
 	default:	/* Anything else shouldn't come to the host */
 		if (printk_ratelimit())
 			dev_err(dev, "RX: HW BUG? unexpected payload type %u\n",
@@ -474,7 +574,7 @@ int i2400m_rx(struct i2400m *i2400m, struct sk_buff *skb)
 	const struct i2400m_msg_hdr *msg_hdr;
 	size_t pl_itr, pl_size, skb_len;
 	unsigned long flags;
-	unsigned num_pls;
+	unsigned num_pls, single_last;
 
 	skb_len = skb->len;
 	d_fnstart(4, dev, "(i2400m %p skb %p [size %zu])\n",
@@ -503,7 +603,8 @@ int i2400m_rx(struct i2400m *i2400m, struct sk_buff *skb)
 						  pl_itr, skb->len);
 		if (result < 0)
 			goto error_pl_descr_check;
-		i2400m_rx_payload(i2400m, skb, num_pls == 1, &msg_hdr->pld[i],
+		single_last = num_pls == 1 || i == num_pls - 1;
+		i2400m_rx_payload(i2400m, skb, single_last, &msg_hdr->pld[i],
 				  skb->data + pl_itr);
 		pl_itr += ALIGN(pl_size, I2400M_PL_PAD);
 		cond_resched();		/* Don't monopolize */
diff --git a/include/linux/wimax/i2400m.h b/include/linux/wimax/i2400m.h
index 686eeb2..ad36e07 100644
--- a/include/linux/wimax/i2400m.h
+++ b/include/linux/wimax/i2400m.h
@@ -207,6 +207,7 @@ enum i2400m_pt {
 	I2400M_PT_TRACE,	/* For device debug */
 	I2400M_PT_RESET_WARM,	/* device reset */
 	I2400M_PT_RESET_COLD,	/* USB[transport] reset, like reconnect */
+	I2400M_PT_EDATA,	/* Extended RX data */
 	I2400M_PT_ILLEGAL
 };
 
@@ -221,6 +222,32 @@ struct i2400m_pl_data_hdr {
 } __attribute__((packed));
 
 
+/*
+ * Payload for an extended data packet
+ *
+ * New in v1.4
+ *
+ * @cs: the type of data in the packet, as defined per (802.16e
+ *     T11.13.19.1). Currently only 2 (IPv4 packet) supported.
+ *
+ * This is prefixed to each and every INCOMING DATA packet.
+ */
+struct i2400m_pl_edata_hdr {
+	__le32 reorder;
+	__u8 cs;
+	__u8 reserved[11];
+} __attribute__((packed));
+
+enum i2400m_cs {
+	I2400M_CS_IPV4_0 = 0,
+	I2400M_CS_IPV4 = 2,
+};
+
+enum i2400m_reorder {
+	I2400M_REORDER_NEEDED     = 0x01,
+};
+
+
 /* Misc constants */
 enum {
 	I2400M_PL_PAD = 16,	/* Payload data size alignment */
@@ -382,6 +409,7 @@ enum i2400m_tlv {
 	I2400M_TLV_DEVICE_RESET_TYPE = 132,
 	I2400M_TLV_CONFIG_IDLE_PARAMETERS = 601,
 	I2400M_TLV_CONFIG_IDLE_TIMEOUT = 611,
+	I2400M_TLV_CONFIG_D2H_DATA_FORMAT = 614,
 };
 
 
@@ -518,5 +546,12 @@ struct i2400m_tlv_config_idle_timeout {
 			 * 0 disabled */
 } __attribute__((packed));
 
+/* New in v1.4 -- for backward compat, will be removed */
+struct i2400m_tlv_config_d2h_data_format {
+	struct i2400m_tlv_hdr hdr;
+	__u8 format; 		/* 0 old format, 1 enhanced */
+	__u8 reserved[3];
+} __attribute__((packed));
+
 
 #endif /* #ifndef __LINUX__WIMAX__I2400M_H__ */
-- 
1.5.6.5

