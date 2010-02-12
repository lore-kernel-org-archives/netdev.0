From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/3] ethtool: Fix filter addition when caching
	n-tuple filters
Date: Fri, 12 Feb 2010 15:48:05 -0800
Message-ID: <20100212234715.2346.60380.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.emeryville.ca.mail.comcast.net ([76.96.27.227]:55685
	"EHLO qmta12.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753466Ab0BLXsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 18:48:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>

We can allow a filter to be added successfully to the underlying
hardware, but still return an error if the cached list memory
allocation fails.  This patch fixes that condition.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/core/ethtool.c |   40 ++++++++++++++++++++++++----------------
 1 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index a1280f6..fbbe4b4 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -283,18 +283,17 @@ err_out:
 	return ret;
 }
 
-static int __rx_ntuple_filter_add(struct ethtool_rx_ntuple_list *list,
-                                  struct ethtool_rx_ntuple_flow_spec *spec)
+static void __rx_ntuple_filter_add(struct ethtool_rx_ntuple_list *list,
+                              struct ethtool_rx_ntuple_flow_spec *spec,
+                              struct ethtool_rx_ntuple_flow_spec_container *fsc)
 {
-	struct ethtool_rx_ntuple_flow_spec_container *fsc;
 
 	/* don't add filters forever */
-	if (list->count >= ETHTOOL_MAX_NTUPLE_LIST_ENTRY)
-		return 0;
-
-	fsc = kmalloc(sizeof(*fsc), GFP_ATOMIC);
-	if (!fsc)
-		return -ENOMEM;
+	if (list->count >= ETHTOOL_MAX_NTUPLE_LIST_ENTRY) {
+		/* free the container */
+		kfree(fsc);
+		return;
+	}
 
 	/* Copy the whole filter over */
 	fsc->fs.flow_type = spec->flow_type;
@@ -310,14 +309,13 @@ static int __rx_ntuple_filter_add(struct ethtool_rx_ntuple_list *list,
 	/* add to the list */
 	list_add_tail_rcu(&fsc->list, &list->list);
 	list->count++;
-
-	return 0;
 }
 
 static int ethtool_set_rx_ntuple(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_rx_ntuple cmd;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
+	struct ethtool_rx_ntuple_flow_spec_container *fsc = NULL;
 	int ret;
 
 	if (!ops->set_rx_ntuple)
@@ -329,16 +327,26 @@ static int ethtool_set_rx_ntuple(struct net_device *dev, void __user *useraddr)
 	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
 		return -EFAULT;
 
-	ret = ops->set_rx_ntuple(dev, &cmd);
-
 	/*
 	 * Cache filter in dev struct for GET operation only if
 	 * the underlying driver doesn't have its own GET operation, and
-	 * only if the filter was added successfully.
+	 * only if the filter was added successfully.  First make sure we
+	 * can allocate the filter, then continue if successful.
 	 */
-	if (!ops->get_rx_ntuple && !ret)
-		if (__rx_ntuple_filter_add(&dev->ethtool_ntuple_list, &cmd.fs))
+	if (!ops->get_rx_ntuple) {
+		fsc = kmalloc(sizeof(*fsc), GFP_ATOMIC);
+		if (!fsc)
 			return -ENOMEM;
+	}
+
+	ret = ops->set_rx_ntuple(dev, &cmd);
+	if (ret) {
+		kfree(fsc);
+		return ret;
+	}
+
+	if (!ops->get_rx_ntuple)
+		__rx_ntuple_filter_add(&dev->ethtool_ntuple_list, &cmd.fs, fsc);
 
 	return ret;
 }

