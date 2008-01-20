From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 2/3][NET] gen_estimator: list_empty() check in est_timer()
	fixed
Date: Mon, 21 Jan 2008 00:49:59 +0100
Message-ID: <20080120234959.GB2691@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:38575 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756161AbYATXrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 18:47:35 -0500
Received: by ug-out-1314.google.com with SMTP id z38so798030ugc.16
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2008 15:47:33 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the method of checking for empty list in est_timer():
list_empty() is not recommended for RCU protected lists. Now, it's simply
a variable used for this.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

diff -Nurp 2.6.24-rc8-mm1-p1-/net/core/gen_estimator.c 2.6.24-rc8-mm1-p1+/net/core/gen_estimator.c
--- 2.6.24-rc8-mm1-p1-/net/core/gen_estimator.c	2008-01-20 20:58:35.000000000 +0100
+++ 2.6.24-rc8-mm1-p1+/net/core/gen_estimator.c	2008-01-20 21:07:42.000000000 +0100
@@ -106,6 +106,7 @@ static void est_timer(unsigned long arg)
 {
 	int idx = (int)arg;
 	struct gen_estimator *e;
+	int list_not_empty = 0;
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(e, &elist[idx].list, list) {
@@ -118,6 +119,9 @@ static void est_timer(unsigned long arg)
 		if (e->bstats == NULL)
 			goto skip;
 
+		if (list_not_empty == 0)
+			list_not_empty = 1;
+
 		nbytes = e->bstats->bytes;
 		npackets = e->bstats->packets;
 		rate = (nbytes - e->last_bytes)<<(7 - idx);
@@ -134,7 +138,7 @@ skip:
 		spin_unlock(e->stats_lock);
 	}
 
-	if (!list_empty(&elist[idx].list))
+	if (list_not_empty)
 		mod_timer(&elist[idx].timer, jiffies + ((HZ/4) << idx));
 	rcu_read_unlock();
 }
