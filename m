From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH v3] netfilter: ipset: Fix sleeping memory allocation in atomic context
Date: Fri, 16 Oct 2015 09:40:28 +0300
Message-ID: <1444977628-19323-1-git-send-email-kernel@kyup.com>
Cc: netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	operations@siteground.com
To: kadlec@blackhole.kfki.hu, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:33328 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753388AbbJPGkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 02:40:33 -0400
Received: by lffv3 with SMTP id v3so70993372lff.0
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 23:40:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---

Changes since v2:
 * Massaged the changelog to reflect discussion 
 on the mailing list

Changes since v1: 
 * Added acked-by 
 * Fixed patch header

 

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
2.5.0
