From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH] netfilter: use krealloc() in nf_conntrack_extend.c
Date: Thu, 22 May 2008 21:47:34 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805222145320.6071@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mpm@selenic.com, clameter@sgi.com
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pekka Enberg <penberg@cs.helsinki.fi>

The ksize() API is going away because it is being abused and it doesn't even
work consistenly across different allocators. Therefore, convert the use 
of ksize() in net/netfilter/nf_conntrack_extend.c to krealloc() that is 
open-coded there.

Cc: Matt Mackall <mpm@selenic.com>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 net/netfilter/nf_conntrack_extend.c |   31 +++++++++++++------------------
 1 file changed, 13 insertions(+), 18 deletions(-)

Index: slab-2.6/net/netfilter/nf_conntrack_extend.c
===================================================================
--- slab-2.6.orig/net/netfilter/nf_conntrack_extend.c	2008-05-22 21:38:14.000000000 +0300
+++ slab-2.6/net/netfilter/nf_conntrack_extend.c	2008-05-22 21:38:21.000000000 +0300
@@ -88,27 +88,22 @@
 	newlen = newoff + t->len;
 	rcu_read_unlock();
 
-	if (newlen >= ksize(ct->ext)) {
-		new = kmalloc(newlen, gfp);
-		if (!new)
-			return NULL;
+	new = krealloc(ct->ext, newlen, gfp);
+	if (!new)
+		return NULL;
 
-		memcpy(new, ct->ext, ct->ext->len);
-
-		for (i = 0; i < NF_CT_EXT_NUM; i++) {
-			if (!nf_ct_ext_exist(ct, i))
-				continue;
+	for (i = 0; i < NF_CT_EXT_NUM; i++) {
+		if (!nf_ct_ext_exist(ct, i))
+			continue;
 
-			rcu_read_lock();
-			t = rcu_dereference(nf_ct_ext_types[i]);
-			if (t && t->move)
-				t->move((void *)new + new->offset[i],
-					(void *)ct->ext + ct->ext->offset[i]);
-			rcu_read_unlock();
-		}
-		kfree(ct->ext);
-		ct->ext = new;
+		rcu_read_lock();
+		t = rcu_dereference(nf_ct_ext_types[i]);
+		if (t && t->move)
+			t->move((void *)new + new->offset[i],
+				(void *)ct->ext + ct->ext->offset[i]);
+		rcu_read_unlock();
 	}
+	ct->ext = new;
 
 	ct->ext->offset[id] = newoff;
 	ct->ext->len = newlen;
