From: Adrian Bunk <bunk@kernel.org>
Subject: [RFC: 2.6.25 patch] ipv4/fib_hash.c: fix NULL dereference
Date: Wed, 20 Feb 2008 00:49:51 +0200
Message-ID: <20080219224951.GP31955@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:47460 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758837AbYBSWu2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 17:50:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unless I miss a guaranteed relation between between "f" and 
"new_fa->fa_info" this patch is required for fixing a NULL dereference
introduced by commit a6501e080c318f8d4467679d17807f42b3a33cd5 and 
spotted by the Coverity checker.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 net/ipv4/fib_hash.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

--- linux-2.6/net/ipv4/fib_hash.c.old	2008-02-19 23:23:14.000000000 +0200
+++ linux-2.6/net/ipv4/fib_hash.c	2008-02-19 23:38:28.000000000 +0200
@@ -367,17 +367,18 @@ static struct fib_node *fib_find_node(st
 	}
 
 	return NULL;
 }
 
 static int fn_hash_insert(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct fn_hash *table = (struct fn_hash *) tb->tb_data;
-	struct fib_node *new_f, *f;
+	struct fib_node *new_f = NULL;
+	struct fib_node *f;
 	struct fib_alias *fa, *new_fa;
 	struct fn_zone *fz;
 	struct fib_info *fi;
 	u8 tos = cfg->fc_tos;
 	__be32 key;
 	int err;
 
 	if (cfg->fc_dst_len > 32)
@@ -491,33 +492,32 @@ static int fn_hash_insert(struct fib_tab
 	}
 
 	err = -ENOENT;
 	if (!(cfg->fc_nlflags & NLM_F_CREATE))
 		goto out;
 
 	err = -ENOBUFS;
 
-	new_f = NULL;
 	if (!f) {
 		new_f = kmem_cache_zalloc(fn_hash_kmem, GFP_KERNEL);
 		if (new_f == NULL)
 			goto out;
 
 		INIT_HLIST_NODE(&new_f->fn_hash);
 		INIT_LIST_HEAD(&new_f->fn_alias);
 		new_f->fn_key = key;
 		f = new_f;
 	}
 
 	new_fa = &f->fn_embedded_alias;
 	if (new_fa->fa_info != NULL) {
 		new_fa = kmem_cache_alloc(fn_alias_kmem, GFP_KERNEL);
 		if (new_fa == NULL)
-			goto out_free_new_f;
+			goto out;
 	}
 	new_fa->fa_info = fi;
 	new_fa->fa_tos = tos;
 	new_fa->fa_type = cfg->fc_type;
 	new_fa->fa_scope = cfg->fc_scope;
 	new_fa->fa_state = 0;
 
 	/*
@@ -535,19 +535,19 @@ static int fn_hash_insert(struct fib_tab
 	if (new_f)
 		fz->fz_nent++;
 	rt_cache_flush(-1);
 
 	rtmsg_fib(RTM_NEWROUTE, key, new_fa, cfg->fc_dst_len, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
 	return 0;
 
-out_free_new_f:
-	kmem_cache_free(fn_hash_kmem, new_f);
 out:
+	if (new_f)
+		kmem_cache_free(fn_hash_kmem, new_f);
 	fib_release_info(fi);
 	return err;
 }
 
 
 static int fn_hash_delete(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct fn_hash *table = (struct fn_hash*)tb->tb_data;

