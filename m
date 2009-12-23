From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next PATCH v2 8/9] llc: convert llc_sap_list to RCU
Date: Thu, 24 Dec 2009 01:45:33 +0200
Message-ID: <1261611934-24348-9-git-send-email-opurdila@ixiacom.com>
References: <1261611934-24348-1-git-send-email-opurdila@ixiacom.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:23684 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757555AbZLWXtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:49:10 -0500
In-Reply-To: <1261611934-24348-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 include/net/llc.h  |    2 +-
 net/llc/llc_core.c |   43 +++++++++++--------------------------------
 net/llc/llc_proc.c |   11 ++++-------
 3 files changed, 16 insertions(+), 40 deletions(-)

diff --git a/include/net/llc.h b/include/net/llc.h
index b020185..aee826d 100644
--- a/include/net/llc.h
+++ b/include/net/llc.h
@@ -92,7 +92,7 @@ struct hlist_nulls_head *llc_sk_laddr_hash(struct llc_sap *sap,
 #define LLC_DEST_CONN            2      /* Type 2 goes here */
 
 extern struct list_head llc_sap_list;
-extern rwlock_t llc_sap_list_lock;
+extern spinlock_t llc_sap_list_lock;
 
 extern int llc_rcv(struct sk_buff *skb, struct net_device *dev,
 		   struct packet_type *pt, struct net_device *orig_dev);
diff --git a/net/llc/llc_core.c b/net/llc/llc_core.c
index 0a5900d..21fe87e 100644
--- a/net/llc/llc_core.c
+++ b/net/llc/llc_core.c
@@ -23,7 +23,7 @@
 #include <net/llc.h>
 
 LIST_HEAD(llc_sap_list);
-DEFINE_RWLOCK(llc_sap_list_lock);
+DEFINE_SPINLOCK(llc_sap_list_lock);
 
 /**
  *	llc_sap_alloc - allocates and initializes sap.
@@ -46,30 +46,6 @@ static struct llc_sap *llc_sap_alloc(void)
 	return sap;
 }
 
-/**
- *	llc_add_sap - add sap to station list
- *	@sap: Address of the sap
- *
- *	Adds a sap to the LLC's station sap list.
- */
-static void llc_add_sap(struct llc_sap *sap)
-{
-	list_add_tail(&sap->node, &llc_sap_list);
-}
-
-/**
- *	llc_del_sap - del sap from station list
- *	@sap: Address of the sap
- *
- *	Removes a sap to the LLC's station sap list.
- */
-static void llc_del_sap(struct llc_sap *sap)
-{
-	write_lock_bh(&llc_sap_list_lock);
-	list_del(&sap->node);
-	write_unlock_bh(&llc_sap_list_lock);
-}
-
 static struct llc_sap *__llc_sap_find(unsigned char sap_value)
 {
 	struct llc_sap* sap;
@@ -93,13 +69,13 @@ out:
  */
 struct llc_sap *llc_sap_find(unsigned char sap_value)
 {
-	struct llc_sap* sap;
+	struct llc_sap *sap;
 
-	read_lock_bh(&llc_sap_list_lock);
+	rcu_read_lock_bh();
 	sap = __llc_sap_find(sap_value);
 	if (sap)
 		llc_sap_hold(sap);
-	read_unlock_bh(&llc_sap_list_lock);
+	rcu_read_unlock_bh();
 	return sap;
 }
 
@@ -120,7 +96,7 @@ struct llc_sap *llc_sap_open(unsigned char lsap,
 {
 	struct llc_sap *sap = NULL;
 
-	write_lock_bh(&llc_sap_list_lock);
+	spin_lock_bh(&llc_sap_list_lock);
 	if (__llc_sap_find(lsap)) /* SAP already exists */
 		goto out;
 	sap = llc_sap_alloc();
@@ -128,9 +104,9 @@ struct llc_sap *llc_sap_open(unsigned char lsap,
 		goto out;
 	sap->laddr.lsap = lsap;
 	sap->rcv_func	= func;
-	llc_add_sap(sap);
+	list_add_tail_rcu(&sap->node, &llc_sap_list);
 out:
-	write_unlock_bh(&llc_sap_list_lock);
+	spin_unlock_bh(&llc_sap_list_lock);
 	return sap;
 }
 
@@ -145,7 +121,10 @@ out:
  */
 void llc_sap_close(struct llc_sap *sap)
 {
-	llc_del_sap(sap);
+	spin_lock_bh(&llc_sap_list_lock);
+	list_del_rcu(&sap->node);
+	spin_unlock_bh(&llc_sap_list_lock);
+	synchronize_rcu();
 	kfree(sap);
 }
 
diff --git a/net/llc/llc_proc.c b/net/llc/llc_proc.c
index 09dec63..7af1ff2 100644
--- a/net/llc/llc_proc.c
+++ b/net/llc/llc_proc.c
@@ -32,14 +32,11 @@ static void llc_ui_format_mac(struct seq_file *seq, u8 *addr)
 
 static struct sock *llc_get_sk_idx(loff_t pos)
 {
-	struct list_head *sap_entry;
 	struct llc_sap *sap;
 	struct sock *sk = NULL;
 	int i;
 
-	list_for_each(sap_entry, &llc_sap_list) {
-		sap = list_entry(sap_entry, struct llc_sap, node);
-
+	list_for_each_entry_rcu(sap, &llc_sap_list, node) {
 		spin_lock_bh(&sap->sk_lock);
 		for (i = 0; i < LLC_SK_LADDR_HASH_ENTRIES; i++) {
 			struct hlist_nulls_head *head = &sap->sk_laddr_hash[i];
@@ -62,7 +59,7 @@ static void *llc_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	loff_t l = *pos;
 
-	read_lock_bh(&llc_sap_list_lock);
+	rcu_read_lock_bh();
 	return l ? llc_get_sk_idx(--l) : SEQ_START_TOKEN;
 }
 
@@ -102,7 +99,7 @@ static void *llc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	if (sk)
 		goto out;
 	spin_unlock_bh(&sap->sk_lock);
-	list_for_each_entry_continue(sap, &llc_sap_list, node) {
+	list_for_each_entry_continue_rcu(sap, &llc_sap_list, node) {
 		spin_lock_bh(&sap->sk_lock);
 		sk = laddr_hash_next(sap, -1);
 		if (sk)
@@ -122,7 +119,7 @@ static void llc_seq_stop(struct seq_file *seq, void *v)
 
 		spin_unlock_bh(&sap->sk_lock);
 	}
-	read_unlock_bh(&llc_sap_list_lock);
+	rcu_read_unlock_bh();
 }
 
 static int llc_seq_socket_show(struct seq_file *seq, void *v)
-- 
1.5.6.5

