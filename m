From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.4 1/4]: Add rb_first/rb_last/rb_prev/rb_next
Date: Sat, 14 Aug 2004 22:01:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411E6FA3.9010102@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020100060703010000030607"
Cc: netdev@oss.sgi.com, devik <devik@cdi.cz>, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020100060703010000030607
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds some useful rbtree functions from 2.6 to 2.4.


--------------020100060703010000030607
Content-Type: text/x-patch;
 name="01-hfsc-2.4.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01-hfsc-2.4.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/11 23:11:30+02:00 kaber@coreworks.de 
#   [RBTREE]: Add rb_first/rb_last/rb_prev/rb_next
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# lib/rbtree.c
#   2004/08/11 23:11:25+02:00 kaber@coreworks.de +71 -0
#   [RBTREE]: Add rb_first/rb_last/rb_prev/rb_next
# 
# include/linux/rbtree.h
#   2004/08/11 23:11:25+02:00 kaber@coreworks.de +6 -0
#   [RBTREE]: Add rb_first/rb_last/rb_prev/rb_next
# 
diff -Nru a/include/linux/rbtree.h b/include/linux/rbtree.h
--- a/include/linux/rbtree.h	2004-08-12 23:23:07 +02:00
+++ b/include/linux/rbtree.h	2004-08-12 23:23:07 +02:00
@@ -121,6 +121,12 @@
 extern void rb_insert_color(rb_node_t *, rb_root_t *);
 extern void rb_erase(rb_node_t *, rb_root_t *);
 
+/* Find logical next and previous nodes in a tree */
+extern rb_node_t *rb_next(rb_node_t *);
+extern rb_node_t *rb_prev(rb_node_t *);
+extern rb_node_t *rb_first(rb_root_t *);
+extern rb_node_t *rb_last(rb_root_t *);
+
 static inline void rb_link_node(rb_node_t * node, rb_node_t * parent, rb_node_t ** rb_link)
 {
 	node->rb_parent = parent;
diff -Nru a/lib/rbtree.c b/lib/rbtree.c
--- a/lib/rbtree.c	2004-08-12 23:23:07 +02:00
+++ b/lib/rbtree.c	2004-08-12 23:23:07 +02:00
@@ -294,3 +294,74 @@
 		__rb_erase_color(child, parent, root);
 }
 EXPORT_SYMBOL(rb_erase);
+
+/*
+ * This function returns the first node (in sort order) of the tree.
+ */
+rb_node_t *rb_first(rb_root_t *root)
+{
+	rb_node_t *n;
+
+	n = root->rb_node;
+	if (!n)
+		return NULL;
+	while (n->rb_left)
+		n = n->rb_left;
+	return n;
+}
+EXPORT_SYMBOL(rb_first);
+
+rb_node_t *rb_last(rb_root_t *root)
+{
+	rb_node_t *n;
+
+	n = root->rb_node;
+	if (!n)
+		return NULL;
+	while (n->rb_right)
+		n = n->rb_right;
+	return n;
+}
+EXPORT_SYMBOL(rb_last);
+
+rb_node_t *rb_next(rb_node_t *node)
+{
+	/* If we have a right-hand child, go down and then left as far
+	   as we can. */
+	if (node->rb_right) {
+		node = node->rb_right;
+		while (node->rb_left)
+			node = node->rb_left;
+	}
+
+	/* No right-hand children.  Everything down and left is
+	   smaller than us, so any 'next' node must be in the general
+	   direction of our parent. Go up the tree; any time the
+	   ancestor is a right-hand child of its parent, keep going
+	   up. First time it's a left-hand child of its parent, said
+	   parent is our 'next' node. */
+	while (node->rb_parent && node == node->rb_parent->rb_right)
+		node = node->rb_parent;
+
+	return node->rb_parent;
+}
+EXPORT_SYMBOL(rb_next);
+
+rb_node_t *rb_prev(rb_node_t *node)
+{
+	/* If we have a left-hand child, go down and then right as far
+	   as we can. */
+	if (node->rb_left) {
+		node = node->rb_left;
+		while (node->rb_right)
+			node = node->rb_right;	 
+	}
+
+	/* No left-hand children. Go up till we find an ancestor which
+	   is a right-hand child of its parent */
+	while (node->rb_parent && node == node->rb_parent->rb_left)
+		node = node->rb_parent;
+
+	return node->rb_parent;
+}
+EXPORT_SYMBOL(rb_prev);

--------------020100060703010000030607--
