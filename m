From: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org
Subject: [PATCH 2/2] [IrDA] f-timer reloading when sending
	rejected frames
Date: Sat, 09 Jun 2007 04:08:17 +0300
Message-ID: <20070609011020.439675215@sortiz.org>
References: <20070609010815.963618030@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	"G. Liakhovetski" <gl-o/hVf8ie6tKzQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline; filename=final-timer-recharge.patch
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

Jean II was right: you have to re-charge the final timer when resending 
rejected frames. Otherwise it triggers at a wrong time and can break the 
currently running communication. Reproducible under rt-preempt.

Signed-off-by: G. Liakhovetski <gl-o/hVf8ie6tKzQB+pC5nmwQ@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>

Index: net-2.6-quilt/net/irda/irlap_event.c
===================================================================
--- net-2.6-quilt.orig/net/irda/irlap_event.c	2007-05-29 09:36:09.000000000 +0300
+++ net-2.6-quilt/net/irda/irlap_event.c	2007-05-29 09:38:19.000000000 +0300
@@ -1418,14 +1418,14 @@
 		 */
 		self->remote_busy = FALSE;
 
+		/* Stop final timer */
+		del_timer(&self->final_timer);
+
 		/*
 		 *  Nr as expected?
 		 */
 		ret = irlap_validate_nr_received(self, info->nr);
 		if (ret == NR_EXPECTED) {
-			/* Stop final timer */
-			del_timer(&self->final_timer);
-
 			/* Update Nr received */
 			irlap_update_nr_received(self, info->nr);
 
@@ -1457,14 +1457,12 @@
 
 			/* Resend rejected frames */
 			irlap_resend_rejected_frames(self, CMD_FRAME);
-
-			/* Final timer ??? Jean II */
+			irlap_start_final_timer(self, self->final_timeout * 2);
 
 			irlap_next_state(self, LAP_NRM_P);
 		} else if (ret == NR_INVALID) {
 			IRDA_DEBUG(1, "%s(), Received RR with "
 				   "invalid nr !\n", __FUNCTION__);
-			del_timer(&self->final_timer);
 
 			irlap_next_state(self, LAP_RESET_WAIT);
 

-- 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
