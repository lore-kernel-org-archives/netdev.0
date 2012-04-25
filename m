From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 5/8] isdn/gigaset: internal function name cleanup
Date: Thu, 26 Apr 2012 01:02:20 +0200 (CEST)
Message-ID: <20120425-patch-gigaset-05.tilman@imap.cc>
References: <20120425-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120425-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Functions clear_at_state and free_strings did the same thing;
drop one of them, keeping the more descriptive name.
Drop a redundant call.
Rename function dealloc_at_states to dealloc_temp_at_states
to clarify its purpose.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/common.c |   16 +++++-----------
 1 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 7679270..6c306d4 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -362,7 +362,7 @@ struct event_t *gigaset_add_event(struct cardstate *cs,
 }
 EXPORT_SYMBOL_GPL(gigaset_add_event);
 
-static void free_strings(struct at_state_t *at_state)
+static void clear_at_state(struct at_state_t *at_state)
 {
 	int i;
 
@@ -372,18 +372,13 @@ static void free_strings(struct at_state_t *at_state)
 	}
 }
 
-static void clear_at_state(struct at_state_t *at_state)
-{
-	free_strings(at_state);
-}
-
-static void dealloc_at_states(struct cardstate *cs)
+static void dealloc_temp_at_states(struct cardstate *cs)
 {
 	struct at_state_t *cur, *next;
 
 	list_for_each_entry_safe(cur, next, &cs->temp_at_states, list) {
 		list_del(&cur->list);
-		free_strings(cur);
+		clear_at_state(cur);
 		kfree(cur);
 	}
 }
@@ -512,7 +507,7 @@ void gigaset_freecs(struct cardstate *cs)
 	case 1: /* error when registering to LL */
 		gig_dbg(DEBUG_INIT, "clearing at_state");
 		clear_at_state(&cs->at_state);
-		dealloc_at_states(cs);
+		dealloc_temp_at_states(cs);
 
 		/* fall through */
 	case 0:	/* error in basic setup */
@@ -848,8 +843,7 @@ static void cleanup_cs(struct cardstate *cs)
 	cs->mstate = MS_UNINITIALIZED;
 
 	clear_at_state(&cs->at_state);
-	dealloc_at_states(cs);
-	free_strings(&cs->at_state);
+	dealloc_temp_at_states(cs);
 	gigaset_at_init(&cs->at_state, NULL, cs, 0);
 
 	cs->inbuf->inputstate = INS_command;
-- 
1.7.3.4
