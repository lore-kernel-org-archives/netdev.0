From: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org
Subject: [PATCH 1/4] [IrDA] Resend frames on timeout
Date: Sat, 19 Jan 2008 01:02:06 +0100
Message-ID: <20080119000555.152691119@sortiz.org>
References: <20080119000205.827714764@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline; filename=irlap_resend_ftimer.patch
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

From: Robie Basak <rb-oss-1-ptXJlWIB0NTrnbRv5XOUuA@public.gmane.org>

When final timer expires, it might also mean that the i:cmd wasn't 
received properly. If we have rejected frames, we can try to resend them.

Signed-off-by: Robie Basak <rb-oss-1-ptXJlWIB0NTrnbRv5XOUuA@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
---
 net/irda/irlap_event.c |   12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

Index: net-2.6.25/net/irda/irlap_event.c
===================================================================
--- net-2.6.25.orig/net/irda/irlap_event.c	2008-01-14 19:27:06.000000000 +0100
+++ net-2.6.25/net/irda/irlap_event.c	2008-01-17 06:33:33.000000000 +0100
@@ -1514,9 +1514,15 @@
 
 		/* N2 is the disconnect timer. Until we reach it, we retry */
 		if (self->retry_count < self->N2) {
-			/* Retry sending the pf bit to the secondary */
-			irlap_wait_min_turn_around(self, &self->qos_tx);
-			irlap_send_rr_frame(self, CMD_FRAME);
+			if (skb_peek(&self->wx_list) == NULL) {
+				/* Retry sending the pf bit to the secondary */
+				IRDA_DEBUG(4, "nrm_p: resending rr");
+				irlap_wait_min_turn_around(self, &self->qos_tx);
+				irlap_send_rr_frame(self, CMD_FRAME);
+ 			} else {
+				IRDA_DEBUG(4, "nrm_p: resend frames");
+				irlap_resend_rejected_frames(self, CMD_FRAME);
+ 			}
 
 			irlap_start_final_timer(self, self->final_timeout);
 			self->retry_count++;

-- 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
