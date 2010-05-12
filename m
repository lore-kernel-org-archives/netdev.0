From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] net sched: cleanup and rate limit warning
Date: Tue, 11 May 2010 17:24:12 -0700
Message-ID: <20100511172412.76aff184@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57003 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752716Ab0ELAYP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 May 2010 20:24:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the user has a bad classification configuration, and gets a packet
that goes through too many steps. Chances are more packets will arrive,
and the message spew will overrun syslog because it is not rate limited.
And because it is not tagged with appropriate priority it can't not be screened.

Added the qdisc to the message to try and give some more context when
the message does arrive.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Please think about this for 2.6.34 and could even be -stable material.

--- a/net/sched/sch_api.c	2010-05-11 17:08:42.177374275 -0700
+++ b/net/sched/sch_api.c	2010-05-11 17:16:59.560612078 -0700
@@ -1637,9 +1638,12 @@ reclassify:
 		tp = otp;
 
 		if (verd++ >= MAX_REC_LOOP) {
-			printk("rule prio %u protocol %02x reclassify loop, "
-			       "packet dropped\n",
-			       tp->prio&0xffff, ntohs(tp->protocol));
+			if (net_ratelimit())
+				printk(KERN_NOTICE
+				       "%s: packet reclassify loop"
+					  " rule prio %u protocol %02x\n",
+				       tp->q->ops->id,
+				       tp->prio & 0xffff, ntohs(tp->protocol));
 			return TC_ACT_SHOT;
 		}
 		skb->tc_verd = SET_TC_VERD(skb->tc_verd, verd);
