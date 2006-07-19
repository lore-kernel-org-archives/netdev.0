From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH] [IrDA] Use alloc_skb() in IrDA TX path
Date: Wed, 19 Jul 2006 08:13:31 +0300
Message-ID: <20060719051331.GA3817@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	Christoph Hellwig <hch@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.pp.htv.fi ([213.243.153.36]:38588 "EHLO smtp3.pp.htv.fi")
	by vger.kernel.org with ESMTP id S932183AbWGRWB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 18:01:26 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

As pointed out by Christoph Hellwig, dev_alloc_skb() is not intended to be
used for allocating TX sk_buff. The IrDA stack was exclusively calling
dev_alloc_skb() on the TX path, and this patch fixes that.

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

---
 net/irda/af_irda.c              |    2 +-
 net/irda/ircomm/ircomm_lmp.c    |    4 ++--
 net/irda/ircomm/ircomm_param.c  |    2 +-
 net/irda/ircomm/ircomm_tty.c    |    5 +++--
 net/irda/iriap.c                |    9 +++++----
 net/irda/iriap_event.c          |    2 +-
 net/irda/irlan/irlan_common.c   |   16 ++++++++--------
 net/irda/irlan/irlan_provider.c |    2 +-
 net/irda/irlap.c                |    2 +-
 net/irda/irlap_frame.c          |   16 ++++++++--------
 net/irda/irlmp.c                |    2 +-
 net/irda/irttp.c                |   11 ++++++-----
 12 files changed, 38 insertions(+), 35 deletions(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 7fae48a..17699ee 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -308,7 +308,7 @@ static void irda_connect_response(struct
 
 	IRDA_ASSERT(self != NULL, return;);
 
-	skb = dev_alloc_skb(64);
+	skb = alloc_skb(64, GFP_ATOMIC);
 	if (skb == NULL) {
 		IRDA_DEBUG(0, "%s() Unable to allocate sk_buff!\n",
 			   __FUNCTION__);
diff --git a/net/irda/ircomm/ircomm_lmp.c b/net/irda/ircomm/ircomm_lmp.c
index d909720..959874b 100644
--- a/net/irda/ircomm/ircomm_lmp.c
+++ b/net/irda/ircomm/ircomm_lmp.c
@@ -81,7 +81,7 @@ static int ircomm_lmp_connect_response(s
 	
 	/* Any userdata supplied? */
 	if (userdata == NULL) {
-		tx_skb = dev_alloc_skb(64);
+		tx_skb = alloc_skb(64, GFP_ATOMIC);
 		if (!tx_skb)
 			return -ENOMEM;
 
@@ -115,7 +115,7 @@ static int ircomm_lmp_disconnect_request
 	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
 
         if (!userdata) {
-		tx_skb = dev_alloc_skb(64);
+		tx_skb = alloc_skb(64, GFP_ATOMIC);
 		if (!tx_skb)
 			return -ENOMEM;
 		
diff --git a/net/irda/ircomm/ircomm_param.c b/net/irda/ircomm/ircomm_param.c
index 6009bab..a39f573 100644
--- a/net/irda/ircomm/ircomm_param.c
+++ b/net/irda/ircomm/ircomm_param.c
@@ -121,7 +121,7 @@ int ircomm_param_request(struct ircomm_t
 
 	skb = self->ctrl_skb;	
 	if (!skb) {
-		skb = dev_alloc_skb(256);
+		skb = alloc_skb(256, GFP_ATOMIC);
 		if (!skb) {
 			spin_unlock_irqrestore(&self->spinlock, flags);
 			return -ENOMEM;
diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index b400f27..cde3b84 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -759,8 +759,9 @@ #endif
 			}
 		} else {
 			/* Prepare a full sized frame */
-			skb = dev_alloc_skb(self->max_data_size+
-					    self->max_header_size);
+			skb = alloc_skb(self->max_data_size+
+					self->max_header_size,
+					GFP_ATOMIC);
 			if (!skb) {
 				spin_unlock_irqrestore(&self->spinlock, flags);
 				return -ENOBUFS;
diff --git a/net/irda/iriap.c b/net/irda/iriap.c
index a047265..61128aa 100644
--- a/net/irda/iriap.c
+++ b/net/irda/iriap.c
@@ -345,7 +345,7 @@ static void iriap_disconnect_request(str
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
-	tx_skb = dev_alloc_skb(64);
+	tx_skb = alloc_skb(64, GFP_ATOMIC);
 	if (tx_skb == NULL) {
 		IRDA_DEBUG(0, "%s(), Could not allocate an sk_buff of length %d\n", 
 			__FUNCTION__, 64);
@@ -396,7 +396,7 @@ int iriap_getvaluebyclass_request(struct
 	attr_len = strlen(attr);	/* Up to IAS_MAX_ATTRIBNAME = 60 */
 
 	skb_len = self->max_header_size+2+name_len+1+attr_len+4;
-	tx_skb = dev_alloc_skb(skb_len);
+	tx_skb = alloc_skb(skb_len, GFP_ATOMIC);
 	if (!tx_skb)
 		return -ENOMEM;
 
@@ -562,7 +562,8 @@ static void iriap_getvaluebyclass_respon
 	 *  value. We add 32 bytes because of the 6 bytes for the frame and
 	 *  max 5 bytes for the value coding.
 	 */
-	tx_skb = dev_alloc_skb(value->len + self->max_header_size + 32);
+	tx_skb = alloc_skb(value->len + self->max_header_size + 32,
+			   GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
@@ -700,7 +701,7 @@ void iriap_send_ack(struct iriap_cb *sel
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
-	tx_skb = dev_alloc_skb(64);
+	tx_skb = alloc_skb(64, GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
diff --git a/net/irda/iriap_event.c b/net/irda/iriap_event.c
index a736074..da17395 100644
--- a/net/irda/iriap_event.c
+++ b/net/irda/iriap_event.c
@@ -365,7 +365,7 @@ static void state_r_disconnect(struct ir
 
 	switch (event) {
 	case IAP_LM_CONNECT_INDICATION:
-		tx_skb = dev_alloc_skb(64);
+		tx_skb = alloc_skb(64, GFP_ATOMIC);
 		if (tx_skb == NULL) {
 			IRDA_WARNING("%s: unable to malloc!\n", __FUNCTION__);
 			return;
diff --git a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
index bd659dd..7dd0a2f 100644
--- a/net/irda/irlan/irlan_common.c
+++ b/net/irda/irlan/irlan_common.c
@@ -636,7 +636,7 @@ void irlan_get_provider_info(struct irla
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
-	skb = dev_alloc_skb(64);
+	skb = alloc_skb(64, GFP_ATOMIC);
 	if (!skb)
 		return;
 
@@ -668,7 +668,7 @@ void irlan_open_data_channel(struct irla
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 	
-	skb = dev_alloc_skb(64);
+	skb = alloc_skb(64, GFP_ATOMIC);
 	if (!skb)
 		return;
 
@@ -704,7 +704,7 @@ void irlan_close_data_channel(struct irl
 	if (self->client.tsap_ctrl == NULL)
 		return;
 
-	skb = dev_alloc_skb(64);
+	skb = alloc_skb(64, GFP_ATOMIC);
 	if (!skb)
 		return;
 
@@ -739,7 +739,7 @@ static void irlan_open_unicast_addr(stru
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);	
 	
-	skb = dev_alloc_skb(128);
+	skb = alloc_skb(128, GFP_ATOMIC);
 	if (!skb)
 		return;
 
@@ -777,7 +777,7 @@ void irlan_set_broadcast_filter(struct i
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 	
- 	skb = dev_alloc_skb(128);
+ 	skb = alloc_skb(128, GFP_ATOMIC);
 	if (!skb)
 		return;
 
@@ -816,7 +816,7 @@ void irlan_set_multicast_filter(struct i
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
- 	skb = dev_alloc_skb(128);
+ 	skb = alloc_skb(128, GFP_ATOMIC);
 	if (!skb)
 		return;
 	
@@ -856,7 +856,7 @@ static void irlan_get_unicast_addr(struc
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 	
-	skb = dev_alloc_skb(128);
+	skb = alloc_skb(128, GFP_ATOMIC);
 	if (!skb)
 		return;
 
@@ -891,7 +891,7 @@ void irlan_get_media_char(struct irlan_c
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 	
-	skb = dev_alloc_skb(64);
+	skb = alloc_skb(64, GFP_ATOMIC);
 	if (!skb)
 		return;
 
diff --git a/net/irda/irlan/irlan_provider.c b/net/irda/irlan/irlan_provider.c
index 39c202d..9c0df86 100644
--- a/net/irda/irlan/irlan_provider.c
+++ b/net/irda/irlan/irlan_provider.c
@@ -296,7 +296,7 @@ void irlan_provider_send_reply(struct ir
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
-	skb = dev_alloc_skb(128);
+	skb = alloc_skb(128, GFP_ATOMIC);
 	if (!skb)
 		return;
 
diff --git a/net/irda/irlap.c b/net/irda/irlap.c
index cade355..9199c12 100644
--- a/net/irda/irlap.c
+++ b/net/irda/irlap.c
@@ -882,7 +882,7 @@ static void irlap_change_speed(struct ir
 	/* Change speed now, or just piggyback speed on frames */
 	if (now) {
 		/* Send down empty frame to trigger speed change */
-		skb = dev_alloc_skb(0);
+		skb = alloc_skb(0, GFP_ATOMIC);
 		if (skb)
 			irlap_queue_xmit(self, skb);
 	}
diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index 3e9a06a..fa5c144 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -117,7 +117,7 @@ void irlap_send_snrm_frame(struct irlap_
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	/* Allocate frame */
-	tx_skb = dev_alloc_skb(64);
+	tx_skb = alloc_skb(64, GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
@@ -210,7 +210,7 @@ void irlap_send_ua_response_frame(struct
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	/* Allocate frame */
-	tx_skb = dev_alloc_skb(64);
+	tx_skb = alloc_skb(64, GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
@@ -250,7 +250,7 @@ void irlap_send_dm_frame( struct irlap_c
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
-	tx_skb = dev_alloc_skb(32);
+	tx_skb = alloc_skb(32, GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
@@ -282,7 +282,7 @@ void irlap_send_disc_frame(struct irlap_
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
-	tx_skb = dev_alloc_skb(16);
+	tx_skb = alloc_skb(16, GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
@@ -315,7 +315,7 @@ void irlap_send_discovery_xid_frame(stru
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 	IRDA_ASSERT(discovery != NULL, return;);
 
-	tx_skb = dev_alloc_skb(64);
+	tx_skb = alloc_skb(64, GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
@@ -576,7 +576,7 @@ void irlap_send_rr_frame(struct irlap_cb
 	struct sk_buff *tx_skb;
 	__u8 *frame;
 
-	tx_skb = dev_alloc_skb(16);
+	tx_skb = alloc_skb(16, GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
@@ -601,7 +601,7 @@ void irlap_send_rd_frame(struct irlap_cb
 	struct sk_buff *tx_skb;
 	__u8 *frame;
 
-	tx_skb = dev_alloc_skb(16);
+	tx_skb = alloc_skb(16, GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
@@ -1215,7 +1215,7 @@ void irlap_send_test_frame(struct irlap_
 	struct test_frame *frame;
 	__u8 *info;
 
-	tx_skb = dev_alloc_skb(cmd->len+sizeof(struct test_frame));
+	tx_skb = alloc_skb(cmd->len+sizeof(struct test_frame), GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
diff --git a/net/irda/irlmp.c b/net/irda/irlmp.c
index 129ad64..5ee7946 100644
--- a/net/irda/irlmp.c
+++ b/net/irda/irlmp.c
@@ -395,7 +395,7 @@ int irlmp_connect_request(struct lsap_cb
 
 	/* Any userdata? */
 	if (tx_skb == NULL) {
-		tx_skb = dev_alloc_skb(64);
+		tx_skb = alloc_skb(64, GFP_ATOMIC);
 		if (!tx_skb)
 			return -ENOMEM;
 
diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index 49c51c5..7a3ccb8 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -306,7 +306,8 @@ static inline void irttp_fragment_skb(st
 		IRDA_DEBUG(2, "%s(), fragmenting ...\n", __FUNCTION__);
 
 		/* Make new segment */
-		frag = dev_alloc_skb(self->max_seg_size+self->max_header_size);
+		frag = alloc_skb(self->max_seg_size+self->max_header_size,
+				 GFP_ATOMIC);
 		if (!frag)
 			return;
 
@@ -805,7 +806,7 @@ static inline void irttp_give_credit(str
 		   self->send_credit, self->avail_credit, self->remote_credit);
 
 	/* Give credit to peer */
-	tx_skb = dev_alloc_skb(64);
+	tx_skb = alloc_skb(64, GFP_ATOMIC);
 	if (!tx_skb)
 		return;
 
@@ -1094,7 +1095,7 @@ int irttp_connect_request(struct tsap_cb
 
 	/* Any userdata supplied? */
 	if (userdata == NULL) {
-		tx_skb = dev_alloc_skb(64);
+		tx_skb = alloc_skb(64, GFP_ATOMIC);
 		if (!tx_skb)
 			return -ENOMEM;
 
@@ -1342,7 +1343,7 @@ int irttp_connect_response(struct tsap_c
 
 	/* Any userdata supplied? */
 	if (userdata == NULL) {
-		tx_skb = dev_alloc_skb(64);
+		tx_skb = alloc_skb(64, GFP_ATOMIC);
 		if (!tx_skb)
 			return -ENOMEM;
 
@@ -1541,7 +1542,7 @@ int irttp_disconnect_request(struct tsap
 
 	if (!userdata) {
 		struct sk_buff *tx_skb;
-		tx_skb = dev_alloc_skb(64);
+		tx_skb = alloc_skb(64, GFP_ATOMIC);
 		if (!tx_skb)
 			return -ENOMEM;
 
-- 
1.4.0
