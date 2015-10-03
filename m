From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 21/23] ocfs2/cluster: move locking into
	attribute store methods
Date: Sat,  3 Oct 2015 15:32:57 +0200
Message-ID: <1443879179-22280-22-git-send-email-hch@lst.de>
References: <1443879179-22280-1-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        Pratyush Anand <pratyush.anand@gmail.com>,
        Pantelis Antoniou <pantelis.antoniou@konsulko.com>,
        Felipe Balbi <balbi@ti.com>, cluster-devel@redhat.com,
        Tejun Heo <tj@kernel.org>, target-devel@vger.kernel.org,
        Andrzej Pietrasiewicz <andrzej.p@samsung.com>,
        ocfs2-devel@oss.oracle.com
To: Joel Becker <jlbec@evilplan.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Nicholas Bellinger <nab@linux-iscsi.org>
Return-path: <ocfs2-devel-bounces@oss.oracle.com>
In-Reply-To: <1443879179-22280-1-git-send-email-hch@lst.de>
List-Unsubscribe: <https://oss.oracle.com/mailman/listinfo/ocfs2-devel>,
	<mailto:ocfs2-devel-request@oss.oracle.com?subject=unsubscribe>
List-Archive: <http://oss.oracle.com/pipermail/ocfs2-devel>
List-Post: <mailto:ocfs2-devel@oss.oracle.com>
List-Help: <mailto:ocfs2-devel-request@oss.oracle.com?subject=help>
List-Subscribe: <https://oss.oracle.com/mailman/listinfo/ocfs2-devel>,
	<mailto:ocfs2-devel-request@oss.oracle.com?subject=subscribe>
Sender: ocfs2-devel-bounces@oss.oracle.com
Errors-To: ocfs2-devel-bounces@oss.oracle.com
List-Id: netdev.vger.kernel.org

The test and separate set bit scheme was racy to start with, so move to do
a test_and_set_bit after doing the earlier error checks inside the actual
store methods.  Also remove the locking for the local attribute which
already has a different scheme to synchronize.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/ocfs2/cluster/nodemanager.c | 54 +++++++++++++++---------------------------
 1 file changed, 19 insertions(+), 35 deletions(-)

diff --git a/fs/ocfs2/cluster/nodemanager.c b/fs/ocfs2/cluster/nodemanager.c
index 441c84e..7a398f6 100644
--- a/fs/ocfs2/cluster/nodemanager.c
+++ b/fs/ocfs2/cluster/nodemanager.c
@@ -188,7 +188,6 @@ enum {
 	O2NM_NODE_ATTR_NUM = 0,
 	O2NM_NODE_ATTR_PORT,
 	O2NM_NODE_ATTR_ADDRESS,
-	O2NM_NODE_ATTR_LOCAL,
 };
 
 static ssize_t o2nm_node_num_write(struct o2nm_node *node, const char *page,
@@ -197,6 +196,7 @@ static ssize_t o2nm_node_num_write(struct o2nm_node *node, const char *page,
 	struct o2nm_cluster *cluster = to_o2nm_cluster_from_node(node);
 	unsigned long tmp;
 	char *p = (char *)page;
+	int ret = 0;
 
 	tmp = simple_strtoul(p, &p, 0);
 	if (!p || (*p && (*p != '\n')))
@@ -215,15 +215,18 @@ static ssize_t o2nm_node_num_write(struct o2nm_node *node, const char *page,
 
 	write_lock(&cluster->cl_nodes_lock);
 	if (cluster->cl_nodes[tmp])
-		p = NULL;
+		ret = -EEXIST;
+	else if (test_and_set_bit(O2NM_NODE_ATTR_NUM,
+			&node->nd_set_attributes))
+		ret = -EBUSY;
 	else  {
 		cluster->cl_nodes[tmp] = node;
 		node->nd_num = tmp;
 		set_bit(tmp, cluster->cl_nodes_bitmap);
 	}
 	write_unlock(&cluster->cl_nodes_lock);
-	if (p == NULL)
-		return -EEXIST;
+	if (ret)
+		return ret;
 
 	return count;
 }
@@ -247,6 +250,8 @@ static ssize_t o2nm_node_ipv4_port_write(struct o2nm_node *node,
 	if (tmp >= (u16)-1)
 		return -ERANGE;
 
+	if (test_and_set_bit(O2NM_NODE_ATTR_PORT, &node->nd_set_attributes))
+		return -EBUSY;
 	node->nd_ipv4_port = htons(tmp);
 
 	return count;
@@ -282,6 +287,9 @@ static ssize_t o2nm_node_ipv4_address_write(struct o2nm_node *node,
 	write_lock(&cluster->cl_nodes_lock);
 	if (o2nm_node_ip_tree_lookup(cluster, ipv4_addr, &p, &parent))
 		ret = -EEXIST;
+	else if (test_and_set_bit(O2NM_NODE_ATTR_ADDRESS,
+			&node->nd_set_attributes))
+		ret = -EBUSY;
 	else {
 		rb_link_node(&node->nd_ip_node, parent, p);
 		rb_insert_color(&node->nd_ip_node, &cluster->cl_node_ip_tree);
@@ -388,24 +396,13 @@ static struct o2nm_node_attribute o2nm_node_attr_local = {
 };
 
 static struct configfs_attribute *o2nm_node_attrs[] = {
-	[O2NM_NODE_ATTR_NUM] = &o2nm_node_attr_num.attr,
-	[O2NM_NODE_ATTR_PORT] = &o2nm_node_attr_ipv4_port.attr,
-	[O2NM_NODE_ATTR_ADDRESS] = &o2nm_node_attr_ipv4_address.attr,
-	[O2NM_NODE_ATTR_LOCAL] = &o2nm_node_attr_local.attr,
+	&o2nm_node_attr_num.attr,
+	&o2nm_node_attr_ipv4_port.attr,
+	&o2nm_node_attr_ipv4_address.attr,
+	&o2nm_node_attr_local.attr,
 	NULL,
 };
 
-static int o2nm_attr_index(struct configfs_attribute *attr)
-{
-	int i;
-	for (i = 0; i < ARRAY_SIZE(o2nm_node_attrs); i++) {
-		if (attr == o2nm_node_attrs[i])
-			return i;
-	}
-	BUG();
-	return 0;
-}
-
 static ssize_t o2nm_node_show(struct config_item *item,
 			      struct configfs_attribute *attr,
 			      char *page)
@@ -427,24 +424,11 @@ static ssize_t o2nm_node_store(struct config_item *item,
 	struct o2nm_node *node = to_o2nm_node(item);
 	struct o2nm_node_attribute *o2nm_node_attr =
 		container_of(attr, struct o2nm_node_attribute, attr);
-	ssize_t ret;
-	int attr_index = o2nm_attr_index(attr);
 
-	if (o2nm_node_attr->store == NULL) {
-		ret = -EINVAL;
-		goto out;
-	}
-
-	if (test_bit(attr_index, &node->nd_set_attributes))
-		return -EBUSY;
-
-	ret = o2nm_node_attr->store(node, page, count);
-	if (ret < count)
-		goto out;
+	if (o2nm_node_attr->store == NULL)
+		return -EINVAL;
 
-	set_bit(attr_index, &node->nd_set_attributes);
-out:
-	return ret;
+	return o2nm_node_attr->store(node, page, count);
 }
 
 static struct configfs_item_operations o2nm_node_item_ops = {
-- 
1.9.1
