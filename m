From: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org
Subject: [PATCH 1/2] [IrDA] Fix Rx/Tx path race
Date: Sat, 09 Jun 2007 04:08:16 +0300
Message-ID: <20070609011019.937132965@sortiz.org>
References: <20070609010815.963618030@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	"G. Liakhovetski" <gl-o/hVf8ie6tKzQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline; filename=0010-IrDA-Fix-Rx-Tx-path-race.patch
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: G. Liakhovetski <gl-o/hVf8ie6tKzQB+pC5nmwQ@public.gmane.org>

We need to switch to NRM _before_ sending the final packet otherwise we might hit a race condition where we get the first packet from the peer while we're still in LAP_XMIT_P.

Cc: G. Liakhovetski <gl-o/hVf8ie6tKzQB+pC5nmwQ@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
---
 include/net/irda/irlap.h |   17 +++++++++++++++++
 net/irda/irlap_event.c   |   18 ------------------
 net/irda/irlap_frame.c   |    3 +++
 3 files changed, 20 insertions(+), 18 deletions(-)

Index: net-2.6-quilt/include/net/irda/irlap.h
===================================================================
--- net-2.6-quilt.orig/include/net/irda/irlap.h	2007-05-10 19:23:04.000000000 +0300
+++ net-2.6-quilt/include/net/irda/irlap.h	2007-05-10 19:24:57.000000000 +0300
@@ -289,4 +289,21 @@
 	self->disconnect_pending = FALSE;
 }
 
+/*
+ * Function irlap_next_state (self, state)
+ *
+ *    Switches state and provides debug information
+ *
+ */
+static inline void irlap_next_state(struct irlap_cb *self, IRLAP_STATE state)
+{
+	/*
+	if (!self || self->magic != LAP_MAGIC)
+		return;
+
+	IRDA_DEBUG(4, "next LAP state = %s\n", irlap_state[state]);
+	*/
+	self->state = state;
+}
+
 #endif
Index: net-2.6-quilt/net/irda/irlap_event.c
===================================================================
--- net-2.6-quilt.orig/net/irda/irlap_event.c	2007-05-10 19:23:04.000000000 +0300
+++ net-2.6-quilt/net/irda/irlap_event.c	2007-05-10 19:23:09.000000000 +0300
@@ -317,23 +317,6 @@
 }
 
 /*
- * Function irlap_next_state (self, state)
- *
- *    Switches state and provides debug information
- *
- */
-static inline void irlap_next_state(struct irlap_cb *self, IRLAP_STATE state)
-{
-	/*
-	if (!self || self->magic != LAP_MAGIC)
-		return;
-
-	IRDA_DEBUG(4, "next LAP state = %s\n", irlap_state[state]);
-	*/
-	self->state = state;
-}
-
-/*
  * Function irlap_state_ndm (event, skb, frame)
  *
  *    NDM (Normal Disconnected Mode) state
@@ -1086,7 +1069,6 @@
 			} else {
 				/* Final packet of window */
 				irlap_send_data_primary_poll(self, skb);
-				irlap_next_state(self, LAP_NRM_P);
 
 				/*
 				 * Make sure state machine does not try to send
Index: net-2.6-quilt/net/irda/irlap_frame.c
===================================================================
--- net-2.6-quilt.orig/net/irda/irlap_frame.c	2007-05-10 19:23:04.000000000 +0300
+++ net-2.6-quilt/net/irda/irlap_frame.c	2007-05-10 19:25:59.000000000 +0300
@@ -798,16 +798,19 @@
 		self->vs = (self->vs + 1) % 8;
 		self->ack_required = FALSE;
 
+		irlap_next_state(self, LAP_NRM_P);
 		irlap_send_i_frame(self, tx_skb, CMD_FRAME);
 	} else {
 		IRDA_DEBUG(4, "%s(), sending unreliable frame\n", __FUNCTION__);
 
 		if (self->ack_required) {
 			irlap_send_ui_frame(self, skb_get(skb), self->caddr, CMD_FRAME);
+			irlap_next_state(self, LAP_NRM_P);
 			irlap_send_rr_frame(self, CMD_FRAME);
 			self->ack_required = FALSE;
 		} else {
 			skb->data[1] |= PF_BIT;
+			irlap_next_state(self, LAP_NRM_P);
 			irlap_send_ui_frame(self, skb_get(skb), self->caddr, CMD_FRAME);
 		}
 	}

-- 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
