From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 24/28] tipc: Enhance sending of bulk name table messages
Date: Sat, 17 Sep 2011 23:32:20 -0400
Message-ID: <1316316744-29514-25-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50004 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756281Ab1IRDdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:33:01 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Modifies the initial transfer of name table entries to a new neighboring
node so that the messages are enqueued as a unit, rather than individually.

The revised algorithm now locates the link carrying the message only once,
and eliminates unnecessary checks for link congestion, message fragmentation,
and message bundling that are not required when sending these messages.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c       |   45 +++++++++++++++++++++++++++++++++++++++++++++
 net/tipc/link.h       |    1 +
 net/tipc/name_distr.c |   10 ++++++++--
 3 files changed, 54 insertions(+), 2 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 74126db..2ea3f22 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -986,6 +986,51 @@ int tipc_link_send(struct sk_buff *buf, u32 dest, u32 selector)
 }
 
 /*
+ * tipc_link_send_names - send name table entries to new neighbor
+ *
+ * Send routine for bulk delivery of name table messages when contact
+ * with a new neighbor occurs. No link congestion checking is performed
+ * because name table messages *must* be delivered. The messages must be
+ * small enough not to require fragmentation.
+ * Called without any locks held.
+ */
+
+void tipc_link_send_names(struct list_head *message_list, u32 dest)
+{
+	struct tipc_node *n_ptr;
+	struct link *l_ptr;
+	struct sk_buff *buf;
+	struct sk_buff *temp_buf;
+
+	if (list_empty(message_list))
+		return;
+
+	read_lock_bh(&tipc_net_lock);
+	n_ptr = tipc_node_find(dest);
+	if (n_ptr) {
+		tipc_node_lock(n_ptr);
+		l_ptr = n_ptr->active_links[0];
+		if (l_ptr) {
+			/* convert circular list to linear list */
+			((struct sk_buff *)message_list->prev)->next = NULL;
+			link_add_chain_to_outqueue(l_ptr,
+				(struct sk_buff *)message_list->next, 0);
+			tipc_link_push_queue(l_ptr);
+			INIT_LIST_HEAD(message_list);
+		}
+		tipc_node_unlock(n_ptr);
+	}
+	read_unlock_bh(&tipc_net_lock);
+
+	/* discard the messages if they couldn't be sent */
+
+	list_for_each_safe(buf, temp_buf, ((struct sk_buff *)message_list)) {
+		list_del((struct list_head *)buf);
+		buf_discard(buf);
+	}
+}
+
+/*
  * link_send_buf_fast: Entry for data messages where the
  * destination link is known and the header is complete,
  * inclusive total message length. Very time critical.
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 74fbeca..e56cb53 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -223,6 +223,7 @@ struct sk_buff *tipc_link_cmd_show_stats(const void *req_tlv_area, int req_tlv_s
 struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area, int req_tlv_space);
 void tipc_link_reset(struct link *l_ptr);
 int tipc_link_send(struct sk_buff *buf, u32 dest, u32 selector);
+void tipc_link_send_names(struct list_head *message_list, u32 dest);
 int tipc_link_send_buf(struct link *l_ptr, struct sk_buff *buf);
 u32 tipc_link_get_max_pkt(u32 dest, u32 selector);
 int tipc_link_send_sections_fast(struct tipc_port *sender,
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 97546f0..b7ca1bd 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -180,6 +180,7 @@ void tipc_named_node_up(unsigned long nodearg)
 	struct publication *publ;
 	struct distr_item *item = NULL;
 	struct sk_buff *buf = NULL;
+	struct list_head message_list;
 	u32 node = (u32)nodearg;
 	u32 left = 0;
 	u32 rest;
@@ -201,6 +202,10 @@ void tipc_named_node_up(unsigned long nodearg)
 	if (!max_item_buf)
 		return;
 
+	/* create list of publication messages, then send them as a unit */
+
+	INIT_LIST_HEAD(&message_list);
+
 	read_lock_bh(&tipc_nametbl_lock);
 	rest = publ_cnt * ITEM_SIZE;
 
@@ -219,13 +224,14 @@ void tipc_named_node_up(unsigned long nodearg)
 		item++;
 		left -= ITEM_SIZE;
 		if (!left) {
-			msg_set_link_selector(buf_msg(buf), node);
-			tipc_link_send(buf, node, node);
+			list_add_tail((struct list_head *)buf, &message_list);
 			buf = NULL;
 		}
 	}
 exit:
 	read_unlock_bh(&tipc_nametbl_lock);
+
+	tipc_link_send_names(&message_list, (u32)node);
 }
 
 /**
-- 
1.7.4.4
