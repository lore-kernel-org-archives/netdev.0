From: Samuel Ortiz <samuel@sortiz.org>
Subject: [RFC PATCH 1/9] irda: Introduce irda_alloc_skb
Date: Mon, 15 Dec 2008 02:57:30 +0100
Message-ID: <20081215015855.713361435@sortiz.org>
References: <20081215015729.587697008@sortiz.org>
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 42.mail-out.ovh.net ([213.251.189.42]:56854 "HELO
	42.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751463AbYLOCDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2008 21:03:07 -0500
Content-Disposition: inline; filename=0001-irda-Introduce-irda_alloc_skb.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We want to have extra space for the irda_skb_cb structure in front of
the actual IrDA data.
It's currently sitting in skb->cb, but that pointer can be altered after
hitting dev_queue_xmit. So, an additional skb header is a safer place.

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 include/net/irda/irda.h         |    1 +
 include/net/irda/irda_device.h  |    6 +++
 net/irda/af_irda.c              |    4 +-
 net/irda/ircomm/ircomm_lmp.c    |    4 +-
 net/irda/ircomm/ircomm_param.c  |    2 +-
 net/irda/ircomm/ircomm_tty.c    |    6 ++--
 net/irda/irda_device.c          |   12 ++++++
 net/irda/iriap.c                |   10 +++---
 net/irda/iriap_event.c          |    2 +-
 net/irda/irlan/irlan_common.c   |   77 +++++++++++++++++++++------------------
 net/irda/irlan/irlan_provider.c |   18 ++++++----
 net/irda/irlap.c                |    2 +-
 net/irda/irlap_frame.c          |   28 ++++++++-------
 net/irda/irlmp.c                |    2 +-
 net/irda/irttp.c                |   14 ++++----
 15 files changed, 110 insertions(+), 78 deletions(-)

diff --git a/include/net/irda/irda.h b/include/net/irda/irda.h
index 7e58206..ce510aa 100644
--- a/include/net/irda/irda.h
+++ b/include/net/irda/irda.h
@@ -132,4 +132,5 @@ extern int irlap_driver_rcv(struct sk_buff *skb, struct net_device *dev,
 			    struct packet_type *ptype,
 			    struct net_device *orig_dev);
 
+extern struct sk_buff *irda_alloc_skb(unsigned int size, gfp_t priority);
 #endif /* NET_IRDA_H */
diff --git a/include/net/irda/irda_device.h b/include/net/irda/irda_device.h
index 3025ae1..305eb05 100644
--- a/include/net/irda/irda_device.h
+++ b/include/net/irda/irda_device.h
@@ -230,6 +230,12 @@ struct net_device *alloc_irdadev(int sizeof_priv);
 
 void irda_setup_dma(int channel, dma_addr_t buffer, int count, int mode);
 
+
+static inline struct irda_skb_cb *irda_get_skb_cb(struct sk_buff *skb)
+{
+	return (struct irda_skb_cb *)(skb->data - sizeof(struct irda_skb_cb));
+}
+
 /*
  * Function irda_get_mtt (skb)
  *
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 3eb5bcc..61def98 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -304,8 +304,8 @@ static void irda_connect_response(struct irda_sock *self)
 
 	IRDA_DEBUG(2, "%s()\n", __func__);
 
-	skb = alloc_skb(TTP_MAX_HEADER + TTP_SAR_HEADER,
-			GFP_ATOMIC);
+	skb = irda_alloc_skb(TTP_MAX_HEADER + TTP_SAR_HEADER,
+			     GFP_ATOMIC);
 	if (skb == NULL) {
 		IRDA_DEBUG(0, "%s() Unable to allocate sk_buff!\n",
 			   __func__);
diff --git a/net/irda/ircomm/ircomm_lmp.c b/net/irda/ircomm/ircomm_lmp.c
index 67c99d2..407bad3 100644
--- a/net/irda/ircomm/ircomm_lmp.c
+++ b/net/irda/ircomm/ircomm_lmp.c
@@ -80,7 +80,7 @@ static int ircomm_lmp_connect_response(struct ircomm_cb *self,
 
 	/* Any userdata supplied? */
 	if (userdata == NULL) {
-		tx_skb = alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
+		tx_skb = irda_alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
 		if (!tx_skb)
 			return -ENOMEM;
 
@@ -114,7 +114,7 @@ static int ircomm_lmp_disconnect_request(struct ircomm_cb *self,
 	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	if (!userdata) {
-		tx_skb = alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
+		tx_skb = irda_alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
 		if (!tx_skb)
 			return -ENOMEM;
 
diff --git a/net/irda/ircomm/ircomm_param.c b/net/irda/ircomm/ircomm_param.c
index d57aefd..e62979b 100644
--- a/net/irda/ircomm/ircomm_param.c
+++ b/net/irda/ircomm/ircomm_param.c
@@ -120,7 +120,7 @@ int ircomm_param_request(struct ircomm_tty_cb *self, __u8 pi, int flush)
 
 	skb = self->ctrl_skb;
 	if (!skb) {
-		skb = alloc_skb(256, GFP_ATOMIC);
+		skb = irda_alloc_skb(256, GFP_ATOMIC);
 		if (!skb) {
 			spin_unlock_irqrestore(&self->spinlock, flags);
 			return -ENOMEM;
diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index e4e2cae..fa62490 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -752,9 +752,9 @@ static int ircomm_tty_write(struct tty_struct *tty,
 			}
 		} else {
 			/* Prepare a full sized frame */
-			skb = alloc_skb(self->max_data_size+
-					self->max_header_size,
-					GFP_ATOMIC);
+			skb = irda_alloc_skb(self->max_data_size+
+					     self->max_header_size,
+					     GFP_ATOMIC);
 			if (!skb) {
 				spin_unlock_irqrestore(&self->spinlock, flags);
 				return -ENOBUFS;
diff --git a/net/irda/irda_device.c b/net/irda/irda_device.c
index ea319e3..5271015 100644
--- a/net/irda/irda_device.c
+++ b/net/irda/irda_device.c
@@ -296,6 +296,18 @@ struct net_device *alloc_irdadev(int sizeof_priv)
 }
 EXPORT_SYMBOL(alloc_irdadev);
 
+struct sk_buff *irda_alloc_skb(unsigned int size, gfp_t priority)
+{
+	struct sk_buff *skb;
+
+	skb = alloc_skb(size + sizeof(struct irda_skb_cb), priority);
+	if (likely(skb))
+		skb_reserve(skb, sizeof(struct irda_skb_cb));
+
+	return skb;
+}
+EXPORT_SYMBOL(irda_alloc_skb);
+
 #ifdef CONFIG_ISA_DMA_API
 /*
  * Function setup_dma (idev, buffer, count, mode)
diff --git a/net/irda/iriap.c b/net/irda/iriap.c
index 4a105dc..dbd91bf 100644
--- a/net/irda/iriap.c
+++ b/net/irda/iriap.c
@@ -345,7 +345,7 @@ static void iriap_disconnect_request(struct iriap_cb *self)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
-	tx_skb = alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
+	tx_skb = irda_alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
 	if (tx_skb == NULL) {
 		IRDA_DEBUG(0,
 			   "%s(), Could not allocate an sk_buff of length %d\n",
@@ -397,7 +397,7 @@ int iriap_getvaluebyclass_request(struct iriap_cb *self,
 	attr_len = strlen(attr);	/* Up to IAS_MAX_ATTRIBNAME = 60 */
 
 	skb_len = self->max_header_size+2+name_len+1+attr_len+4;
-	tx_skb = alloc_skb(skb_len, GFP_ATOMIC);
+	tx_skb = irda_alloc_skb(skb_len, GFP_ATOMIC);
 	if (!tx_skb)
 		return -ENOMEM;
 
@@ -565,8 +565,8 @@ static void iriap_getvaluebyclass_response(struct iriap_cb *self,
 	 *  value. We add 32 bytes because of the 6 bytes for the frame and
 	 *  max 5 bytes for the value coding.
 	 */
-	tx_skb = alloc_skb(value->len + self->max_header_size + 32,
-			   GFP_ATOMIC);
+	tx_skb = irda_alloc_skb(value->len + self->max_header_size + 32,
+				GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
@@ -704,7 +704,7 @@ void iriap_send_ack(struct iriap_cb *self)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
-	tx_skb = alloc_skb(LMP_MAX_HEADER + 1, GFP_ATOMIC);
+	tx_skb = irda_alloc_skb(LMP_MAX_HEADER + 1, GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
diff --git a/net/irda/iriap_event.c b/net/irda/iriap_event.c
index a301cbd..87cd337 100644
--- a/net/irda/iriap_event.c
+++ b/net/irda/iriap_event.c
@@ -365,7 +365,7 @@ static void state_r_disconnect(struct iriap_cb *self, IRIAP_EVENT event,
 
 	switch (event) {
 	case IAP_LM_CONNECT_INDICATION:
-		tx_skb = alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
+		tx_skb = irda_alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
 		if (tx_skb == NULL) {
 			IRDA_WARNING("%s: unable to malloc!\n", __func__);
 			return;
diff --git a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
index 9a1cd87..bcafd88 100644
--- a/net/irda/irlan/irlan_common.c
+++ b/net/irda/irlan/irlan_common.c
@@ -641,8 +641,8 @@ void irlan_get_provider_info(struct irlan_cb *self)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
-	skb = alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER,
-			GFP_ATOMIC);
+	skb = irda_alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER,
+			     GFP_ATOMIC);
 	if (!skb)
 		return;
 
@@ -674,10 +674,11 @@ void irlan_open_data_channel(struct irlan_cb *self)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
-	skb = alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
-			IRLAN_STRING_PARAMETER_LEN("MEDIA", "802.3") +
-			IRLAN_STRING_PARAMETER_LEN("ACCESS_TYPE", "DIRECT"),
-			GFP_ATOMIC);
+	skb = irda_alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
+			     IRLAN_STRING_PARAMETER_LEN("MEDIA", "802.3") +
+			     IRLAN_STRING_PARAMETER_LEN("ACCESS_TYPE",
+							"DIRECT"),
+			     GFP_ATOMIC);
 	if (!skb)
 		return;
 
@@ -713,9 +714,9 @@ void irlan_close_data_channel(struct irlan_cb *self)
 	if (self->client.tsap_ctrl == NULL)
 		return;
 
-	skb = alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
-			IRLAN_BYTE_PARAMETER_LEN("DATA_CHAN"),
-			GFP_ATOMIC);
+	skb = irda_alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
+			     IRLAN_BYTE_PARAMETER_LEN("DATA_CHAN"),
+			     GFP_ATOMIC);
 	if (!skb)
 		return;
 
@@ -750,11 +751,13 @@ static void irlan_open_unicast_addr(struct irlan_cb *self)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
-	skb = alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
-			IRLAN_BYTE_PARAMETER_LEN("DATA_CHAN") +
-			IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE", "DIRECTED") +
-			IRLAN_STRING_PARAMETER_LEN("FILTER_MODE", "FILTER"),
-			GFP_ATOMIC);
+	skb = irda_alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
+			     IRLAN_BYTE_PARAMETER_LEN("DATA_CHAN") +
+			     IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE",
+							"DIRECTED") +
+			     IRLAN_STRING_PARAMETER_LEN("FILTER_MODE",
+							"FILTER"),
+			     GFP_ATOMIC);
 	if (!skb)
 		return;
 
@@ -792,12 +795,14 @@ void irlan_set_broadcast_filter(struct irlan_cb *self, int status)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
-	skb = alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
-			IRLAN_BYTE_PARAMETER_LEN("DATA_CHAN") +
-			IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE", "BROADCAST") +
-			/* We may waste one byte here...*/
-			IRLAN_STRING_PARAMETER_LEN("FILTER_MODE", "FILTER"),
-			GFP_ATOMIC);
+	skb = irda_alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
+			     IRLAN_BYTE_PARAMETER_LEN("DATA_CHAN") +
+			     IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE",
+							"BROADCAST") +
+			     /* We may waste one byte here...*/
+			     IRLAN_STRING_PARAMETER_LEN("FILTER_MODE",
+							"FILTER"),
+			     GFP_ATOMIC);
 	if (!skb)
 		return;
 
@@ -836,12 +841,13 @@ void irlan_set_multicast_filter(struct irlan_cb *self, int status)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
-	skb = alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
-			IRLAN_BYTE_PARAMETER_LEN("DATA_CHAN") +
-			IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE", "MULTICAST") +
-			/* We may waste one byte here...*/
-			IRLAN_STRING_PARAMETER_LEN("FILTER_MODE", "NONE"),
-			GFP_ATOMIC);
+	skb = irda_alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
+			     IRLAN_BYTE_PARAMETER_LEN("DATA_CHAN") +
+			     IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE",
+							"MULTICAST") +
+			     /* We may waste one byte here...*/
+			     IRLAN_STRING_PARAMETER_LEN("FILTER_MODE", "NONE"),
+			     GFP_ATOMIC);
 	if (!skb)
 		return;
 
@@ -881,12 +887,13 @@ static void irlan_get_unicast_addr(struct irlan_cb *self)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
-	skb = alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
-			IRLAN_BYTE_PARAMETER_LEN("DATA_CHAN") +
-			IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE", "DIRECTED") +
-			IRLAN_STRING_PARAMETER_LEN("FILTER_OPERATION",
-						   "DYNAMIC"),
-			GFP_ATOMIC);
+	skb = irda_alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
+			     IRLAN_BYTE_PARAMETER_LEN("DATA_CHAN") +
+			     IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE",
+							"DIRECTED") +
+			     IRLAN_STRING_PARAMETER_LEN("FILTER_OPERATION",
+							"DYNAMIC"),
+			     GFP_ATOMIC);
 	if (!skb)
 		return;
 
@@ -921,9 +928,9 @@ void irlan_get_media_char(struct irlan_cb *self)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
-	skb = alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
-			IRLAN_STRING_PARAMETER_LEN("MEDIA", "802.3"),
-			GFP_ATOMIC);
+	skb = irda_alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
+			     IRLAN_STRING_PARAMETER_LEN("MEDIA", "802.3"),
+			     GFP_ATOMIC);
 
 	if (!skb)
 		return;
diff --git a/net/irda/irlan/irlan_provider.c b/net/irda/irlan/irlan_provider.c
index 3f81f81..4d8ce7f 100644
--- a/net/irda/irlan/irlan_provider.c
+++ b/net/irda/irlan/irlan_provider.c
@@ -296,13 +296,17 @@ void irlan_provider_send_reply(struct irlan_cb *self, int command,
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
-	skb = alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
-			/* Bigger param length comes from CMD_GET_MEDIA_CHAR */
-			IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE", "DIRECTED") +
-			IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE", "BORADCAST") +
-			IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE", "MULTICAST") +
-			IRLAN_STRING_PARAMETER_LEN("ACCESS_TYPE", "HOSTED"),
-			GFP_ATOMIC);
+	skb = irda_alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
+			     /* Bigger param length from CMD_GET_MEDIA_CHAR */
+			     IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE",
+							"DIRECTED") +
+			     IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE",
+							"BORADCAST") +
+			     IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE",
+							"MULTICAST") +
+			     IRLAN_STRING_PARAMETER_LEN("ACCESS_TYPE",
+							"HOSTED"),
+			     GFP_ATOMIC);
 
 	if (!skb)
 		return;
diff --git a/net/irda/irlap.c b/net/irda/irlap.c
index e4965b7..4139e7a 100644
--- a/net/irda/irlap.c
+++ b/net/irda/irlap.c
@@ -881,7 +881,7 @@ static void irlap_change_speed(struct irlap_cb *self, __u32 speed, int now)
 	/* Change speed now, or just piggyback speed on frames */
 	if (now) {
 		/* Send down empty frame to trigger speed change */
-		skb = alloc_skb(0, GFP_ATOMIC);
+		skb = irda_alloc_skb(0, GFP_ATOMIC);
 		if (skb)
 			irlap_queue_xmit(self, skb);
 	}
diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index f17b65a..bf41ebf 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -126,9 +126,9 @@ void irlap_send_snrm_frame(struct irlap_cb *self, struct qos_info *qos)
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	/* Allocate frame */
-	tx_skb = alloc_skb(sizeof(struct snrm_frame) +
-			   IRLAP_NEGOCIATION_PARAMS_LEN,
-			   GFP_ATOMIC);
+	tx_skb = irda_alloc_skb(sizeof(struct snrm_frame) +
+				IRLAP_NEGOCIATION_PARAMS_LEN,
+				GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
@@ -221,9 +221,9 @@ void irlap_send_ua_response_frame(struct irlap_cb *self, struct qos_info *qos)
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	/* Allocate frame */
-	tx_skb = alloc_skb(sizeof(struct ua_frame) +
-			   IRLAP_NEGOCIATION_PARAMS_LEN,
-			   GFP_ATOMIC);
+	tx_skb = irda_alloc_skb(sizeof(struct ua_frame) +
+				IRLAP_NEGOCIATION_PARAMS_LEN,
+				GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
@@ -263,7 +263,7 @@ void irlap_send_dm_frame( struct irlap_cb *self)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
-	tx_skb = alloc_skb(sizeof(struct dm_frame), GFP_ATOMIC);
+	tx_skb = irda_alloc_skb(sizeof(struct dm_frame), GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
@@ -295,7 +295,7 @@ void irlap_send_disc_frame(struct irlap_cb *self)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
-	tx_skb = alloc_skb(sizeof(struct disc_frame), GFP_ATOMIC);
+	tx_skb = irda_alloc_skb(sizeof(struct disc_frame), GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
@@ -328,8 +328,9 @@ void irlap_send_discovery_xid_frame(struct irlap_cb *self, int S, __u8 s,
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 	IRDA_ASSERT(discovery != NULL, return;);
 
-	tx_skb = alloc_skb(sizeof(struct xid_frame) + IRLAP_DISCOVERY_INFO_LEN,
-			   GFP_ATOMIC);
+	tx_skb = irda_alloc_skb(sizeof(struct xid_frame) +
+				IRLAP_DISCOVERY_INFO_LEN,
+				GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
@@ -589,7 +590,7 @@ void irlap_send_rr_frame(struct irlap_cb *self, int command)
 	struct sk_buff *tx_skb;
 	struct rr_frame *frame;
 
-	tx_skb = alloc_skb(sizeof(struct rr_frame), GFP_ATOMIC);
+	tx_skb = irda_alloc_skb(sizeof(struct rr_frame), GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
@@ -614,7 +615,7 @@ void irlap_send_rd_frame(struct irlap_cb *self)
 	struct sk_buff *tx_skb;
 	struct rd_frame *frame;
 
-	tx_skb = alloc_skb(sizeof(struct rd_frame), GFP_ATOMIC);
+	tx_skb = irda_alloc_skb(sizeof(struct rd_frame), GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
@@ -1231,7 +1232,8 @@ void irlap_send_test_frame(struct irlap_cb *self, __u8 caddr, __u32 daddr,
 	struct test_frame *frame;
 	__u8 *info;
 
-	tx_skb = alloc_skb(cmd->len + sizeof(struct test_frame), GFP_ATOMIC);
+	tx_skb = irda_alloc_skb(cmd->len + sizeof(struct test_frame),
+				GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
diff --git a/net/irda/irlmp.c b/net/irda/irlmp.c
index 7bf5b91..18188f2 100644
--- a/net/irda/irlmp.c
+++ b/net/irda/irlmp.c
@@ -396,7 +396,7 @@ int irlmp_connect_request(struct lsap_cb *self, __u8 dlsap_sel,
 
 	/* Any userdata? */
 	if (tx_skb == NULL) {
-		tx_skb = alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
+		tx_skb = irda_alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
 		if (!tx_skb)
 			return -ENOMEM;
 
diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index 74e439e..4b913de 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -306,8 +306,8 @@ static inline void irttp_fragment_skb(struct tsap_cb *self,
 		IRDA_DEBUG(2, "%s(), fragmenting ...\n", __func__);
 
 		/* Make new segment */
-		frag = alloc_skb(self->max_seg_size+self->max_header_size,
-				 GFP_ATOMIC);
+		frag = irda_alloc_skb(self->max_seg_size+self->max_header_size,
+				      GFP_ATOMIC);
 		if (!frag)
 			return;
 
@@ -817,7 +817,7 @@ static inline void irttp_give_credit(struct tsap_cb *self)
 		   self->send_credit, self->avail_credit, self->remote_credit);
 
 	/* Give credit to peer */
-	tx_skb = alloc_skb(TTP_MAX_HEADER, GFP_ATOMIC);
+	tx_skb = irda_alloc_skb(TTP_MAX_HEADER, GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
@@ -1106,8 +1106,8 @@ int irttp_connect_request(struct tsap_cb *self, __u8 dtsap_sel,
 
 	/* Any userdata supplied? */
 	if (userdata == NULL) {
-		tx_skb = alloc_skb(TTP_MAX_HEADER + TTP_SAR_HEADER,
-				   GFP_ATOMIC);
+		tx_skb = irda_alloc_skb(TTP_MAX_HEADER + TTP_SAR_HEADER,
+					GFP_ATOMIC);
 		if (!tx_skb)
 			return -ENOMEM;
 
@@ -1355,7 +1355,7 @@ int irttp_connect_response(struct tsap_cb *self, __u32 max_sdu_size,
 
 	/* Any userdata supplied? */
 	if (userdata == NULL) {
-		tx_skb = alloc_skb(TTP_MAX_HEADER + TTP_SAR_HEADER,
+		tx_skb = irda_alloc_skb(TTP_MAX_HEADER + TTP_SAR_HEADER,
 				   GFP_ATOMIC);
 		if (!tx_skb)
 			return -ENOMEM;
@@ -1553,7 +1553,7 @@ int irttp_disconnect_request(struct tsap_cb *self, struct sk_buff *userdata,
 
 	if (!userdata) {
 		struct sk_buff *tx_skb;
-		tx_skb = alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
+		tx_skb = irda_alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
 		if (!tx_skb)
 			return -ENOMEM;
 
-- 
1.6.0.4.766.g6fc4a.dirty

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
