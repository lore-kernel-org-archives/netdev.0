From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH 3/3] [IrDA] Memory allocations cleanups
Date: Mon, 11 Sep 2006 08:47:00 +0300
Message-ID: <20060911054700.GC6368@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.pp.htv.fi ([213.243.153.36]:30404 "EHLO smtp3.pp.htv.fi")
	by vger.kernel.org with ESMTP id S932164AbWIJWcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Sep 2006 18:32:50 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces the bunch of arbitrary 64 and 128 bytes alloc_skb() calls
with more accurate allocation sizes.

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 include/net/irda/irlan_common.h |   10 ++++++-
 include/net/irda/irlap_frame.h  |   31 +++++++++++++++++++-
 include/net/irda/irlmp.h        |    2 +
 net/irda/af_irda.c              |    3 +-
 net/irda/ircomm/ircomm_lmp.c    |    4 +--
 net/irda/iriap.c                |    9 +++---
 net/irda/iriap_event.c          |    2 +
 net/irda/irlan/irlan_common.c   |   46 ++++++++++++++++++++++++------
 net/irda/irlan/irlan_provider.c |   12 ++++++--
 net/irda/irlap_frame.c          |   59 +++++++++++++++++++++------------------
 net/irda/irlmp.c                |    2 +
 net/irda/irttp.c                |   14 +++++----
 12 files changed, 136 insertions(+), 58 deletions(-)

diff --git a/include/net/irda/irlan_common.h b/include/net/irda/irlan_common.h
index 1c73bdb..9592c37 100644
--- a/include/net/irda/irlan_common.h
+++ b/include/net/irda/irlan_common.h
@@ -98,7 +98,15 @@ #define IRLAN_BYTE   0
 #define IRLAN_SHORT  1
 #define IRLAN_ARRAY  2
 
-#define IRLAN_MAX_HEADER (TTP_HEADER+LMP_HEADER+LAP_MAX_HEADER)
+/* IrLAN sits on top if IrTTP */
+#define IRLAN_MAX_HEADER (TTP_HEADER+LMP_HEADER)
+/* 1 byte for the command code and 1 byte for the parameter count */
+#define IRLAN_CMD_HEADER 2
+
+#define IRLAN_STRING_PARAMETER_LEN(name, value) (1 + strlen((name)) + 2 \
+						+ strlen ((value)))
+#define IRLAN_BYTE_PARAMETER_LEN(name)          (1 + strlen((name)) + 2 + 1)
+#define IRLAN_SHORT_PARAMETER_LEN(name)         (1 + strlen((name)) + 2 + 2)
 
 /*
  *  IrLAN client
diff --git a/include/net/irda/irlap_frame.h b/include/net/irda/irlap_frame.h
index 3452ae2..9dd54a5 100644
--- a/include/net/irda/irlap_frame.h
+++ b/include/net/irda/irlap_frame.h
@@ -74,6 +74,19 @@ #define RSP_FRAME 0x00
 
 #define PF_BIT    0x10 /* Poll/final bit */
 
+/* Some IrLAP field lengths */
+/*
+ * Only baud rate triplet is 4 bytes (PV can be 2 bytes).
+ * All others params (7) are 3 bytes, so that's 7*3 + 1*4 bytes.
+ */
+#define IRLAP_NEGOCIATION_PARAMS_LEN 25
+#define IRLAP_DISCOVERY_INFO_LEN     32
+
+struct disc_frame {
+	__u8 caddr;          /* Connection address */
+	__u8 control;
+} IRDA_PACK;
+
 struct xid_frame {
 	__u8  caddr; /* Connection address */
 	__u8  control;
@@ -95,11 +108,25 @@ struct test_frame {
 struct ua_frame {
 	__u8 caddr;
 	__u8 control;
-
 	__u32 saddr; /* Source device address */
 	__u32 daddr; /* Dest device address */
 } IRDA_PACK;
-	
+
+struct dm_frame {
+	__u8 caddr;          /* Connection address */
+	__u8 control;
+} IRDA_PACK;
+
+struct rd_frame {
+	__u8 caddr;          /* Connection address */
+	__u8 control;
+} IRDA_PACK;
+
+struct rr_frame {
+	__u8 caddr;          /* Connection address */
+	__u8 control;
+} IRDA_PACK;
+
 struct i_frame {
 	__u8 caddr;
 	__u8 control;
diff --git a/include/net/irda/irlmp.h b/include/net/irda/irlmp.h
index 11ecfa5..e212b9b 100644
--- a/include/net/irda/irlmp.h
+++ b/include/net/irda/irlmp.h
@@ -48,7 +48,7 @@ #define LSAP_CONNLESS 0x70 /* Connection
 #define DEV_ADDR_ANY  0xffffffff
 
 #define LMP_HEADER          2    /* Dest LSAP + Source LSAP */
-#define LMP_CONTROL_HEADER  4
+#define LMP_CONTROL_HEADER  4    /* LMP_HEADER + opcode + parameter */
 #define LMP_PID_HEADER      1    /* Used by Ultra */
 #define LMP_MAX_HEADER      (LMP_CONTROL_HEADER+LAP_MAX_HEADER)
 
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 7b7cd5b..7e1aea8 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -309,7 +309,8 @@ static void irda_connect_response(struct
 
 	IRDA_ASSERT(self != NULL, return;);
 
-	skb = alloc_skb(64, GFP_ATOMIC);
+	skb = alloc_skb(TTP_MAX_HEADER + TTP_SAR_HEADER,
+			GFP_ATOMIC);
 	if (skb == NULL) {
 		IRDA_DEBUG(0, "%s() Unable to allocate sk_buff!\n",
 			   __FUNCTION__);
diff --git a/net/irda/ircomm/ircomm_lmp.c b/net/irda/ircomm/ircomm_lmp.c
index 959874b..c8e0d89 100644
--- a/net/irda/ircomm/ircomm_lmp.c
+++ b/net/irda/ircomm/ircomm_lmp.c
@@ -81,7 +81,7 @@ static int ircomm_lmp_connect_response(s
 	
 	/* Any userdata supplied? */
 	if (userdata == NULL) {
-		tx_skb = alloc_skb(64, GFP_ATOMIC);
+		tx_skb = alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
 		if (!tx_skb)
 			return -ENOMEM;
 
@@ -115,7 +115,7 @@ static int ircomm_lmp_disconnect_request
 	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
 
         if (!userdata) {
-		tx_skb = alloc_skb(64, GFP_ATOMIC);
+		tx_skb = alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
 		if (!tx_skb)
 			return -ENOMEM;
 		
diff --git a/net/irda/iriap.c b/net/irda/iriap.c
index 61128aa..415cf4e 100644
--- a/net/irda/iriap.c
+++ b/net/irda/iriap.c
@@ -345,10 +345,11 @@ static void iriap_disconnect_request(str
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
-	tx_skb = alloc_skb(64, GFP_ATOMIC);
+	tx_skb = alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
 	if (tx_skb == NULL) {
-		IRDA_DEBUG(0, "%s(), Could not allocate an sk_buff of length %d\n", 
-			__FUNCTION__, 64);
+		IRDA_DEBUG(0,
+			   "%s(), Could not allocate an sk_buff of length %d\n",
+			   __FUNCTION__, LMP_MAX_HEADER);
 		return;
 	}
 
@@ -701,7 +702,7 @@ void iriap_send_ack(struct iriap_cb *sel
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
-	tx_skb = alloc_skb(64, GFP_ATOMIC);
+	tx_skb = alloc_skb(LMP_MAX_HEADER + 1, GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
diff --git a/net/irda/iriap_event.c b/net/irda/iriap_event.c
index da17395..99b18dc 100644
--- a/net/irda/iriap_event.c
+++ b/net/irda/iriap_event.c
@@ -365,7 +365,7 @@ static void state_r_disconnect(struct ir
 
 	switch (event) {
 	case IAP_LM_CONNECT_INDICATION:
-		tx_skb = alloc_skb(64, GFP_ATOMIC);
+		tx_skb = alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
 		if (tx_skb == NULL) {
 			IRDA_WARNING("%s: unable to malloc!\n", __FUNCTION__);
 			return;
diff --git a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
index 7dd0a2f..9b962f2 100644
--- a/net/irda/irlan/irlan_common.c
+++ b/net/irda/irlan/irlan_common.c
@@ -636,7 +636,8 @@ void irlan_get_provider_info(struct irla
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
-	skb = alloc_skb(64, GFP_ATOMIC);
+	skb = alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER,
+			GFP_ATOMIC);
 	if (!skb)
 		return;
 
@@ -668,7 +669,10 @@ void irlan_open_data_channel(struct irla
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 	
-	skb = alloc_skb(64, GFP_ATOMIC);
+	skb = alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
+			IRLAN_STRING_PARAMETER_LEN("MEDIA", "802.3") +
+			IRLAN_STRING_PARAMETER_LEN("ACCESS_TYPE", "DIRECT"),
+			GFP_ATOMIC);
 	if (!skb)
 		return;
 
@@ -704,7 +708,9 @@ void irlan_close_data_channel(struct irl
 	if (self->client.tsap_ctrl == NULL)
 		return;
 
-	skb = alloc_skb(64, GFP_ATOMIC);
+	skb = alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
+			IRLAN_BYTE_PARAMETER_LEN("DATA_CHAN"),
+			GFP_ATOMIC);
 	if (!skb)
 		return;
 
@@ -715,7 +721,7 @@ void irlan_close_data_channel(struct irl
 	
 	/* Build frame */
  	frame[0] = CMD_CLOSE_DATA_CHAN;
-	frame[1] = 0x01; /* Two parameters */
+	frame[1] = 0x01; /* One parameter */
 
 	irlan_insert_byte_param(skb, "DATA_CHAN", self->dtsap_sel_data);
 
@@ -739,7 +745,11 @@ static void irlan_open_unicast_addr(stru
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);	
 	
-	skb = alloc_skb(128, GFP_ATOMIC);
+	skb = alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
+			IRLAN_BYTE_PARAMETER_LEN("DATA_CHAN") +
+			IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE", "DIRECTED") +
+			IRLAN_STRING_PARAMETER_LEN("FILTER_MODE", "FILTER"),
+			GFP_ATOMIC);
 	if (!skb)
 		return;
 
@@ -777,7 +787,12 @@ void irlan_set_broadcast_filter(struct i
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 	
- 	skb = alloc_skb(128, GFP_ATOMIC);
+ 	skb = alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
+			IRLAN_BYTE_PARAMETER_LEN("DATA_CHAN") +
+			IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE", "BROADCAST") +
+			/* We may waste one byte here...*/
+			IRLAN_STRING_PARAMETER_LEN("FILTER_MODE", "FILTER"),
+			GFP_ATOMIC);
 	if (!skb)
 		return;
 
@@ -816,7 +831,12 @@ void irlan_set_multicast_filter(struct i
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
- 	skb = alloc_skb(128, GFP_ATOMIC);
+	skb = alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
+			IRLAN_BYTE_PARAMETER_LEN("DATA_CHAN") +
+			IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE", "MULTICAST") +
+			/* We may waste one byte here...*/
+			IRLAN_STRING_PARAMETER_LEN("FILTER_MODE", "NONE"),
+			GFP_ATOMIC);
 	if (!skb)
 		return;
 	
@@ -856,7 +876,12 @@ static void irlan_get_unicast_addr(struc
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 	
-	skb = alloc_skb(128, GFP_ATOMIC);
+	skb = alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
+			IRLAN_BYTE_PARAMETER_LEN("DATA_CHAN") +
+			IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE", "DIRECTED") +
+			IRLAN_STRING_PARAMETER_LEN("FILTER_OPERATION",
+						   "DYNAMIC"),
+			GFP_ATOMIC);
 	if (!skb)
 		return;
 
@@ -891,7 +916,10 @@ void irlan_get_media_char(struct irlan_c
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 	
-	skb = alloc_skb(64, GFP_ATOMIC);
+	skb = alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
+			IRLAN_STRING_PARAMETER_LEN("MEDIA", "802.3"),
+			GFP_ATOMIC);
+
 	if (!skb)
 		return;
 
diff --git a/net/irda/irlan/irlan_provider.c b/net/irda/irlan/irlan_provider.c
index 9c0df86..58efde9 100644
--- a/net/irda/irlan/irlan_provider.c
+++ b/net/irda/irlan/irlan_provider.c
@@ -296,7 +296,14 @@ void irlan_provider_send_reply(struct ir
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
-	skb = alloc_skb(128, GFP_ATOMIC);
+	skb = alloc_skb(IRLAN_MAX_HEADER + IRLAN_CMD_HEADER +
+			/* Bigger param length comes from CMD_GET_MEDIA_CHAR */
+			IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE", "DIRECTED") +
+			IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE", "BORADCAST") +
+			IRLAN_STRING_PARAMETER_LEN("FILTER_TYPE", "MULTICAST") +
+			IRLAN_STRING_PARAMETER_LEN("ACCESS_TYPE", "HOSTED"),
+			GFP_ATOMIC);
+
 	if (!skb)
 		return;
 
@@ -354,8 +361,7 @@ void irlan_provider_send_reply(struct ir
 		} else
 			skb->data[1] = 0x02; /* 2 parameters */
 		irlan_insert_byte_param(skb, "DATA_CHAN", self->stsap_sel_data);
-		irlan_insert_array_param(skb, "RECONNECT_KEY", "LINUX RULES!",
-					 12);
+		irlan_insert_string_param(skb, "RECONNECT_KEY", "LINUX RULES!");
 		break;
 	case CMD_FILTER_OPERATION:
 		irlan_filter_request(self, skb);
diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index ccb983b..dba349c 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -117,7 +117,9 @@ void irlap_send_snrm_frame(struct irlap_
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	/* Allocate frame */
-	tx_skb = alloc_skb(64, GFP_ATOMIC);
+	tx_skb = alloc_skb(sizeof(struct snrm_frame) +
+			   IRLAP_NEGOCIATION_PARAMS_LEN,
+			   GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
@@ -136,7 +138,7 @@ void irlap_send_snrm_frame(struct irlap_
 	 *  If we are establishing a connection then insert QoS paramerters
 	 */
 	if (qos) {
-		skb_put(tx_skb, 9); /* 21 left */
+		skb_put(tx_skb, 9); /* 25 left */
 		frame->saddr = cpu_to_le32(self->saddr);
 		frame->daddr = cpu_to_le32(self->daddr);
 
@@ -210,7 +212,9 @@ void irlap_send_ua_response_frame(struct
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	/* Allocate frame */
-	tx_skb = alloc_skb(64, GFP_ATOMIC);
+	tx_skb = alloc_skb(sizeof(struct ua_frame) +
+			   IRLAP_NEGOCIATION_PARAMS_LEN,
+			   GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
@@ -245,23 +249,23 @@ void irlap_send_ua_response_frame(struct
 void irlap_send_dm_frame( struct irlap_cb *self)
 {
 	struct sk_buff *tx_skb = NULL;
-	__u8 *frame;
+	struct dm_frame *frame;
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
-	tx_skb = alloc_skb(32, GFP_ATOMIC);
+	tx_skb = alloc_skb(sizeof(struct dm_frame), GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
-	frame = skb_put(tx_skb, 2);
+	frame = (struct dm_frame *)skb_put(tx_skb, 2);
 
 	if (self->state == LAP_NDM)
-		frame[0] = CBROADCAST;
+		frame->caddr = CBROADCAST;
 	else
-		frame[0] = self->caddr;
+		frame->caddr = self->caddr;
 
-	frame[1] = DM_RSP | PF_BIT;
+	frame->control = DM_RSP | PF_BIT;
 
 	irlap_queue_xmit(self, tx_skb);
 }
@@ -275,21 +279,21 @@ void irlap_send_dm_frame( struct irlap_c
 void irlap_send_disc_frame(struct irlap_cb *self)
 {
 	struct sk_buff *tx_skb = NULL;
-	__u8 *frame;
+	struct disc_frame *frame;
 
 	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
-	tx_skb = alloc_skb(16, GFP_ATOMIC);
+	tx_skb = alloc_skb(sizeof(struct disc_frame), GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
-	frame = skb_put(tx_skb, 2);
+	frame = (struct disc_frame *)skb_put(tx_skb, 2);
 
-	frame[0] = self->caddr | CMD_FRAME;
-	frame[1] = DISC_CMD | PF_BIT;
+	frame->caddr = self->caddr | CMD_FRAME;
+	frame->control = DISC_CMD | PF_BIT;
 
 	irlap_queue_xmit(self, tx_skb);
 }
@@ -315,7 +319,8 @@ void irlap_send_discovery_xid_frame(stru
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 	IRDA_ASSERT(discovery != NULL, return;);
 
-	tx_skb = alloc_skb(64, GFP_ATOMIC);
+	tx_skb = alloc_skb(sizeof(struct xid_frame) + IRLAP_DISCOVERY_INFO_LEN,
+			   GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
@@ -573,18 +578,18 @@ static void irlap_recv_discovery_xid_cmd
 void irlap_send_rr_frame(struct irlap_cb *self, int command)
 {
 	struct sk_buff *tx_skb;
-	__u8 *frame;
+	struct rr_frame *frame;
 
-	tx_skb = alloc_skb(16, GFP_ATOMIC);
+	tx_skb = alloc_skb(sizeof(struct rr_frame), GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
-	frame = skb_put(tx_skb, 2);
+	frame = (struct rr_frame *)skb_put(tx_skb, 2);
 
-	frame[0] = self->caddr;
-	frame[0] |= (command) ? CMD_FRAME : 0;
+	frame->caddr = self->caddr;
+	frame->caddr |= (command) ? CMD_FRAME : 0;
 
-	frame[1] = RR | PF_BIT | (self->vr << 5);
+	frame->control = RR | PF_BIT | (self->vr << 5);
 
 	irlap_queue_xmit(self, tx_skb);
 }
@@ -598,16 +603,16 @@ void irlap_send_rr_frame(struct irlap_cb
 void irlap_send_rd_frame(struct irlap_cb *self)
 {
 	struct sk_buff *tx_skb;
-	__u8 *frame;
+	struct rd_frame *frame;
 
-	tx_skb = alloc_skb(16, GFP_ATOMIC);
+	tx_skb = alloc_skb(sizeof(struct rd_frame), GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
-	frame = skb_put(tx_skb, 2);
+	frame = (struct rd_frame *)skb_put(tx_skb, 2);
 
-	frame[0] = self->caddr;
-	frame[1] = RD_RSP | PF_BIT;
+	frame->caddr = self->caddr;
+	frame->caddr = RD_RSP | PF_BIT;
 
 	irlap_queue_xmit(self, tx_skb);
 }
@@ -1214,7 +1219,7 @@ void irlap_send_test_frame(struct irlap_
 	struct test_frame *frame;
 	__u8 *info;
 
-	tx_skb = alloc_skb(cmd->len+sizeof(struct test_frame), GFP_ATOMIC);
+	tx_skb = alloc_skb(cmd->len + sizeof(struct test_frame), GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
diff --git a/net/irda/irlmp.c b/net/irda/irlmp.c
index c440913..5073261 100644
--- a/net/irda/irlmp.c
+++ b/net/irda/irlmp.c
@@ -392,7 +392,7 @@ int irlmp_connect_request(struct lsap_cb
 
 	/* Any userdata? */
 	if (tx_skb == NULL) {
-		tx_skb = alloc_skb(64, GFP_ATOMIC);
+		tx_skb = alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
 		if (!tx_skb)
 			return -ENOMEM;
 
diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index 42acf1c..3c2e70b 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -804,12 +804,12 @@ static inline void irttp_give_credit(str
 		   self->send_credit, self->avail_credit, self->remote_credit);
 
 	/* Give credit to peer */
-	tx_skb = alloc_skb(64, GFP_ATOMIC);
+	tx_skb = alloc_skb(TTP_MAX_HEADER, GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
 	/* Reserve space for LMP, and LAP header */
-	skb_reserve(tx_skb, self->max_header_size);
+	skb_reserve(tx_skb, LMP_MAX_HEADER);
 
 	/*
 	 *  Since we can transmit and receive frames concurrently,
@@ -1093,7 +1093,8 @@ int irttp_connect_request(struct tsap_cb
 
 	/* Any userdata supplied? */
 	if (userdata == NULL) {
-		tx_skb = alloc_skb(64, GFP_ATOMIC);
+		tx_skb = alloc_skb(TTP_MAX_HEADER + TTP_SAR_HEADER,
+				   GFP_ATOMIC);
 		if (!tx_skb)
 			return -ENOMEM;
 
@@ -1341,7 +1342,8 @@ int irttp_connect_response(struct tsap_c
 
 	/* Any userdata supplied? */
 	if (userdata == NULL) {
-		tx_skb = alloc_skb(64, GFP_ATOMIC);
+		tx_skb = alloc_skb(TTP_MAX_HEADER + TTP_SAR_HEADER,
+				   GFP_ATOMIC);
 		if (!tx_skb)
 			return -ENOMEM;
 
@@ -1540,14 +1542,14 @@ int irttp_disconnect_request(struct tsap
 
 	if (!userdata) {
 		struct sk_buff *tx_skb;
-		tx_skb = alloc_skb(64, GFP_ATOMIC);
+		tx_skb = alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
 		if (!tx_skb)
 			return -ENOMEM;
 
 		/*
 		 *  Reserve space for MUX and LAP header
 		 */
-		skb_reserve(tx_skb, TTP_MAX_HEADER);
+		skb_reserve(tx_skb, LMP_MAX_HEADER);
 
 		userdata = tx_skb;
 	}
-- 
1.4.1.1

