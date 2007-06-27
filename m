From: Patrick McHardy <kaber@trash.net>
Subject: [NET]: gen_estimator: fix locking and timer related bugs [Re: [Bugme-new]
 [Bug 8668] New: HTB Deadlock]
Date: Wed, 27 Jun 2007 17:09:37 +0200
Message-ID: <46827DB1.3060509@trash.net>
References: <20070627114521.GA3762@ff.dom.local> <46824D88.1090300@trash.net> <20070627121013.GB3762@ff.dom.local> <468279FC.3070502@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020504070504040700010903"
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>, ranko@spidernet.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59061 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761076AbXF0PKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 11:10:52 -0400
In-Reply-To: <468279FC.3070502@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020504070504040700010903
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> I look at this just now, and maybe it's enough for asking,
>> but definitely not enough for patch. I'll try to check this
>> more in the evening, so I could send something tomorrow.
>>
>> So if it's not only about kindness, feel free to do it
>> sooner and I've no doubts  - better.
>
> I can take care of it, no problem. 


OK, this patch should fix the Jarek noticed (and a few more).
It does not fix the original HTB problem though.




--------------020504070504040700010903
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET]: gen_estimator: fix locking and timer related bugs

As noticed by Jarek Poplawski <jarkao2@o2.pl>, the timer removal in
gen_kill_estimator races with the timer function rearming the timer.

Additionally there are a few more related problems that seem to be
relicts from the time when the estimator was qdisc specific and
could rely on the rtnl or dev->qdisc_lock:

- the check whether the list is empty and a timer needs to be started
  when adding a new estimator doesn't take the lock, so it races
  against concurrent additions, which can result in the timer getting
  added twice or getting reinitialized after getting added.

- the new estimator's next pointer is also set without holding the
  lock, again racing against concurrent additions with possible
  list corruption as a result.

- the timer deletion when killing an estimator is also not under
  the lock and races against timer arming when adding a new estimator.

Fix by holding the lock around the entire list addition and initial
timer arming. Timer removal is not done explicitly anymore, instead
the timer function only rearms the timer when there are still
estimators present.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 59b5997f78c3cf3366886969ac8e6b38100b30e9
tree 9b43ce1af21ad1c8817f1f2bc8291c0f60457a4e
parent 48d8d7ee5dd17c64833e0343ab4ae8ef01cc2648
author Patrick McHardy <kaber@trash.net> Wed, 27 Jun 2007 17:06:02 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 27 Jun 2007 17:06:02 +0200

 net/core/gen_estimator.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 17daf4c..49a0bd3 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -127,8 +127,8 @@ static void est_timer(unsigned long arg)
 		e->rate_est->pps = (e->avpps+0x1FF)>>10;
 		spin_unlock(e->stats_lock);
 	}
-
-	mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
+	if (elist[idx].list != NULL)
+		mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
 	read_unlock(&est_lock);
 }
 
@@ -173,6 +173,7 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
 	est->last_packets = bstats->packets;
 	est->avpps = rate_est->pps<<10;
 
+	write_lock_bh(&est_lock);
 	est->next = elist[est->interval].list;
 	if (est->next == NULL) {
 		init_timer(&elist[est->interval].timer);
@@ -181,7 +182,6 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
 		elist[est->interval].timer.function = est_timer;
 		add_timer(&elist[est->interval].timer);
 	}
-	write_lock_bh(&est_lock);
 	elist[est->interval].list = est;
 	write_unlock_bh(&est_lock);
 	return 0;
@@ -202,7 +202,6 @@ void gen_kill_estimator(struct gnet_stats_basic *bstats,
 	struct gen_estimator *est, **pest;
 
 	for (idx=0; idx <= EST_MAX_INTERVAL; idx++) {
-		int killed = 0;
 		pest = &elist[idx].list;
 		while ((est=*pest) != NULL) {
 			if (est->rate_est != rate_est || est->bstats != bstats) {
@@ -215,10 +214,7 @@ void gen_kill_estimator(struct gnet_stats_basic *bstats,
 			write_unlock_bh(&est_lock);
 
 			kfree(est);
-			killed++;
 		}
-		if (killed && elist[idx].list == NULL)
-			del_timer(&elist[idx].timer);
 	}
 }
 

--------------020504070504040700010903--
