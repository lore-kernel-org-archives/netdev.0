From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/4) packet scheduler bad TDIFF_SAFE in csz
Date: Tue, 29 Jun 2004 14:00:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629140016.4afeb36b@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This code in the csz scheduler, is just plain broken.  The TDIFF_SAFE 
effectively expands to:
	unsigned long delay = now - q->t_c;
	if (delay > 0) {
		delay = 0;
		goto do_reset;
	}
	if (delay >> q->delta_log)

So delay is always 0!  I assume that what was originally intended
is the to keep delay bounded to 1<<q->delta_log. 

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


diff -Nru a/net/sched/sch_csz.c b/net/sched/sch_csz.c
--- a/net/sched/sch_csz.c	2004-06-29 11:32:40 -07:00
+++ b/net/sched/sch_csz.c	2004-06-29 11:32:40 -07:00
@@ -378,10 +378,8 @@
 	unsigned long		R_c;
 
 	PSCHED_GET_TIME(now);
-	delay = PSCHED_TDIFF_SAFE(now, q->t_c, 0, goto do_reset);
-
+	delay = PSCHED_TDIFF(now, q->t_c);
 	if (delay>>q->delta_log) {
-do_reset:
 		/* Delta is too large.
 		   It is possible if MTU/BW > 1<<q->delta_log
 		   (i.e. configuration error) or because of hardware
