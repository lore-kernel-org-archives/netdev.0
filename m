From: kaber@trash.net
Subject: [PATCH 4/6] netfilter: fix a race in nf_ct_ext_create()
Date: Wed, 22 Sep 2010 09:17:32 +0200
Message-ID: <1285139854-11827-5-git-send-email-kaber@trash.net>
References: <1285139854-11827-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53998 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989Ab0IVHRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 03:17:37 -0400
In-Reply-To: <1285139854-11827-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <Eric Dumazet>

As soon as rcu_read_unlock() is called, there is no guarantee current
thread can safely derefence t pointer, rcu protected.

Fix is to copy t->alloc_size in a temporary variable.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_extend.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index 7dcf7a4..8d9e4c9 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -48,15 +48,17 @@ nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_ct_ext_id id, gfp_t gfp)
 {
 	unsigned int off, len;
 	struct nf_ct_ext_type *t;
+	size_t alloc_size;
 
 	rcu_read_lock();
 	t = rcu_dereference(nf_ct_ext_types[id]);
 	BUG_ON(t == NULL);
 	off = ALIGN(sizeof(struct nf_ct_ext), t->align);
 	len = off + t->len;
+	alloc_size = t->alloc_size;
 	rcu_read_unlock();
 
-	*ext = kzalloc(t->alloc_size, gfp);
+	*ext = kzalloc(alloc_size, gfp);
 	if (!*ext)
 		return NULL;
 
-- 
1.7.1

