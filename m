From: akpm@osdl.org
Subject: [patch 9/9] Avoid warning on CONNTRACK_STAT_INC in destroy_conntrack()
Date: Thu, 28 Oct 2004 00:19:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410280721.i9S7Ll908021@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org,
        rusty@rustcorp.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Rusty Russell <rusty@rustcorp.com.au>

ip_conntrack_put can be called in any context in theory: in particular,
MASQUERADE will can call it (via ip_ct_selective_cleanup) when an interface
comes up with a different address.

Move the CONNTRACK_STAT_INC inside the lock: it needs preemption disabled.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/net/ipv4/netfilter/ip_conntrack_core.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN net/ipv4/netfilter/ip_conntrack_core.c~avoid-warning-on-conntrack_stat_inc-in-destroy_conntrack net/ipv4/netfilter/ip_conntrack_core.c
--- 25/net/ipv4/netfilter/ip_conntrack_core.c~avoid-warning-on-conntrack_stat_inc-in-destroy_conntrack	2004-10-28 00:17:08.778469456 -0700
+++ 25-akpm/net/ipv4/netfilter/ip_conntrack_core.c	2004-10-28 00:17:08.782468848 -0700
@@ -312,6 +312,7 @@ destroy_conntrack(struct nf_conntrack *n
 		}
 		kmem_cache_free(ip_conntrack_expect_cachep, ct->master);
 	}
+	CONNTRACK_STAT_INC(delete);
 	WRITE_UNLOCK(&ip_conntrack_lock);
 
 	if (master)
@@ -320,7 +321,6 @@ destroy_conntrack(struct nf_conntrack *n
 	DEBUGP("destroy_conntrack: returning ct=%p to slab\n", ct);
 	kmem_cache_free(ip_conntrack_cachep, ct);
 	atomic_dec(&ip_conntrack_count);
-	CONNTRACK_STAT_INC(delete);
 }
 
 static void death_by_timeout(unsigned long ul_conntrack)
_
