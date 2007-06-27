From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET]: gen_estimator: fix locking and timer related bugs [Re:
 [Bugme-new] [Bug 8668] New: HTB Deadlock]
Date: Wed, 27 Jun 2007 17:25:45 +0200
Message-ID: <46828179.5030404@trash.net>
References: <20070627114521.GA3762@ff.dom.local> <46824D88.1090300@trash.net> <20070627121013.GB3762@ff.dom.local> <468279FC.3070502@trash.net> <46827DB1.3060509@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050800060208030001050603"
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>, ranko@spidernet.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59358 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121AbXF0P0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 11:26:16 -0400
In-Reply-To: <46827DB1.3060509@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050800060208030001050603
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> [NET]: gen_estimator: fix locking and timer related bugs
> 


That one still left a race, we could be reinitalizing the timer
while it is still running. This patch additionally makes sure
each timer is only initialized once.


--------------050800060208030001050603
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET]: gen_estimator: fix locking and timer related bugs

As noticed by Jarek Poplawski <jarkao2@o2.pl>, the timer removal in
gen_kill_estimator races with the timer function rearming the timer.

Additionally there are a few more related problems that seem to be
relicts from the timer when the estimator was qdisc specific and
could rely on the rtnl or dev->qdisc_lock:

- the check whether the list is empty and a timer needs to be started
  when adding a new estimator doesn't take the lock, so it races
  against concurrent additions, which can result in the timer beeing
  added twice or getting reinitialized after being added.

- the new estimator's next pointer is also set without holding the
  lock, again racing against concurrent additions with possible
  list corruption as a result.

- the timer deletion when killing an estimator is also not under
  the lock and races against timer arming when adding a new estimator.

Fix by holding the lock around the entire list addition and initial
timer arming. Removal is not done explicitly anymore, instead the
timer function only rearms the timer when there are still estimators
present.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit b6a0c468c258d96c6f132fc71ca74225235bc223
tree 6f61004cf4810a4826aa5c7477e4d455ae3a5698
parent 48d8d7ee5dd17c64833e0343ab4ae8ef01cc2648
author Patrick McHardy <kaber@trash.net> Wed, 27 Jun 2007 17:06:02 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 27 Jun 2007 17:24:13 +0200

 net/core/gen_estimator.c |   27 +++++++++++----------------
 1 files changed, 11 insertions(+), 16 deletions(-)

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 17daf4c..88a7805 100644
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
 
@@ -152,6 +152,7 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
 {
 	struct gen_estimator *est;
 	struct gnet_estimator *parm = RTA_DATA(opt);
+	int idx;
 
 	if (RTA_PAYLOAD(opt) < sizeof(*parm))
 		return -EINVAL;
@@ -163,7 +164,7 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
 	if (est == NULL)
 		return -ENOBUFS;
 
-	est->interval = parm->interval + 2;
+	est->interval = idx = parm->interval + 2;
 	est->bstats = bstats;
 	est->rate_est = rate_est;
 	est->stats_lock = stats_lock;
@@ -173,16 +174,14 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
 	est->last_packets = bstats->packets;
 	est->avpps = rate_est->pps<<10;
 
-	est->next = elist[est->interval].list;
-	if (est->next == NULL) {
-		init_timer(&elist[est->interval].timer);
-		elist[est->interval].timer.data = est->interval;
-		elist[est->interval].timer.expires = jiffies + ((HZ<<est->interval)/4);
-		elist[est->interval].timer.function = est_timer;
-		add_timer(&elist[est->interval].timer);
-	}
 	write_lock_bh(&est_lock);
-	elist[est->interval].list = est;
+	if (!elist[idx].timer.function)
+		setup_timer(&elist[idx].timer, est_timer, est->interval);
+	if (elist[est->interval].list == NULL)
+		mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
+
+	est->next = elist[idx].list;
+	elist[idx].list = est;
 	write_unlock_bh(&est_lock);
 	return 0;
 }
@@ -202,7 +201,6 @@ void gen_kill_estimator(struct gnet_stats_basic *bstats,
 	struct gen_estimator *est, **pest;
 
 	for (idx=0; idx <= EST_MAX_INTERVAL; idx++) {
-		int killed = 0;
 		pest = &elist[idx].list;
 		while ((est=*pest) != NULL) {
 			if (est->rate_est != rate_est || est->bstats != bstats) {
@@ -215,10 +213,7 @@ void gen_kill_estimator(struct gnet_stats_basic *bstats,
 			write_unlock_bh(&est_lock);
 
 			kfree(est);
-			killed++;
 		}
-		if (killed && elist[idx].list == NULL)
-			del_timer(&elist[idx].timer);
 	}
 }
 

--------------050800060208030001050603--
