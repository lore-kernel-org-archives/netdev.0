From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH linux1394-2.6.git 03/15] eth1394: refactor .probe and .update
Date: Mon, 2 Apr 2007 02:14:45 +0200 (CEST)
Message-ID: <tkrat.a0e27379330d8f34@s5r6.in-berlin.de>
References: <tkrat.7cdc7f6a1e6d9f28@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux1394-devel@lists.sourceforge.net
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <tkrat.7cdc7f6a1e6d9f28@s5r6.in-berlin.de>
Content-Disposition: INLINE
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux1394-devel-bounces@lists.sourceforge.net
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Move common code into an extra function.  This implicitly adds a missing
node_info->fifo = CSR1212_INVALID_ADDR_SPACE; to .update.

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
 drivers/ieee1394/eth1394.c |   48 ++++++++++++-------------------------
 1 file changed, 16 insertions(+), 32 deletions(-)

Index: linux/drivers/ieee1394/eth1394.c
===================================================================
--- linux.orig/drivers/ieee1394/eth1394.c
+++ linux/drivers/ieee1394/eth1394.c
@@ -340,20 +340,13 @@ static struct eth1394_node_ref *eth1394_
 	return NULL;
 }
 
-static int eth1394_probe(struct device *dev)
+static int eth1394_new_node(struct eth1394_host_info *hi,
+			    struct unit_directory *ud)
 {
-	struct unit_directory *ud;
-	struct eth1394_host_info *hi;
 	struct eth1394_priv *priv;
 	struct eth1394_node_ref *new_node;
 	struct eth1394_node_info *node_info;
 
-	ud = container_of(dev, struct unit_directory, device);
-
-	hi = hpsb_get_hostinfo(&eth1394_highlevel, ud->ne->host);
-	if (!hi)
-		return -ENOENT;
-
 	new_node = kmalloc(sizeof(*new_node), GFP_KERNEL);
 	if (!new_node)
 		return -ENOMEM;
@@ -374,10 +367,22 @@ static int eth1394_probe(struct device *
 
 	priv = netdev_priv(hi->dev);
 	list_add_tail(&new_node->list, &priv->ip_node_list);
-
 	return 0;
 }
 
+static int eth1394_probe(struct device *dev)
+{
+	struct unit_directory *ud;
+	struct eth1394_host_info *hi;
+
+	ud = container_of(dev, struct unit_directory, device);
+	hi = hpsb_get_hostinfo(&eth1394_highlevel, ud->ne->host);
+	if (!hi)
+		return -ENOENT;
+
+	return eth1394_new_node(hi, ud);
+}
+
 static int eth1394_remove(struct device *dev)
 {
 	struct unit_directory *ud;
@@ -421,38 +426,17 @@ static int eth1394_update(struct unit_di
 	struct eth1394_host_info *hi;
 	struct eth1394_priv *priv;
 	struct eth1394_node_ref *node;
-	struct eth1394_node_info *node_info;
 
 	hi = hpsb_get_hostinfo(&eth1394_highlevel, ud->ne->host);
 	if (!hi)
 		return -ENOENT;
 
 	priv = netdev_priv(hi->dev);
-
 	node = eth1394_find_node(&priv->ip_node_list, ud);
 	if (node)
 		return 0;
 
-	node = kmalloc(sizeof(*node), GFP_KERNEL);
-	if (!node)
-		return -ENOMEM;
-
-	node_info = kmalloc(sizeof(*node_info), GFP_KERNEL);
-	if (!node_info) {
-		kfree(node);
-		return -ENOMEM;
-	}
-
-	spin_lock_init(&node_info->pdg.lock);
-	INIT_LIST_HEAD(&node_info->pdg.list);
-	node_info->pdg.sz = 0;
-
-	ud->device.driver_data = node_info;
-	node->ud = ud;
-
-	priv = netdev_priv(hi->dev);
-	list_add_tail(&node->list, &priv->ip_node_list);
-	return 0;
+	return eth1394_new_node(hi, ud);
 }
 
 static struct ieee1394_device_id eth1394_id_table[] = {

-- 
Stefan Richter
-=====-=-=== -=-- ---=-
http://arcgraph.de/sr/


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
