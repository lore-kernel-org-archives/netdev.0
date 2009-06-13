From: Patrick McHardy <kaber@trash.net>
Subject: list_nulls 05/07: add hlist_nulls_add_head and hlist_nulls_del
Date: Sat, 13 Jun 2009 15:09:41 +0200 (MEST)
Message-ID: <20090613130941.2112.19054.sendpatchset@x2.localnet>
References: <20090613130934.2112.65299.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090613130934.2112.65299.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit d219dce76c64f2c883dad0537fa09a56d5ff0a10
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Sat Jun 13 12:28:57 2009 +0200

    list_nulls: add hlist_nulls_add_head and hlist_nulls_del
    
    This patch adds the hlist_nulls_add_head() function which is
    based on hlist_nulls_add_head_rcu() but without the use of
    rcu_assign_pointer(). It also adds hlist_nulls_del which is
    exactly the same like hlist_nulls_del_rcu().
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/list_nulls.h b/include/linux/list_nulls.h
index 93150ec..5d10ae3 100644
--- a/include/linux/list_nulls.h
+++ b/include/linux/list_nulls.h
@@ -56,6 +56,18 @@ static inline int hlist_nulls_empty(const struct hlist_nulls_head *h)
 	return is_a_nulls(h->first);
 }
 
+static inline void hlist_nulls_add_head(struct hlist_nulls_node *n,
+					struct hlist_nulls_head *h)
+{
+	struct hlist_nulls_node *first = h->first;
+
+	n->next = first;
+	n->pprev = &h->first;
+	h->first = n;
+	if (!is_a_nulls(first))
+		first->pprev = &n->next;
+}
+
 static inline void __hlist_nulls_del(struct hlist_nulls_node *n)
 {
 	struct hlist_nulls_node *next = n->next;
@@ -65,6 +77,12 @@ static inline void __hlist_nulls_del(struct hlist_nulls_node *n)
 		next->pprev = pprev;
 }
 
+static inline void hlist_nulls_del(struct hlist_nulls_node *n)
+{
+	__hlist_nulls_del(n);
+	n->pprev = LIST_POISON2;
+}
+
 /**
  * hlist_nulls_for_each_entry	- iterate over list of given type
  * @tpos:	the type * to use as a loop cursor.
