From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 4/9] usb_gigaset: code cleanup
Date: Sun, 25 Oct 2009 20:30:07 +0100 (CET)
Message-ID: <20091023-patch-gigaset-04.tilman@imap.cc>
References: <20091023-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754094AbZJYTaZ@vger.kernel.org>
In-Reply-To: <20091023-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reorganize the code of the Gigaset M10x driver to make it more
readable, less redundant, better aligned to the style of other
parts of the driver, and cause fewer checkpatch.pl complaints.

Impact: code reorganization, no functional change
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/asyncdata.c   |  573 +++++++++++++++++++-----------------
 drivers/isdn/gigaset/common.c      |   34 +--
 drivers/isdn/gigaset/gigaset.h     |   13 +-
 drivers/isdn/gigaset/usb-gigaset.c |   69 +++---
 4 files changed, 358 insertions(+), 331 deletions(-)

diff --git a/drivers/isdn/gigaset/asyncdata.c b/drivers/isdn/gigaset/asyncdata.c
index 256fc48..ccb2a7b 100644
--- a/drivers/isdn/gigaset/asyncdata.c
+++ b/drivers/isdn/gigaset/asyncdata.c
@@ -19,7 +19,7 @@
 
 /* check if byte must be stuffed/escaped
  * I'm not sure which data should be encoded.
- * Therefore I will go the hard way and decode every value
+ * Therefore I will go the hard way and encode every value
  * less than 0x20, the flag sequence and the control escape char.
  */
 static inline int muststuff(unsigned char c)
@@ -35,288 +35,383 @@ static inline int muststuff(unsigned char c)
 
 /* == data input =========================================================== */
 
-/* process a block of received bytes in command mode (modem response)
+/* process a block of received bytes in command mode
+ * (mstate != MS_LOCKED && (inputstate & INS_command))
+ * Append received bytes to the command response buffer and forward them
+ * line by line to the response handler. Exit whenever a mode/state change
+ * might have occurred.
  * Return value:
  *	number of processed bytes
  */
-static inline int cmd_loop(unsigned char c, unsigned char *src, int numbytes,
-			   struct inbuf_t *inbuf)
+static unsigned cmd_loop(unsigned numbytes, struct inbuf_t *inbuf)
 {
+	unsigned char *src = inbuf->data + inbuf->head;
 	struct cardstate *cs = inbuf->cs;
-	unsigned cbytes      = cs->cbytes;
-	int inputstate = inbuf->inputstate;
-	int startbytes = numbytes;
-
-	for (;;) {
-		cs->respdata[cbytes] = c;
-		if (c == 10 || c == 13) {
-			gig_dbg(DEBUG_TRANSCMD, "%s: End of Command (%d Bytes)",
+	unsigned cbytes = cs->cbytes;
+	unsigned procbytes = 0;
+	unsigned char c;
+
+	while (procbytes < numbytes) {
+		c = *src++;
+		procbytes++;
+
+		switch (c) {
+		case '\n':
+			if (cbytes == 0 && cs->respdata[0] == '\r') {
+				/* collapse LF with preceding CR */
+				cs->respdata[0] = 0;
+				break;
+			}
+			/* --v-- fall through --v-- */
+		case '\r':
+			/* end of message line, pass to response handler */
+			gig_dbg(DEBUG_TRANSCMD, "%s: End of Message (%d Bytes)",
 				__func__, cbytes);
+			if (cbytes >= MAX_RESP_SIZE) {
+				dev_warn(cs->dev, "response too large (%d)\n",
+					 cbytes);
+				cbytes = MAX_RESP_SIZE;
+			}
 			cs->cbytes = cbytes;
-			gigaset_handle_modem_response(cs); /* can change
-							      cs->dle */
+			gigaset_handle_modem_response(cs);
 			cbytes = 0;
 
-			if (cs->dle &&
-			    !(inputstate & INS_DLE_command)) {
-				inputstate &= ~INS_command;
-				break;
-			}
-		} else {
-			/* advance in line buffer, checking for overflow */
-			if (cbytes < MAX_RESP_SIZE - 1)
-				cbytes++;
-			else
-				dev_warn(cs->dev, "response too large\n");
-		}
+			/* store EOL byte for CRLF collapsing */
+			cs->respdata[0] = c;
 
-		if (!numbytes)
-			break;
-		c = *src++;
-		--numbytes;
-		if (c == DLE_FLAG &&
-		    (cs->dle || inputstate & INS_DLE_command)) {
-			inputstate |= INS_DLE_char;
-			break;
+			/* cs->dle may have changed */
+			if (cs->dle && !(inbuf->inputstate & INS_DLE_command))
+				inbuf->inputstate &= ~INS_command;
+
+			/* return for reevaluating state */
+			goto exit;
+
+		case DLE_FLAG:
+			if (inbuf->inputstate & INS_DLE_char) {
+				/* quoted DLE: clear quote flag */
+				inbuf->inputstate &= ~INS_DLE_char;
+			} else if (cs->dle ||
+				   (inbuf->inputstate & INS_DLE_command)) {
+				/* DLE escape, pass up for handling */
+				inbuf->inputstate |= INS_DLE_char;
+				goto exit;
+			}
+			/* quoted or not in DLE mode: treat as regular data */
+			/* --v-- fall through --v-- */
+		default:
+			/* append to line buffer if possible */
+			if (cbytes < MAX_RESP_SIZE)
+				cs->respdata[cbytes] = c;
+			cbytes++;
 		}
 	}
-
+exit:
 	cs->cbytes = cbytes;
-	inbuf->inputstate = inputstate;
-
-	return startbytes - numbytes;
+	return procbytes;
 }
 
-/* process a block of received bytes in lock mode (tty i/f)
+/* process a block of received bytes in lock mode
+ * All received bytes are passed unmodified to the tty i/f.
  * Return value:
  *	number of processed bytes
  */
-static inline int lock_loop(unsigned char *src, int numbytes,
-			    struct inbuf_t *inbuf)
+static unsigned lock_loop(unsigned numbytes, struct inbuf_t *inbuf)
 {
-	struct cardstate *cs = inbuf->cs;
-
-	gigaset_dbg_buffer(DEBUG_LOCKCMD, "received response",
-			   numbytes, src);
-	gigaset_if_receive(cs, src, numbytes);
+	unsigned char *src = inbuf->data + inbuf->head;
 
+	gigaset_dbg_buffer(DEBUG_LOCKCMD, "received response", numbytes, src);
+	gigaset_if_receive(inbuf->cs, src, numbytes);
 	return numbytes;
 }
 
+/* set up next receive skb for data mode
+ */
+static void new_rcv_skb(struct bc_state *bcs)
+{
+	struct cardstate *cs = bcs->cs;
+	unsigned short hw_hdr_len = cs->hw_hdr_len;
+
+	if (bcs->ignore) {
+		bcs->skb = NULL;
+		return;
+	}
+
+	bcs->skb = dev_alloc_skb(SBUFSIZE + hw_hdr_len);
+	if (bcs->skb == NULL) {
+		dev_warn(cs->dev, "could not allocate new skb\n");
+		return;
+	}
+	skb_reserve(bcs->skb, hw_hdr_len);
+}
+
 /* process a block of received bytes in HDLC data mode
+ * (mstate != MS_LOCKED && !(inputstate & INS_command) && proto2 == L2_HDLC)
  * Collect HDLC frames, undoing byte stuffing and watching for DLE escapes.
  * When a frame is complete, check the FCS and pass valid frames to the LL.
  * If DLE is encountered, return immediately to let the caller handle it.
  * Return value:
  *	number of processed bytes
- *	numbytes (all bytes processed) on error --FIXME
  */
-static inline int hdlc_loop(unsigned char c, unsigned char *src, int numbytes,
-			    struct inbuf_t *inbuf)
+static unsigned hdlc_loop(unsigned numbytes, struct inbuf_t *inbuf)
 {
 	struct cardstate *cs = inbuf->cs;
-	struct bc_state *bcs = inbuf->bcs;
+	struct bc_state *bcs = cs->bcs;
 	int inputstate = bcs->inputstate;
 	__u16 fcs = bcs->fcs;
 	struct sk_buff *skb = bcs->skb;
-	int startbytes = numbytes;
+	unsigned char *src = inbuf->data + inbuf->head;
+	unsigned procbytes = 0;
+	unsigned char c;
 
-	if (unlikely(inputstate & INS_byte_stuff)) {
+	if (inputstate & INS_byte_stuff) {
+		if (!numbytes)
+			return 0;
 		inputstate &= ~INS_byte_stuff;
 		goto byte_stuff;
 	}
-	for (;;) {
-		if (unlikely(c == PPP_ESCAPE)) {
-			if (unlikely(!numbytes)) {
-				inputstate |= INS_byte_stuff;
+
+	while (procbytes < numbytes) {
+		c = *src++;
+		procbytes++;
+		if (c == DLE_FLAG) {
+			if (inputstate & INS_DLE_char) {
+				/* quoted DLE: clear quote flag */
+				inputstate &= ~INS_DLE_char;
+			} else if (cs->dle || (inputstate & INS_DLE_command)) {
+				/* DLE escape, pass up for handling */
+				inputstate |= INS_DLE_char;
 				break;
 			}
-			c = *src++;
-			--numbytes;
-			if (unlikely(c == DLE_FLAG &&
-				     (cs->dle ||
-				      inbuf->inputstate & INS_DLE_command))) {
-				inbuf->inputstate |= INS_DLE_char;
+		}
+
+		if (c == PPP_ESCAPE) {
+			/* byte stuffing indicator: pull in next byte */
+			if (procbytes >= numbytes) {
+				/* end of buffer, save for later processing */
 				inputstate |= INS_byte_stuff;
 				break;
 			}
 byte_stuff:
+			c = *src++;
+			procbytes++;
+			if (c == DLE_FLAG) {
+				if (inputstate & INS_DLE_char) {
+					/* quoted DLE: clear quote flag */
+					inputstate &= ~INS_DLE_char;
+				} else if (cs->dle ||
+					   (inputstate & INS_DLE_command)) {
+					/* DLE escape, pass up for handling */
+					inputstate |=
+						INS_DLE_char | INS_byte_stuff;
+					break;
+				}
+			}
 			c ^= PPP_TRANS;
-			if (unlikely(!muststuff(c)))
-				gig_dbg(DEBUG_HDLC, "byte stuffed: 0x%02x", c);
-		} else if (unlikely(c == PPP_FLAG)) {
-			if (unlikely(inputstate & INS_skip_frame)) {
 #ifdef CONFIG_GIGASET_DEBUG
-				if (!(inputstate & INS_have_data)) { /* 7E 7E */
-					++bcs->emptycount;
-				} else
-					gig_dbg(DEBUG_HDLC,
-					    "7e----------------------------");
-#endif
-
-				/* end of frame */
-				gigaset_isdn_rcv_err(bcs);
-				dev_kfree_skb_any(skb);
-			} else if (!(inputstate & INS_have_data)) { /* 7E 7E */
-#ifdef CONFIG_GIGASET_DEBUG
-				++bcs->emptycount;
+			if (!muststuff(c))
+				gig_dbg(DEBUG_HDLC, "byte stuffed: 0x%02x", c);
 #endif
-				break;
-			} else {
+		} else if (c == PPP_FLAG) {
+			/* end of frame: process content if any */
+			if (inputstate & INS_have_data) {
 				gig_dbg(DEBUG_HDLC,
 					"7e----------------------------");
 
-				/* end of frame */
-				if (unlikely(fcs != PPP_GOODFCS)) {
+				/* check and pass received frame */
+				if (!skb) {
+					/* skipped frame */
+					gigaset_isdn_rcv_err(bcs);
+				} else if (skb->len < 2) {
+					/* frame too short for FCS */
+					dev_warn(cs->dev,
+						 "short frame (%d)\n",
+						 skb->len);
+					gigaset_isdn_rcv_err(bcs);
+					dev_kfree_skb_any(skb);
+				} else if (fcs != PPP_GOODFCS) {
+					/* frame check error */
 					dev_err(cs->dev,
 				"Checksum failed, %u bytes corrupted!\n",
 						skb->len);
 					gigaset_isdn_rcv_err(bcs);
 					dev_kfree_skb_any(skb);
-				} else if (likely(skb->len > 2)) {
+				} else {
+					/* good frame */
 					__skb_trim(skb, skb->len - 2);
 					gigaset_skb_rcvd(bcs, skb);
-				} else {
-					if (skb->len) {
-						dev_err(cs->dev,
-					"invalid packet size (%d)\n", skb->len);
-						gigaset_isdn_rcv_err(bcs);
-					}
-					dev_kfree_skb_any(skb);
 				}
-			}
 
-			fcs = PPP_INITFCS;
-			inputstate &= ~(INS_have_data | INS_skip_frame);
-			if (unlikely(bcs->ignore)) {
-				inputstate |= INS_skip_frame;
-				skb = NULL;
+				/* prepare reception of next frame */
+				inputstate &= ~INS_have_data;
+				new_rcv_skb(bcs);
+				skb = bcs->skb;
 			} else {
-				skb = dev_alloc_skb(SBUFSIZE + cs->hw_hdr_len);
-				if (skb != NULL) {
-					skb_reserve(skb, cs->hw_hdr_len);
-				} else {
-					dev_warn(cs->dev,
-						"could not allocate new skb\n");
-					inputstate |= INS_skip_frame;
+				/* empty frame (7E 7E) */
+#ifdef CONFIG_GIGASET_DEBUG
+				++bcs->emptycount;
+#endif
+				if (!skb) {
+					/* skipped (?) */
+					gigaset_isdn_rcv_err(bcs);
+					new_rcv_skb(bcs);
+					skb = bcs->skb;
 				}
 			}
 
-			break;
-		} else if (unlikely(muststuff(c))) {
+			fcs = PPP_INITFCS;
+			continue;
+#ifdef CONFIG_GIGASET_DEBUG
+		} else if (muststuff(c)) {
 			/* Should not happen. Possible after ZDLE=1<CR><LF>. */
 			gig_dbg(DEBUG_HDLC, "not byte stuffed: 0x%02x", c);
+#endif
 		}
 
-		/* add character */
-
+		/* regular data byte, append to skb */
 #ifdef CONFIG_GIGASET_DEBUG
-		if (unlikely(!(inputstate & INS_have_data))) {
+		if (!(inputstate & INS_have_data)) {
 			gig_dbg(DEBUG_HDLC, "7e (%d x) ================",
 				bcs->emptycount);
 			bcs->emptycount = 0;
 		}
 #endif
-
 		inputstate |= INS_have_data;
-
-		if (likely(!(inputstate & INS_skip_frame))) {
-			if (unlikely(skb->len == SBUFSIZE)) {
+		if (skb) {
+			if (skb->len == SBUFSIZE) {
 				dev_warn(cs->dev, "received packet too long\n");
 				dev_kfree_skb_any(skb);
-				skb = NULL;
-				inputstate |= INS_skip_frame;
-				break;
+				/* skip remainder of packet */
+				bcs->skb = skb = NULL;
+			} else {
+				*__skb_put(skb, 1) = c;
+				fcs = crc_ccitt_byte(fcs, c);
 			}
-			*__skb_put(skb, 1) = c;
-			fcs = crc_ccitt_byte(fcs, c);
-		}
-
-		if (unlikely(!numbytes))
-			break;
-		c = *src++;
-		--numbytes;
-		if (unlikely(c == DLE_FLAG &&
-			     (cs->dle ||
-			      inbuf->inputstate & INS_DLE_command))) {
-			inbuf->inputstate |= INS_DLE_char;
-			break;
 		}
 	}
+
 	bcs->inputstate = inputstate;
 	bcs->fcs = fcs;
-	bcs->skb = skb;
-	return startbytes - numbytes;
+	return procbytes;
 }
 
 /* process a block of received bytes in transparent data mode
+ * (mstate != MS_LOCKED && !(inputstate & INS_command) && proto2 != L2_HDLC)
  * Invert bytes, undoing byte stuffing and watching for DLE escapes.
  * If DLE is encountered, return immediately to let the caller handle it.
  * Return value:
  *	number of processed bytes
- *	numbytes (all bytes processed) on error --FIXME
  */
-static inline int iraw_loop(unsigned char c, unsigned char *src, int numbytes,
-			    struct inbuf_t *inbuf)
+static unsigned iraw_loop(unsigned numbytes, struct inbuf_t *inbuf)
 {
 	struct cardstate *cs = inbuf->cs;
-	struct bc_state *bcs = inbuf->bcs;
+	struct bc_state *bcs = cs->bcs;
 	int inputstate = bcs->inputstate;
 	struct sk_buff *skb = bcs->skb;
-	int startbytes = numbytes;
+	unsigned char *src = inbuf->data + inbuf->head;
+	unsigned procbytes = 0;
+	unsigned char c;
 
-	for (;;) {
-		/* add character */
-		inputstate |= INS_have_data;
+	if (!skb) {
+		/* skip this block */
+		new_rcv_skb(bcs);
+		return numbytes;
+	}
 
-		if (likely(!(inputstate & INS_skip_frame))) {
-			if (unlikely(skb->len == SBUFSIZE)) {
-				//FIXME just pass skb up and allocate a new one
-				dev_warn(cs->dev, "received packet too long\n");
-				dev_kfree_skb_any(skb);
-				skb = NULL;
-				inputstate |= INS_skip_frame;
+	while (procbytes < numbytes && skb->len < SBUFSIZE) {
+		c = *src++;
+		procbytes++;
+
+		if (c == DLE_FLAG) {
+			if (inputstate & INS_DLE_char) {
+				/* quoted DLE: clear quote flag */
+				inputstate &= ~INS_DLE_char;
+			} else if (cs->dle || (inputstate & INS_DLE_command)) {
+				/* DLE escape, pass up for handling */
+				inputstate |= INS_DLE_char;
 				break;
 			}
-			*__skb_put(skb, 1) = bitrev8(c);
 		}
 
-		if (unlikely(!numbytes))
-			break;
-		c = *src++;
-		--numbytes;
-		if (unlikely(c == DLE_FLAG &&
-			     (cs->dle ||
-			      inbuf->inputstate & INS_DLE_command))) {
-			inbuf->inputstate |= INS_DLE_char;
-			break;
-		}
+		/* regular data byte: append to current skb */
+		inputstate |= INS_have_data;
+		*__skb_put(skb, 1) = bitrev8(c);
 	}
 
 	/* pass data up */
-	if (likely(inputstate & INS_have_data)) {
-		if (likely(!(inputstate & INS_skip_frame))) {
-			gigaset_skb_rcvd(bcs, skb);
-		}
-		inputstate &= ~(INS_have_data | INS_skip_frame);
-		if (unlikely(bcs->ignore)) {
-			inputstate |= INS_skip_frame;
-			skb = NULL;
-		} else {
-			skb = dev_alloc_skb(SBUFSIZE + cs->hw_hdr_len);
-			if (skb != NULL) {
-				skb_reserve(skb, cs->hw_hdr_len);
-			} else {
-				dev_warn(cs->dev,
-					 "could not allocate new skb\n");
-				inputstate |= INS_skip_frame;
+	if (inputstate & INS_have_data) {
+		gigaset_skb_rcvd(bcs, skb);
+		inputstate &= ~INS_have_data;
+		new_rcv_skb(bcs);
+	}
+
+	bcs->inputstate = inputstate;
+	return procbytes;
+}
+
+/* process DLE escapes
+ * Called whenever a DLE sequence might be encountered in the input stream.
+ * Either processes the entire DLE sequence or, if that isn't possible,
+ * notes the fact that an initial DLE has been received in the INS_DLE_char
+ * inputstate flag and resumes processing of the sequence on the next call.
+ */
+static void handle_dle(struct inbuf_t *inbuf)
+{
+	struct cardstate *cs = inbuf->cs;
+
+	if (cs->mstate == MS_LOCKED)
+		return;		/* no DLE processing in lock mode */
+
+	if (!(inbuf->inputstate & INS_DLE_char)) {
+		/* no DLE pending */
+		if (inbuf->data[inbuf->head] == DLE_FLAG &&
+		    (cs->dle || inbuf->inputstate & INS_DLE_command)) {
+			/* start of DLE sequence */
+			inbuf->head++;
+			if (inbuf->head == inbuf->tail ||
+			    inbuf->head == RBUFSIZE) {
+				/* end of buffer, save for later processing */
+				inbuf->inputstate |= INS_DLE_char;
+				return;
 			}
+		} else {
+			/* regular data byte */
+			return;
 		}
 	}
 
-	bcs->inputstate = inputstate;
-	bcs->skb = skb;
-	return startbytes - numbytes;
+	/* consume pending DLE */
+	inbuf->inputstate &= ~INS_DLE_char;
+
+	switch (inbuf->data[inbuf->head]) {
+	case 'X':	/* begin of event message */
+		if (inbuf->inputstate & INS_command)
+			dev_notice(cs->dev,
+				   "received <DLE>X in command mode\n");
+		inbuf->inputstate |= INS_command | INS_DLE_command;
+		inbuf->head++;	/* byte consumed */
+		break;
+	case '.':	/* end of event message */
+		if (!(inbuf->inputstate & INS_DLE_command))
+			dev_notice(cs->dev,
+				   "received <DLE>. without <DLE>X\n");
+		inbuf->inputstate &= ~INS_DLE_command;
+		/* return to data mode if in DLE mode */
+		if (cs->dle)
+			inbuf->inputstate &= ~INS_command;
+		inbuf->head++;	/* byte consumed */
+		break;
+	case DLE_FLAG:	/* DLE in data stream */
+		/* mark as quoted */
+		inbuf->inputstate |= INS_DLE_char;
+		if (!(cs->dle || inbuf->inputstate & INS_DLE_command))
+			dev_notice(cs->dev,
+				   "received <DLE><DLE> not in DLE mode\n");
+		break;	/* quoted byte left in buffer */
+	default:
+		dev_notice(cs->dev, "received <DLE><%02x>\n",
+			   inbuf->data[inbuf->head]);
+		/* quoted byte left in buffer */
+	}
 }
 
 /**
@@ -330,94 +425,39 @@ static inline int iraw_loop(unsigned char c, unsigned char *src, int numbytes,
  */
 void gigaset_m10x_input(struct inbuf_t *inbuf)
 {
-	struct cardstate *cs;
-	unsigned tail, head, numbytes;
-	unsigned char *src, c;
-	int procbytes;
-
-	head = inbuf->head;
-	tail = inbuf->tail;
-	gig_dbg(DEBUG_INTR, "buffer state: %u -> %u", head, tail);
-
-	if (head != tail) {
-		cs = inbuf->cs;
-		src = inbuf->data + head;
-		numbytes = (head > tail ? RBUFSIZE : tail) - head;
-		gig_dbg(DEBUG_INTR, "processing %u bytes", numbytes);
+	struct cardstate *cs = inbuf->cs;
+	unsigned numbytes, procbytes;
 
-		while (numbytes) {
-			if (cs->mstate == MS_LOCKED) {
-				procbytes = lock_loop(src, numbytes, inbuf);
-				src += procbytes;
-				numbytes -= procbytes;
-			} else {
-				c = *src++;
-				--numbytes;
-				if (c == DLE_FLAG && (cs->dle ||
-				    inbuf->inputstate & INS_DLE_command)) {
-					if (!(inbuf->inputstate & INS_DLE_char)) {
-						inbuf->inputstate |= INS_DLE_char;
-						goto nextbyte;
-					}
-					/* <DLE> <DLE> => <DLE> in data stream */
-					inbuf->inputstate &= ~INS_DLE_char;
-				}
+	gig_dbg(DEBUG_INTR, "buffer state: %u -> %u", inbuf->head, inbuf->tail);
 
-				if (!(inbuf->inputstate & INS_DLE_char)) {
-
-					/* FIXME use function pointers?  */
-					if (inbuf->inputstate & INS_command)
-						procbytes = cmd_loop(c, src, numbytes, inbuf);
-					else if (inbuf->bcs->proto2 == L2_HDLC)
-						procbytes = hdlc_loop(c, src, numbytes, inbuf);
-					else
-						procbytes = iraw_loop(c, src, numbytes, inbuf);
-
-					src += procbytes;
-					numbytes -= procbytes;
-				} else {  /* DLE char */
-					inbuf->inputstate &= ~INS_DLE_char;
-					switch (c) {
-					case 'X': /*begin of command*/
-						if (inbuf->inputstate & INS_command)
-							dev_warn(cs->dev,
-					"received <DLE> 'X' in command mode\n");
-						inbuf->inputstate |=
-							INS_command | INS_DLE_command;
-						break;
-					case '.': /*end of command*/
-						if (!(inbuf->inputstate & INS_command))
-							dev_warn(cs->dev,
-					"received <DLE> '.' in hdlc mode\n");
-						inbuf->inputstate &= cs->dle ?
-							~(INS_DLE_command|INS_command)
-							: ~INS_DLE_command;
-						break;
-					//case DLE_FLAG: /*DLE_FLAG in data stream*/ /* schon oben behandelt! */
-					default:
-						dev_err(cs->dev,
-						      "received 0x10 0x%02x!\n",
-							(int) c);
-						/* FIXME: reset driver?? */
-					}
-				}
-			}
-nextbyte:
-			if (!numbytes) {
-				/* end of buffer, check for wrap */
-				if (head > tail) {
-					head = 0;
-					src = inbuf->data;
-					numbytes = tail;
-				} else {
-					head = tail;
-					break;
-				}
-			}
-		}
+	while (inbuf->head != inbuf->tail) {
+		/* check for DLE escape */
+		handle_dle(inbuf);
 
-		gig_dbg(DEBUG_INTR, "setting head to %u", head);
-		inbuf->head = head;
+		/* process a contiguous block of bytes */
+		numbytes = (inbuf->head > inbuf->tail ?
+			    RBUFSIZE : inbuf->tail) - inbuf->head;
+		gig_dbg(DEBUG_INTR, "processing %u bytes", numbytes);
+		/*
+		 * numbytes may be 0 if handle_dle() ate the last byte.
+		 * This does no harm, *_loop() will just return 0 immediately.
+		 */
+
+		if (cs->mstate == MS_LOCKED)
+			procbytes = lock_loop(numbytes, inbuf);
+		else if (inbuf->inputstate & INS_command)
+			procbytes = cmd_loop(numbytes, inbuf);
+		else if (cs->bcs->proto2 == L2_HDLC)
+			procbytes = hdlc_loop(numbytes, inbuf);
+		else
+			procbytes = iraw_loop(numbytes, inbuf);
+		inbuf->head += procbytes;
+
+		/* check for buffer wraparound */
+		if (inbuf->head >= RBUFSIZE)
+			inbuf->head = 0;
+
+		gig_dbg(DEBUG_INTR, "head set to %u", inbuf->head);
 	}
 }
 EXPORT_SYMBOL_GPL(gigaset_m10x_input);
@@ -563,6 +603,7 @@ static struct sk_buff *iraw_encode(struct sk_buff *skb)
  */
 int gigaset_m10x_send_skb(struct bc_state *bcs, struct sk_buff *skb)
 {
+	struct cardstate *cs = bcs->cs;
 	unsigned len = skb->len;
 	unsigned long flags;
 
@@ -571,16 +612,16 @@ int gigaset_m10x_send_skb(struct bc_state *bcs, struct sk_buff *skb)
 	else
 		skb = iraw_encode(skb);
 	if (!skb) {
-		dev_err(bcs->cs->dev,
+		dev_err(cs->dev,
 			"unable to allocate memory for encoding!\n");
 		return -ENOMEM;
 	}
 
 	skb_queue_tail(&bcs->squeue, skb);
-	spin_lock_irqsave(&bcs->cs->lock, flags);
-	if (bcs->cs->connected)
-		tasklet_schedule(&bcs->cs->write_tasklet);
-	spin_unlock_irqrestore(&bcs->cs->lock, flags);
+	spin_lock_irqsave(&cs->lock, flags);
+	if (cs->connected)
+		tasklet_schedule(&cs->write_tasklet);
+	spin_unlock_irqrestore(&cs->lock, flags);
 
 	return len;	/* ok so far */
 }
diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 1d2ae2e..690ac74 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -400,9 +400,9 @@ static void gigaset_freebcs(struct bc_state *bcs)
 	gig_dbg(DEBUG_INIT, "clearing bcs[%d]->at_state", bcs->channel);
 	clear_at_state(&bcs->at_state);
 	gig_dbg(DEBUG_INIT, "freeing bcs[%d]->skb", bcs->channel);
+	dev_kfree_skb(bcs->skb);
+	bcs->skb = NULL;
 
-	if (bcs->skb)
-		dev_kfree_skb(bcs->skb);
 	for (i = 0; i < AT_NUM; ++i) {
 		kfree(bcs->commands[i]);
 		bcs->commands[i] = NULL;
@@ -560,16 +560,13 @@ void gigaset_at_init(struct at_state_t *at_state, struct bc_state *bcs,
 }
 
 
-static void gigaset_inbuf_init(struct inbuf_t *inbuf, struct bc_state *bcs,
-			       struct cardstate *cs, int inputstate)
+static void gigaset_inbuf_init(struct inbuf_t *inbuf, struct cardstate *cs)
 /* inbuf->read must be allocated before! */
 {
 	inbuf->head = 0;
 	inbuf->tail = 0;
 	inbuf->cs = cs;
-	inbuf->bcs = bcs; /*base driver: NULL*/
-	inbuf->rcvbuf = NULL;
-	inbuf->inputstate = inputstate;
+	inbuf->inputstate = INS_command;
 }
 
 /**
@@ -644,16 +641,13 @@ static struct bc_state *gigaset_initbcs(struct bc_state *bcs,
 	bcs->fcs = PPP_INITFCS;
 	bcs->inputstate = 0;
 	if (cs->ignoreframes) {
-		bcs->inputstate |= INS_skip_frame;
 		bcs->skb = NULL;
 	} else {
 		bcs->skb = dev_alloc_skb(SBUFSIZE + cs->hw_hdr_len);
 		if (bcs->skb != NULL)
 			skb_reserve(bcs->skb, cs->hw_hdr_len);
-		else {
+		else
 			pr_err("out of memory\n");
-			bcs->inputstate |= INS_skip_frame;
-		}
 	}
 
 	bcs->channel = channel;
@@ -674,8 +668,8 @@ static struct bc_state *gigaset_initbcs(struct bc_state *bcs,
 	gig_dbg(DEBUG_INIT, "  failed");
 
 	gig_dbg(DEBUG_INIT, "  freeing bcs[%d]->skb", channel);
-	if (bcs->skb)
-		dev_kfree_skb(bcs->skb);
+	dev_kfree_skb(bcs->skb);
+	bcs->skb = NULL;
 
 	return NULL;
 }
@@ -764,10 +758,7 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 	cs->cbytes = 0;
 
 	gig_dbg(DEBUG_INIT, "setting up inbuf");
-	if (onechannel) {			//FIXME distinction necessary?
-		gigaset_inbuf_init(cs->inbuf, cs->bcs, cs, INS_command);
-	} else
-		gigaset_inbuf_init(cs->inbuf, NULL,    cs, INS_command);
+	gigaset_inbuf_init(cs->inbuf, cs);
 
 	cs->connected = 0;
 	cs->isdn_up = 0;
@@ -854,9 +845,10 @@ void gigaset_bcs_reinit(struct bc_state *bcs)
 	bcs->chstate = 0;
 
 	bcs->ignore = cs->ignoreframes;
-	if (bcs->ignore)
-		bcs->inputstate |= INS_skip_frame;
-
+	if (bcs->ignore) {
+		dev_kfree_skb(bcs->skb);
+		bcs->skb = NULL;
+	}
 
 	cs->ops->reinitbcshw(bcs);
 }
@@ -877,8 +869,6 @@ static void cleanup_cs(struct cardstate *cs)
 	free_strings(&cs->at_state);
 	gigaset_at_init(&cs->at_state, NULL, cs, 0);
 
-	kfree(cs->inbuf->rcvbuf);
-	cs->inbuf->rcvbuf = NULL;
 	cs->inbuf->inputstate = INS_command;
 	cs->inbuf->head = 0;
 	cs->inbuf->tail = 0;
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index c59216b..18bff9f 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -223,12 +223,11 @@ void gigaset_dbg_buffer(enum debuglevel level, const unsigned char *msg,
 #define EV_BC_CLOSED	-118
 
 /* input state */
-#define INS_command	0x0001
-#define INS_DLE_char	0x0002
+#define INS_command	0x0001	/* receiving messages (not payload data) */
+#define INS_DLE_char	0x0002	/* DLE flag received (in DLE mode) */
 #define INS_byte_stuff	0x0004
 #define INS_have_data	0x0008
-#define INS_skip_frame	0x0010
-#define INS_DLE_command	0x0020
+#define INS_DLE_command	0x0020	/* DLE message start (<DLE> X) received */
 #define INS_flag_hunt	0x0040
 
 /* channel state */
@@ -290,8 +289,6 @@ extern struct reply_t gigaset_tab_cid[];
 extern struct reply_t gigaset_tab_nocid[];
 
 struct inbuf_t {
-	unsigned char		*rcvbuf;	/* usb-gigaset receive buffer */
-	struct bc_state		*bcs;
 	struct cardstate	*cs;
 	int			inputstate;
 	int			head, tail;
@@ -483,8 +480,8 @@ struct cardstate {
 
 	struct timer_list timer;
 	int retry_count;
-	int dle;			/* !=0 if modem commands/responses are
-					   dle encoded */
+	int dle;			/* !=0 if DLE mode is active
+					   (ZDLE=1 received -- M10x only) */
 	int cur_at_seq;			/* sequence of AT commands being
 					   processed */
 	int curchannel;			/* channel those commands are meant
diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigaset/usb-gigaset.c
index 4deb1ab..f56b2a8 100644
--- a/drivers/isdn/gigaset/usb-gigaset.c
+++ b/drivers/isdn/gigaset/usb-gigaset.c
@@ -43,14 +43,14 @@ MODULE_PARM_DESC(cidmode, "Call-ID mode");
 #define GIGASET_MODULENAME "usb_gigaset"
 #define GIGASET_DEVNAME    "ttyGU"
 
-#define IF_WRITEBUF 2000 //FIXME  // WAKEUP_CHARS: 256
+#define IF_WRITEBUF 2000	/* arbitrary limit */
 
 /* Values for the Gigaset M105 Data */
 #define USB_M105_VENDOR_ID	0x0681
 #define USB_M105_PRODUCT_ID	0x0009
 
 /* table of devices that work with this driver */
-static const struct usb_device_id gigaset_table [] = {
+static const struct usb_device_id gigaset_table[] = {
 	{ USB_DEVICE(USB_M105_VENDOR_ID, USB_M105_PRODUCT_ID) },
 	{ }					/* Terminating entry */
 };
@@ -97,8 +97,8 @@ MODULE_DEVICE_TABLE(usb, gigaset_table);
  *       41 19 -- -- -- -- 06 00 00 00 00 xx 11 13
  *            Used after every "configuration sequence" (RQ 12, RQs 01/03/13).
  *            xx is usually 0x00 but was 0x7e before starting data transfer
- *            in unimodem mode. So, this might be an array of characters that need
- *            special treatment ("commit all bufferd data"?), 11=^Q, 13=^S.
+ *            in unimodem mode. So, this might be an array of characters that
+ *            need special treatment ("commit all bufferd data"?), 11=^Q, 13=^S.
  *
  * Unimodem mode: use "modprobe ppp_async flag_time=0" as the device _needs_ two
  * flags per packet.
@@ -114,7 +114,7 @@ static int gigaset_suspend(struct usb_interface *intf, pm_message_t message);
 static int gigaset_resume(struct usb_interface *intf);
 static int gigaset_pre_reset(struct usb_interface *intf);
 
-static struct gigaset_driver *driver = NULL;
+static struct gigaset_driver *driver;
 
 /* usb specific object needed to register this driver with the usb subsystem */
 static struct usb_driver gigaset_usb_driver = {
@@ -141,6 +141,7 @@ struct usb_cardstate {
 	struct urb		*bulk_out_urb;
 
 	/* Input buffer */
+	unsigned char		*rcvbuf;
 	int			rcvbuf_size;
 	struct urb		*read_urb;
 	__u8			int_in_endpointAddr;
@@ -164,13 +165,11 @@ static int gigaset_set_modem_ctrl(struct cardstate *cs, unsigned old_state,
 	val = tiocm_to_gigaset(new_state);
 
 	gig_dbg(DEBUG_USBREQ, "set flags 0x%02x with mask 0x%02x", val, mask);
-	// don't use this in an interrupt/BH
 	r = usb_control_msg(udev, usb_sndctrlpipe(udev, 0), 7, 0x41,
 			    (val & 0xff) | ((mask & 0xff) << 8), 0,
 			    NULL, 0, 2000 /* timeout? */);
 	if (r < 0)
 		return r;
-	//..
 	return 0;
 }
 
@@ -220,7 +219,6 @@ static int gigaset_baud_rate(struct cardstate *cs, unsigned cflag)
 	cflag &= CBAUD;
 
 	switch (cflag) {
-	//FIXME more values?
 	case    B300: rate =     300; break;
 	case    B600: rate =     600; break;
 	case   B1200: rate =    1200; break;
@@ -273,7 +271,7 @@ static int gigaset_set_line_ctrl(struct cardstate *cs, unsigned cflag)
 	/* set the number of stop bits */
 	if (cflag & CSTOPB) {
 		if ((cflag & CSIZE) == CS5)
-			val |= 1; /* 1.5 stop bits */ //FIXME is this okay?
+			val |= 1; /* 1.5 stop bits */
 		else
 			val |= 2; /* 2 stop bits */
 	}
@@ -282,7 +280,7 @@ static int gigaset_set_line_ctrl(struct cardstate *cs, unsigned cflag)
 }
 
 
- /*================================================================================================================*/
+/*============================================================================*/
 static int gigaset_init_bchannel(struct bc_state *bcs)
 {
 	/* nothing to do for M10x */
@@ -344,7 +342,6 @@ static void gigaset_modem_fill(unsigned long data)
 			if (write_modem(cs) < 0) {
 				gig_dbg(DEBUG_OUTPUT,
 					"modem_fill: write_modem failed");
-				// FIXME should we tell the LL?
 				again = 1; /* no callback will be called! */
 			}
 		}
@@ -356,8 +353,8 @@ static void gigaset_modem_fill(unsigned long data)
  */
 static void gigaset_read_int_callback(struct urb *urb)
 {
-	struct inbuf_t *inbuf = urb->context;
-	struct cardstate *cs = inbuf->cs;
+	struct cardstate *cs = urb->context;
+	struct inbuf_t *inbuf = cs->inbuf;
 	int status = urb->status;
 	int r;
 	unsigned numbytes;
@@ -368,7 +365,7 @@ static void gigaset_read_int_callback(struct urb *urb)
 		numbytes = urb->actual_length;
 
 		if (numbytes) {
-			src = inbuf->rcvbuf;
+			src = cs->hw.usb->rcvbuf;
 			if (unlikely(*src))
 				dev_warn(cs->dev,
 				    "%s: There was no leading 0, but 0x%02x!\n",
@@ -440,7 +437,7 @@ static int send_cb(struct cardstate *cs, struct cmdbuf_t *cb)
 	struct cmdbuf_t *tcb;
 	unsigned long flags;
 	int count;
-	int status = -ENOENT; // FIXME
+	int status = -ENOENT;
 	struct usb_cardstate *ucs = cs->hw.usb;
 
 	do {
@@ -480,7 +477,9 @@ static int send_cb(struct cardstate *cs, struct cmdbuf_t *cb)
 			ucs->busy = 1;
 
 			spin_lock_irqsave(&cs->lock, flags);
-			status = cs->connected ? usb_submit_urb(ucs->bulk_out_urb, GFP_ATOMIC) : -ENODEV;
+			status = cs->connected ?
+				usb_submit_urb(ucs->bulk_out_urb, GFP_ATOMIC) :
+				-ENODEV;
 			spin_unlock_irqrestore(&cs->lock, flags);
 
 			if (status) {
@@ -510,8 +509,8 @@ static int gigaset_write_cmd(struct cardstate *cs, const unsigned char *buf,
 
 	if (len <= 0)
 		return 0;
-
-	if (!(cb = kmalloc(sizeof(struct cmdbuf_t) + len, GFP_ATOMIC))) {
+	cb = kmalloc(sizeof(struct cmdbuf_t) + len, GFP_ATOMIC);
+	if (!cb) {
 		dev_err(cs->dev, "%s: out of memory\n", __func__);
 		return -ENOMEM;
 	}
@@ -637,9 +636,7 @@ static int write_modem(struct cardstate *cs)
 		return -EINVAL;
 	}
 
-	/* Copy data to bulk out buffer and  // FIXME copying not necessary
-	 * transmit data
-	 */
+	/* Copy data to bulk out buffer and transmit data */
 	count = min(bcs->tx_skb->len, (unsigned) ucs->bulk_out_size);
 	skb_copy_from_linear_data(bcs->tx_skb, ucs->bulk_out_buffer, count);
 	skb_pull(bcs->tx_skb, count);
@@ -650,7 +647,8 @@ static int write_modem(struct cardstate *cs)
 	if (cs->connected) {
 		usb_fill_bulk_urb(ucs->bulk_out_urb, ucs->udev,
 				  usb_sndbulkpipe(ucs->udev,
-						  ucs->bulk_out_endpointAddr & 0x0f),
+						  ucs->bulk_out_endpointAddr &
+						  0x0f),
 				  ucs->bulk_out_buffer, count,
 				  gigaset_write_bulk_callback, cs);
 		ret = usb_submit_urb(ucs->bulk_out_urb, GFP_ATOMIC);
@@ -666,7 +664,7 @@ static int write_modem(struct cardstate *cs)
 
 	if (!bcs->tx_skb->len) {
 		/* skb sent completely */
-		gigaset_skb_sent(bcs, bcs->tx_skb); //FIXME also, when ret<0?
+		gigaset_skb_sent(bcs, bcs->tx_skb);
 
 		gig_dbg(DEBUG_INTR, "kfree skb (Adr: %lx)!",
 			(unsigned long) bcs->tx_skb);
@@ -763,8 +761,8 @@ static int gigaset_probe(struct usb_interface *interface,
 	buffer_size = le16_to_cpu(endpoint->wMaxPacketSize);
 	ucs->rcvbuf_size = buffer_size;
 	ucs->int_in_endpointAddr = endpoint->bEndpointAddress;
-	cs->inbuf[0].rcvbuf = kmalloc(buffer_size, GFP_KERNEL);
-	if (!cs->inbuf[0].rcvbuf) {
+	ucs->rcvbuf = kmalloc(buffer_size, GFP_KERNEL);
+	if (!ucs->rcvbuf) {
 		dev_err(cs->dev, "Couldn't allocate rcvbuf\n");
 		retval = -ENOMEM;
 		goto error;
@@ -773,9 +771,9 @@ static int gigaset_probe(struct usb_interface *interface,
 	usb_fill_int_urb(ucs->read_urb, udev,
 			 usb_rcvintpipe(udev,
 					endpoint->bEndpointAddress & 0x0f),
-			 cs->inbuf[0].rcvbuf, buffer_size,
+			 ucs->rcvbuf, buffer_size,
 			 gigaset_read_int_callback,
-			 cs->inbuf + 0, endpoint->bInterval);
+			 cs, endpoint->bInterval);
 
 	retval = usb_submit_urb(ucs->read_urb, GFP_KERNEL);
 	if (retval) {
@@ -789,7 +787,7 @@ static int gigaset_probe(struct usb_interface *interface,
 
 	if (!gigaset_start(cs)) {
 		tasklet_kill(&cs->write_tasklet);
-		retval = -ENODEV; //FIXME
+		retval = -ENODEV;
 		goto error;
 	}
 	return 0;
@@ -798,11 +796,11 @@ error:
 	usb_kill_urb(ucs->read_urb);
 	kfree(ucs->bulk_out_buffer);
 	usb_free_urb(ucs->bulk_out_urb);
-	kfree(cs->inbuf[0].rcvbuf);
+	kfree(ucs->rcvbuf);
 	usb_free_urb(ucs->read_urb);
 	usb_set_intfdata(interface, NULL);
 	ucs->read_urb = ucs->bulk_out_urb = NULL;
-	cs->inbuf[0].rcvbuf = ucs->bulk_out_buffer = NULL;
+	ucs->rcvbuf = ucs->bulk_out_buffer = NULL;
 	usb_put_dev(ucs->udev);
 	ucs->udev = NULL;
 	ucs->interface = NULL;
@@ -831,10 +829,10 @@ static void gigaset_disconnect(struct usb_interface *interface)
 
 	kfree(ucs->bulk_out_buffer);
 	usb_free_urb(ucs->bulk_out_urb);
-	kfree(cs->inbuf[0].rcvbuf);
+	kfree(ucs->rcvbuf);
 	usb_free_urb(ucs->read_urb);
 	ucs->read_urb = ucs->bulk_out_urb = NULL;
-	cs->inbuf[0].rcvbuf = ucs->bulk_out_buffer = NULL;
+	ucs->rcvbuf = ucs->bulk_out_buffer = NULL;
 
 	usb_put_dev(ucs->udev);
 	ucs->interface = NULL;
@@ -916,9 +914,10 @@ static int __init usb_gigaset_init(void)
 	int result;
 
 	/* allocate memory for our driver state and intialize it */
-	if ((driver = gigaset_initdriver(GIGASET_MINOR, GIGASET_MINORS,
-				       GIGASET_MODULENAME, GIGASET_DEVNAME,
-				       &ops, THIS_MODULE)) == NULL)
+	driver = gigaset_initdriver(GIGASET_MINOR, GIGASET_MINORS,
+				    GIGASET_MODULENAME, GIGASET_DEVNAME,
+				    &ops, THIS_MODULE);
+	if (driver == NULL)
 		goto error;
 
 	/* register this driver with the USB subsystem */
-- 
1.6.2.1.214.ge986c
