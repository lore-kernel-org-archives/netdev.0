From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv4: fix NULL dereference in free_fib_info_rcu()
Date: Tue, 15 Aug 2017 05:26:17 -0700
Message-ID: <1502799977.4936.71.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36803 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751654AbdHOM0T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 08:26:19 -0400
Received: by mail-pg0-f66.google.com with SMTP id y129so1278779pgy.3
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 05:26:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

If fi->fib_metrics could not be allocated in fib_create_info()
we attempt to dereference a NULL pointer in free_fib_info_rcu() :

    m = fi->fib_metrics;
    if (m != &dst_default_metrics && atomic_dec_and_test(&m->refcnt))
            kfree(m);

Before my recent patch, we used to call kfree(NULL) and nothing wrong
happened.

Instead of using RCU to defer freeing while we are under memory stress,
it seems better to take immediate action.

This was reported by syzkaller team.

Fixes: 3fb07daff8e9 ("ipv4: add reference counting to metrics")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
---
 net/ipv4/fib_semantics.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index b8d18171cca3..ec3a9ce281a6 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1083,15 +1083,17 @@ struct fib_info *fib_create_info(struct fib_config *cfg,
 	fi = kzalloc(sizeof(*fi)+nhs*sizeof(struct fib_nh), GFP_KERNEL);
 	if (!fi)
 		goto failure;
-	fib_info_cnt++;
 	if (cfg->fc_mx) {
 		fi->fib_metrics = kzalloc(sizeof(*fi->fib_metrics), GFP_KERNEL);
-		if (!fi->fib_metrics)
-			goto failure;
+		if (unlikely(!fi->fib_metrics)) {
+			kfree(fi);
+			return ERR_PTR(err);
+		}
 		atomic_set(&fi->fib_metrics->refcnt, 1);
-	} else
+	} else {
 		fi->fib_metrics = (struct dst_metrics *)&dst_default_metrics;
-
+	}
+	fib_info_cnt++;
 	fi->fib_net = net;
 	fi->fib_protocol = cfg->fc_protocol;
 	fi->fib_scope = cfg->fc_scope;
