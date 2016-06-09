From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 1/5] net: sched: fix qdisc->running lockdep annotations
Date: Thu,  9 Jun 2016 07:45:11 -0700
Message-ID: <1465483515-10821-2-git-send-email-edumazet@google.com>
References: <1465483515-10821-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	David Ahern <dsa@cumulusnetworks.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33924 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbcFIOpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 10:45:24 -0400
Received: by mail-pf0-f171.google.com with SMTP id 62so14109115pfd.1
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 07:45:24 -0700 (PDT)
In-Reply-To: <1465483515-10821-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) qdisc_run_begin() is really using the equivalent of a trylock.
  Instead of using write_seqcount_begin(), use a combination of
  raw_write_seqcount_begin() and correct lockdep annotation.

2) sch_direct_xmit() should use regular spin_lock(root_lock)

Fixes: f9eb8aea2a1e ("net_sched: transform qdisc running bit into a seqcount")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/sch_generic.h | 6 +++++-
 net/sched/sch_generic.c   | 4 ++--
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index c4f5749342ec..d53ecfc1d60e 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -104,7 +104,11 @@ static inline bool qdisc_run_begin(struct Qdisc *qdisc)
 {
 	if (qdisc_is_running(qdisc))
 		return false;
-	write_seqcount_begin(&qdisc->running);
+	/* Variant of write_seqcount_begin() telling lockdep a trylock
+	 * was attempted.
+	 */
+	raw_write_seqcount_begin(&qdisc->running);
+	seqcount_acquire(&qdisc->running.dep_map, 0, 1, _RET_IP_);
 	return true;
 }
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index cebea73e70ac..cad810b45e31 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -137,10 +137,10 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 
 		HARD_TX_UNLOCK(dev, txq);
 	} else {
-		spin_lock_nested(root_lock, SINGLE_DEPTH_NESTING);
+		spin_lock(root_lock);
 		return qdisc_qlen(q);
 	}
-	spin_lock_nested(root_lock, SINGLE_DEPTH_NESTING);
+	spin_lock(root_lock);
 
 	if (dev_xmit_complete(ret)) {
 		/* Driver sent out skb successfully or skb was consumed */
-- 
2.8.0.rc3.226.g39d4020
