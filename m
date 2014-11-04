From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 08/14] openvswitch: Refactor get_dp() function into multiple access APIs.
Date: Mon,  3 Nov 2014 22:01:42 -0800
Message-ID: <1415080902-1866-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog013.obsmtp.com ([74.125.150.66]:50197 "HELO
	na6sys009bog013.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752091AbaKEUBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 15:01:55 -0500
Received: by mail-pd0-f169.google.com with SMTP id y10so1376689pdj.14
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 12:01:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>

Avoid recursive read_rcu_lock() by using the lighter weight
get_dp_rcu() API. Add proper locking assertions to get_dp().

Signed-off-by: Andy Zhou <azhou@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/datapath.c | 31 +++++++++++++++++++++----------
 1 file changed, 21 insertions(+), 10 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index bbb920b..cdbc44c 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -140,19 +140,30 @@ static int queue_gso_packets(struct datapath *dp, struct sk_buff *,
 static int queue_userspace_packet(struct datapath *dp, struct sk_buff *,
 				  const struct dp_upcall_info *);
 
-/* Must be called with rcu_read_lock or ovs_mutex. */
-static struct datapath *get_dp(struct net *net, int dp_ifindex)
+/* Must be called with rcu_read_lock. */
+static struct datapath *get_dp_rcu(struct net *net, int dp_ifindex)
 {
-	struct datapath *dp = NULL;
-	struct net_device *dev;
+	struct net_device *dev = dev_get_by_index_rcu(net, dp_ifindex);
 
-	rcu_read_lock();
-	dev = dev_get_by_index_rcu(net, dp_ifindex);
 	if (dev) {
 		struct vport *vport = ovs_internal_dev_get_vport(dev);
 		if (vport)
-			dp = vport->dp;
+			return vport->dp;
 	}
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
 	rcu_read_unlock();
 
 	return dp;
@@ -573,7 +584,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	packet->mark = flow->key.phy.skb_mark;
 
 	rcu_read_lock();
-	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
+	dp = get_dp_rcu(sock_net(skb->sk), ovs_header->dp_ifindex);
 	err = -ENODEV;
 	if (!dp)
 		goto err_unlock;
@@ -1227,7 +1238,7 @@ static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	struct datapath *dp;
 
 	rcu_read_lock();
-	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
+	dp = get_dp_rcu(sock_net(skb->sk), ovs_header->dp_ifindex);
 	if (!dp) {
 		rcu_read_unlock();
 		return -ENODEV;
@@ -1989,7 +2000,7 @@ static int ovs_vport_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	int i, j = 0;
 
 	rcu_read_lock();
-	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
+	dp = get_dp_rcu(sock_net(skb->sk), ovs_header->dp_ifindex);
 	if (!dp) {
 		rcu_read_unlock();
 		return -ENODEV;
-- 
1.9.3
