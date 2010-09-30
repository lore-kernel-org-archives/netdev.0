From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 9/9] isdn/gigaset: improve bas_gigaset USB error reporting
Date: Fri,  1 Oct 2010 01:35:52 +0200 (CEST)
Message-ID: <20100930-patch-gigaset-09.tilman@imap.cc>
References: <20100930-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100930-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rephrase some USB error messages to make them clearer and more consistent.
Downgrade some warning messages that may occur during normal operation to
debug messages.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/bas-gigaset.c |  112 +++++++++++++++++++----------------
 1 files changed, 61 insertions(+), 51 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 71e3fde..178942a 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -172,7 +172,7 @@ static char *get_usb_rcmsg(int rc)
 	case -EAGAIN:
 		return "start frame too early or too much scheduled";
 	case -EFBIG:
-		return "too many isochronous frames requested";
+		return "too many isoc frames requested";
 	case -EPIPE:
 		return "endpoint stalled";
 	case -EMSGSIZE:
@@ -203,13 +203,13 @@ static char *get_usb_statmsg(int status)
 	case -ENOENT:
 		return "unlinked (sync)";
 	case -EINPROGRESS:
-		return "pending";
+		return "URB still pending";
 	case -EPROTO:
-		return "bit stuffing error, timeout, or unknown USB error";
+		return "bitstuff error, timeout, or unknown USB error";
 	case -EILSEQ:
 		return "CRC mismatch, timeout, or unknown USB error";
 	case -ETIME:
-		return "timed out";
+		return "USB response timeout";
 	case -EPIPE:
 		return "endpoint stalled";
 	case -ECOMM:
@@ -217,15 +217,15 @@ static char *get_usb_statmsg(int status)
 	case -ENOSR:
 		return "OUT buffer underrun";
 	case -EOVERFLOW:
-		return "too much data";
+		return "endpoint babble";
 	case -EREMOTEIO:
-		return "short packet detected";
+		return "short packet";
 	case -ENODEV:
 		return "device removed";
 	case -EXDEV:
-		return "partial isochronous transfer";
+		return "partial isoc transfer";
 	case -EINVAL:
-		return "invalid argument";
+		return "ISO madness";
 	case -ECONNRESET:
 		return "unlinked (async)";
 	case -ESHUTDOWN:
@@ -872,6 +872,7 @@ static void read_iso_callback(struct urb *urb)
 		tasklet_hi_schedule(&ubc->rcvd_tasklet);
 	} else {
 		/* tasklet still busy, drop data and resubmit URB */
+		gig_dbg(DEBUG_ISO, "%s: overrun", __func__);
 		ubc->loststatus = status;
 		for (i = 0; i < BAS_NUMFRAMES; i++) {
 			ubc->isoinlost += urb->iso_frame_desc[i].actual_length;
@@ -887,13 +888,11 @@ static void read_iso_callback(struct urb *urb)
 			urb->dev = bcs->cs->hw.bas->udev;
 			urb->transfer_flags = URB_ISO_ASAP;
 			urb->number_of_packets = BAS_NUMFRAMES;
-			gig_dbg(DEBUG_ISO, "%s: isoc read overrun/resubmit",
-				__func__);
 			rc = usb_submit_urb(urb, GFP_ATOMIC);
 			if (unlikely(rc != 0 && rc != -ENODEV)) {
 				dev_err(bcs->cs->dev,
-					"could not resubmit isochronous read "
-					"URB: %s\n", get_usb_rcmsg(rc));
+				       "could not resubmit isoc read URB: %s\n",
+					get_usb_rcmsg(rc));
 				dump_urb(DEBUG_ISO, "isoc read", urb);
 				error_hangup(bcs);
 			}
@@ -1135,7 +1134,7 @@ static int submit_iso_write_urb(struct isow_urbctx_t *ucx)
 			gig_dbg(DEBUG_ISO, "%s: disconnected", __func__);
 		else
 			dev_err(ucx->bcs->cs->dev,
-				"could not submit isochronous write URB: %s\n",
+				"could not submit isoc write URB: %s\n",
 				get_usb_rcmsg(rc));
 		return rc;
 	}
@@ -1180,7 +1179,7 @@ static void write_iso_tasklet(unsigned long data)
 		ubc->isooutovfl = NULL;
 		spin_unlock_irqrestore(&ubc->isooutlock, flags);
 		if (ovfl) {
-			dev_err(cs->dev, "isochronous write buffer underrun\n");
+			dev_err(cs->dev, "isoc write underrun\n");
 			error_hangup(bcs);
 			break;
 		}
@@ -1205,7 +1204,7 @@ static void write_iso_tasklet(unsigned long data)
 				if (next) {
 					/* couldn't put it back */
 					dev_err(cs->dev,
-					      "losing isochronous write URB\n");
+						"losing isoc write URB\n");
 					error_hangup(bcs);
 				}
 			}
@@ -1232,10 +1231,10 @@ static void write_iso_tasklet(unsigned long data)
 				if (ifd->status ||
 				    ifd->actual_length != ifd->length) {
 					dev_warn(cs->dev,
-					     "isochronous write: frame %d: %s, "
-					     "only %d of %d bytes sent\n",
-					     i, get_usb_statmsg(ifd->status),
-					     ifd->actual_length, ifd->length);
+					    "isoc write: frame %d[%d/%d]: %s\n",
+						 i, ifd->actual_length,
+						 ifd->length,
+						 get_usb_statmsg(ifd->status));
 					offset = (ifd->offset +
 						  ifd->actual_length)
 						 % BAS_OUTBUFSIZE;
@@ -1244,11 +1243,11 @@ static void write_iso_tasklet(unsigned long data)
 			}
 			break;
 		case -EPIPE:			/* stall - probably underrun */
-			dev_err(cs->dev, "isochronous write stalled\n");
+			dev_err(cs->dev, "isoc write: stalled\n");
 			error_hangup(bcs);
 			break;
-		default:			/* severe trouble */
-			dev_warn(cs->dev, "isochronous write: %s\n",
+		default:			/* other errors */
+			dev_warn(cs->dev, "isoc write: %s\n",
 				 get_usb_statmsg(status));
 		}
 
@@ -1304,6 +1303,7 @@ static void read_iso_tasklet(unsigned long data)
 	struct cardstate *cs = bcs->cs;
 	struct urb *urb;
 	int status;
+	struct usb_iso_packet_descriptor *ifd;
 	char *rcvbuf;
 	unsigned long flags;
 	int totleft, numbytes, offset, frame, rc;
@@ -1321,8 +1321,7 @@ static void read_iso_tasklet(unsigned long data)
 		ubc->isoindone = NULL;
 		if (unlikely(ubc->loststatus != -EINPROGRESS)) {
 			dev_warn(cs->dev,
-				 "isochronous read overrun, "
-				 "dropped URB with status: %s, %d bytes lost\n",
+		"isoc read overrun, URB dropped (status: %s, %d bytes)\n",
 				 get_usb_statmsg(ubc->loststatus),
 				 ubc->isoinlost);
 			ubc->loststatus = -EINPROGRESS;
@@ -1352,11 +1351,11 @@ static void read_iso_tasklet(unsigned long data)
 				__func__, get_usb_statmsg(status));
 			continue;		/* -> skip */
 		case -EPIPE:
-			dev_err(cs->dev, "isochronous read stalled\n");
+			dev_err(cs->dev, "isoc read: stalled\n");
 			error_hangup(bcs);
 			continue;		/* -> skip */
-		default:			/* severe trouble */
-			dev_warn(cs->dev, "isochronous read: %s\n",
+		default:			/* other error */
+			dev_warn(cs->dev, "isoc read: %s\n",
 				 get_usb_statmsg(status));
 			goto error;
 		}
@@ -1364,40 +1363,52 @@ static void read_iso_tasklet(unsigned long data)
 		rcvbuf = urb->transfer_buffer;
 		totleft = urb->actual_length;
 		for (frame = 0; totleft > 0 && frame < BAS_NUMFRAMES; frame++) {
-			numbytes = urb->iso_frame_desc[frame].actual_length;
-			if (unlikely(urb->iso_frame_desc[frame].status))
+			ifd = &urb->iso_frame_desc[frame];
+			numbytes = ifd->actual_length;
+			switch (ifd->status) {
+			case 0:			/* success */
+				break;
+			case -EPROTO:		/* protocol error or unplug */
+			case -EILSEQ:
+			case -ETIME:
+				/* probably just disconnected, ignore */
+				gig_dbg(DEBUG_ISO,
+					"isoc read: frame %d[%d]: %s\n",
+					frame, numbytes,
+					get_usb_statmsg(ifd->status));
+				break;
+			default:		/* other error */
+				/* report, assume transferred bytes are ok */
 				dev_warn(cs->dev,
-					 "isochronous read: frame %d[%d]: %s\n",
+					 "isoc read: frame %d[%d]: %s\n",
 					 frame, numbytes,
-					 get_usb_statmsg(
-					    urb->iso_frame_desc[frame].status));
+					 get_usb_statmsg(ifd->status));
+			}
 			if (unlikely(numbytes > BAS_MAXFRAME))
 				dev_warn(cs->dev,
-					 "isochronous read: frame %d: "
-					 "numbytes (%d) > BAS_MAXFRAME\n",
-					 frame, numbytes);
+					 "isoc read: frame %d[%d]: %s\n",
+					 frame, numbytes,
+					 "exceeds max frame size");
 			if (unlikely(numbytes > totleft)) {
 				dev_warn(cs->dev,
-					 "isochronous read: frame %d: "
-					 "numbytes (%d) > totleft (%d)\n",
-					 frame, numbytes, totleft);
+					 "isoc read: frame %d[%d]: %s\n",
+					 frame, numbytes,
+					 "exceeds total transfer length");
 				numbytes = totleft;
 			}
-			offset = urb->iso_frame_desc[frame].offset;
+			offset = ifd->offset;
 			if (unlikely(offset + numbytes > BAS_INBUFSIZE)) {
 				dev_warn(cs->dev,
-					 "isochronous read: frame %d: "
-					 "offset (%d) + numbytes (%d) "
-					 "> BAS_INBUFSIZE\n",
-					 frame, offset, numbytes);
+					 "isoc read: frame %d[%d]: %s\n",
+					 frame, numbytes,
+					 "exceeds end of buffer");
 				numbytes = BAS_INBUFSIZE - offset;
 			}
 			gigaset_isoc_receive(rcvbuf + offset, numbytes, bcs);
 			totleft -= numbytes;
 		}
 		if (unlikely(totleft > 0))
-			dev_warn(cs->dev,
-				 "isochronous read: %d data bytes missing\n",
+			dev_warn(cs->dev, "isoc read: %d data bytes missing\n",
 				 totleft);
 
 error:
@@ -1413,9 +1424,9 @@ error:
 		rc = usb_submit_urb(urb, GFP_ATOMIC);
 		if (unlikely(rc != 0 && rc != -ENODEV)) {
 			dev_err(cs->dev,
-				"could not resubmit isochronous read URB: %s\n",
+				"could not resubmit isoc read URB: %s\n",
 				get_usb_rcmsg(rc));
-			dump_urb(DEBUG_ISO, "resubmit iso read", urb);
+			dump_urb(DEBUG_ISO, "resubmit isoc read", urb);
 			error_hangup(bcs);
 		}
 	}
@@ -1647,8 +1658,7 @@ static int gigaset_init_bchannel(struct bc_state *bcs)
 
 	if (cs->hw.bas->basstate & BS_SUSPEND) {
 		dev_notice(cs->dev,
-			   "not starting isochronous I/O, "
-			   "suspend in progress\n");
+			   "not starting isoc I/O, suspend in progress\n");
 		spin_unlock_irqrestore(&cs->lock, flags);
 		return -EHOSTUNREACH;
 	}
@@ -1657,7 +1667,7 @@ static int gigaset_init_bchannel(struct bc_state *bcs)
 	if (ret < 0) {
 		spin_unlock_irqrestore(&cs->lock, flags);
 		dev_err(cs->dev,
-			"could not start isochronous I/O for channel B%d: %s\n",
+			"could not start isoc I/O for channel B%d: %s\n",
 			bcs->channel + 1,
 			ret == -EFAULT ? "null URB" : get_usb_rcmsg(ret));
 		if (ret != -ENODEV)
@@ -2086,7 +2096,7 @@ static int gigaset_freebcshw(struct bc_state *bcs)
 
 	/* kill URBs and tasklets before freeing - better safe than sorry */
 	ubc->running = 0;
-	gig_dbg(DEBUG_INIT, "%s: killing iso URBs", __func__);
+	gig_dbg(DEBUG_INIT, "%s: killing isoc URBs", __func__);
 	for (i = 0; i < BAS_OUTURBS; ++i) {
 		usb_kill_urb(ubc->isoouturbs[i].urb);
 		usb_free_urb(ubc->isoouturbs[i].urb);
-- 
1.7.3.15.g442cb
