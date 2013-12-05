From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net/stable] br: fix use of ->rx_handler_data in code executed on non-rx_handler path
Date: Thu,  5 Dec 2013 15:50:25 +0100
Message-ID: <1386255025-23823-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jtluka@redhat.com, zhiguohong@tencent.com,
	bridge@lists.linux-foundation.org, stephen@networkplumber.org,
	edumazet@google.com, laine@redhat.com, mst@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:61625 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756754Ab3LEOu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 09:50:28 -0500
Received: by mail-ee0-f49.google.com with SMTP id c41so3164665eek.36
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 06:50:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

br_stp_rcv() is reached by non-rx_handler path. That means there is no
guarantee that dev is bridge port and therefore simple NULL check of
->rx_handler_data is not enough. There is need to check if dev is really
bridge port and since only rcu read lock is held here, do it by checking
->rx_handler pointer.

Note that synchronize_net() in netdev_rx_handler_unregister() ensures
this approach as valid.

Introduced originally by:
commit f350a0a87374418635689471606454abc7beaa3a
  "bridge: use rx_handler_data pointer to store net_bridge_port pointer"

Fixed but not in the best way by:
commit b5ed54e94d324f17c97852296d61a143f01b227a
  "bridge: fix RCU races with bridge port"

Reintroduced by:
commit 716ec052d2280d511e10e90ad54a86f5b5d4dcc2
  "bridge: fix NULL pointer deref of br_port_get_rcu"

Please apply to stable trees as well. Thanks.

Reported-by: Laine Stump <laine@redhat.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/bridge/br_private.h  | 12 ++++++++++++
 net/bridge/br_stp_bpdu.c |  2 +-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 229d820..67a2d4b 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -204,6 +204,13 @@ static inline struct net_bridge_port *br_port_get_rcu(const struct net_device *d
 	return rcu_dereference(dev->rx_handler_data);
 }
 
+static inline bool br_rx_handler_check_rcu(const struct net_device *dev);
+
+static inline struct net_bridge_port *br_port_get_check_rcu(const struct net_device *dev)
+{
+	return br_rx_handler_check_rcu(dev) ? br_port_get_rcu(dev) : NULL;
+}
+
 static inline struct net_bridge_port *br_port_get_rtnl(const struct net_device *dev)
 {
 	return br_port_exists(dev) ?
@@ -426,6 +433,11 @@ netdev_features_t br_features_recompute(struct net_bridge *br,
 int br_handle_frame_finish(struct sk_buff *skb);
 rx_handler_result_t br_handle_frame(struct sk_buff **pskb);
 
+static inline bool br_rx_handler_check_rcu(const struct net_device *dev)
+{
+	return rcu_dereference(dev->rx_handler) == br_handle_frame;
+}
+
 /* br_ioctl.c */
 int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 int br_ioctl_deviceless_stub(struct net *net, unsigned int cmd,
diff --git a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
index 8660ea3..bdb459d 100644
--- a/net/bridge/br_stp_bpdu.c
+++ b/net/bridge/br_stp_bpdu.c
@@ -153,7 +153,7 @@ void br_stp_rcv(const struct stp_proto *proto, struct sk_buff *skb,
 	if (buf[0] != 0 || buf[1] != 0 || buf[2] != 0)
 		goto err;
 
-	p = br_port_get_rcu(dev);
+	p = br_port_get_check_rcu(dev);
 	if (!p)
 		goto err;
 
-- 
1.8.3.1
