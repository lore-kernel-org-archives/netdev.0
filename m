From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netem: dont call vfree() under spinlock and BH disabled
Date: Sat, 24 Dec 2011 06:28:51 +0100
Message-ID: <1324704531.2915.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55167 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915Ab1LXF2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Dec 2011 00:28:55 -0500
Received: by wgbdr13 with SMTP id dr13so18243713wgb.1
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 21:28:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 6373a9a286 (netem: use vmalloc for distribution table) added a
regression, since vfree() is called while holding a spinlock and BH
being disabled.

Fix this by doing the pointers swap in critical section, and freeing
after spinlock release.

Also add __GFP_NOWARN to the kmalloc() try, since we fallback to
vmalloc().

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_netem.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index eb3b9a8..a4ab207 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -488,7 +488,7 @@ static int get_dist_table(struct Qdisc *sch, const struct nlattr *attr)
 		return -EINVAL;
 
 	s = sizeof(struct disttable) + n * sizeof(s16);
-	d = kmalloc(s, GFP_KERNEL);
+	d = kmalloc(s, GFP_KERNEL | __GFP_NOWARN);
 	if (!d)
 		d = vmalloc(s);
 	if (!d)
@@ -501,9 +501,10 @@ static int get_dist_table(struct Qdisc *sch, const struct nlattr *attr)
 	root_lock = qdisc_root_sleeping_lock(sch);
 
 	spin_lock_bh(root_lock);
-	dist_free(q->delay_dist);
-	q->delay_dist = d;
+	swap(q->delay_dist, d);
 	spin_unlock_bh(root_lock);
+
+	dist_free(d);
 	return 0;
 }
 
