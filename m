From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ping: implement proper locking
Date: Fri, 24 Mar 2017 16:29:45 -0700
Message-ID: <1490398185.24891.5.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Solar Designer <solar@openwall.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36410 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932972AbdCXX3s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 19:29:48 -0400
Received: by mail-pf0-f195.google.com with SMTP id r137so643409pfr.3
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 16:29:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We got a report of yet another bug in ping

http://www.openwall.com/lists/oss-security/2017/03/24/6

->disconnect() is not called with socket lock held.

Fix this by acquiring ping rwlock earlier.

Thanks to Alexander and Andrey for letting us know of this problem.

Fixes: c319b4d76b9e ("net: ipv4: add IPPROTO_ICMP socket kind")
Reported-by: Solar Designer <solar@openwall.com>
Reported-by: Andrey Konovalov <andreyknvl@google.com>
---
 net/ipv4/ping.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 2af6244b83e27ae384e96cf071c10c5a89674804..ccfbce13a6333a65dab64e4847dd510dfafb1b43 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -156,17 +156,18 @@ int ping_hash(struct sock *sk)
 void ping_unhash(struct sock *sk)
 {
 	struct inet_sock *isk = inet_sk(sk);
+
 	pr_debug("ping_unhash(isk=%p,isk->num=%u)\n", isk, isk->inet_num);
+	write_lock_bh(&ping_table.lock);
 	if (sk_hashed(sk)) {
-		write_lock_bh(&ping_table.lock);
 		hlist_nulls_del(&sk->sk_nulls_node);
 		sk_nulls_node_init(&sk->sk_nulls_node);
 		sock_put(sk);
 		isk->inet_num = 0;
 		isk->inet_sport = 0;
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
-		write_unlock_bh(&ping_table.lock);
 	}
+	write_unlock_bh(&ping_table.lock);
 }
 EXPORT_SYMBOL_GPL(ping_unhash);
 
