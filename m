From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v3 net-next 02/27] net: add RCU variant to search for netdev_adjacent link
Date: Tue, 17 Sep 2013 02:46:27 +0200
Message-ID: <1379378812-18346-3-git-send-email-vfalico@redhat.com>
References: <1379378812-18346-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26845 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751416Ab3IQAqy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Sep 2013 20:46:54 -0400
In-Reply-To: <1379378812-18346-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we have only the RTNL flavour, however we can traverse it while
holding only RCU, so add the RCU search. Add only one function that will be
used further, other functions can be added easily afterwards, if anyone
would need them.

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Cong Wang <amwang@redhat.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v2  -> v3:
    No change.
    
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    rename neighbour_dev_list/all_dev_list to adj_list/all_adj_list and rework
    the naming of functions - to make the use the pattern
    netdev_(all_)(lower|upper)_* . Uninline functions to get better stack
    traces - inline doesn't give much speed improvement, but this way the stack
    traces are meaningful. Remove the unused (through the whole patchset)
    functions - they can easily be added afterwards.

 net/core/dev.c | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index f69a8ab..75eabef 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4380,6 +4380,33 @@ struct netdev_adjacent {
 	struct rcu_head rcu;
 };
 
+static struct netdev_adjacent *__netdev_find_adj_rcu(struct net_device *dev,
+						     struct net_device *adj_dev,
+						     bool upper, bool neighbour)
+{
+	struct netdev_adjacent *adj;
+	struct list_head *adj_list;
+
+	if (neighbour)
+		adj_list = upper ? &dev->adj_list.upper :
+				   &dev->adj_list.lower;
+	else
+		adj_list = upper ? &dev->all_adj_list.upper :
+				   &dev->all_adj_list.lower;
+
+	list_for_each_entry_rcu(adj, adj_list, list) {
+		if (adj->dev == adj_dev)
+			return adj;
+	}
+	return NULL;
+}
+
+static struct netdev_adjacent *__netdev_lower_find_rcu(struct net_device *dev,
+							struct net_device *ldev)
+{
+	return __netdev_find_adj_rcu(dev, ldev, false, true);
+}
+
 static struct netdev_adjacent *__netdev_find_adj(struct net_device *dev,
 						 struct net_device *adj_dev,
 						 bool upper, bool neighbour)
-- 
1.8.4
