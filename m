From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 10/10] tipc: purge signal handler infrastructure
Date: Mon, 5 May 2014 08:56:18 +0800
Message-ID: <1399251378-23842-11-git-send-email-ying.xue@windriver.com>
References: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:59972 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754144AbaEEA44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 20:56:56 -0400
In-Reply-To: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the previous commits of this series, we removed all asynchronous
actions which were based on the tasklet handler - "tipc_k_signal()".

So the moment has now come when we can completely remove the tasklet
handler infrastructure. That is done with this commit.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/Makefile  |    2 +-
 net/tipc/core.c    |    7 ---
 net/tipc/core.h    |    6 +--
 net/tipc/handler.c |  134 ----------------------------------------------------
 4 files changed, 2 insertions(+), 147 deletions(-)
 delete mode 100644 net/tipc/handler.c

diff --git a/net/tipc/Makefile b/net/tipc/Makefile
index b282f71..a080c66 100644
--- a/net/tipc/Makefile
+++ b/net/tipc/Makefile
@@ -5,7 +5,7 @@
 obj-$(CONFIG_TIPC) := tipc.o
 
 tipc-y	+= addr.o bcast.o bearer.o config.o \
-	   core.o handler.o link.o discover.o msg.o  \
+	   core.o link.o discover.o msg.o  \
 	   name_distr.o  subscr.o name_table.o net.o  \
 	   netlink.o node.o node_subscr.o port.o ref.o  \
 	   socket.o log.o eth_media.o server.o
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 50d5742..57f8ae9 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -80,7 +80,6 @@ struct sk_buff *tipc_buf_acquire(u32 size)
  */
 static void tipc_core_stop(void)
 {
-	tipc_handler_stop();
 	tipc_net_stop();
 	tipc_bearer_cleanup();
 	tipc_netlink_stop();
@@ -100,10 +99,6 @@ static int tipc_core_start(void)
 
 	get_random_bytes(&tipc_random, sizeof(tipc_random));
 
-	err = tipc_handler_start();
-	if (err)
-		goto out_handler;
-
 	err = tipc_ref_table_init(tipc_max_ports, tipc_random);
 	if (err)
 		goto out_reftbl;
@@ -146,8 +141,6 @@ out_netlink:
 out_nametbl:
 	tipc_ref_table_stop();
 out_reftbl:
-	tipc_handler_stop();
-out_handler:
 	return err;
 }
 
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 36cbf15..ae55d37 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -89,8 +89,6 @@ extern int tipc_random __read_mostly;
 /*
  * Routines available to privileged subsystems
  */
-int tipc_handler_start(void);
-void tipc_handler_stop(void);
 int tipc_netlink_start(void);
 void tipc_netlink_stop(void);
 int tipc_socket_init(void);
@@ -109,12 +107,10 @@ void tipc_unregister_sysctl(void);
 #endif
 
 /*
- * TIPC timer and signal code
+ * TIPC timer code
  */
 typedef void (*Handler) (unsigned long);
 
-u32 tipc_k_signal(Handler routine, unsigned long argument);
-
 /**
  * k_init_timer - initialize a timer
  * @timer: pointer to timer structure
diff --git a/net/tipc/handler.c b/net/tipc/handler.c
deleted file mode 100644
index 1fabf16..0000000
--- a/net/tipc/handler.c
+++ /dev/null
@@ -1,134 +0,0 @@
-/*
- * net/tipc/handler.c: TIPC signal handling
- *
- * Copyright (c) 2000-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions are met:
- *
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the names of the copyright holders nor the names of its
- *    contributors may be used to endorse or promote products derived from
- *    this software without specific prior written permission.
- *
- * Alternatively, this software may be distributed under the terms of the
- * GNU General Public License ("GPL") version 2 as published by the Free
- * Software Foundation.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
- * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
- * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
- * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
- * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
- * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
- * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
- * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
- * POSSIBILITY OF SUCH DAMAGE.
- */
-
-#include "core.h"
-
-struct queue_item {
-	struct list_head next_signal;
-	void (*handler) (unsigned long);
-	unsigned long data;
-};
-
-static struct kmem_cache *tipc_queue_item_cache;
-static struct list_head signal_queue_head;
-static DEFINE_SPINLOCK(qitem_lock);
-static int handler_enabled __read_mostly;
-
-static void process_signal_queue(unsigned long dummy);
-
-static DECLARE_TASKLET_DISABLED(tipc_tasklet, process_signal_queue, 0);
-
-
-unsigned int tipc_k_signal(Handler routine, unsigned long argument)
-{
-	struct queue_item *item;
-
-	spin_lock_bh(&qitem_lock);
-	if (!handler_enabled) {
-		spin_unlock_bh(&qitem_lock);
-		return -ENOPROTOOPT;
-	}
-
-	item = kmem_cache_alloc(tipc_queue_item_cache, GFP_ATOMIC);
-	if (!item) {
-		pr_err("Signal queue out of memory\n");
-		spin_unlock_bh(&qitem_lock);
-		return -ENOMEM;
-	}
-	item->handler = routine;
-	item->data = argument;
-	list_add_tail(&item->next_signal, &signal_queue_head);
-	spin_unlock_bh(&qitem_lock);
-	tasklet_schedule(&tipc_tasklet);
-	return 0;
-}
-
-static void process_signal_queue(unsigned long dummy)
-{
-	struct queue_item *__volatile__ item;
-	struct list_head *l, *n;
-
-	spin_lock_bh(&qitem_lock);
-	list_for_each_safe(l, n, &signal_queue_head) {
-		item = list_entry(l, struct queue_item, next_signal);
-		list_del(&item->next_signal);
-		spin_unlock_bh(&qitem_lock);
-		item->handler(item->data);
-		spin_lock_bh(&qitem_lock);
-		kmem_cache_free(tipc_queue_item_cache, item);
-	}
-	spin_unlock_bh(&qitem_lock);
-}
-
-int tipc_handler_start(void)
-{
-	tipc_queue_item_cache =
-		kmem_cache_create("tipc_queue_items", sizeof(struct queue_item),
-				  0, SLAB_HWCACHE_ALIGN, NULL);
-	if (!tipc_queue_item_cache)
-		return -ENOMEM;
-
-	INIT_LIST_HEAD(&signal_queue_head);
-	tasklet_enable(&tipc_tasklet);
-	handler_enabled = 1;
-	return 0;
-}
-
-void tipc_handler_stop(void)
-{
-	struct list_head *l, *n;
-	struct queue_item *item;
-
-	spin_lock_bh(&qitem_lock);
-	if (!handler_enabled) {
-		spin_unlock_bh(&qitem_lock);
-		return;
-	}
-	handler_enabled = 0;
-	spin_unlock_bh(&qitem_lock);
-
-	tasklet_kill(&tipc_tasklet);
-
-	spin_lock_bh(&qitem_lock);
-	list_for_each_safe(l, n, &signal_queue_head) {
-		item = list_entry(l, struct queue_item, next_signal);
-		list_del(&item->next_signal);
-		kmem_cache_free(tipc_queue_item_cache, item);
-	}
-	spin_unlock_bh(&qitem_lock);
-
-	kmem_cache_destroy(tipc_queue_item_cache);
-}
-- 
1.7.9.5
