From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 3/9] gigaset: fix bad assumptions about CAPI skbuffs
Date: Sun, 25 Oct 2009 20:29:57 +0100 (CET)
Message-ID: <20091023-patch-gigaset-03.tilman@imap.cc>
References: <20091023-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754087AbZJYTaN@vger.kernel.org>
In-Reply-To: <20091023-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CAPI interface incorrectly assumed that CAPI messages would always
start at the beginning of the data buffer: fix by treating DATA_B3
messages as the link layer header to their payload data. This fix
changes the way acknowledgement information is propagated through the
hardware specific modules and thereby impacts the ISDN4Linux variant
of the driver, too.

Also some assumptions about methods not being called from interrupt
context turned out to be unwarranted; fix by using dev_kfree_skb_any()
wherever non-interrupt context isn't guaranteed.

Impact: bugfix
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/asyncdata.c |   55 +++++++++++++++++++++----------------
 drivers/isdn/gigaset/capi.c      |   29 ++++++++++---------
 drivers/isdn/gigaset/gigaset.h   |    2 +-
 drivers/isdn/gigaset/i4l.c       |   28 ++++++++++++++-----
 drivers/isdn/gigaset/isocdata.c  |    6 ++--
 5 files changed, 70 insertions(+), 50 deletions(-)

diff --git a/drivers/isdn/gigaset/asyncdata.c b/drivers/isdn/gigaset/asyncdata.c
index a25216b..256fc48 100644
--- a/drivers/isdn/gigaset/asyncdata.c
+++ b/drivers/isdn/gigaset/asyncdata.c
@@ -156,7 +156,7 @@ byte_stuff:
 
 				/* end of frame */
 				gigaset_isdn_rcv_err(bcs);
-				dev_kfree_skb(skb);
+				dev_kfree_skb_any(skb);
 			} else if (!(inputstate & INS_have_data)) { /* 7E 7E */
 #ifdef CONFIG_GIGASET_DEBUG
 				++bcs->emptycount;
@@ -172,7 +172,7 @@ byte_stuff:
 				"Checksum failed, %u bytes corrupted!\n",
 						skb->len);
 					gigaset_isdn_rcv_err(bcs);
-					dev_kfree_skb(skb);
+					dev_kfree_skb_any(skb);
 				} else if (likely(skb->len > 2)) {
 					__skb_trim(skb, skb->len - 2);
 					gigaset_skb_rcvd(bcs, skb);
@@ -182,7 +182,7 @@ byte_stuff:
 					"invalid packet size (%d)\n", skb->len);
 						gigaset_isdn_rcv_err(bcs);
 					}
-					dev_kfree_skb(skb);
+					dev_kfree_skb_any(skb);
 				}
 			}
 
@@ -430,11 +430,11 @@ EXPORT_SYMBOL_GPL(gigaset_m10x_input);
  * opening and closing flags, preserving headroom data.
  * parameters:
  *	skb		skb containing original packet (freed upon return)
- *	headroom	number of headroom bytes to preserve
  * Return value:
  *	pointer to newly allocated skb containing the result frame
+ *	and the original link layer header, NULL on error
  */
-static struct sk_buff *HDLC_Encode(struct sk_buff *skb, int headroom)
+static struct sk_buff *HDLC_Encode(struct sk_buff *skb)
 {
 	struct sk_buff *hdlc_skb;
 	__u16 fcs;
@@ -456,17 +456,19 @@ static struct sk_buff *HDLC_Encode(struct sk_buff *skb, int headroom)
 
 	/* size of new buffer: original size + number of stuffing bytes
 	 * + 2 bytes FCS + 2 stuffing bytes for FCS (if needed) + 2 flag bytes
-	 * + room for acknowledgement header
+	 * + room for link layer header
 	 */
-	hdlc_skb = dev_alloc_skb(skb->len + stuf_cnt + 6 + headroom);
+	hdlc_skb = dev_alloc_skb(skb->len + stuf_cnt + 6 + skb->mac_len);
 	if (!hdlc_skb) {
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return NULL;
 	}
 
-	/* Copy acknowledgement header into new skb */
-	skb_reserve(hdlc_skb, headroom);
-	memcpy(hdlc_skb->head, skb->head, headroom);
+	/* Copy link layer header into new skb */
+	skb_reset_mac_header(hdlc_skb);
+	skb_reserve(hdlc_skb, skb->mac_len);
+	memcpy(skb_mac_header(hdlc_skb), skb_mac_header(skb), skb->mac_len);
+	hdlc_skb->mac_len = skb->mac_len;
 
 	/* Add flag sequence in front of everything.. */
 	*(skb_put(hdlc_skb, 1)) = PPP_FLAG;
@@ -497,7 +499,7 @@ static struct sk_buff *HDLC_Encode(struct sk_buff *skb, int headroom)
 
 	*(skb_put(hdlc_skb, 1)) = PPP_FLAG;
 
-	dev_kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 	return hdlc_skb;
 }
 
@@ -506,28 +508,33 @@ static struct sk_buff *HDLC_Encode(struct sk_buff *skb, int headroom)
  * preserving headroom data.
  * parameters:
  *	skb		skb containing original packet (freed upon return)
- *	headroom	number of headroom bytes to preserve
  * Return value:
  *	pointer to newly allocated skb containing the result frame
+ *	and the original link layer header, NULL on error
  */
-static struct sk_buff *iraw_encode(struct sk_buff *skb, int headroom)
+static struct sk_buff *iraw_encode(struct sk_buff *skb)
 {
 	struct sk_buff *iraw_skb;
 	unsigned char c;
 	unsigned char *cp;
 	int len;
 
-	/* worst case: every byte must be stuffed */
-	iraw_skb = dev_alloc_skb(2*skb->len + headroom);
+	/* size of new buffer (worst case = every byte must be stuffed):
+	 * 2 * original size + room for link layer header
+	 */
+	iraw_skb = dev_alloc_skb(2*skb->len + skb->mac_len);
 	if (!iraw_skb) {
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return NULL;
 	}
 
-	/* Copy acknowledgement header into new skb */
-	skb_reserve(iraw_skb, headroom);
-	memcpy(iraw_skb->head, skb->head, headroom);
+	/* copy link layer header into new skb */
+	skb_reset_mac_header(iraw_skb);
+	skb_reserve(iraw_skb, skb->mac_len);
+	memcpy(skb_mac_header(iraw_skb), skb_mac_header(skb), skb->mac_len);
+	iraw_skb->mac_len = skb->mac_len;
 
+	/* copy and stuff data */
 	cp = skb->data;
 	len = skb->len;
 	while (len--) {
@@ -536,7 +543,7 @@ static struct sk_buff *iraw_encode(struct sk_buff *skb, int headroom)
 			*(skb_put(iraw_skb, 1)) = c;
 		*(skb_put(iraw_skb, 1)) = c;
 	}
-	dev_kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 	return iraw_skb;
 }
 
@@ -548,7 +555,7 @@ static struct sk_buff *iraw_encode(struct sk_buff *skb, int headroom)
  * Called by LL to encode and queue an skb for sending, and start
  * transmission if necessary.
  * Once the payload data has been transmitted completely, gigaset_skb_sent()
- * will be called with the first cs->hw_hdr_len bytes of skb->head preserved.
+ * will be called with the skb's link layer header preserved.
  *
  * Return value:
  *	number of bytes accepted for sending (skb->len) if ok,
@@ -560,9 +567,9 @@ int gigaset_m10x_send_skb(struct bc_state *bcs, struct sk_buff *skb)
 	unsigned long flags;
 
 	if (bcs->proto2 == L2_HDLC)
-		skb = HDLC_Encode(skb, bcs->cs->hw_hdr_len);
+		skb = HDLC_Encode(skb);
 	else
-		skb = iraw_encode(skb, bcs->cs->hw_hdr_len);
+		skb = iraw_encode(skb);
 	if (!skb) {
 		dev_err(bcs->cs->dev,
 			"unable to allocate memory for encoding!\n");
diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index d1afac2..3f5cd06 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -362,6 +362,7 @@ void gigaset_skb_sent(struct bc_state *bcs, struct sk_buff *dskb)
 	struct cardstate *cs = bcs->cs;
 	struct gigaset_capi_ctr *iif = cs->iif;
 	struct gigaset_capi_appl *ap = bcs->ap;
+	unsigned char *req = skb_mac_header(dskb);
 	struct sk_buff *cskb;
 	u16 flags;
 
@@ -380,7 +381,7 @@ void gigaset_skb_sent(struct bc_state *bcs, struct sk_buff *dskb)
 	}
 
 	/* ToDo: honor unset "delivery confirmation" bit */
-	flags = CAPIMSG_FLAGS(dskb->head);
+	flags = CAPIMSG_FLAGS(req);
 
 	/* build DATA_B3_CONF message */
 	cskb = alloc_skb(CAPI_DATA_B3_CONF_LEN, GFP_ATOMIC);
@@ -393,11 +394,11 @@ void gigaset_skb_sent(struct bc_state *bcs, struct sk_buff *dskb)
 	CAPIMSG_SETAPPID(cskb->data, ap->id);
 	CAPIMSG_SETCOMMAND(cskb->data, CAPI_DATA_B3);
 	CAPIMSG_SETSUBCOMMAND(cskb->data,  CAPI_CONF);
-	CAPIMSG_SETMSGID(cskb->data, CAPIMSG_MSGID(dskb->head));
+	CAPIMSG_SETMSGID(cskb->data, CAPIMSG_MSGID(req));
 	CAPIMSG_SETCONTROLLER(cskb->data, iif->ctr.cnr);
 	CAPIMSG_SETPLCI_PART(cskb->data, bcs->channel + 1);
 	CAPIMSG_SETNCCI_PART(cskb->data, 1);
-	CAPIMSG_SETHANDLE_CONF(cskb->data, CAPIMSG_HANDLE_REQ(dskb->head));
+	CAPIMSG_SETHANDLE_CONF(cskb->data, CAPIMSG_HANDLE_REQ(req));
 	if (flags & ~CAPI_FLAGS_DELIVERY_CONFIRMATION)
 		CAPIMSG_SETINFO_CONF(cskb->data,
 				     CapiFlagsNotSupportedByProtocol);
@@ -437,7 +438,7 @@ void gigaset_skb_rcvd(struct bc_state *bcs, struct sk_buff *skb)
 	/* don't send further B3 messages if disconnected */
 	if (ap->connected < APCONN_ACTIVE) {
 		gig_dbg(DEBUG_LLDATA, "disconnected, discarding data");
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return;
 	}
 
@@ -1461,7 +1462,7 @@ static void do_connect_resp(struct gigaset_capi_ctr *iif,
 	/* decode message */
 	capi_message2cmsg(cmsg, skb->data);
 	dump_cmsg(DEBUG_CMD, __func__, cmsg);
-	dev_kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 
 	/* extract and check channel number from PLCI */
 	channel = (cmsg->adr.adrPLCI >> 8) & 0xff;
@@ -1652,7 +1653,7 @@ static void do_connect_b3_resp(struct gigaset_capi_ctr *iif,
 	    ((cmsg->adr.adrNCCI >> 16) & 0xffff) != 1) {
 		dev_notice(cs->dev, "%s: invalid %s 0x%02x\n",
 			   "CONNECT_B3_RESP", "NCCI", cmsg->adr.adrNCCI);
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return;
 	}
 	bcs = &cs->bcs[channel-1];
@@ -1665,7 +1666,7 @@ static void do_connect_b3_resp(struct gigaset_capi_ctr *iif,
 		if (!gigaset_add_event(cs, &bcs->at_state,
 				       EV_HUP, NULL, 0, NULL)) {
 			dev_err(cs->dev, "%s: out of memory\n", __func__);
-			dev_kfree_skb(skb);
+			dev_kfree_skb_any(skb);
 			return;
 		}
 		gig_dbg(DEBUG_CMD, "scheduling HUP");
@@ -1880,12 +1881,12 @@ static void do_data_b3_req(struct gigaset_capi_ctr *iif,
 		return;
 	}
 
-	/*
-	 * pull CAPI message from skb,
-	 * pass payload data to device-specific module
-	 * CAPI message will be preserved in headroom
-	 */
+	/* pull CAPI message into link layer header */
+	skb_reset_mac_header(skb);
+	skb->mac_len = msglen;
 	skb_pull(skb, msglen);
+
+	/* pass to device-specific module */
 	if (cs->ops->send_skb(&cs->bcs[channel-1], skb) < 0) {
 		send_conf(iif, ap, skb, CAPI_MSGOSRESOURCEERR);
 		return;
@@ -1946,7 +1947,7 @@ static void do_nothing(struct gigaset_capi_ctr *iif,
 		capi_message2cmsg(&iif->acmsg, skb->data);
 		dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
 	}
-	dev_kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 }
 
 static void do_data_b3_resp(struct gigaset_capi_ctr *iif,
@@ -1954,7 +1955,7 @@ static void do_data_b3_resp(struct gigaset_capi_ctr *iif,
 			    struct sk_buff *skb)
 {
 	dump_rawmsg(DEBUG_LLDATA, __func__, skb->data);
-	dev_kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 }
 
 /* table of outgoing CAPI message handlers with lookup function */
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index 4749ef1..c59216b 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -625,7 +625,7 @@ struct gigaset_ops {
 
 	/* Called from LL interface to put an skb into the send-queue.
 	 * After sending is completed, gigaset_skb_sent() must be called
-	 * with the first cs->hw_hdr_len bytes of skb->head preserved. */
+	 * with the skb's link layer header preserved. */
 	int (*send_skb)(struct bc_state *bcs, struct sk_buff *skb);
 
 	/* Called from ev-layer.c to process a block of data
diff --git a/drivers/isdn/gigaset/i4l.c b/drivers/isdn/gigaset/i4l.c
index aca72a0..828824f 100644
--- a/drivers/isdn/gigaset/i4l.c
+++ b/drivers/isdn/gigaset/i4l.c
@@ -41,8 +41,8 @@ static int writebuf_from_LL(int driverID, int channel, int ack,
 {
 	struct cardstate *cs;
 	struct bc_state *bcs;
+	unsigned char *ack_header;
 	unsigned len;
-	unsigned skblen;
 
 	if (!(cs = gigaset_get_cs_by_id(driverID))) {
 		pr_err("%s: invalid driver ID (%d)\n", __func__, driverID);
@@ -78,11 +78,23 @@ static int writebuf_from_LL(int driverID, int channel, int ack,
 		return -EINVAL;
 	}
 
-	skblen = ack ? len : 0;
-	skb->head[0] = skblen & 0xff;
-	skb->head[1] = skblen >> 8;
-	gig_dbg(DEBUG_MCMD, "skb: len=%u, skblen=%u: %02x %02x",
-		len, skblen, (unsigned) skb->head[0], (unsigned) skb->head[1]);
+	/* set up acknowledgement header */
+	if (skb_headroom(skb) < HW_HDR_LEN) {
+		/* should never happen */
+		dev_err(cs->dev, "%s: insufficient skb headroom\n", __func__);
+		return -ENOMEM;
+	}
+	skb_set_mac_header(skb, -HW_HDR_LEN);
+	skb->mac_len = HW_HDR_LEN;
+	ack_header = skb_mac_header(skb);
+	if (ack) {
+		ack_header[0] = len & 0xff;
+		ack_header[1] = len >> 8;
+	} else {
+		ack_header[0] = ack_header[1] = 0;
+	}
+	gig_dbg(DEBUG_MCMD, "skb: len=%u, ack=%d: %02x %02x",
+		len, ack, ack_header[0], ack_header[1]);
 
 	/* pass to device-specific module */
 	return cs->ops->send_skb(bcs, skb);
@@ -99,6 +111,7 @@ static int writebuf_from_LL(int driverID, int channel, int ack,
 void gigaset_skb_sent(struct bc_state *bcs, struct sk_buff *skb)
 {
 	isdn_if *iif = bcs->cs->iif;
+	unsigned char *ack_header = skb_mac_header(skb);
 	unsigned len;
 	isdn_ctrl response;
 
@@ -108,8 +121,7 @@ void gigaset_skb_sent(struct bc_state *bcs, struct sk_buff *skb)
 		dev_warn(bcs->cs->dev, "%s: skb->len==%d\n",
 			 __func__, skb->len);
 
-	len = (unsigned char) skb->head[0] |
-	      (unsigned) (unsigned char) skb->head[1] << 8;
+	len = ack_header[0] + ((unsigned) ack_header[1] << 8);
 	if (len) {
 		gig_dbg(DEBUG_MCMD, "ACKing to LL (id: %d, ch: %d, sz: %u)",
 			bcs->cs->myid, bcs->channel, len);
diff --git a/drivers/isdn/gigaset/isocdata.c b/drivers/isdn/gigaset/isocdata.c
index 7dabfd3..bc41611 100644
--- a/drivers/isdn/gigaset/isocdata.c
+++ b/drivers/isdn/gigaset/isocdata.c
@@ -576,12 +576,12 @@ static inline void hdlc_done(struct bc_state *bcs)
 		dev_notice(cs->dev, "received short frame (%d octets)\n",
 			   procskb->len);
 		bcs->hw.bas->runts++;
-		dev_kfree_skb(procskb);
+		dev_kfree_skb_any(procskb);
 		gigaset_isdn_rcv_err(bcs);
 	} else if (bcs->fcs != PPP_GOODFCS) {
 		dev_notice(cs->dev, "frame check error (0x%04x)\n", bcs->fcs);
 		bcs->hw.bas->fcserrs++;
-		dev_kfree_skb(procskb);
+		dev_kfree_skb_any(procskb);
 		gigaset_isdn_rcv_err(bcs);
 	} else {
 		len = procskb->len;
@@ -985,7 +985,7 @@ void gigaset_isoc_input(struct inbuf_t *inbuf)
  * Called by LL to queue an skb for sending, and start transmission if
  * necessary.
  * Once the payload data has been transmitted completely, gigaset_skb_sent()
- * will be called with the first cs->hw_hdr_len bytes of skb->head preserved.
+ * will be called with the skb's link layer header preserved.
  *
  * Return value:
  *	number of bytes accepted for sending (skb->len) if ok,
-- 
1.6.2.1.214.ge986c
