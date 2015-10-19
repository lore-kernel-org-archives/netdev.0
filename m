From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/4] netfilter: ipset: Fix sleeping memory allocation in atomic context
Date: Mon, 19 Oct 2015 20:22:55 +0200
Message-ID: <1445278975-2412-5-git-send-email-pablo@netfilter.org>
References: <1445278975-2412-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1445278975-2412-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nikolay Borisov <kernel@kyup.com>

Commit 00590fdd5be0 introduced RCU locking in list type and in
doing so introduced a memory allocation in list_set_add, which
is done in an atomic context, due to the fact that ipset rcu
list modifications are serialised with a spin lock. The reason
why we can't use a mutex is that in addition to modifying the
list with ipset commands, it's also being modified when a
particular ipset rule timeout expires aka garbage collection.
This gc is triggered from set_cleanup_entries, which in turn
is invoked from a timer thus requiring the lock to be bh-safe.

Concretely the following call chain can lead to "sleeping function
called in atomic context" splat:
call_ad -> list_set_uadt -> list_set_uadd -> kzalloc(, GFP_KERNEL).
And since GFP_KERNEL allows initiating direct reclaim thus
potentially sleeping in the allocation path.

To fix the issue change the allocation type to GFP_ATOMIC, to
correctly reflect that it is occuring in an atomic context.

Fixes: 00590fdd5be0 ("netfilter: ipset: Introduce RCU locking in list type")
Signed-off-by: Nikolay Borisov <kernel@kyup.com>
Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_list_set.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index a1fe537..5a30ce6 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -297,7 +297,7 @@ list_set_uadd(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	      ip_set_timeout_expired(ext_timeout(n, set))))
 		n =  NULL;
 
-	e = kzalloc(set->dsize, GFP_KERNEL);
+	e = kzalloc(set->dsize, GFP_ATOMIC);
 	if (!e)
 		return -ENOMEM;
 	e->id = d->id;
-- 
2.1.4

