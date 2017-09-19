From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 5/7] tcp: batch tcp_net_metrics_exit
Date: Tue, 19 Sep 2017 16:27:07 -0700
Message-ID: <20170919232709.14690-6-edumazet@google.com>
References: <20170919232709.14690-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:57339 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751728AbdISX1X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 19:27:23 -0400
Received: by mail-pf0-f177.google.com with SMTP id g65so591007pfe.13
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 16:27:23 -0700 (PDT)
In-Reply-To: <20170919232709.14690-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When dealing with a list of dismantling netns, we can scan
tcp_metrics once, saving cpu cycles.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_metrics.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 102b2c90bb807d3a88d31b59324baf72cf901cdf..0ab78abc811bef0388089befed672e3d4ee9d881 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -892,10 +892,14 @@ static void tcp_metrics_flush_all(struct net *net)
 
 	for (row = 0; row < max_rows; row++, hb++) {
 		struct tcp_metrics_block __rcu **pp;
+		bool match;
+
 		spin_lock_bh(&tcp_metrics_lock);
 		pp = &hb->chain;
 		for (tm = deref_locked(*pp); tm; tm = deref_locked(*pp)) {
-			if (net_eq(tm_net(tm), net)) {
+			match = net ? net_eq(tm_net(tm), net) :
+				!atomic_read(&tm_net(tm)->count);
+			if (match) {
 				*pp = tm->tcpm_next;
 				kfree_rcu(tm, rcu_head);
 			} else {
@@ -1018,14 +1022,14 @@ static int __net_init tcp_net_metrics_init(struct net *net)
 	return 0;
 }
 
-static void __net_exit tcp_net_metrics_exit(struct net *net)
+static void __net_exit tcp_net_metrics_exit_batch(struct list_head *net_exit_list)
 {
-	tcp_metrics_flush_all(net);
+	tcp_metrics_flush_all(NULL);
 }
 
 static __net_initdata struct pernet_operations tcp_net_metrics_ops = {
-	.init	=	tcp_net_metrics_init,
-	.exit	=	tcp_net_metrics_exit,
+	.init		=	tcp_net_metrics_init,
+	.exit_batch	=	tcp_net_metrics_exit_batch,
 };
 
 void __init tcp_metrics_init(void)
-- 
2.14.1.690.gbb1197296e-goog
