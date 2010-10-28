From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] fib: Fix fib zone and its hash leak on namespace stop
Date: Thu, 28 Oct 2010 16:00:43 +0400
Message-ID: <4CC965EB.60600@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:37892 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755187Ab0J1MAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 08:00:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we stop a namespace we flush the table and free one, but the
added fn_zone-s (and their hashes if grown) are leaked. Need to free.
Tries releases all its stuff in the flushing code.

Shame on us - this bug exists since the very first make-fib-per-net
patches in 2.6.27 :(

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index ba3666d..07bdb5e 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -158,6 +158,8 @@ extern int fib_table_flush(struct fib_table *table);
 extern void fib_table_select_default(struct fib_table *table,
 				     const struct flowi *flp,
 				     struct fib_result *res);
+extern void fib_free_table(struct fib_table *tb);
+
 
 
 #ifndef CONFIG_IP_MULTIPLE_TABLES
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 36e27c2..eb6f69a 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1052,7 +1052,7 @@ static void ip_fib_net_exit(struct net *net)
 		hlist_for_each_entry_safe(tb, node, tmp, head, tb_hlist) {
 			hlist_del(node);
 			fib_table_flush(tb);
-			kfree(tb);
+			fib_free_table(tb);
 		}
 	}
 	kfree(net->ipv4.fib_table_hash);
diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index b232375..b3acb04 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -716,6 +716,24 @@ int fib_table_flush(struct fib_table *tb)
 	return found;
 }
 
+void fib_free_table(struct fib_table *tb)
+{
+	struct fn_hash *table = (struct fn_hash *) tb->tb_data;
+	struct fn_zone *fz, *next;
+
+	next = table->fn_zone_list;
+	while (next != NULL) {
+		fz = next;
+		next = fz->fz_next;
+
+		if (fz->fz_hash != fz->fz_embedded_hash)
+			fz_hash_free(fz->fz_hash, fz->fz_divisor);
+
+		kfree(fz);
+	}
+
+	kfree(tb);
+}
 
 static inline int
 fn_hash_dump_bucket(struct sk_buff *skb, struct netlink_callback *cb,
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index b144508..200eb53 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1797,6 +1797,11 @@ int fib_table_flush(struct fib_table *tb)
 	return found;
 }
 
+void fib_free_table(struct fib_table *tb)
+{
+	kfree(tb);
+}
+
 void fib_table_select_default(struct fib_table *tb,
 			      const struct flowi *flp,
 			      struct fib_result *res)
