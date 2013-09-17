From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH net-next] gen_estimator: change the lock order for better perfermance
Date: Tue, 17 Sep 2013 16:38:21 +0800
Message-ID: <1379407101-18933-1-git-send-email-zhiguohong@tencent.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	Hong Zhiguo <zhiguohong@tencent.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:50896 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536Ab3IQIkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 04:40:39 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so5196833pbb.5
        for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 01:40:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hong Zhiguo <zhiguohong@tencent.com>

e->stats_lock is usually taken by fast path to update stats.
In the old order, fast path should wait for write_lock(&est_lock).
Even though it's only one line inside the write_lock(&est_lock),
but if there's interrupt or page fault, a lot of spin on
e->stats_lock will be wasted in fast path.

Signed-off-by: Hong Zhiguo <zhiguohong@tencent.com>
---
 net/core/gen_estimator.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 6b5b6e7..bad7f5f 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -120,11 +120,11 @@ static void est_timer(unsigned long arg)
 		u32 npackets;
 		u32 rate;
 
-		spin_lock(e->stats_lock);
 		read_lock(&est_lock);
 		if (e->bstats == NULL)
 			goto skip;
 
+		spin_lock(e->stats_lock);
 		nbytes = e->bstats->bytes;
 		npackets = e->bstats->packets;
 		brate = (nbytes - e->last_bytes)<<(7 - idx);
@@ -136,9 +136,9 @@ static void est_timer(unsigned long arg)
 		e->last_packets = npackets;
 		e->avpps += (rate >> e->ewma_log) - (e->avpps >> e->ewma_log);
 		e->rate_est->pps = (e->avpps+0x1FF)>>10;
+		spin_unlock(e->stats_lock);
 skip:
 		read_unlock(&est_lock);
-		spin_unlock(e->stats_lock);
 	}
 
 	if (!list_empty(&elist[idx].list))
-- 
1.8.1.2
