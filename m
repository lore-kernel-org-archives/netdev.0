From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] NET_SCHED: restore HZ value to /proc/net/psched
Date: Mon, 23 Jun 2008 11:13:20 -0700
Message-ID: <20080623111320.7ddb72b9@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:36443 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753654AbYFWSN1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 14:13:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some changes back in  2.6.22 broke a number of
other places where the iproute2 utilities depended on kernel HZ
value. The use of HZ was a bad original ABI design choice; the
question is how to fix the impacts.

During 2.6.22 development, the psched clock was converted over
to use high resolution timers, and one of the changes was to the
return value of /proc/net/psched. This file is used by utilities
to determine conversion between time and jiffies.
It would be better to go back to the original format
output where the fourth field was the kernel HZ.

The motivation for the change was to make the HTB burst size
default smaller because the kernel clock resolution was better.  
But the change broke the use of jiffies by dst_metrics.

With this revert all the metric RTT values will work again.
The only use of hz in htb is to set the buffer and ceiling buffer default,
and having the old value would cause a slightly larger value. Note: the comment
in q_htb is incorrect, the value calculated is the default not the
minimum.  As an example if HTB rate is 1mbit, then the default buffer
would be come 11500 (with 100 HZ) vs 1500 (with 2.6.25).

This effectively reverts commit 4361cb17f0df5491fe6e2c3ae1defc98e9a64a79
I am not 100% convinced this is the best or only solution.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/sched/sch_api.c	2008-06-23 10:55:44.000000000 -0700
+++ b/net/sched/sch_api.c	2008-06-23 10:56:11.000000000 -0700
@@ -1266,13 +1266,9 @@ EXPORT_SYMBOL(tcf_destroy_chain);
 #ifdef CONFIG_PROC_FS
 static int psched_show(struct seq_file *seq, void *v)
 {
-	struct timespec ts;
-
-	hrtimer_get_res(CLOCK_MONOTONIC, &ts);
 	seq_printf(seq, "%08x %08x %08x %08x\n",
 		   (u32)NSEC_PER_USEC, (u32)PSCHED_US2NS(1),
-		   1000000,
-		   (u32)NSEC_PER_SEC/(u32)ktime_to_ns(timespec_to_ktime(ts)));
+		   1000000, HZ);
 
 	return 0;
 }
