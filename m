From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 7/9] cxgb4: use kvzalloc and kvfree
Date: Thu, 13 May 2010 19:11:25 +0800
Message-ID: <1273749085-10415-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:59040 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755679Ab0EMLLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 07:11:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use kvzalloc and kvfree

use kvzalloc and kvfree

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 drivers/net/cxgb4/cxgb4.h      |    3 ---
 drivers/net/cxgb4/cxgb4_main.c |   37 +++++--------------------------------
 drivers/net/cxgb4/l2t.c        |    2 +-
 3 files changed, 6 insertions(+), 36 deletions(-)
diff --git a/drivers/net/cxgb4/cxgb4.h b/drivers/net/cxgb4/cxgb4.h
index 8856a75..2a38fad 100644
--- a/drivers/net/cxgb4/cxgb4.h
+++ b/drivers/net/cxgb4/cxgb4.h
@@ -584,9 +584,6 @@ static inline struct adapter *netdev2adap(const struct net_device *dev)
 void t4_os_portmod_changed(const struct adapter *adap, int port_id);
 void t4_os_link_changed(struct adapter *adap, int port_id, int link_stat);
 
-void *t4_alloc_mem(size_t size);
-void t4_free_mem(void *addr);
-
 void t4_free_sge_resources(struct adapter *adap);
 irq_handler_t t4_intr_handler(struct adapter *adap);
 netdev_tx_t t4_eth_xmit(struct sk_buff *skb, struct net_device *dev);
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 1bad500..776f72f 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -55,7 +55,6 @@
 #include <linux/sched.h>
 #include <linux/seq_file.h>
 #include <linux/sockios.h>
-#include <linux/vmalloc.h>
 #include <linux/workqueue.h>
 #include <net/neighbour.h>
 #include <net/netevent.h>
@@ -742,32 +741,6 @@ out:	release_firmware(fw);
 	return ret;
 }
 
-/*
- * Allocate a chunk of memory using kmalloc or, if that fails, vmalloc.
- * The allocated memory is cleared.
- */
-void *t4_alloc_mem(size_t size)
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
- * Free memory allocated through alloc_mem().
- */
-void t4_free_mem(void *addr)
-{
-	if (is_vmalloc_addr(addr))
-		vfree(addr);
-	else
-		kfree(addr);
-}
-
 static inline int is_offload(const struct adapter *adap)
 {
 	return adap->params.offload;
@@ -2034,7 +2007,7 @@ static int tid_init(struct tid_info *t)
 	size = t->ntids * sizeof(*t->tid_tab) + natids * sizeof(*t->atid_tab) +
 	       t->nstids * sizeof(*t->stid_tab) +
 	       BITS_TO_LONGS(t->nstids) * sizeof(long);
-	t->tid_tab = t4_alloc_mem(size);
+	t->tid_tab = kvzalloc(size);
 	if (!t->tid_tab)
 		return -ENOMEM;
 
@@ -3308,8 +3281,8 @@ sriov:
 	return 0;
 
  out_free_dev:
-	t4_free_mem(adapter->tids.tid_tab);
-	t4_free_mem(adapter->l2t);
+	kvfree(adapter->tids.tid_tab);
+	kvfree(adapter->l2t);
 	for_each_port(adapter, i)
 		if (adapter->port[i])
 			free_netdev(adapter->port[i]);
@@ -3349,8 +3322,8 @@ static void __devexit remove_one(struct pci_dev *pdev)
 
 		t4_sge_stop(adapter);
 		t4_free_sge_resources(adapter);
-		t4_free_mem(adapter->l2t);
-		t4_free_mem(adapter->tids.tid_tab);
+		kvfree(adapter->l2t);
+		kvfree(adapter->tids.tid_tab);
 		disable_msi(adapter);
 
 		for_each_port(adapter, i)
diff --git a/drivers/net/cxgb4/l2t.c b/drivers/net/cxgb4/l2t.c
index 9f96724..f975087 100644
--- a/drivers/net/cxgb4/l2t.c
+++ b/drivers/net/cxgb4/l2t.c
@@ -513,7 +513,7 @@ struct l2t_data *t4_init_l2t(void)
 	int i;
 	struct l2t_data *d;
 
-	d = t4_alloc_mem(sizeof(*d));
+	d = kvzalloc(sizeof(*d));
 	if (!d)
 		return NULL;
 
