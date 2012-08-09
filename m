From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: must free metrics at net dismantle
Date: Thu, 09 Aug 2012 11:19:13 +0200
Message-ID: <1344503953.28967.575.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59088 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270Ab2HIJTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 05:19:18 -0400
Received: by bkwj10 with SMTP id j10so78954bkw.19
        for <netdev@vger.kernel.org>; Thu, 09 Aug 2012 02:19:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We currently leak all tcp metrics at struct net dismantle time.

tcp_net_metrics_exit() frees the hash table, we must first
iterate it to free all metrics.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_metrics.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 2288a63..0abe67b 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -731,6 +731,18 @@ static int __net_init tcp_net_metrics_init(struct net *net)
 
 static void __net_exit tcp_net_metrics_exit(struct net *net)
 {
+	unsigned int i;
+
+	for (i = 0; i < (1U << net->ipv4.tcp_metrics_hash_log) ; i++) {
+		struct tcp_metrics_block *tm, *next;
+
+		tm = rcu_dereference_protected(net->ipv4.tcp_metrics_hash[i].chain, 1);
+		while (tm) {
+			next = rcu_dereference_protected(tm->tcpm_next, 1);
+			kfree(tm);
+			tm = next;
+		}
+	}
 	kfree(net->ipv4.tcp_metrics_hash);
 }
 
