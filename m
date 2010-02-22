From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 3/4] gigaset: reduce syslog clutter
Date: Tue, 23 Feb 2010 00:09:52 +0100 (CET)
Message-ID: <20100221-patch-gigaset-03.tilman@imap.cc>
References: <20100221-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([195.227.45.7]:57831 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754687Ab0BVXLL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2010 18:11:11 -0500
In-Reply-To: <20100221-patch-gigaset-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 3/4] gigaset: reduce syslog clutter

Improve readability of the Gigaset driver's kernel messages by
removing a few unnecessary messages and limiting the emission
of some debug messages more narrowly.

Impact: logging
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/asyncdata.c   |    4 +-
 drivers/isdn/gigaset/bas-gigaset.c |   18 +++-------
 drivers/isdn/gigaset/capi.c        |   15 ++------
 drivers/isdn/gigaset/common.c      |   49 +++++++++++----------------
 drivers/isdn/gigaset/ev-layer.c    |   63 ++++++++++++++++++-----------------
 drivers/isdn/gigaset/gigaset.h     |    7 +---
 drivers/isdn/gigaset/i4l.c         |   52 +++--------------------------
 drivers/isdn/gigaset/interface.c   |   12 ++----
 drivers/isdn/gigaset/proc.c        |    2 -
 drivers/isdn/gigaset/usb-gigaset.c |    2 +-
 10 files changed, 77 insertions(+), 147 deletions(-)

diff --git a/drivers/isdn/gigaset/asyncdata.c b/drivers/isdn/gigaset/asyncdata.c
index e913beb..c5016bd 100644
--- a/drivers/isdn/gigaset/asyncdata.c
+++ b/drivers/isdn/gigaset/asyncdata.c
@@ -67,14 +67,14 @@ static unsigned cmd_loop(unsigned numbytes, struct inbuf_t *inbuf)
 			/* --v-- fall through --v-- */
 		case '\r':
 			/* end of message line, pass to response handler */
-			gig_dbg(DEBUG_TRANSCMD, "%s: End of Message (%d Bytes)",
-				__func__, cbytes);
 			if (cbytes >= MAX_RESP_SIZE) {
 				dev_warn(cs->dev, "response too large (%d)\n",
 					 cbytes);
 				cbytes = MAX_RESP_SIZE;
 			}
 			cs->cbytes = cbytes;
+			gigaset_dbg_buffer(DEBUG_TRANSCMD, "received response",
+					   cbytes, cs->respdata);
 			gigaset_handle_modem_response(cs);
 			cbytes = 0;
 
diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 95ebc51..0be15c7 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -347,12 +347,7 @@ static inline void error_hangup(struct bc_state *bcs)
 {
 	struct cardstate *cs = bcs->cs;
 
-	gig_dbg(DEBUG_ANY, "%s: scheduling HUP for channel %d",
-		__func__, bcs->channel);
-
-	if (!gigaset_add_event(cs, &bcs->at_state, EV_HUP, NULL, 0, NULL))
-		dev_err(cs->dev, "event queue full\n");
-
+	gigaset_add_event(cs, &bcs->at_state, EV_HUP, NULL, 0, NULL);
 	gigaset_schedule_event(cs);
 }
 
@@ -1706,8 +1701,7 @@ static void complete_cb(struct cardstate *cs)
 
 	/* unqueue completed buffer */
 	cs->cmdbytes -= cs->curlen;
-	gig_dbg(DEBUG_TRANSCMD|DEBUG_LOCKCMD,
-		"write_command: sent %u bytes, %u left",
+	gig_dbg(DEBUG_OUTPUT, "write_command: sent %u bytes, %u left",
 		cs->curlen, cs->cmdbytes);
 	if (cb->next != NULL) {
 		cs->cmdbuf = cb->next;
@@ -1881,13 +1875,13 @@ static int start_cbsend(struct cardstate *cs)
 
 	/* check if suspend requested */
 	if (ucs->basstate & BS_SUSPEND) {
-		gig_dbg(DEBUG_TRANSCMD|DEBUG_LOCKCMD, "suspending");
+		gig_dbg(DEBUG_OUTPUT, "suspending");
 		return -EHOSTUNREACH;
 	}
 
 	/* check if AT channel is open */
 	if (!(ucs->basstate & BS_ATOPEN)) {
-		gig_dbg(DEBUG_TRANSCMD|DEBUG_LOCKCMD, "AT channel not open");
+		gig_dbg(DEBUG_OUTPUT, "AT channel not open");
 		rc = req_submit(cs->bcs, HD_OPEN_ATCHANNEL, 0, BAS_TIMEOUT);
 		if (rc < 0) {
 			/* flush command queue */
@@ -2251,7 +2245,7 @@ static int gigaset_probe(struct usb_interface *interface,
 	int i, j;
 	int rc;
 
-	gig_dbg(DEBUG_ANY,
+	gig_dbg(DEBUG_INIT,
 		"%s: Check if device matches .. (Vendor: 0x%x, Product: 0x%x)",
 		__func__, le16_to_cpu(udev->descriptor.idVendor),
 		le16_to_cpu(udev->descriptor.idProduct));
@@ -2259,7 +2253,7 @@ static int gigaset_probe(struct usb_interface *interface,
 	/* set required alternate setting */
 	hostif = interface->cur_altsetting;
 	if (hostif->desc.bAlternateSetting != 3) {
-		gig_dbg(DEBUG_ANY,
+		gig_dbg(DEBUG_INIT,
 			"%s: wrong alternate setting %d - trying to switch",
 			__func__, hostif->desc.bAlternateSetting);
 		if (usb_set_interface(udev, hostif->desc.bInterfaceNumber, 3)
diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index 3f5cd06..7ac71c5 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -1427,9 +1427,10 @@ static void do_connect_req(struct gigaset_capi_ctr *iif,
 
 	/* queue & schedule EV_DIAL event */
 	if (!gigaset_add_event(cs, &bcs->at_state, EV_DIAL, commands,
-			       bcs->at_state.seq_index, NULL))
-		goto oom;
-	gig_dbg(DEBUG_CMD, "scheduling DIAL");
+			       bcs->at_state.seq_index, NULL)) {
+		info = CAPI_MSGOSRESOURCEERR;
+		goto error;
+	}
 	gigaset_schedule_event(cs);
 	ap->connected = APCONN_SETUP;
 	send_conf(iif, ap, skb, CapiSuccess);
@@ -1543,7 +1544,6 @@ static void do_connect_resp(struct gigaset_capi_ctr *iif,
 		if (!gigaset_add_event(cs, &cs->bcs[channel-1].at_state,
 				       EV_ACCEPT, NULL, 0, NULL))
 			return;
-		gig_dbg(DEBUG_CMD, "scheduling ACCEPT");
 		gigaset_schedule_event(cs);
 		return;
 
@@ -1584,7 +1584,6 @@ static void do_connect_resp(struct gigaset_capi_ctr *iif,
 		if (!gigaset_add_event(cs, &cs->bcs[channel-1].at_state,
 				       EV_HUP, NULL, 0, NULL))
 			return;
-		gig_dbg(DEBUG_CMD, "scheduling HUP");
 		gigaset_schedule_event(cs);
 		return;
 	}
@@ -1667,11 +1666,9 @@ static void do_connect_b3_resp(struct gigaset_capi_ctr *iif,
 		/* trigger hangup, causing eventual DISCONNECT_IND */
 		if (!gigaset_add_event(cs, &bcs->at_state,
 				       EV_HUP, NULL, 0, NULL)) {
-			dev_err(cs->dev, "%s: out of memory\n", __func__);
 			dev_kfree_skb_any(skb);
 			return;
 		}
-		gig_dbg(DEBUG_CMD, "scheduling HUP");
 		gigaset_schedule_event(cs);
 
 		/* emit DISCONNECT_B3_IND */
@@ -1770,11 +1767,9 @@ static void do_disconnect_req(struct gigaset_capi_ctr *iif,
 
 	/* trigger hangup, causing eventual DISCONNECT_IND */
 	if (!gigaset_add_event(cs, &bcs->at_state, EV_HUP, NULL, 0, NULL)) {
-		dev_err(cs->dev, "%s: out of memory\n", __func__);
 		send_conf(iif, ap, skb, CAPI_MSGOSRESOURCEERR);
 		return;
 	}
-	gig_dbg(DEBUG_CMD, "scheduling HUP");
 	gigaset_schedule_event(cs);
 
 	/* emit reply */
@@ -1817,11 +1812,9 @@ static void do_disconnect_b3_req(struct gigaset_capi_ctr *iif,
 	/* trigger hangup, causing eventual DISCONNECT_B3_IND */
 	if (!gigaset_add_event(cs, &cs->bcs[channel-1].at_state,
 			       EV_HUP, NULL, 0, NULL)) {
-		dev_err(cs->dev, "%s: out of memory\n", __func__);
 		send_conf(iif, ap, skb, CAPI_MSGOSRESOURCEERR);
 		return;
 	}
-	gig_dbg(DEBUG_CMD, "scheduling HUP");
 	gigaset_schedule_event(cs);
 
 	/* NCPI parameter: not applicable for B3 Transparent */
diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 664b0c5..85de339 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -149,10 +149,8 @@ static int test_timeout(struct at_state_t *at_state)
 		return 0;
 	}
 
-	if (!gigaset_add_event(at_state->cs, at_state, EV_TIMEOUT, NULL,
-			       at_state->timer_index, NULL))
-			dev_err(at_state->cs->dev, "%s: out of memory\n",
-				__func__);
+	gigaset_add_event(at_state->cs, at_state, EV_TIMEOUT, NULL,
+			  at_state->timer_index, NULL);
 	return 1;
 }
 
@@ -180,7 +178,7 @@ static void timer_tick(unsigned long data)
 	if (cs->running) {
 		mod_timer(&cs->timer, jiffies + msecs_to_jiffies(GIG_TICK));
 		if (timeout) {
-			gig_dbg(DEBUG_CMD, "scheduling timeout");
+			gig_dbg(DEBUG_EVENT, "scheduling timeout");
 			tasklet_schedule(&cs->event_tasklet);
 		}
 	}
@@ -194,14 +192,14 @@ int gigaset_get_channel(struct bc_state *bcs)
 
 	spin_lock_irqsave(&bcs->cs->lock, flags);
 	if (bcs->use_count || !try_module_get(bcs->cs->driver->owner)) {
-		gig_dbg(DEBUG_ANY, "could not allocate channel %d",
+		gig_dbg(DEBUG_CHANNEL, "could not allocate channel %d",
 			bcs->channel);
 		spin_unlock_irqrestore(&bcs->cs->lock, flags);
 		return 0;
 	}
 	++bcs->use_count;
 	bcs->busy = 1;
-	gig_dbg(DEBUG_ANY, "allocated channel %d", bcs->channel);
+	gig_dbg(DEBUG_CHANNEL, "allocated channel %d", bcs->channel);
 	spin_unlock_irqrestore(&bcs->cs->lock, flags);
 	return 1;
 }
@@ -213,7 +211,7 @@ struct bc_state *gigaset_get_free_channel(struct cardstate *cs)
 
 	spin_lock_irqsave(&cs->lock, flags);
 	if (!try_module_get(cs->driver->owner)) {
-		gig_dbg(DEBUG_ANY,
+		gig_dbg(DEBUG_CHANNEL,
 			"could not get module for allocating channel");
 		spin_unlock_irqrestore(&cs->lock, flags);
 		return NULL;
@@ -223,12 +221,12 @@ struct bc_state *gigaset_get_free_channel(struct cardstate *cs)
 			++cs->bcs[i].use_count;
 			cs->bcs[i].busy = 1;
 			spin_unlock_irqrestore(&cs->lock, flags);
-			gig_dbg(DEBUG_ANY, "allocated channel %d", i);
+			gig_dbg(DEBUG_CHANNEL, "allocated channel %d", i);
 			return cs->bcs + i;
 		}
 	module_put(cs->driver->owner);
 	spin_unlock_irqrestore(&cs->lock, flags);
-	gig_dbg(DEBUG_ANY, "no free channel");
+	gig_dbg(DEBUG_CHANNEL, "no free channel");
 	return NULL;
 }
 
@@ -238,14 +236,15 @@ void gigaset_free_channel(struct bc_state *bcs)
 
 	spin_lock_irqsave(&bcs->cs->lock, flags);
 	if (!bcs->busy) {
-		gig_dbg(DEBUG_ANY, "could not free channel %d", bcs->channel);
+		gig_dbg(DEBUG_CHANNEL, "could not free channel %d",
+			bcs->channel);
 		spin_unlock_irqrestore(&bcs->cs->lock, flags);
 		return;
 	}
 	--bcs->use_count;
 	bcs->busy = 0;
 	module_put(bcs->cs->driver->owner);
-	gig_dbg(DEBUG_ANY, "freed channel %d", bcs->channel);
+	gig_dbg(DEBUG_CHANNEL, "freed channel %d", bcs->channel);
 	spin_unlock_irqrestore(&bcs->cs->lock, flags);
 }
 
@@ -258,14 +257,15 @@ int gigaset_get_channels(struct cardstate *cs)
 	for (i = 0; i < cs->channels; ++i)
 		if (cs->bcs[i].use_count) {
 			spin_unlock_irqrestore(&cs->lock, flags);
-			gig_dbg(DEBUG_ANY, "could not allocate all channels");
+			gig_dbg(DEBUG_CHANNEL,
+				"could not allocate all channels");
 			return 0;
 		}
 	for (i = 0; i < cs->channels; ++i)
 		++cs->bcs[i].use_count;
 	spin_unlock_irqrestore(&cs->lock, flags);
 
-	gig_dbg(DEBUG_ANY, "allocated all channels");
+	gig_dbg(DEBUG_CHANNEL, "allocated all channels");
 
 	return 1;
 }
@@ -275,7 +275,7 @@ void gigaset_free_channels(struct cardstate *cs)
 	unsigned long flags;
 	int i;
 
-	gig_dbg(DEBUG_ANY, "unblocking all channels");
+	gig_dbg(DEBUG_CHANNEL, "unblocking all channels");
 	spin_lock_irqsave(&cs->lock, flags);
 	for (i = 0; i < cs->channels; ++i)
 		--cs->bcs[i].use_count;
@@ -287,7 +287,7 @@ void gigaset_block_channels(struct cardstate *cs)
 	unsigned long flags;
 	int i;
 
-	gig_dbg(DEBUG_ANY, "blocking all channels");
+	gig_dbg(DEBUG_CHANNEL, "blocking all channels");
 	spin_lock_irqsave(&cs->lock, flags);
 	for (i = 0; i < cs->channels; ++i)
 		++cs->bcs[i].use_count;
@@ -338,6 +338,8 @@ struct event_t *gigaset_add_event(struct cardstate *cs,
 	unsigned next, tail;
 	struct event_t *event = NULL;
 
+	gig_dbg(DEBUG_EVENT, "queueing event %d", type);
+
 	spin_lock_irqsave(&cs->ev_lock, flags);
 
 	tail = cs->ev_tail;
@@ -934,11 +936,8 @@ int gigaset_start(struct cardstate *cs)
 
 	if (!gigaset_add_event(cs, &cs->at_state, EV_START, NULL, 0, NULL)) {
 		cs->waiting = 0;
-		dev_err(cs->dev, "%s: out of memory\n", __func__);
 		goto error;
 	}
-
-	gig_dbg(DEBUG_CMD, "scheduling START");
 	gigaset_schedule_event(cs);
 
 	wait_event(cs->waitqueue, !cs->waiting);
@@ -973,12 +972,8 @@ int gigaset_shutdown(struct cardstate *cs)
 
 	cs->waiting = 1;
 
-	if (!gigaset_add_event(cs, &cs->at_state, EV_SHUTDOWN, NULL, 0, NULL)) {
-		dev_err(cs->dev, "%s: out of memory\n", __func__);
+	if (!gigaset_add_event(cs, &cs->at_state, EV_SHUTDOWN, NULL, 0, NULL))
 		goto exit;
-	}
-
-	gig_dbg(DEBUG_CMD, "scheduling SHUTDOWN");
 	gigaset_schedule_event(cs);
 
 	wait_event(cs->waitqueue, !cs->waiting);
@@ -1004,12 +999,8 @@ void gigaset_stop(struct cardstate *cs)
 
 	cs->waiting = 1;
 
-	if (!gigaset_add_event(cs, &cs->at_state, EV_STOP, NULL, 0, NULL)) {
-		dev_err(cs->dev, "%s: out of memory\n", __func__);
+	if (!gigaset_add_event(cs, &cs->at_state, EV_STOP, NULL, 0, NULL))
 		goto exit;
-	}
-
-	gig_dbg(DEBUG_CMD, "scheduling STOP");
 	gigaset_schedule_event(cs);
 
 	wait_event(cs->waitqueue, !cs->waiting);
diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index ddeb045..c8f89b7 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -427,7 +427,7 @@ static int isdn_getnum(char *p)
 {
 	int v = -1;
 
-	gig_dbg(DEBUG_TRANSCMD, "string: %s", p);
+	gig_dbg(DEBUG_EVENT, "string: %s", p);
 
 	while (*p >= '0' && *p <= '9')
 		v = ((v < 0) ? 0 : (v * 10)) + (int) ((*p++) - '0');
@@ -444,7 +444,7 @@ static int isdn_gethex(char *p)
 	int v = 0;
 	int c;
 
-	gig_dbg(DEBUG_TRANSCMD, "string: %s", p);
+	gig_dbg(DEBUG_EVENT, "string: %s", p);
 
 	if (!*p)
 		return -1;
@@ -517,7 +517,6 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 		return;
 	}
 	cs->respdata[len] = 0;
-	gig_dbg(DEBUG_TRANSCMD, "raw string: '%s'", cs->respdata);
 	argv[0] = cs->respdata;
 	params = 1;
 	if (cs->at_state.getstring) {
@@ -552,14 +551,14 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 		for (j = 1; j < params; ++j)
 			argv[j][-1] = 0;
 
-		gig_dbg(DEBUG_TRANSCMD, "CMD received: %s", argv[0]);
+		gig_dbg(DEBUG_EVENT, "CMD received: %s", argv[0]);
 		if (cid) {
 			--params;
-			gig_dbg(DEBUG_TRANSCMD, "CID: %s", argv[params]);
+			gig_dbg(DEBUG_EVENT, "CID: %s", argv[params]);
 		}
-		gig_dbg(DEBUG_TRANSCMD, "available params: %d", params - 1);
+		gig_dbg(DEBUG_EVENT, "available params: %d", params - 1);
 		for (j = 1; j < params; j++)
-			gig_dbg(DEBUG_TRANSCMD, "param %d: %s", j, argv[j]);
+			gig_dbg(DEBUG_EVENT, "param %d: %s", j, argv[j]);
 	}
 
 	spin_lock_irqsave(&cs->ev_lock, flags);
@@ -642,7 +641,7 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 					dev_err(cs->dev, "out of memory\n");
 				++curarg;
 			}
-			gig_dbg(DEBUG_CMD, "string==%s",
+			gig_dbg(DEBUG_EVENT, "string==%s",
 				event->ptr ? (char *) event->ptr : "NULL");
 			break;
 		case RT_ZCAU:
@@ -669,7 +668,7 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 				++curarg;
 			} else
 				event->parameter = -1;
-			gig_dbg(DEBUG_CMD, "parameter==%d", event->parameter);
+			gig_dbg(DEBUG_EVENT, "parameter==%d", event->parameter);
 			break;
 		}
 
@@ -684,7 +683,7 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 	spin_unlock_irqrestore(&cs->ev_lock, flags);
 
 	if (curarg != params)
-		gig_dbg(DEBUG_ANY,
+		gig_dbg(DEBUG_EVENT,
 			"invalid number of processed parameters: %d/%d",
 			curarg, params);
 }
@@ -705,8 +704,8 @@ static void disconnect(struct at_state_t **at_state_p)
 	/* revert to selected idle mode */
 	if (!cs->cidmode) {
 		cs->at_state.pending_commands |= PC_UMMODE;
+		gig_dbg(DEBUG_EVENT, "Scheduling PC_UMMODE");
 		cs->commands_pending = 1;
-		gig_dbg(DEBUG_CMD, "Scheduling PC_UMMODE");
 	}
 	spin_unlock_irqrestore(&cs->lock, flags);
 
@@ -784,15 +783,15 @@ static void init_failed(struct cardstate *cs, int mode)
 static void schedule_init(struct cardstate *cs, int state)
 {
 	if (cs->at_state.pending_commands & PC_INIT) {
-		gig_dbg(DEBUG_CMD, "not scheduling PC_INIT again");
+		gig_dbg(DEBUG_EVENT, "not scheduling PC_INIT again");
 		return;
 	}
 	cs->mstate = state;
 	cs->mode = M_UNKNOWN;
 	gigaset_block_channels(cs);
 	cs->at_state.pending_commands |= PC_INIT;
+	gig_dbg(DEBUG_EVENT, "Scheduling PC_INIT");
 	cs->commands_pending = 1;
-	gig_dbg(DEBUG_CMD, "Scheduling PC_INIT");
 }
 
 /* Add "AT" to a command, add the cid, dle encode it, send the result to the
@@ -923,7 +922,7 @@ static void start_dial(struct at_state_t *at_state, void *data,
 	}
 
 	at_state->pending_commands |= PC_CID;
-	gig_dbg(DEBUG_CMD, "Scheduling PC_CID");
+	gig_dbg(DEBUG_EVENT, "Scheduling PC_CID");
 	cs->commands_pending = 1;
 	return;
 
@@ -933,7 +932,7 @@ error:
 		commands[i] = NULL;
 	}
 	at_state->pending_commands |= PC_NOCID;
-	gig_dbg(DEBUG_CMD, "Scheduling PC_NOCID");
+	gig_dbg(DEBUG_EVENT, "Scheduling PC_NOCID");
 	cs->commands_pending = 1;
 	return;
 }
@@ -955,7 +954,7 @@ static void start_accept(struct at_state_t *at_state)
 		dev_err(at_state->cs->dev, "out of memory\n");
 		/* error reset */
 		at_state->pending_commands |= PC_HUP;
-		gig_dbg(DEBUG_CMD, "Scheduling PC_HUP");
+		gig_dbg(DEBUG_EVENT, "Scheduling PC_HUP");
 		cs->commands_pending = 1;
 		return;
 	}
@@ -964,7 +963,7 @@ static void start_accept(struct at_state_t *at_state)
 	snprintf(bcs->commands[AT_ISO], 9, "^SISO=%u\r", bcs->channel + 1);
 
 	at_state->pending_commands |= PC_ACCEPT;
-	gig_dbg(DEBUG_CMD, "Scheduling PC_ACCEPT");
+	gig_dbg(DEBUG_EVENT, "Scheduling PC_ACCEPT");
 	cs->commands_pending = 1;
 }
 
@@ -1009,8 +1008,8 @@ static void do_shutdown(struct cardstate *cs)
 	if (cs->mstate == MS_READY) {
 		cs->mstate = MS_SHUTDOWN;
 		cs->at_state.pending_commands |= PC_SHUTDOWN;
+		gig_dbg(DEBUG_EVENT, "Scheduling PC_SHUTDOWN");
 		cs->commands_pending = 1;
-		gig_dbg(DEBUG_CMD, "Scheduling PC_SHUTDOWN");
 	} else
 		finish_shutdown(cs);
 }
@@ -1191,8 +1190,8 @@ static void do_action(int action, struct cardstate *cs,
 		}
 		spin_unlock_irqrestore(&cs->lock, flags);
 		cs->at_state.pending_commands |= PC_CIDMODE;
+		gig_dbg(DEBUG_EVENT, "Scheduling PC_CIDMODE");
 		cs->commands_pending = 1;
-		gig_dbg(DEBUG_CMD, "Scheduling PC_CIDMODE");
 		break;
 	case ACT_FAILINIT:
 		dev_warn(cs->dev, "Could not initialize the device.\n");
@@ -1443,7 +1442,7 @@ static void do_action(int action, struct cardstate *cs,
 	case ACT_GOTVER:
 		if (cs->gotfwver == 0) {
 			cs->gotfwver = 1;
-			gig_dbg(DEBUG_ANY,
+			gig_dbg(DEBUG_EVENT,
 				"firmware version %02d.%03d.%02d.%02d",
 				cs->fwver[0], cs->fwver[1],
 				cs->fwver[2], cs->fwver[3]);
@@ -1481,8 +1480,8 @@ static void do_action(int action, struct cardstate *cs,
 		break;
 	case ACT_HUP:
 		at_state->pending_commands |= PC_HUP;
+		gig_dbg(DEBUG_EVENT, "Scheduling PC_HUP");
 		cs->commands_pending = 1;
-		gig_dbg(DEBUG_CMD, "Scheduling PC_HUP");
 		break;
 
 	/* hotplug events */
@@ -1519,10 +1518,10 @@ static void do_action(int action, struct cardstate *cs,
 			cs->cidmode = ev->parameter;
 			if (ev->parameter) {
 				cs->at_state.pending_commands |= PC_CIDMODE;
-				gig_dbg(DEBUG_CMD, "Scheduling PC_CIDMODE");
+				gig_dbg(DEBUG_EVENT, "Scheduling PC_CIDMODE");
 			} else {
 				cs->at_state.pending_commands |= PC_UMMODE;
-				gig_dbg(DEBUG_CMD, "Scheduling PC_UMMODE");
+				gig_dbg(DEBUG_EVENT, "Scheduling PC_UMMODE");
 			}
 			cs->commands_pending = 1;
 		}
@@ -1573,6 +1572,8 @@ static void process_event(struct cardstate *cs, struct event_t *ev)
 	if (ev->cid >= 0) {
 		at_state = at_state_from_cid(cs, ev->cid);
 		if (!at_state) {
+			gig_dbg(DEBUG_EVENT, "event %d for invalid cid %d",
+				ev->type, ev->cid);
 			gigaset_add_event(cs, &cs->at_state, RSP_WRONG_CID,
 					  NULL, 0, NULL);
 			return;
@@ -1580,13 +1581,13 @@ static void process_event(struct cardstate *cs, struct event_t *ev)
 	} else {
 		at_state = ev->at_state;
 		if (at_state_invalid(cs, at_state)) {
-			gig_dbg(DEBUG_ANY, "event for invalid at_state %p",
+			gig_dbg(DEBUG_EVENT, "event for invalid at_state %p",
 				at_state);
 			return;
 		}
 	}
 
-	gig_dbg(DEBUG_CMD, "connection state %d, event %d",
+	gig_dbg(DEBUG_EVENT, "connection state %d, event %d",
 		at_state->ConState, ev->type);
 
 	bcs = at_state->bcs;
@@ -1600,11 +1601,11 @@ static void process_event(struct cardstate *cs, struct event_t *ev)
 		if (ev->parameter != at_state->timer_index
 		    || !at_state->timer_active) {
 			ev->type = RSP_NONE; /* old timeout */
-			gig_dbg(DEBUG_ANY, "old timeout");
+			gig_dbg(DEBUG_EVENT, "old timeout");
 		} else if (!at_state->waiting)
-			gig_dbg(DEBUG_ANY, "timeout occurred");
+			gig_dbg(DEBUG_EVENT, "timeout occurred");
 		else
-			gig_dbg(DEBUG_ANY, "stopped waiting");
+			gig_dbg(DEBUG_EVENT, "stopped waiting");
 	}
 	spin_unlock_irqrestore(&cs->lock, flags);
 
@@ -1712,11 +1713,11 @@ static void process_command_flags(struct cardstate *cs)
 	cs->commands_pending = 0;
 
 	if (cs->cur_at_seq) {
-		gig_dbg(DEBUG_CMD, "not searching scheduled commands: busy");
+		gig_dbg(DEBUG_EVENT, "not searching scheduled commands: busy");
 		return;
 	}
 
-	gig_dbg(DEBUG_CMD, "searching scheduled commands");
+	gig_dbg(DEBUG_EVENT, "searching scheduled commands");
 
 	sequence = SEQ_NONE;
 
@@ -1857,7 +1858,7 @@ static void process_command_flags(struct cardstate *cs)
 			switch (cs->mode) {
 			case M_UNIMODEM:
 				cs->at_state.pending_commands |= PC_CIDMODE;
-				gig_dbg(DEBUG_CMD, "Scheduling PC_CIDMODE");
+				gig_dbg(DEBUG_EVENT, "Scheduling PC_CIDMODE");
 				cs->commands_pending = 1;
 				return;
 #ifdef GIG_MAYINITONDIAL
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index c9ccf7d..1875ab8 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -78,9 +78,10 @@ enum debuglevel {
 	DEBUG_STREAM	  = 0x00040, /* application data stream I/O events */
 	DEBUG_STREAM_DUMP = 0x00080, /* application data stream content */
 	DEBUG_LLDATA	  = 0x00100, /* sent/received LL data */
+	DEBUG_EVENT	  = 0x00200, /* event processing */
 	DEBUG_DRIVER	  = 0x00400, /* driver structure */
 	DEBUG_HDLC	  = 0x00800, /* M10x HDLC processing */
-	DEBUG_WRITE	  = 0x01000, /* M105 data write */
+	DEBUG_CHANNEL	  = 0x01000, /* channel allocation/deallocation */
 	DEBUG_TRANSCMD	  = 0x02000, /* AT-COMMANDS+RESPONSES */
 	DEBUG_MCMD	  = 0x04000, /* COMMANDS THAT ARE SENT VERY OFTEN */
 	DEBUG_INIT	  = 0x08000, /* (de)allocation+initialization of data
@@ -785,8 +786,6 @@ static inline void gigaset_schedule_event(struct cardstate *cs)
 static inline void gigaset_bchannel_down(struct bc_state *bcs)
 {
 	gigaset_add_event(bcs->cs, &bcs->at_state, EV_BC_CLOSED, NULL, 0, NULL);
-
-	gig_dbg(DEBUG_CMD, "scheduling BC_CLOSED");
 	gigaset_schedule_event(bcs->cs);
 }
 
@@ -795,8 +794,6 @@ static inline void gigaset_bchannel_down(struct bc_state *bcs)
 static inline void gigaset_bchannel_up(struct bc_state *bcs)
 {
 	gigaset_add_event(bcs->cs, &bcs->at_state, EV_BC_OPEN, NULL, 0, NULL);
-
-	gig_dbg(DEBUG_CMD, "scheduling BC_OPEN");
 	gigaset_schedule_event(bcs->cs);
 }
 
diff --git a/drivers/isdn/gigaset/i4l.c b/drivers/isdn/gigaset/i4l.c
index c129ee4..f0acb9d 100644
--- a/drivers/isdn/gigaset/i4l.c
+++ b/drivers/isdn/gigaset/i4l.c
@@ -216,7 +216,7 @@ static int command_from_LL(isdn_ctrl *cntrl)
 		return -EINVAL;
 
 	case ISDN_CMD_DIAL:
-		gig_dbg(DEBUG_ANY,
+		gig_dbg(DEBUG_CMD,
 			"ISDN_CMD_DIAL (phone: %s, msn: %s, si1: %d, si2: %d)",
 			cntrl->parm.setup.phone, cntrl->parm.setup.eazmsn,
 			cntrl->parm.setup.si1, cntrl->parm.setup.si2);
@@ -304,11 +304,10 @@ static int command_from_LL(isdn_ctrl *cntrl)
 			gigaset_free_channel(bcs);
 			return -ENOMEM;
 		}
-
-		gig_dbg(DEBUG_CMD, "scheduling DIAL");
 		gigaset_schedule_event(cs);
 		break;
 	case ISDN_CMD_ACCEPTD:
+		gig_dbg(DEBUG_CMD, "ISDN_CMD_ACCEPTD");
 		if (ch >= cs->channels) {
 			dev_err(cs->dev,
 				"ISDN_CMD_ACCEPTD: invalid channel (%d)\n", ch);
@@ -318,14 +317,11 @@ static int command_from_LL(isdn_ctrl *cntrl)
 		if (!gigaset_add_event(cs, &bcs->at_state,
 				       EV_ACCEPT, NULL, 0, NULL))
 			return -ENOMEM;
-
-		gig_dbg(DEBUG_CMD, "scheduling ACCEPT");
 		gigaset_schedule_event(cs);
 
 		break;
-	case ISDN_CMD_ACCEPTB:
-		break;
 	case ISDN_CMD_HANGUP:
+		gig_dbg(DEBUG_CMD, "ISDN_CMD_HANGUP");
 		if (ch >= cs->channels) {
 			dev_err(cs->dev,
 				"ISDN_CMD_HANGUP: invalid channel (%d)\n", ch);
@@ -335,8 +331,6 @@ static int command_from_LL(isdn_ctrl *cntrl)
 		if (!gigaset_add_event(cs, &bcs->at_state,
 				       EV_HUP, NULL, 0, NULL))
 			return -ENOMEM;
-
-		gig_dbg(DEBUG_CMD, "scheduling HUP");
 		gigaset_schedule_event(cs);
 
 		break;
@@ -376,6 +370,7 @@ static int command_from_LL(isdn_ctrl *cntrl)
 		}
 		break;
 	case ISDN_CMD_SETL3: /* Set L3 to given protocol */
+		gig_dbg(DEBUG_CMD, "ISDN_CMD_SETL3");
 		if (ch >= cs->channels) {
 			dev_err(cs->dev,
 				"ISDN_CMD_SETL3: invalid channel (%d)\n", ch);
@@ -390,44 +385,9 @@ static int command_from_LL(isdn_ctrl *cntrl)
 		}
 
 		break;
-	case ISDN_CMD_PROCEED:
-		gig_dbg(DEBUG_ANY, "ISDN_CMD_PROCEED");
-		break;
-	case ISDN_CMD_ALERT:
-		gig_dbg(DEBUG_ANY, "ISDN_CMD_ALERT");
-		if (cntrl->arg >= cs->channels) {
-			dev_err(cs->dev,
-				"ISDN_CMD_ALERT: invalid channel (%d)\n",
-				(int) cntrl->arg);
-			return -EINVAL;
-		}
-		break;
-	case ISDN_CMD_REDIR:
-		gig_dbg(DEBUG_ANY, "ISDN_CMD_REDIR");
-		break;
-	case ISDN_CMD_PROT_IO:
-		gig_dbg(DEBUG_ANY, "ISDN_CMD_PROT_IO");
-		break;
-	case ISDN_CMD_FAXCMD:
-		gig_dbg(DEBUG_ANY, "ISDN_CMD_FAXCMD");
-		break;
-	case ISDN_CMD_GETL2:
-		gig_dbg(DEBUG_ANY, "ISDN_CMD_GETL2");
-		break;
-	case ISDN_CMD_GETL3:
-		gig_dbg(DEBUG_ANY, "ISDN_CMD_GETL3");
-		break;
-	case ISDN_CMD_GETEAZ:
-		gig_dbg(DEBUG_ANY, "ISDN_CMD_GETEAZ");
-		break;
-	case ISDN_CMD_SETSIL:
-		gig_dbg(DEBUG_ANY, "ISDN_CMD_SETSIL");
-		break;
-	case ISDN_CMD_GETSIL:
-		gig_dbg(DEBUG_ANY, "ISDN_CMD_GETSIL");
-		break;
+
 	default:
-		dev_err(cs->dev, "unknown command %d from LL\n",
+		gig_dbg(DEBUG_CMD, "unknown command %d from LL",
 			cntrl->command);
 		return -EINVAL;
 	}
diff --git a/drivers/isdn/gigaset/interface.c b/drivers/isdn/gigaset/interface.c
index d2260b0..a1bcbc2 100644
--- a/drivers/isdn/gigaset/interface.c
+++ b/drivers/isdn/gigaset/interface.c
@@ -45,8 +45,6 @@ static int if_lock(struct cardstate *cs, int *arg)
 		cs->waiting = 0;
 		return -ENOMEM;
 	}
-
-	gig_dbg(DEBUG_CMD, "scheduling IF_LOCK");
 	gigaset_schedule_event(cs);
 
 	wait_event(cs->waitqueue, !cs->waiting);
@@ -81,8 +79,6 @@ static int if_version(struct cardstate *cs, unsigned arg[4])
 			cs->waiting = 0;
 			return -ENOMEM;
 		}
-
-		gig_dbg(DEBUG_CMD, "scheduling IF_VER");
 		gigaset_schedule_event(cs);
 
 		wait_event(cs->waitqueue, !cs->waiting);
@@ -274,7 +270,7 @@ static int if_ioctl(struct tty_struct *tty, struct file *file,
 					? -EFAULT : 0;
 			break;
 		default:
-			gig_dbg(DEBUG_ANY, "%s: arg not supported - 0x%04x",
+			gig_dbg(DEBUG_IF, "%s: arg not supported - 0x%04x",
 				__func__, cmd);
 			retval = -ENOIOCTLCMD;
 		}
@@ -455,7 +451,7 @@ static void if_throttle(struct tty_struct *tty)
 	else if (!cs->open_count)
 		dev_warn(cs->dev, "%s: device not opened\n", __func__);
 	else
-		gig_dbg(DEBUG_ANY, "%s: not implemented\n", __func__);
+		gig_dbg(DEBUG_IF, "%s: not implemented\n", __func__);
 
 	mutex_unlock(&cs->mutex);
 }
@@ -479,7 +475,7 @@ static void if_unthrottle(struct tty_struct *tty)
 	else if (!cs->open_count)
 		dev_warn(cs->dev, "%s: device not opened\n", __func__);
 	else
-		gig_dbg(DEBUG_ANY, "%s: not implemented\n", __func__);
+		gig_dbg(DEBUG_IF, "%s: not implemented\n", __func__);
 
 	mutex_unlock(&cs->mutex);
 }
@@ -630,7 +626,7 @@ void gigaset_if_receive(struct cardstate *cs,
 	spin_lock_irqsave(&cs->lock, flags);
 	tty = cs->tty;
 	if (tty == NULL)
-		gig_dbg(DEBUG_ANY, "receive on closed device");
+		gig_dbg(DEBUG_IF, "receive on closed device");
 	else {
 		tty_buffer_request_room(tty, len);
 		tty_insert_flip_string(tty, buffer, len);
diff --git a/drivers/isdn/gigaset/proc.c b/drivers/isdn/gigaset/proc.c
index 758a00c..b69f73a 100644
--- a/drivers/isdn/gigaset/proc.c
+++ b/drivers/isdn/gigaset/proc.c
@@ -48,8 +48,6 @@ static ssize_t set_cidmode(struct device *dev, struct device_attribute *attr,
 		mutex_unlock(&cs->mutex);
 		return -ENOMEM;
 	}
-
-	gig_dbg(DEBUG_CMD, "scheduling PROC_CIDMODE");
 	gigaset_schedule_event(cs);
 
 	wait_event(cs->waitqueue, !cs->waiting);
diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigaset/usb-gigaset.c
index 3ab1dae..9430a2b 100644
--- a/drivers/isdn/gigaset/usb-gigaset.c
+++ b/drivers/isdn/gigaset/usb-gigaset.c
@@ -628,7 +628,7 @@ static int write_modem(struct cardstate *cs)
 	struct usb_cardstate *ucs = cs->hw.usb;
 	unsigned long flags;
 
-	gig_dbg(DEBUG_WRITE, "len: %d...", bcs->tx_skb->len);
+	gig_dbg(DEBUG_OUTPUT, "len: %d...", bcs->tx_skb->len);
 
 	if (!bcs->tx_skb->len) {
 		dev_kfree_skb_any(bcs->tx_skb);
-- 
1.6.5.3.298.g39add

