From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 19/31: xtables: check for unconditionality of policies
Date: Thu, 10 Sep 2009 18:12:11 +0200 (MEST)
Message-ID: <20090910161206.31179.59496.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 90e7d4ab5c8b0c4c2e00e4893977f6aeec0f18f1
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Thu Jul 9 22:54:53 2009 +0200

    netfilter: xtables: check for unconditionality of policies
    
    This adds a check that iptables's original author Rusty set forth in
    a FIXME comment.
    
    Underflows in iptables are better known as chain policies, and are
    required to be unconditional or there would be a stochastical chance
    for the policy rule to be skipped if it does not match. If that were
    to happen, rule execution would continue in an unexpected spurious
    fashion.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index d91f083..064082d 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -8,7 +8,7 @@
  * Copyright (C) 2002 David S. Miller (davem@redhat.com)
  *
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
@@ -563,13 +563,15 @@ static inline int check_entry_size_and_hooks(struct arpt_entry *e,
 			continue;
 		if ((unsigned char *)e - base == hook_entries[h])
 			newinfo->hook_entry[h] = hook_entries[h];
-		if ((unsigned char *)e - base == underflows[h])
+		if ((unsigned char *)e - base == underflows[h]) {
+			if (!unconditional(&e->arp)) {
+				pr_err("Underflows must be unconditional\n");
+				return -EINVAL;
+			}
 			newinfo->underflow[h] = underflows[h];
+		}
 	}
 
-	/* FIXME: underflows must be unconditional, standard verdicts
-	   < 0 (not ARPT_RETURN). --RR */
-
 	/* Clear counters and comefrom */
 	e->counters = ((struct xt_counters) { 0, 0 });
 	e->comefrom = 0;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 6e7b7e8..6e546d5 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -8,6 +8,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/cache.h>
 #include <linux/capability.h>
 #include <linux/skbuff.h>
@@ -738,13 +739,15 @@ check_entry_size_and_hooks(struct ipt_entry *e,
 			continue;
 		if ((unsigned char *)e - base == hook_entries[h])
 			newinfo->hook_entry[h] = hook_entries[h];
-		if ((unsigned char *)e - base == underflows[h])
+		if ((unsigned char *)e - base == underflows[h]) {
+			if (!unconditional(&e->ip)) {
+				pr_err("Underflows must be unconditional\n");
+				return -EINVAL;
+			}
 			newinfo->underflow[h] = underflows[h];
+		}
 	}
 
-	/* FIXME: underflows must be unconditional, standard verdicts
-	   < 0 (not IPT_RETURN). --RR */
-
 	/* Clear counters and comefrom */
 	e->counters = ((struct xt_counters) { 0, 0 });
 	e->comefrom = 0;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 8e4921a..b0599b9 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -8,7 +8,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/capability.h>
 #include <linux/in.h>
 #include <linux/skbuff.h>
@@ -771,13 +771,15 @@ check_entry_size_and_hooks(struct ip6t_entry *e,
 			continue;
 		if ((unsigned char *)e - base == hook_entries[h])
 			newinfo->hook_entry[h] = hook_entries[h];
-		if ((unsigned char *)e - base == underflows[h])
+		if ((unsigned char *)e - base == underflows[h]) {
+			if (!unconditional(&e->ipv6)) {
+				pr_err("Underflows must be unconditional\n");
+				return -EINVAL;
+			}
 			newinfo->underflow[h] = underflows[h];
+		}
 	}
 
-	/* FIXME: underflows must be unconditional, standard verdicts
-	   < 0 (not IP6T_RETURN). --RR */
-
 	/* Clear counters and comefrom */
 	e->counters = ((struct xt_counters) { 0, 0 });
 	e->comefrom = 0;
