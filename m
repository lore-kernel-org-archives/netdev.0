From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v2 04/11] net ipset: use rbtree postorder iteration instead of opencoding
Date: Wed,  6 Nov 2013 17:42:33 -0800
Message-ID: <1383788572-25938-5-git-send-email-cody@linux.vnet.ibm.com>
References: <1383788572-25938-1-git-send-email-cody@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
	Cody P Schafer <cody@linux.vnet.ibm.com>,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Andrew Morton <akpm@linux-foundation.org>,
	EXT4 <linux-ext4@vger.kernel.org>, Jan Kara <jack@suse.cz>,
	rostedt@goodmis.org, "David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:48959 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753545Ab3KGBrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 20:47:02 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cody@linux.vnet.ibm.com>;
	Wed, 6 Nov 2013 18:47:01 -0700
In-Reply-To: <1383788572-25938-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
