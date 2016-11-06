From: Xin Long <lucien.xin@gmail.com>
Subject: rhashtable: how to use insecure_elasticity of rhashtable_params
Date: Sun, 6 Nov 2016 21:15:07 +0800
Message-ID: <CADvbK_cPQVT-icKn_2WpKqTyWgVEJikSAbg6=xB3+dt=zcdk0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        davem <davem@davemloft.net>, Phil Sutter <phil@nwl.cc>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:32871 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751699AbcKFNPJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Nov 2016 08:15:09 -0500
Received: by mail-qk0-f195.google.com with SMTP id x190so9567906qkb.0
        for <netdev@vger.kernel.org>; Sun, 06 Nov 2016 05:15:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when I don't set  insecure_elasticity, ht->elasticity would be
set 16, it would be checked in  the loop of __rhashtable_insert_fast
and rhashtable_lookup_one.

But if I set  insecure_elasticity = true,  ht->elasticity wouldn't be
set (and the default is 0). when it is checked in that loop. they
also return EAGAIN, as:

    if (elasticity <= 0)
        return ERR_PTR(-EAGAIN);

it seems insecure_elasticity=true doesn't really work well.

* @insecure_elasticity: Set to true to disable chain length checks

shouldn't it be something like this ? or did I miss something ?

-------------------------------------
diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 5c132d3..9743ab7 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -702,7 +702,8 @@ static inline void *__rhashtable_insert_fast(
                struct rhlist_head *plist;
                struct rhlist_head *list;

-               elasticity--;
+               if (ht->elasticity)
+                       elasticity--;
                if (!key ||
                    (params.obj_cmpfn ?
                     params.obj_cmpfn(&arg, rht_obj(ht, head)) :
@@ -726,7 +727,7 @@ static inline void *__rhashtable_insert_fast(
                goto good;
        }

-       if (elasticity <= 0)
+       if (ht->elasticity && elasticity <= 0)
                goto slow_path;

        data = ERR_PTR(-E2BIG);
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 32d0ad0..e3d615a 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -444,7 +444,8 @@ static void *rhashtable_lookup_one(struct rhashtable *ht,
                struct rhlist_head *list;
                struct rhlist_head *plist;

-               elasticity--;
+               if (ht->elasticity)
+                       elasticity--;
                if (!key ||
                    (ht->p.obj_cmpfn ?
                     ht->p.obj_cmpfn(&arg, rht_obj(ht, head)) :
@@ -465,7 +466,7 @@ static void *rhashtable_lookup_one(struct rhashtable *ht,
                return NULL;
        }

-       if (elasticity <= 0)
+       if (ht->elasticity && elasticity <= 0)
                return ERR_PTR(-EAGAIN);

        return ERR_PTR(-ENOENT);
