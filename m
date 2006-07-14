From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] HTB initialize upper bound properly
Date: Fri, 14 Jul 2006 12:03:41 -0700
Message-ID: <20060714120341.0c7f4466@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:48355 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1422714AbWGNTEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 15:04:14 -0400
To: "David S. Miller" <davem@davemloft.net>, Jamal <hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The upper bound for HTB time diff needs to be scaled to PSCHED
units rather than just assuming usecs.  The field mbuffer is used
in TDIFF_SAFE(), as an upper bound.  Untested...

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- netem-2.6.orig/net/sched/sch_htb.c
+++ netem-2.6/net/sched/sch_htb.c
@@ -196,7 +196,7 @@ struct htb_class
     struct qdisc_rate_table *rate;	/* rate table of the class itself */
     struct qdisc_rate_table *ceil;	/* ceiling rate (limits borrows too) */
     long buffer,cbuffer;		/* token bucket depth/rate */
-    long mbuffer;			/* max wait time */
+    psched_tdiff_t mbuffer;		/* max wait time */
     long tokens,ctokens;		/* current number of tokens */
     psched_time_t t_c;			/* checkpoint time */
 };
@@ -1601,7 +1601,7 @@ static int htb_change_class(struct Qdisc
 		/* set class to be in HTB_CAN_SEND state */
 		cl->tokens = hopt->buffer;
 		cl->ctokens = hopt->cbuffer;
-		cl->mbuffer = 60000000; /* 1min */
+		cl->mbuffer = PSCHED_JIFFIE2US(HZ*60) /* 1min */
 		PSCHED_GET_TIME(cl->t_c);
 		cl->cmode = HTB_CAN_SEND;
 
