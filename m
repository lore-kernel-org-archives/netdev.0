From: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
Subject: [PATCH 06/11] gigaset: improve error recovery
Date: Wed,  7 Oct 2009 00:18:51 +0200 (CEST)
Message-ID: <20091006-patch-gigaset-06.tilman@imap.cc>
References: <20091006-patch-gigaset-00.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: isdn4linux-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org, Karsten Keil <isdn-iHCpqvpFUx0uJkBD2foKsQ@public.gmane.org>,
        Karsten Keil <keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org>, Hansjoerg Lipp <hjlipp-S0/GAf8tV78@public.gmane.org>,
        i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
In-Reply-To: <20091006-patch-gigaset-00.tilman-ZTO5kqT2PaM@public.gmane.org>
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

When the Gigaset base stops responding, try resetting the USB
connection to recover.

Impact: error handling improvement
Signed-off-by: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
---
 drivers/isdn/gigaset/bas-gigaset.c |   69 +++++++++++++++++++++++------------
 1 files changed, 45 insertions(+), 24 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 9e7108a..5ed1d99 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -134,6 +134,7 @@ struct bas_cardstate {
 #define BS_ATRDPEND	0x040	/* urb_cmd_in in use */
 #define BS_ATWRPEND	0x080	/* urb_cmd_out in use */
 #define BS_SUSPEND	0x100	/* USB port suspended */
+#define BS_RESETTING	0x200	/* waiting for HD_RESET_INTERRUPT_PIPE_ACK */
 
 
 static struct gigaset_driver *driver = NULL;
@@ -319,6 +320,21 @@ static int gigaset_set_line_ctrl(struct cardstate *cs, unsigned cflag)
 	return -EINVAL;
 }
 
+/* set/clear bits in base connection state, return previous state
+ */
+static inline int update_basstate(struct bas_cardstate *ucs,
+				  int set, int clear)
+{
+	unsigned long flags;
+	int state;
+
+	spin_lock_irqsave(&ucs->lock, flags);
+	state = ucs->basstate;
+	ucs->basstate = (state & ~clear) | set;
+	spin_unlock_irqrestore(&ucs->lock, flags);
+	return state;
+}
+
 /* error_hangup
  * hang up any existing connection because of an unrecoverable error
  * This function may be called from any context and takes care of scheduling
@@ -350,12 +366,9 @@ static inline void error_hangup(struct bc_state *bcs)
  */
 static inline void error_reset(struct cardstate *cs)
 {
-	/* close AT command channel to recover (ignore errors) */
-	req_submit(cs->bcs, HD_CLOSE_ATCHANNEL, 0, BAS_TIMEOUT);
-
-	//FIXME try to recover without bothering the user
-	dev_err(cs->dev,
-	    "unrecoverable error - please disconnect Gigaset base to reset\n");
+	/* reset interrupt pipe to recover (ignore errors) */
+	update_basstate(cs->hw.bas, BS_RESETTING, 0);
+	req_submit(cs->bcs, HD_RESET_INTERRUPT_PIPE, 0, BAS_TIMEOUT);
 }
 
 /* check_pending
@@ -398,8 +411,13 @@ static void check_pending(struct bas_cardstate *ucs)
 	case HD_DEVICE_INIT_ACK:		/* no reply expected */
 		ucs->pending = 0;
 		break;
-	/* HD_READ_ATMESSAGE, HD_WRITE_ATMESSAGE, HD_RESET_INTERRUPTPIPE
-	 * are handled separately and should never end up here
+	case HD_RESET_INTERRUPT_PIPE:
+		if (!(ucs->basstate & BS_RESETTING))
+			ucs->pending = 0;
+		break;
+	/*
+	 * HD_READ_ATMESSAGE and HD_WRITE_ATMESSAGE are handled separately
+	 * and should never end up here
 	 */
 	default:
 		dev_warn(&ucs->interface->dev,
@@ -449,21 +467,6 @@ static void cmd_in_timeout(unsigned long data)
 	error_reset(cs);
 }
 
-/* set/clear bits in base connection state, return previous state
- */
-inline static int update_basstate(struct bas_cardstate *ucs,
-				  int set, int clear)
-{
-	unsigned long flags;
-	int state;
-
-	spin_lock_irqsave(&ucs->lock, flags);
-	state = ucs->basstate;
-	ucs->basstate = (state & ~clear) | set;
-	spin_unlock_irqrestore(&ucs->lock, flags);
-	return state;
-}
-
 /* read_ctrl_callback
  * USB completion handler for control pipe input
  * called by the USB subsystem in interrupt context
@@ -762,7 +765,8 @@ static void read_int_callback(struct urb *urb)
 		break;
 
 	case HD_RESET_INTERRUPT_PIPE_ACK:
-		gig_dbg(DEBUG_USBREQ, "HD_RESET_INTERRUPT_PIPE_ACK");
+		update_basstate(ucs, 0, BS_RESETTING);
+		dev_notice(cs->dev, "interrupt pipe reset\n");
 		break;
 
 	case HD_SUSPEND_END:
@@ -1429,6 +1433,7 @@ static void req_timeout(unsigned long data)
 
 	case HD_CLOSE_ATCHANNEL:
 		dev_err(bcs->cs->dev, "timeout closing AT channel\n");
+		error_reset(bcs->cs);
 		break;
 
 	case HD_CLOSE_B2CHANNEL:
@@ -1438,6 +1443,13 @@ static void req_timeout(unsigned long data)
 		error_reset(bcs->cs);
 		break;
 
+	case HD_RESET_INTERRUPT_PIPE:
+		/* error recovery escalation */
+		dev_err(bcs->cs->dev,
+			"reset interrupt pipe timeout, attempting USB reset\n");
+		usb_queue_reset_device(bcs->cs->hw.bas->interface);
+		break;
+
 	default:
 		dev_warn(bcs->cs->dev, "request 0x%02x timed out, clearing\n",
 			 pending);
@@ -1930,6 +1942,15 @@ static int gigaset_write_cmd(struct cardstate *cs,
 		goto notqueued;
 	}
 
+	/* translate "+++" escape sequence sent as a single separate command
+	 * into "close AT channel" command for error recovery
+	 * The next command will reopen the AT channel automatically.
+	 */
+	if (len == 3 && !memcmp(buf, "+++", 3)) {
+		rc = req_submit(cs->bcs, HD_CLOSE_ATCHANNEL, 0, BAS_TIMEOUT);
+		goto notqueued;
+	}
+
 	if (len > IF_WRITEBUF)
 		len = IF_WRITEBUF;
 	if (!(cb = kmalloc(sizeof(struct cmdbuf_t) + len, GFP_ATOMIC))) {
-- 
1.6.2.1.214.ge986c
