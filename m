From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net] ping: implement proper locking
Date: Fri, 24 Mar 2017 19:36:13 -0700
Message-ID: <1490409373.24891.8.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1490398185.24891.5.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170324.191016.1704224805339195329.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, solar@openwall.com, andreyknvl@google.com,
        edumazet@google.com, Daniel Jiang <danieljiang0415@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35679 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965027AbdCYCgQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 22:36:16 -0400
Received: by mail-pg0-f67.google.com with SMTP id g2so1187527pge.2
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 19:36:15 -0700 (PDT)
In-Reply-To: <20170324.191016.1704224805339195329.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We got a report of yet another bug in ping

http://www.openwall.com/lists/oss-security/2017/03/24/6

->disconnect() is not called with socket lock held.

Fix this by acquiring ping rwlock earlier.

Thanks to Daniel, Alexander and Andrey for letting us know this problem.

Fixes: c319b4d76b9e ("net: ipv4: add IPPROTO_ICMP socket kind")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Daniel Jiang <danieljiang0415@gmail.com>
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
 
