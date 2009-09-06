From: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
Subject: [PATCH 10/12] gigaset: prepare for CAPI implementation
Date: Sun,  6 Sep 2009 20:58:52 +0200 (CEST)
Message-ID: <20090906-patch-gigaset-10.tilman@imap.cc>
References: <20090906-patch-gigaset-00.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Hansjoerg Lipp <hjlipp-S0/GAf8tV78@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
Return-path: <i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
In-Reply-To: <20090906-patch-gigaset-00.tilman-ZTO5kqT2PaM@public.gmane.org>
List-Unsubscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.isdn4linux.de/pipermail/i4ldeveloper>
List-Post: <mailto:i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
List-Help: <mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=help>
List-Subscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=subscribe>
Sender: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
Errors-To: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
List-Id: netdev.vger.kernel.org

Reorganize the code of the Gigaset driver, moving all isdn4linux
dependencies to the source file i4l.c so that it can be replaced
by a file capi.c interfacing to Kernel CAPI instead.

Impact: refactoring, no functional change
Signed-off-by: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
---
 drivers/isdn/gigaset/asyncdata.c   |  109 ++++-----
 drivers/isdn/gigaset/bas-gigaset.c |    4 +-
 drivers/isdn/gigaset/common.c      |   42 ++--
 drivers/isdn/gigaset/ev-layer.c    |   63 +++--
 drivers/isdn/gigaset/gigaset.h     |   90 ++-----
 drivers/isdn/gigaset/i4l.c         |  499 +++++++++++++++++++++---------------
 drivers/isdn/gigaset/isocdata.c    |   80 +++---
 7 files changed, 469 insertions(+), 418 deletions(-)

diff --git a/drivers/isdn/gigaset/asyncdata.c b/drivers/isdn/gigaset/asyncdata.c
index 44a58e6..5cadbd2 100644
--- a/drivers/isdn/gigaset/asyncdata.c
+++ b/drivers/isdn/gigaset/asyncdata.c
@@ -119,8 +119,6 @@ static inline int hdlc_loop(unsigned char c, unsigned char *src, int numbytes,
 	int inputstate = bcs->inputstate;
 	__u16 fcs = bcs->fcs;
 	struct sk_buff *skb = bcs->skb;
-	unsigned char error;
-	struct sk_buff *compskb;
 	int startbytes = numbytes;
 	int l;
 
@@ -158,8 +156,8 @@ byte_stuff:
 #endif
 
 				/* end of frame */
-				error = 1;
-				gigaset_rcv_error(NULL, cs, bcs);
+				gigaset_isdn_rcv_err(bcs);
+				dev_kfree_skb(skb);
 			} else if (!(inputstate & INS_have_data)) { /* 7E 7E */
 #ifdef CONFIG_GIGASET_DEBUG
 				++bcs->emptycount;
@@ -170,50 +168,34 @@ byte_stuff:
 					"7e----------------------------");
 
 				/* end of frame */
-				error = 0;
-
 				if (unlikely(fcs != PPP_GOODFCS)) {
 					dev_err(cs->dev,
 				"Checksum failed, %u bytes corrupted!\n",
 						skb->len);
-					compskb = NULL;
-					gigaset_rcv_error(compskb, cs, bcs);
-					error = 1;
+					gigaset_isdn_rcv_err(bcs);
+					dev_kfree_skb(skb);
+				} else if (likely((l = skb->len) > 2)) {
+					__skb_trim(skb, l-2);
+					gigaset_skb_rcvd(bcs, skb);
 				} else {
-					if (likely((l = skb->len) > 2)) {
-						skb->tail -= 2;
-						skb->len -= 2;
-					} else {
-						dev_kfree_skb(skb);
-						skb = NULL;
-						inputstate |= INS_skip_frame;
-						if (l == 1) {
-							dev_err(cs->dev,
-						  "invalid packet size (1)!\n");
-							error = 1;
-							gigaset_rcv_error(NULL,
-								cs, bcs);
-						}
-					}
-					if (likely(!(error ||
-						     (inputstate &
-						      INS_skip_frame)))) {
-						gigaset_rcv_skb(skb, cs, bcs);
+					if (l) {
+						dev_err(cs->dev,
+					"invalid packet size (%d)\n", l);
+						gigaset_isdn_rcv_err(bcs);
 					}
+					dev_kfree_skb(skb);
 				}
 			}
 
-			if (unlikely(error))
-				if (skb)
-					dev_kfree_skb(skb);
-
 			fcs = PPP_INITFCS;
 			inputstate &= ~(INS_have_data | INS_skip_frame);
 			if (unlikely(bcs->ignore)) {
 				inputstate |= INS_skip_frame;
 				skb = NULL;
-			} else if (likely((skb = dev_alloc_skb(SBUFSIZE + HW_HDR_LEN)) != NULL)) {
-				skb_reserve(skb, HW_HDR_LEN);
+			} else if ((skb =
+				    dev_alloc_skb(SBUFSIZE + cs->hw_hdr_len))
+				   != NULL) {
+				skb_reserve(skb, cs->hw_hdr_len);
 			} else {
 				dev_warn(cs->dev,
 					 "could not allocate new skb\n");
@@ -314,15 +296,15 @@ static inline int iraw_loop(unsigned char c, unsigned char *src, int numbytes,
 	/* pass data up */
 	if (likely(inputstate & INS_have_data)) {
 		if (likely(!(inputstate & INS_skip_frame))) {
-			gigaset_rcv_skb(skb, cs, bcs);
+			gigaset_skb_rcvd(bcs, skb);
 		}
 		inputstate &= ~(INS_have_data | INS_skip_frame);
 		if (unlikely(bcs->ignore)) {
 			inputstate |= INS_skip_frame;
 			skb = NULL;
-		} else if (likely((skb = dev_alloc_skb(SBUFSIZE + HW_HDR_LEN))
-				  != NULL)) {
-			skb_reserve(skb, HW_HDR_LEN);
+		} else if ((skb = dev_alloc_skb(SBUFSIZE + cs->hw_hdr_len))
+			   != NULL) {
+			skb_reserve(skb, cs->hw_hdr_len);
 		} else {
 			dev_warn(cs->dev, "could not allocate new skb\n");
 			inputstate |= INS_skip_frame;
@@ -383,7 +365,7 @@ void gigaset_m10x_input(struct inbuf_t *inbuf)
 					/* FIXME use function pointers?  */
 					if (inbuf->inputstate & INS_command)
 						procbytes = cmd_loop(c, src, numbytes, inbuf);
-					else if (inbuf->bcs->proto2 == ISDN_PROTO_L2_HDLC)
+					else if (inbuf->bcs->proto2 == L2_HDLC)
 						procbytes = hdlc_loop(c, src, numbytes, inbuf);
 					else
 						procbytes = iraw_loop(c, src, numbytes, inbuf);
@@ -440,16 +422,16 @@ EXPORT_SYMBOL_GPL(gigaset_m10x_input);
 
 /* == data output ========================================================== */
 
-/* Encoding of a PPP packet into an octet stuffed HDLC frame
- * with FCS, opening and closing flags.
+/*
+ * Encode a data packet into an octet stuffed HDLC frame with FCS,
+ * opening and closing flags, preserving headroom data.
  * parameters:
- *	skb	skb containing original packet (freed upon return)
- *	head	number of headroom bytes to allocate in result skb
- *	tail	number of tailroom bytes to allocate in result skb
+ *	skb		skb containing original packet (freed upon return)
+ *	headroom	number of headroom bytes to preserve
  * Return value:
  *	pointer to newly allocated skb containing the result frame
  */
-static struct sk_buff *HDLC_Encode(struct sk_buff *skb, int head, int tail)
+static struct sk_buff *HDLC_Encode(struct sk_buff *skb, int headroom)
 {
 	struct sk_buff *hdlc_skb;
 	__u16 fcs;
@@ -471,16 +453,17 @@ static struct sk_buff *HDLC_Encode(struct sk_buff *skb, int head, int tail)
 
 	/* size of new buffer: original size + number of stuffing bytes
 	 * + 2 bytes FCS + 2 stuffing bytes for FCS (if needed) + 2 flag bytes
+	 * + room for acknowledgement header
 	 */
-	hdlc_skb = dev_alloc_skb(skb->len + stuf_cnt + 6 + tail + head);
+	hdlc_skb = dev_alloc_skb(skb->len + stuf_cnt + 6 + headroom);
 	if (!hdlc_skb) {
 		dev_kfree_skb(skb);
 		return NULL;
 	}
-	skb_reserve(hdlc_skb, head);
 
-	/* Copy acknowledge request into new skb */
-	memcpy(hdlc_skb->head, skb->head, 2);
+	/* Copy acknowledgement header into new skb */
+	skb_reserve(hdlc_skb, headroom);
+	memcpy(hdlc_skb->head, skb->head, headroom);
 
 	/* Add flag sequence in front of everything.. */
 	*(skb_put(hdlc_skb, 1)) = PPP_FLAG;
@@ -515,15 +498,16 @@ static struct sk_buff *HDLC_Encode(struct sk_buff *skb, int head, int tail)
 	return hdlc_skb;
 }
 
-/* Encoding of a raw packet into an octet stuffed bit inverted frame
+/*
+ * Encode a data packet into an octet stuffed raw bit inverted frame,
+ * preserving headroom data.
  * parameters:
- *	skb	skb containing original packet (freed upon return)
- *	head	number of headroom bytes to allocate in result skb
- *	tail	number of tailroom bytes to allocate in result skb
+ *	skb		skb containing original packet (freed upon return)
+ *	headroom	number of headroom bytes to preserve
  * Return value:
  *	pointer to newly allocated skb containing the result frame
  */
-static struct sk_buff *iraw_encode(struct sk_buff *skb, int head, int tail)
+static struct sk_buff *iraw_encode(struct sk_buff *skb, int headroom)
 {
 	struct sk_buff *iraw_skb;
 	unsigned char c;
@@ -531,12 +515,15 @@ static struct sk_buff *iraw_encode(struct sk_buff *skb, int head, int tail)
 	int len;
 
 	/* worst case: every byte must be stuffed */
-	iraw_skb = dev_alloc_skb(2*skb->len + tail + head);
+	iraw_skb = dev_alloc_skb(2*skb->len + headroom);
 	if (!iraw_skb) {
 		dev_kfree_skb(skb);
 		return NULL;
 	}
-	skb_reserve(iraw_skb, head);
+
+	/* Copy acknowledgement header into new skb */
+	skb_reserve(iraw_skb, headroom);
+	memcpy(iraw_skb->head, skb->head, headroom);
 
 	cp = skb->data;
 	len = skb->len;
@@ -555,8 +542,10 @@ static struct sk_buff *iraw_encode(struct sk_buff *skb, int head, int tail)
  * @bcs:	B channel descriptor structure.
  * @skb:	data to send.
  *
- * Called by i4l.c to encode and queue an skb for sending, and start
+ * Called by LL to encode and queue an skb for sending, and start
  * transmission if necessary.
+ * Once the payload data has been transmitted completely, gigaset_skb_sent()
+ * will be called with the first cs->hw_hdr_len bytes of skb->head preserved.
  *
  * Return value:
  *	number of bytes accepted for sending (skb->len) if ok,
@@ -567,10 +556,10 @@ int gigaset_m10x_send_skb(struct bc_state *bcs, struct sk_buff *skb)
 	unsigned len = skb->len;
 	unsigned long flags;
 
-	if (bcs->proto2 == ISDN_PROTO_L2_HDLC)
-		skb = HDLC_Encode(skb, HW_HDR_LEN, 0);
+	if (bcs->proto2 == L2_HDLC)
+		skb = HDLC_Encode(skb, bcs->cs->hw_hdr_len);
 	else
-		skb = iraw_encode(skb, HW_HDR_LEN, 0);
+		skb = iraw_encode(skb, bcs->cs->hw_hdr_len);
 	if (!skb) {
 		dev_err(bcs->cs->dev,
 			"unable to allocate memory for encoding!\n");
diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 44bcfd9..84e107b 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -911,7 +911,7 @@ static int starturbs(struct bc_state *bcs)
 	int rc;
 
 	/* initialize L2 reception */
-	if (bcs->proto2 == ISDN_PROTO_L2_HDLC)
+	if (bcs->proto2 == L2_HDLC)
 		bcs->inputstate |= INS_flag_hunt;
 
 	/* submit all isochronous input URBs */
@@ -1064,7 +1064,7 @@ static int submit_iso_write_urb(struct isow_urbctx_t *ucx)
 					"%s: buffer busy at frame %d",
 					__func__, nframe);
 				/* tasklet will be restarted from
-				   gigaset_send_skb() */
+				   gigaset_isoc_send_skb() */
 			} else {
 				dev_err(ucx->bcs->cs->dev,
 					"%s: buffer error %d at frame %d\n",
diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 33dcd8d..a2847c2 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -463,6 +463,12 @@ void gigaset_freecs(struct cardstate *cs)
 
 	switch (cs->cs_init) {
 	default:
+		/* clear B channel structures */
+		for (i = 0; i < cs->channels; ++i) {
+			gig_dbg(DEBUG_INIT, "clearing bcs[%d]", i);
+			gigaset_freebcs(cs->bcs + i);
+		}
+
 		/* clear device sysfs */
 		gigaset_free_dev_sysfs(cs);
 
@@ -477,22 +483,16 @@ void gigaset_freecs(struct cardstate *cs)
 	case 2: /* error in initcshw */
 		/* Deregister from LL */
 		make_invalid(cs, VALID_ID);
-		gig_dbg(DEBUG_INIT, "clearing iif");
-		gigaset_i4l_cmd(cs, ISDN_STAT_UNLOAD);
+		gigaset_isdn_unregister(cs);
 
 		/* fall through */
-	case 1: /* error when regestering to LL */
+	case 1: /* error when registering to LL */
 		gig_dbg(DEBUG_INIT, "clearing at_state");
 		clear_at_state(&cs->at_state);
 		dealloc_at_states(cs);
 
 		/* fall through */
-	case 0: /* error in one call to initbcs */
-		for (i = 0; i < cs->channels; ++i) {
-			gig_dbg(DEBUG_INIT, "clearing bcs[%d]", i);
-			gigaset_freebcs(cs->bcs + i);
-		}
-
+	case 0:	/* error in basic setup */
 		clear_events(cs);
 		gig_dbg(DEBUG_INIT, "freeing inbuf");
 		kfree(cs->inbuf);
@@ -620,8 +620,9 @@ static struct bc_state *gigaset_initbcs(struct bc_state *bcs,
 	if (cs->ignoreframes) {
 		bcs->inputstate |= INS_skip_frame;
 		bcs->skb = NULL;
-	} else if ((bcs->skb = dev_alloc_skb(SBUFSIZE + HW_HDR_LEN)) != NULL)
-		skb_reserve(bcs->skb, HW_HDR_LEN);
+	} else if ((bcs->skb = dev_alloc_skb(SBUFSIZE + cs->hw_hdr_len))
+		   != NULL)
+		skb_reserve(bcs->skb, cs->hw_hdr_len);
 	else {
 		pr_err("out of memory\n");
 		bcs->inputstate |= INS_skip_frame;
@@ -726,14 +727,6 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 	cs->mode = M_UNKNOWN;
 	cs->mstate = MS_UNINITIALIZED;
 
-	for (i = 0; i < channels; ++i) {
-		gig_dbg(DEBUG_INIT, "setting up bcs[%d].read", i);
-		if (!gigaset_initbcs(cs->bcs + i, cs, i)) {
-			pr_err("could not allocate channel %d data\n", i);
-			goto error;
-		}
-	}
-
 	++cs->cs_init;
 
 	gig_dbg(DEBUG_INIT, "setting up at_state");
@@ -758,7 +751,7 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 	cs->cmdbytes = 0;
 
 	gig_dbg(DEBUG_INIT, "setting up iif");
-	if (!gigaset_register_to_LL(cs, modulename)) {
+	if (!gigaset_isdn_register(cs, modulename)) {
 		pr_err("error registering ISDN device\n");
 		goto error;
 	}
@@ -777,6 +770,15 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 	/* set up device sysfs */
 	gigaset_init_dev_sysfs(cs);
 
+	/* set up channel data structures */
+	for (i = 0; i < channels; ++i) {
+		gig_dbg(DEBUG_INIT, "setting up bcs[%d]", i);
+		if (!gigaset_initbcs(cs->bcs + i, cs, i)) {
+			pr_err("could not allocate channel %d data\n", i);
+			goto error;
+		}
+	}
+
 	spin_lock_irqsave(&cs->lock, flags);
 	cs->running = 1;
 	spin_unlock_irqrestore(&cs->lock, flags);
diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index c12f6fd..950afd4 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -127,7 +127,6 @@
 #define ACT_NOTIFY_BC_UP	39
 #define ACT_DIAL		40
 #define ACT_ACCEPT		41
-#define ACT_PROTO_L2		42
 #define ACT_HUP			43
 #define ACT_IF_LOCK		44
 #define ACT_START		45
@@ -365,8 +364,6 @@ struct reply_t gigaset_tab_cid[] =
 	{EV_BC_CLOSED, -1, -1, -1,                 -1,-1, {ACT_NOTIFY_BC_DOWN}}, //FIXME
 
 	/* misc. */
-	{EV_PROTO_L2,  -1, -1, -1,                 -1,-1, {ACT_PROTO_L2}}, //FIXME
-
 	{RSP_ZCON,     -1, -1, -1,                 -1,-1, {ACT_DEBUG}}, //FIXME
 	{RSP_ZCCR,     -1, -1, -1,                 -1,-1, {ACT_DEBUG}}, //FIXME
 	{RSP_ZAOC,     -1, -1, -1,                 -1,-1, {ACT_DEBUG}}, //FIXME
@@ -714,7 +711,7 @@ static void disconnect(struct at_state_t **at_state_p)
 		/* notify LL */
 		if (bcs->chstate & (CHS_D_UP | CHS_NOTIFY_LL)) {
 			bcs->chstate &= ~(CHS_D_UP | CHS_NOTIFY_LL);
-			gigaset_i4l_channel_cmd(bcs, ISDN_STAT_DHUP);
+			gigaset_isdn_hupD(bcs);
 		}
 	} else {
 		/* no B channel assigned: just deallocate */
@@ -872,12 +869,12 @@ static void bchannel_down(struct bc_state *bcs)
 {
 	if (bcs->chstate & CHS_B_UP) {
 		bcs->chstate &= ~CHS_B_UP;
-		gigaset_i4l_channel_cmd(bcs, ISDN_STAT_BHUP);
+		gigaset_isdn_hupB(bcs);
 	}
 
 	if (bcs->chstate & (CHS_D_UP | CHS_NOTIFY_LL)) {
 		bcs->chstate &= ~(CHS_D_UP | CHS_NOTIFY_LL);
-		gigaset_i4l_channel_cmd(bcs, ISDN_STAT_DHUP);
+		gigaset_isdn_hupD(bcs);
 	}
 
 	gigaset_free_channel(bcs);
@@ -894,15 +891,16 @@ static void bchannel_up(struct bc_state *bcs)
 	}
 
 	bcs->chstate |= CHS_B_UP;
-	gigaset_i4l_channel_cmd(bcs, ISDN_STAT_BCONN);
+	gigaset_isdn_connB(bcs);
 }
 
 static void start_dial(struct at_state_t *at_state, void *data, unsigned seq_index)
 {
 	struct bc_state *bcs = at_state->bcs;
 	struct cardstate *cs = at_state->cs;
-	int retval;
+	char **commands = data;
 	unsigned long flags;
+	int i;
 
 	bcs->chstate |= CHS_NOTIFY_LL;
 
@@ -913,10 +911,10 @@ static void start_dial(struct at_state_t *at_state, void *data, unsigned seq_ind
 	}
 	spin_unlock_irqrestore(&cs->lock, flags);
 
-	retval = gigaset_isdn_setup_dial(at_state, data);
-	if (retval != 0)
-		goto error;
-
+	for (i = 0; i < AT_NUM; ++i) {
+		kfree(bcs->commands[i]);
+		bcs->commands[i] = commands[i];
+	}
 
 	at_state->pending_commands |= PC_CID;
 	gig_dbg(DEBUG_CMD, "Scheduling PC_CID");
@@ -924,6 +922,10 @@ static void start_dial(struct at_state_t *at_state, void *data, unsigned seq_ind
 	return;
 
 error:
+	for (i = 0; i < AT_NUM; ++i) {
+		kfree(commands[i]);
+		commands[i] = NULL;
+	}
 	at_state->pending_commands |= PC_NOCID;
 	gig_dbg(DEBUG_CMD, "Scheduling PC_NOCID");
 	cs->commands_pending = 1;
@@ -933,20 +935,30 @@ error:
 static void start_accept(struct at_state_t *at_state)
 {
 	struct cardstate *cs = at_state->cs;
-	int retval;
+	struct bc_state *bcs = at_state->bcs;
+	int i;
 
-	retval = gigaset_isdn_setup_accept(at_state);
+	for (i = 0; i < AT_NUM; ++i) {
+		kfree(bcs->commands[i]);
+		bcs->commands[i] = NULL;
+	}
 
-	if (retval == 0) {
-		at_state->pending_commands |= PC_ACCEPT;
-		gig_dbg(DEBUG_CMD, "Scheduling PC_ACCEPT");
-		cs->commands_pending = 1;
-	} else {
+	if (!(bcs->commands[AT_PROTO] = kmalloc(9, GFP_ATOMIC)) ||
+	    !(bcs->commands[AT_ISO  ] = kmalloc(9, GFP_ATOMIC))) {
+		dev_err(at_state->cs->dev, "out of memory\n");
 		/* error reset */
 		at_state->pending_commands |= PC_HUP;
 		gig_dbg(DEBUG_CMD, "Scheduling PC_HUP");
 		cs->commands_pending = 1;
+		return;
 	}
+
+	snprintf(bcs->commands[AT_PROTO], 9, "^SBPR=%u\r", bcs->proto2);
+	snprintf(bcs->commands[AT_ISO  ], 9, "^SISO=%u\r", bcs->channel + 1);
+
+	at_state->pending_commands |= PC_ACCEPT;
+	gig_dbg(DEBUG_CMD, "Scheduling PC_ACCEPT");
+	cs->commands_pending = 1;
 }
 
 static void do_start(struct cardstate *cs)
@@ -957,7 +969,7 @@ static void do_start(struct cardstate *cs)
 		schedule_init(cs, MS_INIT);
 
 	cs->isdn_up = 1;
-	gigaset_i4l_cmd(cs, ISDN_STAT_RUN);
+	gigaset_isdn_start(cs);
 					// FIXME: not in locked mode
 					// FIXME 2: only after init sequence
 
@@ -975,7 +987,7 @@ static void finish_shutdown(struct cardstate *cs)
 	/* Tell the LL that the device is not available .. */
 	if (cs->isdn_up) {
 		cs->isdn_up = 0;
-		gigaset_i4l_cmd(cs, ISDN_STAT_STOP);
+		gigaset_isdn_stop(cs);
 	}
 
 	/* The rest is done by cleanup_cs () in user mode. */
@@ -1276,7 +1288,7 @@ static void do_action(int action, struct cardstate *cs,
 			break;
 		}
 		bcs->chstate |= CHS_D_UP;
-		gigaset_i4l_channel_cmd(bcs, ISDN_STAT_DCONN);
+		gigaset_isdn_connD(bcs);
 		cs->ops->init_bchannel(bcs);
 		break;
 	case ACT_DLE1:
@@ -1284,7 +1296,7 @@ static void do_action(int action, struct cardstate *cs,
 		bcs = cs->bcs + cs->curchannel;
 
 		bcs->chstate |= CHS_D_UP;
-		gigaset_i4l_channel_cmd(bcs, ISDN_STAT_DCONN);
+		gigaset_isdn_connD(bcs);
 		cs->ops->init_bchannel(bcs);
 		break;
 	case ACT_FAKEHUP:
@@ -1474,11 +1486,6 @@ static void do_action(int action, struct cardstate *cs,
 	case ACT_ACCEPT:
 		start_accept(at_state);
 		break;
-	case ACT_PROTO_L2:
-		gig_dbg(DEBUG_CMD, "set protocol to %u",
-			(unsigned) ev->parameter);
-		at_state->bcs->proto2 = ev->parameter;
-		break;
 	case ACT_HUP:
 		at_state->pending_commands |= PC_HUP;
 		cs->commands_pending = 1;
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index a2f6125..1185da2 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -23,7 +23,6 @@
 #include <linux/compiler.h>
 #include <linux/types.h>
 #include <linux/spinlock.h>
-#include <linux/isdnif.h>
 #include <linux/usb.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
@@ -40,7 +39,6 @@
 
 #define MAX_REC_PARAMS 10	/* Max. number of params in response string */
 #define MAX_RESP_SIZE 512	/* Max. size of a response string */
-#define HW_HDR_LEN 2		/* Header size used to store ack info */
 
 #define MAX_EVENTS 64		/* size of event queue */
 
@@ -216,7 +214,6 @@ void gigaset_dbg_buffer(enum debuglevel level, const unsigned char *msg,
 #define EV_START	-110
 #define EV_STOP		-111
 #define EV_IF_LOCK	-112
-#define EV_PROTO_L2	-113
 #define EV_ACCEPT	-114
 #define EV_DIAL		-115
 #define EV_HUP		-116
@@ -259,6 +256,11 @@ void gigaset_dbg_buffer(enum debuglevel level, const unsigned char *msg,
 #define SM_LOCKED	0
 #define SM_ISDN		1 /* default */
 
+/* layer 2 protocols (AT^SBPR=...) */
+#define L2_BITSYNC	0
+#define L2_HDLC		1
+#define L2_VOICE	2
+
 struct gigaset_ops;
 struct gigaset_driver;
 
@@ -395,7 +397,7 @@ struct bc_state {
 
 	unsigned chstate;		/* bitmap (CHS_*) */
 	int ignore;
-	unsigned proto2;		/* Layer 2 protocol (ISDN_PROTO_L2_*) */
+	unsigned proto2;		/* layer 2 protocol (L2_*) */
 	char *commands[AT_NUM];		/* see AT_XXXX */
 
 #ifdef CONFIG_GIGASET_DEBUG
@@ -456,12 +458,13 @@ struct cardstate {
 
 	unsigned running;		/* !=0 if events are handled */
 	unsigned connected;		/* !=0 if hardware is connected */
-	unsigned isdn_up;		/* !=0 after ISDN_STAT_RUN */
+	unsigned isdn_up;		/* !=0 after gigaset_isdn_start() */
 
 	unsigned cidmode;
 
 	int myid;			/* id for communication with LL */
-	isdn_if iif;
+	void *iif;			/* LL interface structure */
+	unsigned short hw_hdr_len;	/* headroom needed in data skbs */
 
 	struct reply_t *tabnocid;
 	struct reply_t *tabcid;
@@ -616,7 +619,9 @@ struct gigaset_ops {
 	int (*baud_rate)(struct cardstate *cs, unsigned cflag);
 	int (*set_line_ctrl)(struct cardstate *cs, unsigned cflag);
 
-	/* Called from i4l.c to put an skb into the send-queue. */
+	/* Called from LL interface to put an skb into the send-queue.
+	 * After sending is completed, gigaset_skb_sent() must be called
+	 * with the first cs->hw_hdr_len bytes of skb->head preserved. */
 	int (*send_skb)(struct bc_state *bcs, struct sk_buff *skb);
 
 	/* Called from ev-layer.c to process a block of data
@@ -638,8 +643,7 @@ struct gigaset_ops {
  *  Functions implemented in asyncdata.c
  */
 
-/* Called from i4l.c to put an skb into the send-queue.
- * After sending gigaset_skb_sent() should be called. */
+/* Called from LL interface to put an skb into the send queue. */
 int gigaset_m10x_send_skb(struct bc_state *bcs, struct sk_buff *skb);
 
 /* Called from ev-layer.c to process a block of data
@@ -650,8 +654,7 @@ void gigaset_m10x_input(struct inbuf_t *inbuf);
  *  Functions implemented in isocdata.c
  */
 
-/* Called from i4l.c to put an skb into the send-queue.
- * After sending gigaset_skb_sent() should be called. */
+/* Called from LL interface to put an skb into the send queue. */
 int gigaset_isoc_send_skb(struct bc_state *bcs, struct sk_buff *skb);
 
 /* Called from ev-layer.c to process a block of data
@@ -674,36 +677,26 @@ void gigaset_isowbuf_init(struct isowbuf_t *iwb, unsigned char idle);
 int gigaset_isowbuf_getbytes(struct isowbuf_t *iwb, int size);
 
 /* ===========================================================================
- *  Functions implemented in i4l.c/gigaset.h
+ *  Functions implemented in LL interface
  */
 
-/* Called by gigaset_initcs() for setting up with the isdn4linux subsystem */
-int gigaset_register_to_LL(struct cardstate *cs, const char *isdnid);
+/* Called from common.c for setting up/shutting down with the ISDN subsystem */
+int gigaset_isdn_register(struct cardstate *cs, const char *isdnid);
+void gigaset_isdn_unregister(struct cardstate *cs);
 
-/* Called from xxx-gigaset.c to indicate completion of sending an skb */
+/* Called from hardware module to indicate completion of an skb */
 void gigaset_skb_sent(struct bc_state *bcs, struct sk_buff *skb);
+void gigaset_skb_rcvd(struct bc_state *bcs, struct sk_buff *skb);
+void gigaset_isdn_rcv_err(struct bc_state *bcs);
 
 /* Called from common.c/ev-layer.c to indicate events relevant to the LL */
+void gigaset_isdn_start(struct cardstate *cs);
+void gigaset_isdn_stop(struct cardstate *cs);
 int gigaset_isdn_icall(struct at_state_t *at_state);
-int gigaset_isdn_setup_accept(struct at_state_t *at_state);
-int gigaset_isdn_setup_dial(struct at_state_t *at_state, void *data);
-
-void gigaset_i4l_cmd(struct cardstate *cs, int cmd);
-void gigaset_i4l_channel_cmd(struct bc_state *bcs, int cmd);
-
-
-static inline void gigaset_isdn_rcv_err(struct bc_state *bcs)
-{
-	isdn_ctrl response;
-
-	/* error -> LL */
-	gig_dbg(DEBUG_CMD, "sending L1ERR");
-	response.driver = bcs->cs->myid;
-	response.command = ISDN_STAT_L1ERR;
-	response.arg = bcs->channel;
-	response.parm.errcode = ISDN_STAT_L1ERR_RECV;
-	bcs->cs->iif.statcallb(&response);
-}
+void gigaset_isdn_connD(struct bc_state *bcs);
+void gigaset_isdn_hupD(struct bc_state *bcs);
+void gigaset_isdn_connB(struct bc_state *bcs);
+void gigaset_isdn_hupB(struct bc_state *bcs);
 
 /* ===========================================================================
  *  Functions implemented in ev-layer.c
@@ -816,35 +809,6 @@ static inline void gigaset_bchannel_up(struct bc_state *bcs)
 /* handling routines for sk_buff */
 /* ============================= */
 
-/* pass received skb to LL
- * Warning: skb must not be accessed anymore!
- */
-static inline void gigaset_rcv_skb(struct sk_buff *skb,
-				   struct cardstate *cs,
-				   struct bc_state *bcs)
-{
-	cs->iif.rcvcallb_skb(cs->myid, bcs->channel, skb);
-	bcs->trans_down++;
-}
-
-/* handle reception of corrupted skb
- * Warning: skb must not be accessed anymore!
- */
-static inline void gigaset_rcv_error(struct sk_buff *procskb,
-				     struct cardstate *cs,
-				     struct bc_state *bcs)
-{
-	if (procskb)
-		dev_kfree_skb(procskb);
-
-	if (bcs->ignore)
-		--bcs->ignore;
-	else {
-		++bcs->corrupted;
-		gigaset_isdn_rcv_err(bcs);
-	}
-}
-
 /* append received bytes to inbuf */
 int gigaset_fill_inbuf(struct inbuf_t *inbuf, const unsigned char *src,
 		       unsigned numbytes);
diff --git a/drivers/isdn/gigaset/i4l.c b/drivers/isdn/gigaset/i4l.c
index 654489d..8ce97a3 100644
--- a/drivers/isdn/gigaset/i4l.c
+++ b/drivers/isdn/gigaset/i4l.c
@@ -14,6 +14,9 @@
  */
 
 #include "gigaset.h"
+#include <linux/isdnif.h>
+
+#define HW_HDR_LEN	2	/* Header size used to store ack info */
 
 /* == Handling of I4L IO =====================================================*/
 
@@ -95,6 +98,7 @@ static int writebuf_from_LL(int driverID, int channel, int ack,
  */
 void gigaset_skb_sent(struct bc_state *bcs, struct sk_buff *skb)
 {
+	isdn_if *iif = bcs->cs->iif;
 	unsigned len;
 	isdn_ctrl response;
 
@@ -114,71 +118,171 @@ void gigaset_skb_sent(struct bc_state *bcs, struct sk_buff *skb)
 		response.command = ISDN_STAT_BSENT;
 		response.arg = bcs->channel;
 		response.parm.length = len;
-		bcs->cs->iif.statcallb(&response);
+		iif->statcallb(&response);
 	}
 }
 EXPORT_SYMBOL_GPL(gigaset_skb_sent);
 
+/**
+ * gigaset_skb_rcvd() - pass received skb to LL
+ * @bcs:	B channel descriptor structure.
+ * @skb:	received data.
+ *
+ * Called by hardware module {bas,ser,usb}_gigaset when user data has
+ * been successfully received, for passing to the LL.
+ * Warning: skb must not be accessed anymore!
+ */
+void gigaset_skb_rcvd(struct bc_state *bcs, struct sk_buff *skb)
+{
+	isdn_if *iif = bcs->cs->iif;
+
+	iif->rcvcallb_skb(bcs->cs->myid, bcs->channel, skb);
+	bcs->trans_down++;
+}
+EXPORT_SYMBOL_GPL(gigaset_skb_rcvd);
+
+/**
+ * gigaset_isdn_rcv_err() - signal receive error
+ * @bcs:	B channel descriptor structure.
+ *
+ * Called by hardware module {bas,ser,usb}_gigaset when a receive error
+ * has occurred, for signalling to the LL.
+ */
+void gigaset_isdn_rcv_err(struct bc_state *bcs)
+{
+	isdn_if *iif = bcs->cs->iif;
+	isdn_ctrl response;
+
+	/* if currently ignoring packets, just count down */
+	if (bcs->ignore) {
+		bcs->ignore--;
+		return;
+	}
+
+	/* update statistics */
+	bcs->corrupted++;
+
+	/* error -> LL */
+	gig_dbg(DEBUG_CMD, "sending L1ERR");
+	response.driver = bcs->cs->myid;
+	response.command = ISDN_STAT_L1ERR;
+	response.arg = bcs->channel;
+	response.parm.errcode = ISDN_STAT_L1ERR_RECV;
+	iif->statcallb(&response);
+}
+EXPORT_SYMBOL_GPL(gigaset_isdn_rcv_err);
+
 /* This function will be called by LL to send commands
  * NOTE: LL ignores the returned value, for commands other than ISDN_CMD_IOCTL,
  * so don't put too much effort into it.
  */
 static int command_from_LL(isdn_ctrl *cntrl)
 {
-	struct cardstate *cs = gigaset_get_cs_by_id(cntrl->driver);
+	struct cardstate *cs;
 	struct bc_state *bcs;
 	int retval = 0;
-	struct setup_parm *sp;
+	char **commands;
+	int ch;
+	int i;
+	size_t l;
 
 	gigaset_debugdrivers();
 
-	if (!cs) {
+	gig_dbg(DEBUG_CMD, "driver: %d, command: %d, arg: 0x%lx",
+		cntrl->driver, cntrl->command, cntrl->arg);
+
+	if ((cs = gigaset_get_cs_by_id(cntrl->driver)) == NULL) {
 		pr_err("%s: invalid driver ID (%d)\n", __func__, cntrl->driver);
 		return -ENODEV;
 	}
+	ch = cntrl->arg & 0xff;
 
 	switch (cntrl->command) {
 	case ISDN_CMD_IOCTL:
-		gig_dbg(DEBUG_ANY, "ISDN_CMD_IOCTL (driver: %d, arg: %ld)",
-			cntrl->driver, cntrl->arg);
-
 		dev_warn(cs->dev, "ISDN_CMD_IOCTL not supported\n");
 		return -EINVAL;
 
 	case ISDN_CMD_DIAL:
 		gig_dbg(DEBUG_ANY,
-			"ISDN_CMD_DIAL (driver: %d, ch: %ld, "
-			"phone: %s, ownmsn: %s, si1: %d, si2: %d)",
-			cntrl->driver, cntrl->arg,
+			"ISDN_CMD_DIAL (phone: %s, msn: %s, si1: %d, si2: %d)",
 			cntrl->parm.setup.phone, cntrl->parm.setup.eazmsn,
 			cntrl->parm.setup.si1, cntrl->parm.setup.si2);
 
-		if (cntrl->arg >= cs->channels) {
+		if (ch >= cs->channels) {
 			dev_err(cs->dev,
-				"ISDN_CMD_DIAL: invalid channel (%d)\n",
-				(int) cntrl->arg);
+				"ISDN_CMD_DIAL: invalid channel (%d)\n", ch);
 			return -EINVAL;
 		}
-
-		bcs = cs->bcs + cntrl->arg;
-
+		bcs = cs->bcs + ch;
 		if (!gigaset_get_channel(bcs)) {
 			dev_err(cs->dev, "ISDN_CMD_DIAL: channel not free\n");
 			return -EBUSY;
 		}
 
-		sp = kmalloc(sizeof *sp, GFP_ATOMIC);
-		if (!sp) {
+		commands = kzalloc(AT_NUM*(sizeof *commands), GFP_ATOMIC);
+		if (!commands) {
 			gigaset_free_channel(bcs);
 			dev_err(cs->dev, "ISDN_CMD_DIAL: out of memory\n");
 			return -ENOMEM;
 		}
-		*sp = cntrl->parm.setup;
 
-		if (!gigaset_add_event(cs, &bcs->at_state, EV_DIAL, sp,
+		l = 3 + strlen(cntrl->parm.setup.phone);
+		if (!(commands[AT_DIAL] = kmalloc(l, GFP_ATOMIC)))
+			goto oom;
+		if (cntrl->parm.setup.phone[0] == '*' &&
+		    cntrl->parm.setup.phone[1] == '*') {
+			/* internal call: translate ** prefix to CTP value */
+			if (!(commands[AT_TYPE] =
+			      kstrdup("^SCTP=0\r", GFP_ATOMIC)))
+				goto oom;
+			snprintf(commands[AT_DIAL], l,
+				 "D%s\r", cntrl->parm.setup.phone+2);
+		} else {
+			if (!(commands[AT_TYPE] =
+			      kstrdup("^SCTP=1\r", GFP_ATOMIC)))
+				goto oom;
+			snprintf(commands[AT_DIAL], l,
+				 "D%s\r", cntrl->parm.setup.phone);
+		}
+
+		if ((l = strlen(cntrl->parm.setup.eazmsn)) != 0) {
+			l += 8;
+			if (!(commands[AT_MSN] = kmalloc(l, GFP_ATOMIC)))
+				goto oom;
+			snprintf(commands[AT_MSN], l, "^SMSN=%s\r",
+				 cntrl->parm.setup.eazmsn);
+		}
+
+		switch (cntrl->parm.setup.si1) {
+		case 1:		/* audio */
+			/* BC = 9090A3: 3.1 kHz audio, A-law */
+			if (!(commands[AT_BC] =
+			      kstrdup("^SBC=9090A3\r", GFP_ATOMIC)))
+				goto oom;
+			break;
+		case 7:		/* data */
+		default:	/* hope the app knows what it is doing */
+			/* BC = 8890: unrestricted digital information */
+			if (!(commands[AT_BC] =
+			      kstrdup("^SBC=8890\r", GFP_ATOMIC)))
+				goto oom;
+		}
+		/* ToDo: other si1 values, inspect si2, set HLC/LLC */
+
+		if (!(commands[AT_PROTO] = kmalloc(9, GFP_ATOMIC)))
+			goto oom;
+		snprintf(commands[AT_PROTO], 9, "^SBPR=%u\r", bcs->proto2);
+
+		if (!(commands[AT_ISO] = kmalloc(9, GFP_ATOMIC)))
+			goto oom;
+		snprintf(commands[AT_ISO], 9, "^SISO=%u\r",
+			 (unsigned) bcs->channel + 1);
+
+		if (!gigaset_add_event(cs, &bcs->at_state, EV_DIAL, commands,
 				       bcs->at_state.seq_index, NULL)) {
-			//FIXME what should we do?
-			kfree(sp);
+			for (i = 0; i < AT_NUM; ++i)
+				kfree(commands[i]);
+			kfree(commands);
 			gigaset_free_channel(bcs);
 			return -ENOMEM;
 		}
@@ -186,93 +290,83 @@ static int command_from_LL(isdn_ctrl *cntrl)
 		gig_dbg(DEBUG_CMD, "scheduling DIAL");
 		gigaset_schedule_event(cs);
 		break;
-	case ISDN_CMD_ACCEPTD: //FIXME
-		gig_dbg(DEBUG_ANY, "ISDN_CMD_ACCEPTD");
-
-		if (cntrl->arg >= cs->channels) {
+	case ISDN_CMD_ACCEPTD:
+		if (ch >= cs->channels) {
 			dev_err(cs->dev,
-				"ISDN_CMD_ACCEPTD: invalid channel (%d)\n",
-				(int) cntrl->arg);
+				"ISDN_CMD_ACCEPTD: invalid channel (%d)\n", ch);
 			return -EINVAL;
 		}
-
-		if (!gigaset_add_event(cs, &cs->bcs[cntrl->arg].at_state,
-				       EV_ACCEPT, NULL, 0, NULL)) {
-			//FIXME what should we do?
+		bcs = cs->bcs + ch;
+		if (!gigaset_add_event(cs, &bcs->at_state,
+				       EV_ACCEPT, NULL, 0, NULL))
 			return -ENOMEM;
-		}
 
 		gig_dbg(DEBUG_CMD, "scheduling ACCEPT");
 		gigaset_schedule_event(cs);
 
 		break;
 	case ISDN_CMD_ACCEPTB:
-		gig_dbg(DEBUG_ANY, "ISDN_CMD_ACCEPTB");
 		break;
 	case ISDN_CMD_HANGUP:
-		gig_dbg(DEBUG_ANY, "ISDN_CMD_HANGUP (ch: %d)",
-			(int) cntrl->arg);
-
-		if (cntrl->arg >= cs->channels) {
+		if (ch >= cs->channels) {
 			dev_err(cs->dev,
-				"ISDN_CMD_HANGUP: invalid channel (%d)\n",
-				(int) cntrl->arg);
+				"ISDN_CMD_HANGUP: invalid channel (%d)\n", ch);
 			return -EINVAL;
 		}
-
-		if (!gigaset_add_event(cs, &cs->bcs[cntrl->arg].at_state,
-				       EV_HUP, NULL, 0, NULL)) {
-			//FIXME what should we do?
+		bcs = cs->bcs + ch;
+		if (!gigaset_add_event(cs, &bcs->at_state,
+				       EV_HUP, NULL, 0, NULL))
 			return -ENOMEM;
-		}
 
 		gig_dbg(DEBUG_CMD, "scheduling HUP");
 		gigaset_schedule_event(cs);
 
 		break;
-	case ISDN_CMD_CLREAZ: /* Do not signal incoming signals */ //FIXME
-		gig_dbg(DEBUG_ANY, "ISDN_CMD_CLREAZ");
+	case ISDN_CMD_CLREAZ: /* Do not signal incoming signals */
+		dev_info(cs->dev, "ignoring ISDN_CMD_CLREAZ\n");
 		break;
-	case ISDN_CMD_SETEAZ: /* Signal incoming calls for given MSN */ //FIXME
-		gig_dbg(DEBUG_ANY,
-			"ISDN_CMD_SETEAZ (id: %d, ch: %ld, number: %s)",
-			cntrl->driver, cntrl->arg, cntrl->parm.num);
+	case ISDN_CMD_SETEAZ: /* Signal incoming calls for given MSN */
+		dev_info(cs->dev, "ignoring ISDN_CMD_SETEAZ (%s)\n",
+			 cntrl->parm.num);
 		break;
 	case ISDN_CMD_SETL2: /* Set L2 to given protocol */
-		gig_dbg(DEBUG_ANY, "ISDN_CMD_SETL2 (ch: %ld, proto: %lx)",
-			cntrl->arg & 0xff, (cntrl->arg >> 8));
-
-		if ((cntrl->arg & 0xff) >= cs->channels) {
+		if (ch >= cs->channels) {
 			dev_err(cs->dev,
-				"ISDN_CMD_SETL2: invalid channel (%d)\n",
-				(int) cntrl->arg & 0xff);
+				"ISDN_CMD_SETL2: invalid channel (%d)\n", ch);
 			return -EINVAL;
 		}
-
-		if (!gigaset_add_event(cs, &cs->bcs[cntrl->arg & 0xff].at_state,
-				       EV_PROTO_L2, NULL, cntrl->arg >> 8,
-				       NULL)) {
-			//FIXME what should we do?
-			return -ENOMEM;
+		bcs = cs->bcs + ch;
+		if (bcs->chstate & CHS_D_UP) {
+			dev_err(cs->dev,
+				"ISDN_CMD_SETL2: channel active (%d)\n", ch);
+			return -EINVAL;
+		}
+		switch (cntrl->arg >> 8) {
+		case ISDN_PROTO_L2_HDLC:
+			gig_dbg(DEBUG_CMD, "ISDN_CMD_SETL2: setting L2_HDLC");
+			bcs->proto2 = L2_HDLC;
+			break;
+		case ISDN_PROTO_L2_TRANS:
+			gig_dbg(DEBUG_CMD, "ISDN_CMD_SETL2: setting L2_VOICE");
+			bcs->proto2 = L2_VOICE;
+			break;
+		default:
+			dev_err(cs->dev,
+				"ISDN_CMD_SETL2: unsupported protocol (%lu)\n",
+				cntrl->arg >> 8);
+			return -EINVAL;
 		}
-
-		gig_dbg(DEBUG_CMD, "scheduling PROTO_L2");
-		gigaset_schedule_event(cs);
 		break;
 	case ISDN_CMD_SETL3: /* Set L3 to given protocol */
-		gig_dbg(DEBUG_ANY, "ISDN_CMD_SETL3 (ch: %ld, proto: %lx)",
-			cntrl->arg & 0xff, (cntrl->arg >> 8));
-
-		if ((cntrl->arg & 0xff) >= cs->channels) {
+		if (ch >= cs->channels) {
 			dev_err(cs->dev,
-				"ISDN_CMD_SETL3: invalid channel (%d)\n",
-				(int) cntrl->arg & 0xff);
+				"ISDN_CMD_SETL3: invalid channel (%d)\n", ch);
 			return -EINVAL;
 		}
 
 		if (cntrl->arg >> 8 != ISDN_PROTO_L3_TRANS) {
 			dev_err(cs->dev,
-				"ISDN_CMD_SETL3: invalid protocol %lu\n",
+				"ISDN_CMD_SETL3: unsupported protocol (%lu)\n",
 				cntrl->arg >> 8);
 			return -EINVAL;
 		}
@@ -324,149 +418,34 @@ static int command_from_LL(isdn_ctrl *cntrl)
 	}
 
 	return retval;
+
+oom:
+	dev_err(bcs->cs->dev, "out of memory\n");
+	for (i = 0; i < AT_NUM; ++i)
+		kfree(commands[i]);
+	return -ENOMEM;
 }
 
-void gigaset_i4l_cmd(struct cardstate *cs, int cmd)
+static void gigaset_i4l_cmd(struct cardstate *cs, int cmd)
 {
+	isdn_if *iif = cs->iif;
 	isdn_ctrl command;
 
 	command.driver = cs->myid;
 	command.command = cmd;
 	command.arg = 0;
-	cs->iif.statcallb(&command);
+	iif->statcallb(&command);
 }
 
-void gigaset_i4l_channel_cmd(struct bc_state *bcs, int cmd)
+static void gigaset_i4l_channel_cmd(struct bc_state *bcs, int cmd)
 {
+	isdn_if *iif = bcs->cs->iif;
 	isdn_ctrl command;
 
 	command.driver = bcs->cs->myid;
 	command.command = cmd;
 	command.arg = bcs->channel;
-	bcs->cs->iif.statcallb(&command);
-}
-
-int gigaset_isdn_setup_dial(struct at_state_t *at_state, void *data)
-{
-	struct bc_state *bcs = at_state->bcs;
-	unsigned proto;
-	const char *bc;
-	size_t length[AT_NUM];
-	size_t l;
-	int i;
-	struct setup_parm *sp = data;
-
-	switch (bcs->proto2) {
-	case ISDN_PROTO_L2_HDLC:
-		proto = 1; /* 0: Bitsynchron, 1: HDLC, 2: voice */
-		break;
-	case ISDN_PROTO_L2_TRANS:
-		proto = 2; /* 0: Bitsynchron, 1: HDLC, 2: voice */
-		break;
-	default:
-		dev_err(bcs->cs->dev, "%s: invalid L2 protocol: %u\n",
-			__func__, bcs->proto2);
-		return -EINVAL;
-	}
-
-	switch (sp->si1) {
-	case 1:		/* audio */
-		bc = "9090A3";	/* 3.1 kHz audio, A-law */
-		break;
-	case 7:		/* data */
-	default:	/* hope the app knows what it is doing */
-		bc = "8890";	/* unrestricted digital information */
-	}
-	//FIXME add missing si1 values from 1TR6, inspect si2, set HLC/LLC
-
-	length[AT_DIAL ] = 1 + strlen(sp->phone) + 1 + 1;
-	l = strlen(sp->eazmsn);
-	length[AT_MSN  ] = l ? 6 + l + 1 + 1 : 0;
-	length[AT_BC   ] = 5 + strlen(bc) + 1 + 1;
-	length[AT_PROTO] = 6 + 1 + 1 + 1; /* proto: 1 character */
-	length[AT_ISO  ] = 6 + 1 + 1 + 1; /* channel: 1 character */
-	length[AT_TYPE ] = 6 + 1 + 1 + 1; /* call type: 1 character */
-	length[AT_HLC  ] = 0;
-
-	for (i = 0; i < AT_NUM; ++i) {
-		kfree(bcs->commands[i]);
-		bcs->commands[i] = NULL;
-		if (length[i] &&
-		    !(bcs->commands[i] = kmalloc(length[i], GFP_ATOMIC))) {
-			dev_err(bcs->cs->dev, "out of memory\n");
-			return -ENOMEM;
-		}
-	}
-
-	/* type = 1: extern, 0: intern, 2: recall, 3: door, 4: centrex */
-	if (sp->phone[0] == '*' && sp->phone[1] == '*') {
-		/* internal call: translate ** prefix to CTP value */
-		snprintf(bcs->commands[AT_DIAL], length[AT_DIAL],
-			 "D%s\r", sp->phone+2);
-		strncpy(bcs->commands[AT_TYPE], "^SCTP=0\r", length[AT_TYPE]);
-	} else {
-		snprintf(bcs->commands[AT_DIAL], length[AT_DIAL],
-			 "D%s\r", sp->phone);
-		strncpy(bcs->commands[AT_TYPE], "^SCTP=1\r", length[AT_TYPE]);
-	}
-
-	if (bcs->commands[AT_MSN])
-		snprintf(bcs->commands[AT_MSN], length[AT_MSN],
-			 "^SMSN=%s\r", sp->eazmsn);
-	snprintf(bcs->commands[AT_BC   ], length[AT_BC   ],
-		 "^SBC=%s\r", bc);
-	snprintf(bcs->commands[AT_PROTO], length[AT_PROTO],
-		 "^SBPR=%u\r", proto);
-	snprintf(bcs->commands[AT_ISO  ], length[AT_ISO  ],
-		 "^SISO=%u\r", (unsigned)bcs->channel + 1);
-
-	return 0;
-}
-
-int gigaset_isdn_setup_accept(struct at_state_t *at_state)
-{
-	unsigned proto;
-	size_t length[AT_NUM];
-	int i;
-	struct bc_state *bcs = at_state->bcs;
-
-	switch (bcs->proto2) {
-	case ISDN_PROTO_L2_HDLC:
-		proto = 1; /* 0: Bitsynchron, 1: HDLC, 2: voice */
-		break;
-	case ISDN_PROTO_L2_TRANS:
-		proto = 2; /* 0: Bitsynchron, 1: HDLC, 2: voice */
-		break;
-	default:
-		dev_err(at_state->cs->dev, "%s: invalid protocol: %u\n",
-			__func__, bcs->proto2);
-		return -EINVAL;
-	}
-
-	length[AT_DIAL ] = 0;
-	length[AT_MSN  ] = 0;
-	length[AT_BC   ] = 0;
-	length[AT_PROTO] = 6 + 1 + 1 + 1; /* proto: 1 character */
-	length[AT_ISO  ] = 6 + 1 + 1 + 1; /* channel: 1 character */
-	length[AT_TYPE ] = 0;
-	length[AT_HLC  ] = 0;
-
-	for (i = 0; i < AT_NUM; ++i) {
-		kfree(bcs->commands[i]);
-		bcs->commands[i] = NULL;
-		if (length[i] &&
-		    !(bcs->commands[i] = kmalloc(length[i], GFP_ATOMIC))) {
-			dev_err(at_state->cs->dev, "out of memory\n");
-			return -ENOMEM;
-		}
-	}
-
-	snprintf(bcs->commands[AT_PROTO], length[AT_PROTO],
-		 "^SBPR=%u\r", proto);
-	snprintf(bcs->commands[AT_ISO  ], length[AT_ISO  ],
-		 "^SISO=%u\r", (unsigned) bcs->channel + 1);
-
-	return 0;
+	iif->statcallb(&command);
 }
 
 /**
@@ -482,6 +461,7 @@ int gigaset_isdn_icall(struct at_state_t *at_state)
 {
 	struct cardstate *cs = at_state->cs;
 	struct bc_state *bcs = at_state->bcs;
+	isdn_if *iif = cs->iif;
 	isdn_ctrl response;
 	int retval;
 
@@ -531,7 +511,7 @@ int gigaset_isdn_icall(struct at_state_t *at_state)
 		response.arg = bcs->channel; //FIXME
 	}
 	response.driver = cs->myid;
-	retval = cs->iif.statcallb(&response);
+	retval = iif->statcallb(&response);
 	gig_dbg(DEBUG_CMD, "Response: %d", retval);
 	switch (retval) {
 	case 0:	/* no takers */
@@ -560,16 +540,108 @@ int gigaset_isdn_icall(struct at_state_t *at_state)
 	}
 }
 
-/* Set Callback function pointer */
-int gigaset_register_to_LL(struct cardstate *cs, const char *isdnid)
+/**
+ * gigaset_isdn_connD() - signal D channel connect
+ * @bcs:	B channel descriptor structure.
+ *
+ * Called by main module to notify the LL that the D channel connection has
+ * been established.
+ */
+void gigaset_isdn_connD(struct bc_state *bcs)
 {
-	isdn_if *iif = &cs->iif;
+	gig_dbg(DEBUG_CMD, "sending DCONN");
+	gigaset_i4l_channel_cmd(bcs, ISDN_STAT_DCONN);
+}
 
-	gig_dbg(DEBUG_ANY, "Register driver capabilities to LL");
+/**
+ * gigaset_isdn_hupD() - signal D channel hangup
+ * @bcs:	B channel descriptor structure.
+ *
+ * Called by main module to notify the LL that the D channel connection has
+ * been shut down.
+ */
+void gigaset_isdn_hupD(struct bc_state *bcs)
+{
+	gig_dbg(DEBUG_CMD, "sending DHUP");
+	gigaset_i4l_channel_cmd(bcs, ISDN_STAT_DHUP);
+}
+
+/**
+ * gigaset_isdn_connB() - signal B channel connect
+ * @bcs:	B channel descriptor structure.
+ *
+ * Called by main module to notify the LL that the B channel connection has
+ * been established.
+ */
+void gigaset_isdn_connB(struct bc_state *bcs)
+{
+	gig_dbg(DEBUG_CMD, "sending BCONN");
+	gigaset_i4l_channel_cmd(bcs, ISDN_STAT_BCONN);
+}
+
+/**
+ * gigaset_isdn_hupB() - signal B channel hangup
+ * @bcs:	B channel descriptor structure.
+ *
+ * Called by main module to notify the LL that the B channel connection has
+ * been shut down.
+ */
+void gigaset_isdn_hupB(struct bc_state *bcs)
+{
+	gig_dbg(DEBUG_CMD, "sending BHUP");
+	gigaset_i4l_channel_cmd(bcs, ISDN_STAT_BHUP);
+}
+
+/**
+ * gigaset_isdn_start() - signal device availability
+ * @cs:		device descriptor structure.
+ *
+ * Called by main module to notify the LL that the device is available for
+ * use.
+ */
+void gigaset_isdn_start(struct cardstate *cs)
+{
+	gig_dbg(DEBUG_CMD, "sending RUN");
+	gigaset_i4l_cmd(cs, ISDN_STAT_RUN);
+}
+
+/**
+ * gigaset_isdn_stop() - signal device unavailability
+ * @cs:		device descriptor structure.
+ *
+ * Called by main module to notify the LL that the device is no longer
+ * available for use.
+ */
+void gigaset_isdn_stop(struct cardstate *cs)
+{
+	gig_dbg(DEBUG_CMD, "sending STOP");
+	gigaset_i4l_cmd(cs, ISDN_STAT_STOP);
+}
+
+/**
+ * gigaset_isdn_register() - register to LL
+ * @cs:		device descriptor structure.
+ * @isdnid:	device name.
+ *
+ * Called by main module to register the device with the LL.
+ *
+ * Return value: 1 for success, 0 for failure
+ */
+int gigaset_isdn_register(struct cardstate *cs, const char *isdnid)
+{
+	isdn_if *iif;
+
+	pr_info("ISDN4Linux interface\n");
+
+	if ((iif = kmalloc(sizeof *iif, GFP_KERNEL)) == NULL) {
+		pr_err("out of memory\n");
+		return 0;
+	}
 
 	if (snprintf(iif->id, sizeof iif->id, "%s_%u", isdnid, cs->minor_index)
 	    >= sizeof iif->id) {
 		pr_err("ID too long: %s\n", isdnid);
+		kfree(iif);
 		return 0;
 	}
 
@@ -593,9 +665,26 @@ int gigaset_register_to_LL(struct cardstate *cs, const char *isdnid)
 
 	if (!register_isdn(iif)) {
 		pr_err("register_isdn failed\n");
+		kfree(iif);
 		return 0;
 	}
 
+	cs->iif = iif;
 	cs->myid = iif->channels;		/* Set my device id */
+	cs->hw_hdr_len = HW_HDR_LEN;
 	return 1;
 }
+
+/**
+ * gigaset_isdn_unregister() - unregister from LL
+ * @cs:		device descriptor structure.
+ *
+ * Called by main module to unregister the device from the LL.
+ */
+void gigaset_isdn_unregister(struct cardstate *cs)
+{
+	gig_dbg(DEBUG_CMD, "sending UNLOAD");
+	gigaset_i4l_cmd(cs, ISDN_STAT_UNLOAD);
+	kfree(cs->iif);
+	cs->iif = NULL;
+}
diff --git a/drivers/isdn/gigaset/isocdata.c b/drivers/isdn/gigaset/isocdata.c
index 9f3ef7b..31743a6 100644
--- a/drivers/isdn/gigaset/isocdata.c
+++ b/drivers/isdn/gigaset/isocdata.c
@@ -500,7 +500,7 @@ int gigaset_isoc_buildframe(struct bc_state *bcs, unsigned char *in, int len)
 	int result;
 
 	switch (bcs->proto2) {
-	case ISDN_PROTO_L2_HDLC:
+	case L2_HDLC:
 		result = hdlc_buildframe(bcs->hw.bas->isooutbuf, in, len);
 		gig_dbg(DEBUG_ISO, "%s: %d bytes HDLC -> %d",
 			__func__, len, result);
@@ -542,8 +542,9 @@ static inline void hdlc_flush(struct bc_state *bcs)
 	if (likely(bcs->skb != NULL))
 		skb_trim(bcs->skb, 0);
 	else if (!bcs->ignore) {
-		if ((bcs->skb = dev_alloc_skb(SBUFSIZE + HW_HDR_LEN)) != NULL)
-			skb_reserve(bcs->skb, HW_HDR_LEN);
+		if ((bcs->skb = dev_alloc_skb(SBUFSIZE + bcs->cs->hw_hdr_len))
+		    != NULL)
+			skb_reserve(bcs->skb, bcs->cs->hw_hdr_len);
 		else
 			dev_err(bcs->cs->dev, "could not allocate skb\n");
 	}
@@ -557,7 +558,9 @@ static inline void hdlc_flush(struct bc_state *bcs)
  */
 static inline void hdlc_done(struct bc_state *bcs)
 {
+	struct cardstate *cs = bcs->cs;
 	struct sk_buff *procskb;
+	unsigned int len;
 
 	if (unlikely(bcs->ignore)) {
 		bcs->ignore--;
@@ -568,32 +571,30 @@ static inline void hdlc_done(struct bc_state *bcs)
 	if ((procskb = bcs->skb) == NULL) {
 		/* previous error */
 		gig_dbg(DEBUG_ISO, "%s: skb=NULL", __func__);
-		gigaset_rcv_error(NULL, bcs->cs, bcs);
-	} else if (procskb->len < 2) {
-		dev_notice(bcs->cs->dev, "received short frame (%d octets)\n",
-			   procskb->len);
+		gigaset_isdn_rcv_err(bcs);
+	} else if ((len = procskb->len) < 2) {
+		dev_notice(cs->dev, "received short frame (%d octets)\n", len);
 		bcs->hw.bas->runts++;
-		gigaset_rcv_error(procskb, bcs->cs, bcs);
+		dev_kfree_skb(procskb);
+		gigaset_isdn_rcv_err(bcs);
 	} else if (bcs->fcs != PPP_GOODFCS) {
-		dev_notice(bcs->cs->dev, "frame check error (0x%04x)\n",
-			   bcs->fcs);
+		dev_notice(cs->dev, "frame check error (0x%04x)\n", bcs->fcs);
 		bcs->hw.bas->fcserrs++;
-		gigaset_rcv_error(procskb, bcs->cs, bcs);
+		dev_kfree_skb(procskb);
+		gigaset_isdn_rcv_err(bcs);
 	} else {
-		procskb->len -= 2;		/* subtract FCS */
-		procskb->tail -= 2;
-		gig_dbg(DEBUG_ISO, "%s: good frame (%d octets)",
-			__func__, procskb->len);
+		__skb_trim(procskb, len -= 2);	/* subtract FCS */
+		gig_dbg(DEBUG_ISO, "%s: good frame (%d octets)", __func__, len);
 		dump_bytes(DEBUG_STREAM_DUMP,
-			   "rcv data", procskb->data, procskb->len);
-		bcs->hw.bas->goodbytes += procskb->len;
-		gigaset_rcv_skb(procskb, bcs->cs, bcs);
+			   "rcv data", procskb->data, len);
+		bcs->hw.bas->goodbytes += len;
+		gigaset_skb_rcvd(bcs, procskb);
 	}
 
-	if ((bcs->skb = dev_alloc_skb(SBUFSIZE + HW_HDR_LEN)) != NULL)
-		skb_reserve(bcs->skb, HW_HDR_LEN);
+	if ((bcs->skb = dev_alloc_skb(SBUFSIZE + cs->hw_hdr_len)) != NULL)
+		skb_reserve(bcs->skb, cs->hw_hdr_len);
 	else
-		dev_err(bcs->cs->dev, "could not allocate skb\n");
+		dev_err(cs->dev, "could not allocate skb\n");
 	bcs->fcs = PPP_INITFCS;
 }
 
@@ -610,12 +611,8 @@ static inline void hdlc_frag(struct bc_state *bcs, unsigned inbits)
 
 	dev_notice(bcs->cs->dev, "received partial byte (%d bits)\n", inbits);
 	bcs->hw.bas->alignerrs++;
-	gigaset_rcv_error(bcs->skb, bcs->cs, bcs);
-
-	if ((bcs->skb = dev_alloc_skb(SBUFSIZE + HW_HDR_LEN)) != NULL)
-		skb_reserve(bcs->skb, HW_HDR_LEN);
-	else
-		dev_err(bcs->cs->dev, "could not allocate skb\n");
+	gigaset_isdn_rcv_err(bcs);
+	__skb_trim(bcs->skb, 0);
 	bcs->fcs = PPP_INITFCS;
 }
 
@@ -648,8 +645,8 @@ static const unsigned char bitcounts[256] = {
 /* hdlc_unpack
  * perform HDLC frame processing (bit unstuffing, flag detection, FCS calculation)
  * on a sequence of received data bytes (8 bits each, LSB first)
- * pass on successfully received, complete frames as SKBs via gigaset_rcv_skb
- * notify of errors via gigaset_rcv_error
+ * pass on successfully received, complete frames as SKBs via gigaset_skb_rcvd
+ * notify of errors via gigaset_isdn_rcv_err
  * tally frames, errors etc. in BC structure counters
  * parameters:
  *	src	received data
@@ -841,7 +838,7 @@ static inline void hdlc_unpack(unsigned char *src, unsigned count,
 }
 
 /* trans_receive
- * pass on received USB frame transparently as SKB via gigaset_rcv_skb
+ * pass on received USB frame transparently as SKB via gigaset_skb_rcvd
  * invert bytes
  * tally frames, errors etc. in BC structure counters
  * parameters:
@@ -852,6 +849,7 @@ static inline void hdlc_unpack(unsigned char *src, unsigned count,
 static inline void trans_receive(unsigned char *src, unsigned count,
 				 struct bc_state *bcs)
 {
+	struct cardstate *cs = bcs->cs;
 	struct sk_buff *skb;
 	int dobytes;
 	unsigned char *dst;
@@ -862,12 +860,12 @@ static inline void trans_receive(unsigned char *src, unsigned count,
 		return;
 	}
 	if (unlikely((skb = bcs->skb) == NULL)) {
-		bcs->skb = skb = dev_alloc_skb(SBUFSIZE + HW_HDR_LEN);
+		bcs->skb = skb = dev_alloc_skb(SBUFSIZE + cs->hw_hdr_len);
 		if (!skb) {
-			dev_err(bcs->cs->dev, "could not allocate skb\n");
+			dev_err(cs->dev, "could not allocate skb\n");
 			return;
 		}
-		skb_reserve(skb, HW_HDR_LEN);
+		skb_reserve(skb, cs->hw_hdr_len);
 	}
 	bcs->hw.bas->goodbytes += skb->len;
 	dobytes = TRANSBUFSIZE - skb->len;
@@ -881,14 +879,14 @@ static inline void trans_receive(unsigned char *src, unsigned count,
 		if (dobytes == 0) {
 			dump_bytes(DEBUG_STREAM_DUMP,
 				   "rcv data", skb->data, skb->len);
-			gigaset_rcv_skb(skb, bcs->cs, bcs);
-			bcs->skb = skb = dev_alloc_skb(SBUFSIZE + HW_HDR_LEN);
+			gigaset_skb_rcvd(bcs, skb);
+			bcs->skb = skb =
+				dev_alloc_skb(SBUFSIZE + cs->hw_hdr_len);
 			if (!skb) {
-				dev_err(bcs->cs->dev,
-					"could not allocate skb\n");
+				dev_err(cs->dev, "could not allocate skb\n");
 				return;
 			}
-			skb_reserve(bcs->skb, HW_HDR_LEN);
+			skb_reserve(skb, cs->hw_hdr_len);
 			dobytes = TRANSBUFSIZE;
 		}
 	}
@@ -897,7 +895,7 @@ static inline void trans_receive(unsigned char *src, unsigned count,
 void gigaset_isoc_receive(unsigned char *src, unsigned count, struct bc_state *bcs)
 {
 	switch (bcs->proto2) {
-	case ISDN_PROTO_L2_HDLC:
+	case L2_HDLC:
 		hdlc_unpack(src, count, bcs);
 		break;
 	default:		/* assume transparent */
@@ -981,8 +979,10 @@ void gigaset_isoc_input(struct inbuf_t *inbuf)
  * @bcs:	B channel descriptor structure.
  * @skb:	data to send.
  *
- * Called by i4l.c to queue an skb for sending, and start transmission if
+ * Called by LL to queue an skb for sending, and start transmission if
  * necessary.
+ * Once the payload data has been transmitted completely, gigaset_skb_sent()
+ * will be called with the first cs->hw_hdr_len bytes of skb->head preserved.
  *
  * Return value:
  *	number of bytes accepted for sending (skb->len) if ok,
-- 
1.6.2.1.214.ge986c
