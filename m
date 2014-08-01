From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH net-next] ipv4: remove nested rcu_read_lock/unlock
Date: Fri, 1 Aug 2014 14:00:36 +0800
Message-ID: <53DB2D04.6030909@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:39879 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750745AbaHAGAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 02:00:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


ip_local_deliver_finish() already have a rcu_read_lock/unlock, so
the rcu_read_lock/unlock is unnecessary.

See the stack below:
ip_local_deliver_finish
	|
	|
	->icmp_rcv
		|
		|
		->icmp_socket_deliver

Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv4/icmp.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 092400e..ea7d4af 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -670,11 +670,9 @@ static void icmp_socket_deliver(struct sk_buff *skb, u32 info)
 
 	raw_icmp_error(skb, protocol, info);
 
-	rcu_read_lock();
 	ipprot = rcu_dereference(inet_protos[protocol]);
 	if (ipprot && ipprot->err_handler)
 		ipprot->err_handler(skb, info);
-	rcu_read_unlock();
 }
 
 static bool icmp_tag_validation(int proto)
-- 
1.8.3.1
