From: Jim Baxter <jim_baxter@mentor.com>
Subject: [PATCH v1 2/3] usb: gadget: NCM: Add transmit multi-frame.
Date: Thu, 29 May 2014 18:12:22 +0100
Message-ID: <1401383543-10181-3-git-send-email-jim_baxter@mentor.com>
References: <Jim Baxter <jim_baxter@mentor.com>
 <1401383543-10181-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	<linux-usb@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	<netdev@vger.kernel.org>
To: Felipe Balbi <balbi@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401383543-10181-1-git-send-email-jim_baxter@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds multi-frame support to the NCM NTB's for
the gadget driver. This allows multiple network
packets to be put inside a single USB NTB with a
maximum size of 16kB.

It has a time out of 300ms to ensure that smaller
number of packets still maintain a normal latency.

Also the .fp_index and .next_fp_index have been
changed to .ndp_index and .next_ndp_index to
match the latest CDC-NCM specification and
help with maintenance.

Results transmitting from gadget to host.

Before the change:

TCP_STREAM Throughput (10^6bits/sec): 22.72
UDP_STREAM Throughput (10^6bits/sec): 25.94

Latency:
netperf -H 192.168.1.101 -v2 -l 50 -t TCP_RR -- -r 16384,16384
Trans.   RoundTrip  Throughput
Rate     Latency    10^6bits/s
per sec  usec/Tran  Outbound

100.83   9918.116   13.215

After the change:

TCP_STREAM Throughput (10^6bits/sec): 124.26
UDP_STREAM Throughput (10^6bits/sec): 227.48

Latency:
netperf -H 192.168.1.101 -v2 -l 50 -t TCP_RR -- -r 16384,16384
Trans.   RoundTrip  Throughput
Rate     Latency    10^6bits/s
per sec  usec/Tran  Outbound

156.80   6377.730   20.552

Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
---
 drivers/usb/gadget/f_ncm.c   |  335 ++++++++++++++++++++++++++++++++----------
 drivers/usb/gadget/u_ether.c |   19 ++-
 drivers/usb/gadget/u_ether.h |    2 +
 3 files changed, 269 insertions(+), 87 deletions(-)

diff --git a/drivers/usb/gadget/f_ncm.c b/drivers/usb/gadget/f_ncm.c
index d0ebbac..5452fb6 100644
--- a/drivers/usb/gadget/f_ncm.c
+++ b/drivers/usb/gadget/f_ncm.c
@@ -68,6 +68,18 @@ struct f_ncm {
 	 * callback and ethernet open/close
 	 */
 	spinlock_t			lock;
+
+	struct net_device		*netdev;
+
+	/* For multi-frame NDP TX */
+	struct sk_buff			*skb_tx_data;
+	struct sk_buff			*skb_tx_ndp;
+	u16				ndp_dgram_count;
+	bool				timer_force_tx;
+	struct tasklet_struct		tx_tasklet;
+	struct hrtimer			task_timer;
+
+	bool				timer_stopping;
 };
 
 static inline struct f_ncm *func_to_ncm(struct usb_function *f)
@@ -92,15 +104,20 @@ static inline unsigned ncm_bitrate(struct usb_gadget *g)
  * If the host can group frames, allow it to do that, 16K is selected,
  * because it's used by default by the current linux host driver
  */
-#define NTB_DEFAULT_IN_SIZE	USB_CDC_NCM_NTB_MIN_IN_SIZE
+#define NTB_DEFAULT_IN_SIZE	16384
 #define NTB_OUT_SIZE		16384
 
-/*
- * skbs of size less than that will not be aligned
- * to NCM's dwNtbInMaxSize to save bus bandwidth
+/* Allocation for storing the NDP, 32 should suffice for a
+ * 16k packet. This allows a maximum of 32 * 507 Byte packets to
+ * be transmitted in a single 16kB skb, though when sending full size
+ * packets this limit will be plenty.
+ * Smaller packets are not likely to be trying to maximize the
+ * throughput and will be mstly sending smaller infrequent frames.
  */
+#define TX_MAX_NUM_DPE		32
 
-#define	MAX_TX_NONFIXED		(512 * 3)
+/* Delay for the transmit to wait before sending an unfilled NTB frame. */
+#define TX_TIMEOUT_NSECS	300000
 
 #define FORMATS_SUPPORTED	(USB_CDC_NCM_NTB16_SUPPORTED |	\
 				 USB_CDC_NCM_NTB32_SUPPORTED)
@@ -355,14 +372,15 @@ struct ndp_parser_opts {
 	u32		ndp_sign;
 	unsigned	nth_size;
 	unsigned	ndp_size;
+	unsigned	dpe_size;
 	unsigned	ndplen_align;
 	/* sizes in u16 units */
 	unsigned	dgram_item_len; /* index or length */
 	unsigned	block_length;
-	unsigned	fp_index;
+	unsigned	ndp_index;
 	unsigned	reserved1;
 	unsigned	reserved2;
-	unsigned	next_fp_index;
+	unsigned	next_ndp_index;
 };
 
 #define INIT_NDP16_OPTS {					\
@@ -370,13 +388,14 @@ struct ndp_parser_opts {
 		.ndp_sign = USB_CDC_NCM_NDP16_NOCRC_SIGN,	\
 		.nth_size = sizeof(struct usb_cdc_ncm_nth16),	\
 		.ndp_size = sizeof(struct usb_cdc_ncm_ndp16),	\
+		.dpe_size = sizeof(struct usb_cdc_ncm_dpe16),	\
 		.ndplen_align = 4,				\
 		.dgram_item_len = 1,				\
 		.block_length = 1,				\
-		.fp_index = 1,					\
+		.ndp_index = 1,					\
 		.reserved1 = 0,					\
 		.reserved2 = 0,					\
-		.next_fp_index = 1,				\
+		.next_ndp_index = 1,				\
 	}
 
 
@@ -385,13 +404,14 @@ struct ndp_parser_opts {
 		.ndp_sign = USB_CDC_NCM_NDP32_NOCRC_SIGN,	\
 		.nth_size = sizeof(struct usb_cdc_ncm_nth32),	\
 		.ndp_size = sizeof(struct usb_cdc_ncm_ndp32),	\
+		.dpe_size = sizeof(struct usb_cdc_ncm_dpe32),	\
 		.ndplen_align = 8,				\
 		.dgram_item_len = 2,				\
 		.block_length = 2,				\
-		.fp_index = 2,					\
+		.ndp_index = 2,					\
 		.reserved1 = 1,					\
 		.reserved2 = 2,					\
-		.next_fp_index = 2,				\
+		.next_ndp_index = 2,				\
 	}
 
 static const struct ndp_parser_opts ndp16_opts = INIT_NDP16_OPTS;
@@ -803,6 +823,8 @@ static int ncm_set_alt(struct usb_function *f, unsigned intf, unsigned alt)
 
 		if (ncm->port.in_ep->driver_data) {
 			DBG(cdev, "reset ncm\n");
+			ncm->timer_stopping = true;
+			ncm->netdev = NULL;
 			gether_disconnect(&ncm->port);
 			ncm_reset_values(ncm);
 		}
@@ -839,6 +861,8 @@ static int ncm_set_alt(struct usb_function *f, unsigned intf, unsigned alt)
 			net = gether_connect(&ncm->port);
 			if (IS_ERR(net))
 				return PTR_ERR(net);
+			ncm->netdev = net;
+			ncm->timer_stopping = false;
 		}
 
 		spin_lock(&ncm->lock);
@@ -865,95 +889,232 @@ static int ncm_get_alt(struct usb_function *f, unsigned intf)
 	return ncm->port.in_ep->driver_data ? 1 : 0;
 }
 
+static struct sk_buff *package_for_tx(struct f_ncm *ncm)
+{
+	__le16		*ntb_iter;
+	struct sk_buff	*skb2 = NULL;
+	unsigned	ndp_pad;
+	unsigned	ndp_index;
+	unsigned	new_len;
+
+	const struct ndp_parser_opts *opts = ncm->parser_opts;
+	const int ndp_align = le16_to_cpu(ntb_parameters.wNdpInAlignment);
+	const int dgram_idx_len = 2 * 2 * opts->dgram_item_len;
+
+	/* Stop the timer */
+	hrtimer_try_to_cancel(&ncm->task_timer);
+
+	ndp_pad = ALIGN(ncm->skb_tx_data->len, ndp_align) -
+			ncm->skb_tx_data->len;
+	ndp_index = ncm->skb_tx_data->len + ndp_pad;
+	new_len = ndp_index + dgram_idx_len + ncm->skb_tx_ndp->len;
+
+	/* Set the final BlockLength and wNdpIndex */
+	ntb_iter = (void *) ncm->skb_tx_data->data;
+	/* Increment pointer to BlockLength */
+	ntb_iter += 2 + 1 + 1;
+	put_ncm(&ntb_iter, opts->block_length, new_len);
+	put_ncm(&ntb_iter, opts->ndp_index, ndp_index);
+
+	/* Set the final NDP wLength */
+	new_len = opts->ndp_size +
+			(ncm->ndp_dgram_count * dgram_idx_len);
+	ncm->ndp_dgram_count = 0;
+	/* Increment from start to wLength */
+	ntb_iter = (void *) ncm->skb_tx_ndp->data;
+	ntb_iter += 2;
+	put_unaligned_le16(new_len, ntb_iter);
+
+	/* Merge the skbs */
+	swap(skb2, ncm->skb_tx_data);
+	if (ncm->skb_tx_data) {
+		dev_kfree_skb_any(ncm->skb_tx_data);
+		ncm->skb_tx_data = NULL;
+	}
+
+	/* Insert NDP alignment. */
+	ntb_iter = (void *) skb_put(skb2, ndp_pad);
+	memset(ntb_iter, 0, ndp_pad);
+
+	/* Copy NTB across. */
+	ntb_iter = (void *) skb_put(skb2, ncm->skb_tx_ndp->len);
+	memcpy(ntb_iter, ncm->skb_tx_ndp->data, ncm->skb_tx_ndp->len);
+	dev_kfree_skb_any(ncm->skb_tx_ndp);
+	ncm->skb_tx_ndp = NULL;
+
+	/* Insert zero'd datagram. */
+	ntb_iter = (void *) skb_put(skb2, dgram_idx_len);
+	memset(ntb_iter, 0, dgram_idx_len);
+
+	return skb2;
+}
+
 static struct sk_buff *ncm_wrap_ntb(struct gether *port,
 				    struct sk_buff *skb)
 {
 	struct f_ncm	*ncm = func_to_ncm(&port->func);
-	struct sk_buff	*skb2;
+	struct sk_buff	*skb2 = NULL;
 	int		ncb_len = 0;
-	__le16		*tmp;
-	int		div;
-	int		rem;
-	int		pad;
-	int		ndp_align;
-	int		ndp_pad;
+	__le16		*ntb_data;
+	__le16		*ntb_ndp;
+	int		dgram_pad;
+
 	unsigned	max_size = ncm->port.fixed_in_len;
 	const struct ndp_parser_opts *opts = ncm->parser_opts;
-	unsigned	crc_len = ncm->is_crc ? sizeof(uint32_t) : 0;
-
-	div = le16_to_cpu(ntb_parameters.wNdpInDivisor);
-	rem = le16_to_cpu(ntb_parameters.wNdpInPayloadRemainder);
-	ndp_align = le16_to_cpu(ntb_parameters.wNdpInAlignment);
-
-	ncb_len += opts->nth_size;
-	ndp_pad = ALIGN(ncb_len, ndp_align) - ncb_len;
-	ncb_len += ndp_pad;
-	ncb_len += opts->ndp_size;
-	ncb_len += 2 * 2 * opts->dgram_item_len; /* Datagram entry */
-	ncb_len += 2 * 2 * opts->dgram_item_len; /* Zero datagram entry */
-	pad = ALIGN(ncb_len, div) + rem - ncb_len;
-	ncb_len += pad;
+	const int ndp_align = le16_to_cpu(ntb_parameters.wNdpInAlignment);
+	const int div = le16_to_cpu(ntb_parameters.wNdpInDivisor);
+	const int rem = le16_to_cpu(ntb_parameters.wNdpInPayloadRemainder);
+	const int dgram_idx_len = 2 * 2 * opts->dgram_item_len;
 
-	if (ncb_len + skb->len + crc_len > max_size) {
-		dev_kfree_skb_any(skb);
+	if (!skb && !ncm->skb_tx_data)
 		return NULL;
-	}
 
-	skb2 = skb_copy_expand(skb, ncb_len,
-			       max_size - skb->len - ncb_len - crc_len,
-			       GFP_ATOMIC);
-	dev_kfree_skb_any(skb);
-	if (!skb2)
-		return NULL;
+	if (skb) {
+		/* Add the CRC if required up front */
+		if (ncm->is_crc) {
+			uint32_t	crc;
+			__le16		*crc_pos;
+
+			crc = ~crc32_le(~0,
+					skb->data,
+					skb->len);
+			crc_pos = (void *) skb_put(skb, sizeof(uint32_t));
+			put_unaligned_le32(crc, crc_pos);
+		}
 
-	skb = skb2;
+		/* If the new skb is too big for the current NCM NTB then
+		 * set the current stored skb to be sent now and clear it
+		 * ready for new data.
+		 * NOTE: Assume maximum align for speed of calculation.
+		 */
+		if (ncm->skb_tx_data
+		    && (ncm->ndp_dgram_count >= TX_MAX_NUM_DPE
+		    || (ncm->skb_tx_data->len +
+		    div + rem + skb->len +
+		    ncm->skb_tx_ndp->len + ndp_align + (2 * dgram_idx_len))
+		    > max_size)) {
+			skb2 = package_for_tx(ncm);
+			if (!skb2)
+				goto err;
+		}
 
-	tmp = (void *) skb_push(skb, ncb_len);
-	memset(tmp, 0, ncb_len);
+		if (!ncm->skb_tx_data) {
+			ncb_len = opts->nth_size;
+			dgram_pad = ALIGN(ncb_len, div) + rem - ncb_len;
+			ncb_len += dgram_pad;
 
-	put_unaligned_le32(opts->nth_sign, tmp); /* dwSignature */
-	tmp += 2;
-	/* wHeaderLength */
-	put_unaligned_le16(opts->nth_size, tmp++);
-	tmp++; /* skip wSequence */
-	put_ncm(&tmp, opts->block_length, skb->len); /* (d)wBlockLength */
-	/* (d)wFpIndex */
-	/* the first pointer is right after the NTH + align */
-	put_ncm(&tmp, opts->fp_index, opts->nth_size + ndp_pad);
+			/* Create a new skb for the NTH and datagrams. */
+			ncm->skb_tx_data = alloc_skb(max_size, GFP_ATOMIC);
+			if (!ncm->skb_tx_data)
+				goto err;
 
-	tmp = (void *)tmp + ndp_pad;
+			ntb_data = (void *) skb_put(ncm->skb_tx_data, ncb_len);
+			memset(ntb_data, 0, ncb_len);
+			/* dwSignature */
+			put_unaligned_le32(opts->nth_sign, ntb_data);
+			ntb_data += 2;
+			/* wHeaderLength */
+			put_unaligned_le16(opts->nth_size, ntb_data++);
+
+			/* Allocate an skb for storing the NDP,
+			 * TX_MAX_NUM_DPE should easily suffice for a
+			 * 16k packet.
+			 */
+			ncm->skb_tx_ndp = alloc_skb((int)(opts->ndp_size
+						    + opts->dpe_size
+						    * TX_MAX_NUM_DPE),
+						    GFP_ATOMIC);
+			if (!ncm->skb_tx_ndp)
+				goto err;
+			ntb_ndp = (void *) skb_put(ncm->skb_tx_ndp,
+						    opts->ndp_size);
+			memset(ntb_ndp, 0, ncb_len);
+			/* dwSignature */
+			put_unaligned_le32(ncm->ndp_sign, ntb_ndp);
+			ntb_ndp += 2;
 
-	/* NDP */
-	put_unaligned_le32(ncm->ndp_sign, tmp); /* dwSignature */
-	tmp += 2;
-	/* wLength */
-	put_unaligned_le16(ncb_len - opts->nth_size - pad, tmp++);
+			/* There is always a zeroed entry */
+			ncm->ndp_dgram_count = 1;
 
-	tmp += opts->reserved1;
-	tmp += opts->next_fp_index; /* skip reserved (d)wNextFpIndex */
-	tmp += opts->reserved2;
+			/* Note: we skip opts->next_ndp_index */
+		}
 
-	if (ncm->is_crc) {
-		uint32_t crc;
+		/* Delay the timer. */
+		hrtimer_start(&ncm->task_timer,
+			      ktime_set(0, TX_TIMEOUT_NSECS),
+			      HRTIMER_MODE_REL);
+
+		/* Add the datagram position entries */
+		ntb_ndp = (void *) skb_put(ncm->skb_tx_ndp, dgram_idx_len);
+		memset(ntb_ndp, 0, dgram_idx_len);
+
+		ncb_len = ncm->skb_tx_data->len;
+		dgram_pad = ALIGN(ncb_len, div) + rem - ncb_len;
+		ncb_len += dgram_pad;
+
+		/* (d)wDatagramIndex */
+		put_ncm(&ntb_ndp, opts->dgram_item_len, ncb_len);
+		/* (d)wDatagramLength */
+		put_ncm(&ntb_ndp, opts->dgram_item_len, skb->len);
+		ncm->ndp_dgram_count++;
+
+		/* Add the new data to the skb */
+		ntb_data = (void *) skb_put(ncm->skb_tx_data, dgram_pad);
+		memset(ntb_data, 0, dgram_pad);
+		ntb_data = (void *) skb_put(ncm->skb_tx_data, skb->len);
+		memcpy(ntb_data, skb->data, skb->len);
+		dev_kfree_skb_any(skb);
+		skb = NULL;
 
-		crc = ~crc32_le(~0,
-				skb->data + ncb_len,
-				skb->len - ncb_len);
-		put_unaligned_le32(crc, skb->data + skb->len);
-		skb_put(skb, crc_len);
+	} else if (ncm->skb_tx_data && ncm->timer_force_tx) {
+		/* If the tx was requested because of a timeout then send */
+		skb2 = package_for_tx(ncm);
+		if (!skb2)
+			goto err;
 	}
 
-	/* (d)wDatagramIndex[0] */
-	put_ncm(&tmp, opts->dgram_item_len, ncb_len);
-	/* (d)wDatagramLength[0] */
-	put_ncm(&tmp, opts->dgram_item_len, skb->len - ncb_len);
-	/* (d)wDatagramIndex[1] and  (d)wDatagramLength[1] already zeroed */
+	return skb2;
+
+err:
+	ncm->netdev->stats.tx_dropped++;
+
+	if (skb)
+		dev_kfree_skb_any(skb);
+	if (ncm->skb_tx_data)
+		dev_kfree_skb_any(ncm->skb_tx_data);
+	if (ncm->skb_tx_ndp)
+		dev_kfree_skb_any(ncm->skb_tx_ndp);
+
+	return NULL;
+}
+
+/*
+ * This transmits the NTB if there are frames waiting.
+ */
+static void ncm_tx_tasklet(unsigned long data)
+{
+	struct f_ncm	*ncm = (void *)data;
 
-	if (skb->len > MAX_TX_NONFIXED)
-		memset(skb_put(skb, max_size - skb->len),
-		       0, max_size - skb->len);
+	if (ncm->timer_stopping)
+		return;
+
+	/* Only send if data is available. */
+	if (ncm->skb_tx_data) {
+		ncm->timer_force_tx = true;
+		ncm->netdev->netdev_ops->ndo_start_xmit(NULL, ncm->netdev);
+		ncm->timer_force_tx = false;
+	}
+}
 
-	return skb;
+/*
+ * The transmit should only be run if no skb data has been sent
+ * for a certain duration.
+ */
+static enum hrtimer_restart ncm_tx_timeout(struct hrtimer *data)
+{
+	struct f_ncm *ncm = container_of(data, struct f_ncm, task_timer);
+	tasklet_schedule(&ncm->tx_tasklet);
+	return HRTIMER_NORESTART;
 }
 
 static int ncm_unwrap_ntb(struct gether *port,
@@ -996,7 +1157,7 @@ static int ncm_unwrap_ntb(struct gether *port,
 		goto err;
 	}
 
-	ndp_index = get_ncm(&tmp, opts->fp_index);
+	ndp_index = get_ncm(&tmp, opts->ndp_index);
 
 	/* Run through all the NDP's in the NTB */
 	do {
@@ -1033,7 +1194,7 @@ static int ncm_unwrap_ntb(struct gether *port,
 		}
 		tmp += opts->reserved1;
 		/* Check for another NDP (d)wNextNdpIndex */
-		ndp_index = get_ncm(&tmp, opts->next_fp_index);
+		ndp_index = get_ncm(&tmp, opts->next_ndp_index);
 		tmp += opts->reserved2;
 
 		ndp_len -= opts->ndp_size;
@@ -1107,8 +1268,11 @@ static void ncm_disable(struct usb_function *f)
 
 	DBG(cdev, "ncm deactivated\n");
 
-	if (ncm->port.in_ep->driver_data)
+	if (ncm->port.in_ep->driver_data) {
+		ncm->timer_stopping = true;
+		ncm->netdev = NULL;
 		gether_disconnect(&ncm->port);
+	}
 
 	if (ncm->notify->driver_data) {
 		usb_ep_disable(ncm->notify);
@@ -1277,6 +1441,10 @@ static int ncm_bind(struct usb_configuration *c, struct usb_function *f)
 	ncm->port.open = ncm_open;
 	ncm->port.close = ncm_close;
 
+	tasklet_init(&ncm->tx_tasklet, ncm_tx_tasklet, (unsigned long) ncm);
+	hrtimer_init(&ncm->task_timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
+	ncm->task_timer.function = ncm_tx_timeout;
+
 	DBG(cdev, "CDC Network: %s speed IN/%s OUT/%s NOTIFY/%s\n",
 			gadget_is_dualspeed(c->cdev->gadget) ? "dual" : "full",
 			ncm->port.in_ep->name, ncm->port.out_ep->name,
@@ -1390,6 +1558,10 @@ static void ncm_unbind(struct usb_configuration *c, struct usb_function *f)
 
 	DBG(c->cdev, "ncm unbind\n");
 
+	hrtimer_cancel(&ncm->task_timer);
+	tasklet_kill(&ncm->tx_tasklet);
+
+	ncm_string_defs[0].id = 0;
 	usb_free_all_descriptors(f);
 
 	kfree(ncm->notify_req->buf);
@@ -1426,6 +1598,7 @@ static struct usb_function *ncm_alloc(struct usb_function_instance *fi)
 	ncm->port.ioport = netdev_priv(opts->net);
 	mutex_unlock(&opts->lock);
 	ncm->port.is_fixed = true;
+	ncm->port.supports_multi_frame = true;
 
 	ncm->port.func.name = "cdc_network";
 	/* descriptors are per-instance copies */
diff --git a/drivers/usb/gadget/u_ether.c b/drivers/usb/gadget/u_ether.c
index fe0880d..b561c93 100644
--- a/drivers/usb/gadget/u_ether.c
+++ b/drivers/usb/gadget/u_ether.c
@@ -483,7 +483,7 @@ static netdev_tx_t eth_start_xmit(struct sk_buff *skb,
 					struct net_device *net)
 {
 	struct eth_dev		*dev = netdev_priv(net);
-	int			length = skb->len;
+	int			length = 0;
 	int			retval;
 	struct usb_request	*req = NULL;
 	unsigned long		flags;
@@ -500,13 +500,13 @@ static netdev_tx_t eth_start_xmit(struct sk_buff *skb,
 	}
 	spin_unlock_irqrestore(&dev->lock, flags);
 
-	if (!in) {
+	if (skb && !in) {
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
 	/* apply outgoing CDC or RNDIS filters */
-	if (!is_promisc(cdc_filter)) {
+	if (skb && !is_promisc(cdc_filter)) {
 		u8		*dest = skb->data;
 
 		if (is_multicast_ether_addr(dest)) {
@@ -557,11 +557,17 @@ static netdev_tx_t eth_start_xmit(struct sk_buff *skb,
 		if (dev->port_usb)
 			skb = dev->wrap(dev->port_usb, skb);
 		spin_unlock_irqrestore(&dev->lock, flags);
-		if (!skb)
+		if (!skb) {
+			/* Multi frame CDC protocols may store the frame for
+			 * later which is not a dropped frame.
+			 */
+			if (dev->port_usb->supports_multi_frame)
+				goto multiframe;
 			goto drop;
-
-		length = skb->len;
+		}
 	}
+
+	length = skb->len;
 	req->buf = skb->data;
 	req->context = skb;
 	req->complete = tx_complete;
@@ -604,6 +610,7 @@ static netdev_tx_t eth_start_xmit(struct sk_buff *skb,
 		dev_kfree_skb_any(skb);
 drop:
 		dev->net->stats.tx_dropped++;
+multiframe:
 		spin_lock_irqsave(&dev->req_lock, flags);
 		if (list_empty(&dev->tx_reqs))
 			netif_start_queue(net);
diff --git a/drivers/usb/gadget/u_ether.h b/drivers/usb/gadget/u_ether.h
index 0f0290a..334b389 100644
--- a/drivers/usb/gadget/u_ether.h
+++ b/drivers/usb/gadget/u_ether.h
@@ -18,6 +18,7 @@
 #include <linux/if_ether.h>
 #include <linux/usb/composite.h>
 #include <linux/usb/cdc.h>
+#include <linux/netdevice.h>
 
 #include "gadget_chips.h"
 
@@ -74,6 +75,7 @@ struct gether {
 	bool				is_fixed;
 	u32				fixed_out_len;
 	u32				fixed_in_len;
+	bool				supports_multi_frame;
 	struct sk_buff			*(*wrap)(struct gether *port,
 						struct sk_buff *skb);
 	int				(*unwrap)(struct gether *port,
-- 
1.7.9.5
