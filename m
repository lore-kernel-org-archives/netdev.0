From: Timur Tabi <timur-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Subject: [PATCH 1/2] dt: introduce for_each_available_child_of_node,
 of_get_next_available_child
Date: Tue, 14 Aug 2012 18:20:23 -0500
Message-ID: <1344986424-14360-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>, David Miller
 <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 <devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Macro for_each_child_of_node() makes it easy to iterate over all of the
children for a given device tree node, including those nodes that are
marked as unavailable (i.e. status = "disabled").

Introduce for_each_available_child_of_node(), which is like
for_each_child_of_node(), but it automatically skips unavailable nodes.
This also requires the introduction of helper function
of_get_next_available_child(), which returns the next available child
node.

Signed-off-by: Timur Tabi <timur-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
---
 drivers/of/base.c  |   27 +++++++++++++++++++++++++++
 include/linux/of.h |    7 +++++++
 2 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/drivers/of/base.c b/drivers/of/base.c
index c181b94..d4a1c9a 100644
--- a/drivers/of/base.c
+++ b/drivers/of/base.c
@@ -364,6 +364,33 @@ struct device_node *of_get_next_child(const struct device_node *node,
 EXPORT_SYMBOL(of_get_next_child);
 
 /**
+ *	of_get_next_available_child - Find the next available child node
+ *	@node:	parent node
+ *	@prev:	previous child of the parent node, or NULL to get first
+ *
+ *      This function is like of_get_next_child(), except that it
+ *      automatically skips any disabled nodes (i.e. status = "disabled").
+ */
+struct device_node *of_get_next_available_child(const struct device_node *node,
+	struct device_node *prev)
+{
+	struct device_node *next;
+
+	read_lock(&devtree_lock);
+	next = prev ? prev->sibling : node->child;
+	for (; next; next = next->sibling) {
+		if (!of_device_is_available(next))
+			continue;
+		if (of_node_get(next))
+			break;
+	}
+	of_node_put(prev);
+	read_unlock(&devtree_lock);
+	return next;
+}
+EXPORT_SYMBOL(of_get_next_available_child);
+
+/**
  *	of_find_node_by_path - Find a node matching a full OF path
  *	@path:	The full path to match
  *
diff --git a/include/linux/of.h b/include/linux/of.h
index 5919ee3..1b11632 100644
--- a/include/linux/of.h
+++ b/include/linux/of.h
@@ -190,10 +190,17 @@ extern struct device_node *of_get_parent(const struct device_node *node);
 extern struct device_node *of_get_next_parent(struct device_node *node);
 extern struct device_node *of_get_next_child(const struct device_node *node,
 					     struct device_node *prev);
+extern struct device_node *of_get_next_available_child(
+	const struct device_node *node, struct device_node *prev);
+
 #define for_each_child_of_node(parent, child) \
 	for (child = of_get_next_child(parent, NULL); child != NULL; \
 	     child = of_get_next_child(parent, child))
 
+#define for_each_available_child_of_node(parent, child) \
+	for (child = of_get_next_available_child(parent, NULL); child != NULL; \
+	     child = of_get_next_available_child(parent, child))
+
 static inline int of_get_child_count(const struct device_node *np)
 {
 	struct device_node *child;
-- 
1.7.3.4
