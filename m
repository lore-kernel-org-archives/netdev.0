From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 4/6] isdn/gigaset: beautify common.c
Date: Mon, 21 Jan 2013 22:57:21 +0100 (CET)
Message-ID: <20130121-patch-isdn-04.tilman@imap.cc>
References: <20130121-patch-isdn-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130121-patch-isdn-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rearrange the gigaset_freecs() function to make it more readable,
and adapt gigaset_initcs() accordingly.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/common.c |   31 +++++++++----------------------
 1 files changed, 9 insertions(+), 22 deletions(-)

diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 6849a11..7c78144 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -467,11 +467,6 @@ void gigaset_freecs(struct cardstate *cs)
 
 	mutex_lock(&cs->mutex);
 
-	if (!cs->bcs)
-		goto f_cs;
-	if (!cs->inbuf)
-		goto f_bcs;
-
 	spin_lock_irqsave(&cs->lock, flags);
 	cs->running = 0;
 	spin_unlock_irqrestore(&cs->lock, flags); /* event handler and timer are
@@ -507,17 +502,16 @@ void gigaset_freecs(struct cardstate *cs)
 		gig_dbg(DEBUG_INIT, "clearing at_state");
 		clear_at_state(&cs->at_state);
 		dealloc_temp_at_states(cs);
+		clear_events(cs);
 		tty_port_destroy(&cs->port);
 
 		/* fall through */
 	case 0:	/* error in basic setup */
-		clear_events(cs);
 		gig_dbg(DEBUG_INIT, "freeing inbuf");
 		kfree(cs->inbuf);
+		kfree(cs->bcs);
 	}
-f_bcs:	gig_dbg(DEBUG_INIT, "freeing bcs[]");
-	kfree(cs->bcs);
-f_cs:	gig_dbg(DEBUG_INIT, "freeing cs");
+
 	mutex_unlock(&cs->mutex);
 	free_cs(cs);
 }
@@ -687,19 +681,6 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 		return NULL;
 	}
 
-	gig_dbg(DEBUG_INIT, "allocating bcs[0..%d]", channels - 1);
-	cs->bcs = kmalloc(channels * sizeof(struct bc_state), GFP_KERNEL);
-	if (!cs->bcs) {
-		pr_err("out of memory\n");
-		goto error;
-	}
-	gig_dbg(DEBUG_INIT, "allocating inbuf");
-	cs->inbuf = kmalloc(sizeof(struct inbuf_t), GFP_KERNEL);
-	if (!cs->inbuf) {
-		pr_err("out of memory\n");
-		goto error;
-	}
-
 	cs->cs_init = 0;
 	cs->channels = channels;
 	cs->onechannel = onechannel;
@@ -729,6 +710,12 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 	cs->mode = M_UNKNOWN;
 	cs->mstate = MS_UNINITIALIZED;
 
+	cs->bcs = kmalloc(channels * sizeof(struct bc_state), GFP_KERNEL);
+	cs->inbuf = kmalloc(sizeof(struct inbuf_t), GFP_KERNEL);
+	if (!cs->bcs || !cs->inbuf) {
+		pr_err("out of memory\n");
+		goto error;
+	}
 	++cs->cs_init;
 
 	gig_dbg(DEBUG_INIT, "setting up at_state");
-- 
1.7.3.4
