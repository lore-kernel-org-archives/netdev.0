From: Andy Zhou <azhou@ovn.org>
Subject: [net-next v2 2/4] openvswitch: export get_dp() API.
Date: Tue, 17 Oct 2017 00:36:43 -0700
Message-ID: <1508225805-11613-3-git-send-email-azhou@ovn.org>
References: <1508225805-11613-1-git-send-email-azhou@ovn.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: pshelar@ovn.org, joe@ovn.org, gvrose8192@gmail.com,
        Andy Zhou <azhou@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:45150 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933907AbdJQHiG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 03:38:06 -0400
Received: by mail-pf0-f193.google.com with SMTP id d28so747773pfe.2
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 00:38:06 -0700 (PDT)
In-Reply-To: <1508225805-11613-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Later patches will invoke get_dp() outside of datapath.c. Export it.

Signed-off-by: Andy Zhou <azhou@ovn.org>
---
 net/openvswitch/datapath.c | 29 -----------------------------
 net/openvswitch/datapath.h | 31 +++++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+), 29 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index c3aec6227c91..ac7154018676 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -142,35 +142,6 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *,
 				  const struct dp_upcall_info *,
 				  uint32_t cutlen);
 
-/* Must be called with rcu_read_lock. */
-static struct datapath *get_dp_rcu(struct net *net, int dp_ifindex)
-{
-	struct net_device *dev = dev_get_by_index_rcu(net, dp_ifindex);
-
-	if (dev) {
-		struct vport *vport = ovs_internal_dev_get_vport(dev);
-		if (vport)
-			return vport->dp;
-	}
-
-	return NULL;
-}
-
-/* The caller must hold either ovs_mutex or rcu_read_lock to keep the
- * returned dp pointer valid.
- */
-static inline struct datapath *get_dp(struct net *net, int dp_ifindex)
-{
-	struct datapath *dp;
-
-	WARN_ON_ONCE(!rcu_read_lock_held() && !lockdep_ovsl_is_held());
-	rcu_read_lock();
-	dp = get_dp_rcu(net, dp_ifindex);
-	rcu_read_unlock();
-
-	return dp;
-}
-
 /* Must be called with rcu_read_lock or ovs_mutex. */
 const char *ovs_dp_name(const struct datapath *dp)
 {
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 480600649d0b..ad14b571219d 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -30,6 +30,7 @@
 #include "conntrack.h"
 #include "flow.h"
 #include "flow_table.h"
+#include "vport-internal_dev.h"
 
 #define DP_MAX_PORTS           USHRT_MAX
 #define DP_VPORT_HASH_BUCKETS  1024
@@ -190,6 +191,36 @@ static inline struct vport *ovs_vport_ovsl(const struct datapath *dp, int port_n
 	return ovs_lookup_vport(dp, port_no);
 }
 
+/* Must be called with rcu_read_lock. */
+static inline struct datapath *get_dp_rcu(struct net *net, int dp_ifindex)
+{
+	struct net_device *dev = dev_get_by_index_rcu(net, dp_ifindex);
+
+	if (dev) {
+		struct vport *vport = ovs_internal_dev_get_vport(dev);
+
+		if (vport)
+			return vport->dp;
+	}
+
+	return NULL;
+}
+
+/* The caller must hold either ovs_mutex or rcu_read_lock to keep the
+ * returned dp pointer valid.
+ */
+static inline struct datapath *get_dp(struct net *net, int dp_ifindex)
+{
+	struct datapath *dp;
+
+	WARN_ON_ONCE(!rcu_read_lock_held() && !lockdep_ovsl_is_held());
+	rcu_read_lock();
+	dp = get_dp_rcu(net, dp_ifindex);
+	rcu_read_unlock();
+
+	return dp;
+}
+
 extern struct notifier_block ovs_dp_device_notifier;
 extern struct genl_family dp_vport_genl_family;
 
-- 
1.8.3.1
