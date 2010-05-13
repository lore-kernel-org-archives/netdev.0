From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 8/9] cxgb3: use kvzalloc and kvfree
Date: Thu, 13 May 2010 19:14:31 +0800
Message-ID: <1273749271-10469-1-git-send-email-xiaosuo@gmail.com>
Cc: Divy Le Ray <divy@chelsio.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

use kvzalloc and kvfree

use kvzalloc and kvfree

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 drivers/net/cxgb3/cxgb3_defs.h    |    2 --
 drivers/net/cxgb3/cxgb3_offload.c |   31 ++-----------------------------
 drivers/net/cxgb3/l2t.c           |    4 ++--
 3 files changed, 4 insertions(+), 33 deletions(-)
diff --git a/drivers/net/cxgb3/cxgb3_defs.h b/drivers/net/cxgb3/cxgb3_defs.h
index 47e5376..d3c662f 100644
--- a/drivers/net/cxgb3/cxgb3_defs.h
+++ b/drivers/net/cxgb3/cxgb3_defs.h
@@ -41,8 +41,6 @@
 
 #define VALIDATE_TID 1
 
-void *cxgb_alloc_mem(unsigned long size);
-void cxgb_free_mem(void *addr);
 void cxgb_neigh_update(struct neighbour *neigh);
 void cxgb_redirect(struct dst_entry *old, struct dst_entry *new);
 
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index c6485b3..799c9b7 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -39,7 +39,6 @@
 #include <linux/if_vlan.h>
 #include <net/netevent.h>
 #include <linux/highmem.h>
-#include <linux/vmalloc.h>
 
 #include "common.h"
 #include "regs.h"
@@ -1156,32 +1155,6 @@ void cxgb_redirect(struct dst_entry *old, struct dst_entry *new)
 }
 
 /*
- * Allocate a chunk of memory using kmalloc or, if that fails, vmalloc.
- * The allocated memory is cleared.
- */
-void *cxgb_alloc_mem(unsigned long size)
-{
-	void *p = kmalloc(size, GFP_KERNEL);
-
-	if (!p)
-		p = vmalloc(size);
-	if (p)
-		memset(p, 0, size);
-	return p;
-}
-
-/*
- * Free memory allocated through t3_alloc_mem().
- */
-void cxgb_free_mem(void *addr)
-{
-	if (is_vmalloc_addr(addr))
-		vfree(addr);
-	else
-		kfree(addr);
-}
-
-/*
  * Allocate and initialize the TID tables.  Returns 0 on success.
  */
 static int init_tid_tabs(struct tid_info *t, unsigned int ntids,
@@ -1191,7 +1164,7 @@ static int init_tid_tabs(struct tid_info *t, unsigned int ntids,
 	unsigned long size = ntids * sizeof(*t->tid_tab) +
 	    natids * sizeof(*t->atid_tab) + nstids * sizeof(*t->stid_tab);
 
-	t->tid_tab = cxgb_alloc_mem(size);
+	t->tid_tab = kvzalloc(size);
 	if (!t->tid_tab)
 		return -ENOMEM;
 
@@ -1227,7 +1200,7 @@ static int init_tid_tabs(struct tid_info *t, unsigned int ntids,
 
 static void free_tid_maps(struct tid_info *t)
 {
-	cxgb_free_mem(t->tid_tab);
+	kvfree(t->tid_tab);
 }
 
 static inline void add_adapter(struct adapter *adap)
diff --git a/drivers/net/cxgb3/l2t.c b/drivers/net/cxgb3/l2t.c
index 2f3ee72..71e8c32 100644
--- a/drivers/net/cxgb3/l2t.c
+++ b/drivers/net/cxgb3/l2t.c
@@ -420,7 +420,7 @@ struct l2t_data *t3_init_l2t(unsigned int l2t_capacity)
 	struct l2t_data *d;
 	int i, size = sizeof(*d) + l2t_capacity * sizeof(struct l2t_entry);
 
-	d = cxgb_alloc_mem(size);
+	d = kvzalloc(size);
 	if (!d)
 		return NULL;
 
@@ -441,6 +441,6 @@ struct l2t_data *t3_init_l2t(unsigned int l2t_capacity)
 
 void t3_free_l2t(struct l2t_data *d)
 {
-	cxgb_free_mem(d);
+	kvfree(d);
 }
 
