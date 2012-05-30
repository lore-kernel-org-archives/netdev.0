From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: Re: Strange latency spikes/TX network stalls on Sun Fire X4150(x86)
 and e1000e
Date: Wed, 30 May 2012 09:06:02 +0900
Message-ID: <20120530090602.6204d857.shimoda.hiroaki@gmail.com>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
	<88c43001441945e1431609db252b69e7@visp.net.lb>
	<df211722d18136698aeeda2f17b876e2@visp.net.lb>
	<d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
	<CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>
	<79d6b56fdf5f4be4656079568d5a7445@visp.net.lb>
	<CA+mtBx_sF5GCMRpLQuTruZ=xpFTFpd5z8SZJaG_dBqf4oCXpwg@mail.gmail.com>
	<20120529232518.e5b41759.shimoda.hiroaki@gmail.com>
	<CA+mtBx_uYy9XcRvpD2E46FuMBFu38iQvCiwFHWqbhPBmY=JfOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, eric.dumazet@gmail.com,
	davem@davemloft.net
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:53412 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751603Ab2E3AGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 20:06:06 -0400
Received: by dady13 with SMTP id y13so6128834dad.19
        for <netdev@vger.kernel.org>; Tue, 29 May 2012 17:06:06 -0700 (PDT)
In-Reply-To: <CA+mtBx_uYy9XcRvpD2E46FuMBFu38iQvCiwFHWqbhPBmY=JfOg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While reading the bql code, I have some questions.

1) dql_completed() and dql_queued() can be called concurrently,
   so dql->num_queued could change while processing
   dql_completed().
   Is it intentional to refer num_queued from "dql->" each time ?

2) From the comment in the code
   *   - The queue was over-limit in the previous interval and
   *     when enqueuing it was possible that all queued data
   *     had been consumed.

   and

   * Queue was not starved, check if the limit can be decreased.
   * A decrease is only considered if the queue has been busy in
   * the whole interval (the check above). 

   the calculation of all_prev_completed should take into account
   completed == dql->prev_num_queued case ?
   On current implementation, limit shrinks easily and some NIC
   hit TX stalls.
   To mitigate TX stalls, should we fix all_prev_completed rather
   than individual driver ?

3) limit calculation fails to consider integer wrap around in
   one place ?

Here is the patch what I meant.

diff --git a/lib/dynamic_queue_limits.c b/lib/dynamic_queue_limits.c
@@ -11,22 +11,27 @@
 #include <linux/dynamic_queue_limits.h>
 
 #define POSDIFF(A, B) ((A) > (B) ? (A) - (B) : 0)
+#define POSDIFFI(A, B) ((int)((A) - (B)) > 0 ? (A) - (B) : 0)
+#define AFTER_EQ(A, B) ((int)((A) - (B)) >= 0)
 
 /* Records completed count and recalculates the queue limit */
 void dql_completed(struct dql *dql, unsigned int count)
 {
 	unsigned int inprogress, prev_inprogress, limit;
-	unsigned int ovlimit, all_prev_completed, completed;
+	unsigned int ovlimit, completed, num_queued;
+	bool all_prev_completed;
+
+	num_queued = dql->num_queued;
 
 	/* Can't complete more than what's in queue */
-	BUG_ON(count > dql->num_queued - dql->num_completed);
+	BUG_ON(count > num_queued - dql->num_completed);
 
 	completed = dql->num_completed + count;
 	limit = dql->limit;
-	ovlimit = POSDIFF(dql->num_queued - dql->num_completed, limit);
-	inprogress = dql->num_queued - completed;
+	ovlimit = POSDIFF(num_queued - dql->num_completed, limit);
+	inprogress = num_queued - completed;
 	prev_inprogress = dql->prev_num_queued - dql->num_completed;
-	all_prev_completed = POSDIFF(completed, dql->prev_num_queued);
+	all_prev_completed = AFTER_EQ(completed, dql->prev_num_queued);
 
 	if ((ovlimit && !inprogress) ||
 	    (dql->prev_ovlimit && all_prev_completed)) {
@@ -45,7 +50,7 @@ void dql_completed(struct dql *dql, unsigned int count)
 		 *     of bytes both sent and completed in the last interval,
 		 *     plus any previous over-limit.
 		 */
-		limit += POSDIFF(completed, dql->prev_num_queued) +
+		limit += POSDIFFI(completed, dql->prev_num_queued) +
 		     dql->prev_ovlimit;
 		dql->slack_start_time = jiffies;
 		dql->lowest_slack = UINT_MAX;
@@ -104,7 +109,7 @@ void dql_completed(struct dql *dql, unsigned int count)
 	dql->prev_ovlimit = ovlimit;
 	dql->prev_last_obj_cnt = dql->last_obj_cnt;
 	dql->num_completed = completed;
-	dql->prev_num_queued = dql->num_queued;
+	dql->prev_num_queued = num_queued;
 }
 EXPORT_SYMBOL(dql_completed);
