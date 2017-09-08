From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/9] netfilter: xtables: add scheduling opportunity in get_counters
Date: Fri,  8 Sep 2017 19:45:43 +0200
Message-ID: <1504892748-1605-5-git-send-email-pablo@netfilter.org>
References: <1504892748-1605-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54488 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756735AbdIHRqC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 8 Sep 2017 13:46:02 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id EDCD48D0509
        for <netdev@vger.kernel.org>; Fri,  8 Sep 2017 19:45:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D3BD0B5024
        for <netdev@vger.kernel.org>; Fri,  8 Sep 2017 19:45:30 +0200 (CEST)
In-Reply-To: <1504892748-1605-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

There are reports about spurious softlockups during iptables-restore, a
backtrace i saw points at get_counters -- it uses a sequence lock and also
has unbounded restart loop.

Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/arp_tables.c | 1 +
 net/ipv4/netfilter/ip_tables.c  | 1 +
 net/ipv6/netfilter/ip6_tables.c | 1 +
 3 files changed, 3 insertions(+)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index e04457198f93..9e2770fd00be 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -629,6 +629,7 @@ static void get_counters(const struct xt_table_info *t,
 
 			ADD_COUNTER(counters[i], bcnt, pcnt);
 			++i;
+			cond_resched();
 		}
 	}
 }
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 576cba2b57e9..39286e543ee6 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -776,6 +776,7 @@ get_counters(const struct xt_table_info *t,
 
 			ADD_COUNTER(counters[i], bcnt, pcnt);
 			++i; /* macro does multi eval of i */
+			cond_resched();
 		}
 	}
 }
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 54b1e75eded1..01bd3ee5ebc6 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -795,6 +795,7 @@ get_counters(const struct xt_table_info *t,
 
 			ADD_COUNTER(counters[i], bcnt, pcnt);
 			++i;
+			cond_resched();
 		}
 	}
 }
-- 
2.1.4
