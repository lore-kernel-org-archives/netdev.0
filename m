From: Anjali Singhai Jain <anjali.singhai@intel.com>
Subject: [RFC PATCH v2 4/4] geneve: Add geneve_get_rx_port support
Date: Fri,  4 Dec 2015 00:19:04 -0800
Message-ID: <1449217144-18756-5-git-send-email-anjali.singhai@intel.com>
References: <1449217144-18756-1-git-send-email-anjali.singhai@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:45409 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755334AbbLDIBx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 03:01:53 -0500
In-Reply-To: <1449217144-18756-1-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds an op that the drivers can call into to get existing
geneve ports.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c |  3 +++
 drivers/net/geneve.c                        | 24 ++++++++++++++++++++++++
 include/net/geneve.h                        |  8 ++++++++
 3 files changed, 35 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ea7e6ac..a55493b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5300,6 +5300,9 @@ int i40e_open(struct net_device *netdev)
 #ifdef CONFIG_I40E_VXLAN
 	vxlan_get_rx_port(netdev);
 #endif
+#ifdef CONFIG_I40E_GENEVE
+	geneve_get_rx_port(netdev);
+#endif
 
 	return 0;
 }
diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index b43fd56..bcf2be0 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1090,6 +1090,30 @@ static struct device_type geneve_type = {
 	.name = "geneve",
 };
 
+/* Calls the ndo_add_geneve_port of the caller in order to
+ * supply the listening GENEVE udp ports. Callers are expected
+ * to implement the ndo_add_geneve_port.
+ */
+void geneve_get_rx_port(struct net_device *dev)
+{
+	struct net *net = dev_net(dev);
+	struct geneve_net *gn = net_generic(net, geneve_net_id);
+	struct geneve_sock *gs;
+	sa_family_t sa_family;
+	struct sock *sk;
+	__be16 port;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(gs, &gn->sock_list, list) {
+		sk = gs->sock->sk;
+		sa_family = sk->sk_family;
+		port = inet_sk(sk)->inet_sport;
+		dev->netdev_ops->ndo_add_geneve_port(dev, sa_family, port);
+	}
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL_GPL(geneve_get_rx_port);
+
 /* Initialize the device structure. */
 static void geneve_setup(struct net_device *dev)
 {
diff --git a/include/net/geneve.h b/include/net/geneve.h
index 3106ed6..e6c23dc 100644
--- a/include/net/geneve.h
+++ b/include/net/geneve.h
@@ -62,6 +62,14 @@ struct genevehdr {
 	struct geneve_opt options[];
 };
 
+#if IS_ENABLED(CONFIG_GENEVE)
+void geneve_get_rx_port(struct net_device *netdev);
+#else
+static inline void geneve_get_rx_port(struct net_device *netdev)
+{
+}
+#endif
+
 #ifdef CONFIG_INET
 struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 					u8 name_assign_type, u16 dst_port);
-- 
1.8.1.4
