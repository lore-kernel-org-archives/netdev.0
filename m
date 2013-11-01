From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 1/8] net ipset: use rbtree postorder iteration instead of opencoding
Date: Fri,  1 Nov 2013 15:38:45 -0700
Message-ID: <1383345566-25087-1-git-send-email-cody@linux.vnet.ibm.com>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>, coreteam@netfilter.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use rbtree_postorder_for_each_entry_safe() to destroy the rbtree instead
of opencoding an alternate postorder iteration that modifies the tree

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 net/netfilter/ipset/ip_set_hash_netiface.c | 27 ++++-----------------------
 1 file changed, 4 insertions(+), 23 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 7d798d5..99dba4c 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -45,31 +45,12 @@ struct iface_node {
 static void
 rbtree_destroy(struct rb_root *root)
 {
-	struct rb_node *p, *n = root->rb_node;
-	struct iface_node *node;
-
-	/* Non-recursive destroy, like in ext3 */
-	while (n) {
-		if (n->rb_left) {
-			n = n->rb_left;
-			continue;
-		}
-		if (n->rb_right) {
-			n = n->rb_right;
-			continue;
-		}
-		p = rb_parent(n);
-		node = rb_entry(n, struct iface_node, node);
-		if (!p)
-			*root = RB_ROOT;
-		else if (p->rb_left == n)
-			p->rb_left = NULL;
-		else if (p->rb_right == n)
-			p->rb_right = NULL;
+	struct iface_node *node, *next;
 
+	rbtree_postorder_for_each_entry_safe(node, next, root, node)
 		kfree(node);
-		n = p;
-	}
+
+	*root = RB_ROOT;
 }
 
 static int
-- 
1.8.4.2
