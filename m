From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 01/16] batman-adv: Handle parent interfaces
	in a different netns
Date: Tue, 16 Aug 2016 10:32:29 +0200
Message-ID: <1471336364-16334-2-git-send-email-sw@simonwunderlich.de>
References: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1471336364-16334-1-git-send-email-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>

batman-adv tries to prevent the user from placing a batX soft
interface into another batman mesh as a hard interface. It does this
by walking up the devices list of parents and ensures they are all
none batX interfaces. iflink can point to an interface in a different
namespace, so also retrieve the parents name space when finding the
parent and use it when doing the comparison.

Signed-off-by: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
[sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org: Fix alignments, simplify parent netns retrieval]
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
---
 net/batman-adv/hard-interface.c | 50 +++++++++++++++++++++++++++++++++++------
 1 file changed, 43 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 714af8e..43c9a3e 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -35,6 +35,8 @@
 #include <linux/rtnetlink.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
+#include <net/net_namespace.h>
+#include <net/rtnetlink.h>
 
 #include "bat_v.h"
 #include "bridge_loop_avoidance.h"
@@ -84,25 +86,55 @@ out:
 }
 
 /**
+ * batadv_getlink_net - return link net namespace (of use fallback)
+ * @netdev: net_device to check
+ * @fallback_net: return in case get_link_net is not available for @netdev
+ *
+ * Return: result of rtnl_link_ops->get_link_net or @fallback_net
+ */
+static const struct net *batadv_getlink_net(const struct net_device *netdev,
+					    const struct net *fallback_net)
+{
+	if (!netdev->rtnl_link_ops)
+		return fallback_net;
+
+	if (!netdev->rtnl_link_ops->get_link_net)
+		return fallback_net;
+
+	return netdev->rtnl_link_ops->get_link_net(netdev);
+}
+
+/**
  * batadv_mutual_parents - check if two devices are each others parent
- * @dev1: 1st net_device
- * @dev2: 2nd net_device
+ * @dev1: 1st net dev
+ * @net1: 1st devices netns
+ * @dev2: 2nd net dev
+ * @net2: 2nd devices netns
  *
  * veth devices come in pairs and each is the parent of the other!
  *
  * Return: true if the devices are each others parent, otherwise false
  */
 static bool batadv_mutual_parents(const struct net_device *dev1,
-				  const struct net_device *dev2)
+				  const struct net *net1,
+				  const struct net_device *dev2,
+				  const struct net *net2)
 {
 	int dev1_parent_iflink = dev_get_iflink(dev1);
 	int dev2_parent_iflink = dev_get_iflink(dev2);
+	const struct net *dev1_parent_net;
+	const struct net *dev2_parent_net;
+
+	dev1_parent_net = batadv_getlink_net(dev1, net1);
+	dev2_parent_net = batadv_getlink_net(dev2, net2);
 
 	if (!dev1_parent_iflink || !dev2_parent_iflink)
 		return false;
 
 	return (dev1_parent_iflink == dev2->ifindex) &&
-	       (dev2_parent_iflink == dev1->ifindex);
+	       (dev2_parent_iflink == dev1->ifindex) &&
+	       net_eq(dev1_parent_net, net2) &&
+	       net_eq(dev2_parent_net, net1);
 }
 
 /**
@@ -120,8 +152,9 @@ static bool batadv_mutual_parents(const struct net_device *dev1,
  */
 static bool batadv_is_on_batman_iface(const struct net_device *net_dev)
 {
-	struct net_device *parent_dev;
 	struct net *net = dev_net(net_dev);
+	struct net_device *parent_dev;
+	const struct net *parent_net;
 	bool ret;
 
 	/* check if this is a batman-adv mesh interface */
@@ -133,13 +166,16 @@ static bool batadv_is_on_batman_iface(const struct net_device *net_dev)
 	    dev_get_iflink(net_dev) == net_dev->ifindex)
 		return false;
 
+	parent_net = batadv_getlink_net(net_dev, net);
+
 	/* recurse over the parent device */
-	parent_dev = __dev_get_by_index(net, dev_get_iflink(net_dev));
+	parent_dev = __dev_get_by_index((struct net *)parent_net,
+					dev_get_iflink(net_dev));
 	/* if we got a NULL parent_dev there is something broken.. */
 	if (WARN(!parent_dev, "Cannot find parent device"))
 		return false;
 
-	if (batadv_mutual_parents(net_dev, parent_dev))
+	if (batadv_mutual_parents(net_dev, net, parent_dev, parent_net))
 		return false;
 
 	ret = batadv_is_on_batman_iface(parent_dev);
-- 
2.8.1
