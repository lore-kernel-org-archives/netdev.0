From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] rhashtable: Make sure max_size is non zero
Date: Thu, 27 Apr 2017 15:30:24 -0700
Message-ID: <20170427223024.32657-1-f.fainelli@gmail.com>
References: <56843a86-9a09-16e8-acec-05a80396f282@gmail.com>
Cc: davem@davemloft.net, herbert@gondor.apana.org.au, fw@strlen.de,
        tgraf@suug.ch, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33303 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162212AbdD0Wa2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 18:30:28 -0400
Received: by mail-it0-f65.google.com with SMTP id z67so3883493itb.0
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 15:30:27 -0700 (PDT)
In-Reply-To: <56843a86-9a09-16e8-acec-05a80396f282@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 6d684e54690c ("rhashtable: Cap total number of
entries to 2^31"), we would be hitting a panic() in net/core/rtnetlink.c
during initialization. The call stack would look like this:

register_pernet_subsys()
    ...
    ops->init()
	rtnetlink_net_init()
	  netlink_kernel_create()
	     netlink_insert()
		__netlink_insert()
		   rhashtable_lookup_insert_key()
		      __rhashtable_insert_fast()
			rht_grow_above_max()

And here, we have rht_grow_above_max() return true, because ht->nelemts = 0 (legit)
&& ht->max_elems = 0 (looks bogus).

Eventually, we would be return -E2BIG from __rhashtable_insert_fast()
and propagate this all the way back to the caller.

After commit 6d684e54690c what changed is that we would take the
following condition:

if (ht->p.max_size < ht->max_elems / 2)
	ht->max_elems = ht->p.max_size * 2;

and since ht->p.max_size = 0, we would set ht->max_elems to 0 as well.

Fix this by taking this branch only when ht->p.max_size is non-zero

Fixes: Fixes: 6d684e54690c ("rhashtable: Cap total number of entries to 2^31")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 lib/rhashtable.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 751630bbe409..6b4f07760fec 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -963,7 +963,7 @@ int rhashtable_init(struct rhashtable *ht,
 
 	/* Cap total entries at 2^31 to avoid nelems overflow. */
 	ht->max_elems = 1u << 31;
-	if (ht->p.max_size < ht->max_elems / 2)
+	if (ht->p.max_size && (ht->p.max_size < ht->max_elems / 2))
 		ht->max_elems = ht->p.max_size * 2;
 
 	ht->p.min_size = max(ht->p.min_size, HASH_MIN_SIZE);
-- 
2.12.2
