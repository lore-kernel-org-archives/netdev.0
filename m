From: kaber@trash.net
Subject: [PATCH 3/4] netfilter: xtables: fix reentrancy
Date: Sun, 20 Mar 2011 16:32:27 +0100
Message-ID: <1300635148-22648-4-git-send-email-kaber@trash.net>
References: <1300635148-22648-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300635148-22648-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>

commit f3c5c1bfd4308 (make ip_tables reentrant) introduced a race in
handling the stackptr restore, at the end of ipt_do_table()

We should do it before the call to xt_info_rdunlock_bh(), or we allow
cpu preemption and another cpu overwrites stackptr of original one.

A second fix is to change the underflow test to check the origptr value
instead of 0 to detect underflow, or else we allow a jump from different
hooks.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ip_tables.c  |    4 ++--
 net/ipv6/netfilter/ip6_tables.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index b09ed0d..ffcea0d 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -387,7 +387,7 @@ ipt_do_table(struct sk_buff *skb,
 					verdict = (unsigned)(-v) - 1;
 					break;
 				}
-				if (*stackptr == 0) {
+				if (*stackptr <= origptr) {
 					e = get_entry(table_base,
 					    private->underflow[hook]);
 					pr_debug("Underflow (this is normal) "
@@ -427,10 +427,10 @@ ipt_do_table(struct sk_buff *skb,
 			/* Verdict */
 			break;
 	} while (!acpar.hotdrop);
-	xt_info_rdunlock_bh();
 	pr_debug("Exiting %s; resetting sp from %u to %u\n",
 		 __func__, *stackptr, origptr);
 	*stackptr = origptr;
+	xt_info_rdunlock_bh();
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
 #else
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index c9598a9..0b2af9b 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -410,7 +410,7 @@ ip6t_do_table(struct sk_buff *skb,
 					verdict = (unsigned)(-v) - 1;
 					break;
 				}
-				if (*stackptr == 0)
+				if (*stackptr <= origptr)
 					e = get_entry(table_base,
 					    private->underflow[hook]);
 				else
@@ -441,8 +441,8 @@ ip6t_do_table(struct sk_buff *skb,
 			break;
 	} while (!acpar.hotdrop);
 
-	xt_info_rdunlock_bh();
 	*stackptr = origptr;
+	xt_info_rdunlock_bh();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
-- 
1.7.4

