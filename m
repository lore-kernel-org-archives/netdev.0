From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/16] ipv4: Deliver ICMP redirects to sockets too.
Date: Thu, 12 Jul 2012 08:06:53 -0700 (PDT)
Message-ID: <20120712.080653.1463195798230664640.davem@davemloft.net>
References: <20120712.011049.831106026936792516.davem@davemloft.net>
	<20120712235837.4d611326830a16f9a035dd75@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shimoda.hiroaki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57352 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755191Ab2GLPGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 11:06:54 -0400
In-Reply-To: <20120712235837.4d611326830a16f9a035dd75@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Date: Thu, 12 Jul 2012 23:58:37 +0900

> So, I think avobe deleted checks about skb->len need to move to
> ping_err() in case of packets are malformed.

You would be wrong, the check belongs in icmp_socket_deliver().

====================
>From f0a70e902f483295a8b6d74ef4393bc577b703d7 Mon Sep 17 00:00:00 2001
From: "David S. Miller" <davem@davemloft.net>
Date: Thu, 12 Jul 2012 08:06:04 -0700
Subject: [PATCH] ipv4: Put proper checks into icmp_socket_deliver().

All handler->err() routines expect that we've done a pskb_may_pull()
test to make sure that IP header length + 8 bytes can be safely
pulled.

Reported-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/icmp.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index d01aeb4..ea3a996 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -640,6 +640,12 @@ static void icmp_socket_deliver(struct sk_buff *skb, u32 info)
 	const struct net_protocol *ipprot;
 	int protocol = iph->protocol;
 
+	/* Checkin full IP header plus 8 bytes of protocol to
+	 * avoid additional coding at protocol handlers.
+	 */
+	if (!pskb_may_pull(skb, iph->ihl * 4 + 8))
+		return;
+
 	raw_icmp_error(skb, protocol, info);
 
 	rcu_read_lock();
@@ -733,12 +739,6 @@ static void icmp_unreach(struct sk_buff *skb)
 		goto out;
 	}
 
-	/* Checkin full IP header plus 8 bytes of protocol to
-	 * avoid additional coding at protocol handlers.
-	 */
-	if (!pskb_may_pull(skb, iph->ihl * 4 + 8))
-		goto out;
-
 	icmp_socket_deliver(skb, info);
 
 out:
-- 
1.7.10.4
