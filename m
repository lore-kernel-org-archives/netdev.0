From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: fix a potential rcu_read_lock() imbalance in
 rt6_fill_node()
Date: Tue, 27 Mar 2012 21:53:52 +0200
Message-ID: <1332878032.3547.39.camel@edumazet-glaptop>
References: <4F70E308.7070908@candelatech.com>
	 <20120326.174945.1186427809261872546.davem@davemloft.net>
	 <4F70E560.3020102@candelatech.com>  <4F70F688.6050108@candelatech.com>
	 <1332805148.3547.14.camel@edumazet-glaptop>
	 <4F71EF2A.8020507@candelatech.com>
	 <1332877149.3547.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Dave Jones <davej@redhat.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:33241 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755803Ab2C0Tx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 15:53:56 -0400
Received: by eekc41 with SMTP id c41so86770eek.19
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 12:53:54 -0700 (PDT)
In-Reply-To: <1332877149.3547.24.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f2c31e32b378 (net: fix NULL dereferences in check_peer_redir() )
added a regression in rt6_fill_node(), leading to rcu_read_lock()
imbalance.

Thats because NLA_PUT() can make a jump to nla_put_failure label.

Fix this by using nla_put()

Many thanks to Ben Greear for his help

Reported-by: Ben Greear <greearb@candelatech.com>
Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/route.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 24c456e..496b627 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2474,8 +2474,12 @@ static int rt6_fill_node(struct net *net,
 
 	rcu_read_lock();
 	n = dst_get_neighbour_noref(&rt->dst);
-	if (n)
-		NLA_PUT(skb, RTA_GATEWAY, 16, &n->primary_key);
+	if (n) {
+		if (nla_put(skb, RTA_GATEWAY, 16, &n->primary_key) < 0) {
+			rcu_read_unlock();
+			goto nla_put_failure;
+		}
+	}
 	rcu_read_unlock();
 
 	if (rt->dst.dev)
