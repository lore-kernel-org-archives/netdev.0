From: David Miller <davem@davemloft.net>
Subject: [PATCH] Revert "ipv4: Allow configuring subnets as local addresses"
Date: Thu, 23 Dec 2010 12:10:39 -0800 (PST)
Message-ID: <20101223.121039.70184809.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54151
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751418Ab0LWUKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Dec 2010 15:10:10 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 072E724C088
	for <netdev@vger.kernel.org>; Thu, 23 Dec 2010 12:10:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This reverts commit 4465b469008bc03b98a1b8df4e9ae501b6c69d4b.

Conflicts:

	net/ipv4/fib_frontend.c

As reported by Ben Greear, this causes regressions:

> Change 4465b469008bc03b98a1b8df4e9ae501b6c69d4b caused rules
> to stop matching the input device properly because the
> FLOWI_FLAG_MATCH_ANY_IIF is always defined in ip_dev_find().
>
> This breaks rules such as:
>
> ip rule add pref 512 lookup local
> ip rule del pref 0 lookup local
> ip link set eth2 up
> ip -4 addr add 172.16.0.102/24 broadcast 172.16.0.255 dev eth2
> ip rule add to 172.16.0.102 iif eth2 lookup local pref 10
> ip rule add iif eth2 lookup 10001 pref 20
> ip route add 172.16.0.0/24 dev eth2 table 10001
> ip route add unreachable 0/0 table 10001
>
> If you had a second interface 'eth0' that was on a different
> subnet, pinging a system on that interface would fail:
>
>   [root@ct503-60 ~]# ping 192.168.100.1
>   connect: Invalid argument

Reported-by: Ben Greear <greearb@candelatech.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---

I'm posting this because there were non-trivial merge conflicts
with Eric Dumazet's RCU work.

 include/net/flow.h      |    1 -
 net/core/fib_rules.c    |    3 +--
 net/ipv4/fib_frontend.c |   10 ++++++++--
 3 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 0ac3fb5..bb08692 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -49,7 +49,6 @@ struct flowi {
 	__u8	proto;
 	__u8	flags;
 #define FLOWI_FLAG_ANYSRC 0x01
-#define FLOWI_FLAG_MATCH_ANY_IIF 0x02
 	union {
 		struct {
 			__be16	sport;
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 82a4369..a20e5d3 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -181,8 +181,7 @@ static int fib_rule_match(struct fib_rule *rule, struct fib_rules_ops *ops,
 {
 	int ret = 0;
 
-	if (rule->iifindex && (rule->iifindex != fl->iif) &&
-	    !(fl->flags & FLOWI_FLAG_MATCH_ANY_IIF))
+	if (rule->iifindex && (rule->iifindex != fl->iif))
 		goto out;
 
 	if (rule->oifindex && (rule->oifindex != fl->oif))
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index eb6f69a..c19c1f7 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -163,13 +163,19 @@ struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
 				.daddr = addr
 			}
 		},
-		.flags = FLOWI_FLAG_MATCH_ANY_IIF
 	};
 	struct fib_result res = { 0 };
 	struct net_device *dev = NULL;
+	struct fib_table *local_table;
+
+#ifdef CONFIG_IP_MULTIPLE_TABLES
+	res.r = NULL;
+#endif
 
 	rcu_read_lock();
-	if (fib_lookup(net, &fl, &res)) {
+	local_table = fib_get_table(net, RT_TABLE_LOCAL);
+	if (!local_table ||
+	    fib_table_lookup(local_table, &fl, &res, FIB_LOOKUP_NOREF)) {
 		rcu_read_unlock();
 		return NULL;
 	}
-- 
1.7.3.4

