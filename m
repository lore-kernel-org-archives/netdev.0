From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [RFC] sk_nulls_next_rcu
Date: Tue, 1 Dec 2009 02:19:29 +0200
Message-ID: <200912010219.29340.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:19462 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751712AbZLAAWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 19:22:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I am trying to convert the LLC code to RCU, and it appears that for proc 
support a sk_nulls_next_rcu would be required. 

Is this the wrong way to do it, or is it that nobody need it yet?

Thanks,
tavi

 
diff --git a/include/net/sock.h b/include/net/sock.h
index 3f1a480..989d7e9 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -351,6 +351,13 @@ static inline struct sock *sk_nulls_next(const struct sock *sk)
 		NULL;
 }
 
+static inline struct sock *sk_nulls_next_rcu(const struct sock *sk)
+{
+     struct hlist_nulls_node *n = rcu_dereference(sk->sk_nulls_node.next);
+     return !is_a_nulls(n) ? hlist_nulls_entry(n, struct sock, sk_nulls_node) :
+	    NULL;
+}
+
 static inline int sk_unhashed(const struct sock *sk)
 {
 	return hlist_unhashed(&sk->sk_node);

diff --git a/net/llc/llc_proc.c b/net/llc/llc_proc.c
index be47ac4..7567fb9 100644
--- a/net/llc/llc_proc.c
+++ b/net/llc/llc_proc.c
@@ -34,19 +34,19 @@ static struct sock *llc_get_sk_idx(loff_t pos)
 {
 	struct list_head *sap_entry;
 	struct llc_sap *sap;
-	struct hlist_node *node;
+	struct hlist_nulls_node *node;
 	struct sock *sk = NULL;
 
 	list_for_each(sap_entry, &llc_sap_list) {
 		sap = list_entry(sap_entry, struct llc_sap, node);
 
-		read_lock_bh(&sap->sk_list.lock);
-		sk_for_each(sk, node, &sap->sk_list.list) {
+		rcu_read_lock_bh();
+		sk_nulls_for_each_rcu(sk, node, &sap->sk_list.list) {
 			if (!pos)
 				goto found;
 			--pos;
 		}
-		read_unlock_bh(&sap->sk_list.lock);
+		rcu_read_unlock_bh();
 	}
 	sk = NULL;
 found:
@@ -73,25 +73,25 @@ static void *llc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 		goto out;
 	}
 	sk = v;
-	next = sk_next(sk);
+	next = sk_nulls_next(sk);
 	if (next) {
 		sk = next;
 		goto out;
 	}
 	llc = llc_sk(sk);
 	sap = llc->sap;
-	read_unlock_bh(&sap->sk_list.lock);
+	rcu_read_unlock_bh();
 	sk = NULL;
 	for (;;) {
+		struct hlist_nulls_node *node;
+
 		if (sap->node.next == &llc_sap_list)
 			break;
 		sap = list_entry(sap->node.next, struct llc_sap, node);
-		read_lock_bh(&sap->sk_list.lock);
-		if (!hlist_empty(&sap->sk_list.list)) {
-			sk = sk_head(&sap->sk_list.list);
+		rcu_read_lock_bh();
+		sk_nulls_for_each_rcu(sk, node, &sap->sk_list.list)
 			break;
-		}
-		read_unlock_bh(&sap->sk_list.lock);
+		rcu_read_unlock_bh();
 	}
 out:
 	return sk;
@@ -99,13 +99,8 @@ out:
 
 static void llc_seq_stop(struct seq_file *seq, void *v)
 {
-	if (v && v != SEQ_START_TOKEN) {
-		struct sock *sk = v;
-		struct llc_sock *llc = llc_sk(sk);
-		struct llc_sap *sap = llc->sap;
-
-		read_unlock_bh(&sap->sk_list.lock);
-	}
+	if (v && v != SEQ_START_TOKEN)
+		rcu_read_unlock_bh();
 	read_unlock_bh(&llc_sap_list_lock);
 }
 
