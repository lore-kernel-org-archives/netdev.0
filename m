From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v4 net-next 03/27] net: add RCU variant to search for netdev_adjacent link
Date: Tue, 24 Sep 2013 13:46:43 +0200
Message-ID: <1380023227-9576-4-git-send-email-vfalico@redhat.com>
References: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37303 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751038Ab3IXLrA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 07:47:00 -0400
In-Reply-To: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we have only the RTNL flavour, however we can traverse it while
holding only RCU, so add the RCU search. Add an RCU variant that uses
list_head * as an argument, so that it can be universally used afterwards.

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Cong Wang <amwang@redhat.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v3  -> v4:
    Use the list argument, instead of bool upper.
    
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

 net/core/dev.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 9a395e0..9290f09 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4380,6 +4380,19 @@ struct netdev_adjacent {
 	struct rcu_head rcu;
 };
 
+static struct netdev_adjacent *__netdev_find_adj_rcu(struct net_device *dev,
+						     struct net_device *adj_dev,
+						     struct list_head *adj_list)
+{
+	struct netdev_adjacent *adj;
+
+	list_for_each_entry_rcu(adj, adj_list, list) {
+		if (adj->dev == adj_dev)
+			return adj;
+	}
+	return NULL;
+}
+
 static struct netdev_adjacent *__netdev_find_adj(struct net_device *dev,
 						 struct net_device *adj_dev,
 						 struct list_head *adj_list)
-- 
1.8.4
