From: Yi-Hung Wei <yihung.wei@gmail.com>
Subject: [PATCH net] openvswitch: Fix ovs_flow_key_update()
Date: Wed, 29 Mar 2017 17:14:10 -0700
Message-ID: <1490832850-6012-1-git-send-email-yihung.wei@gmail.com>
Cc: Yi-Hung Wei <yihung.wei@gmail.com>, linux-kernel@vger.kernel.org
To: jbenc@redhat.com, joe@ovn.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ovs_flow_key_update() is called when the flow key is invalid, and it is
used to update and revalidate the flow key. Commit 329f45bc4f19
("openvswitch: add mac_proto field to the flow key") introduces mac_proto
field to flow key and use it to determine whether the flow key is valid.
However, the commit does not update the code path in ovs_flow_key_update()
to revalidate the flow key which may cause BUG_ON() on execute_recirc().
This patch addresses the aforementioned issue.

Fixes: 329f45bc4f19 ("openvswitch: add mac_proto field to the flow key")
Signed-off-by: Yi-Hung Wei <yihung.wei@gmail.com>
---
 net/openvswitch/flow.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 9d4bb8eb63f2..bb33f5341294 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -53,6 +53,8 @@
 #include "flow_netlink.h"
 #include "vport.h"
 
+static int key_extract_mac_proto(struct sk_buff *skb);
+
 u64 ovs_flow_used_time(unsigned long flow_jiffies)
 {
 	struct timespec cur_ts;
@@ -745,6 +747,13 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 
 int ovs_flow_key_update(struct sk_buff *skb, struct sw_flow_key *key)
 {
+	int res;
+
+	res = key_extract_mac_proto(skb);
+	if (res < 0)
+		return res;
+	key->mac_proto = res;
+
 	return key_extract(skb, key);
 }
 
-- 
2.7.4
