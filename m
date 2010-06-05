From: xiaohui.xin@intel.com
Subject: [RFC PATCH v7 03/19] Export 2 func for device to assign/deassign new strucure
Date: Sat,  5 Jun 2010 18:14:42 +0800
Message-ID: <1275732899-5423-3-git-send-email-xiaohui.xin@intel.com>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-2-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1275732899-5423-2-git-send-email-xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 include/linux/netdevice.h |    3 +++
 net/core/dev.c            |   28 ++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index bae725c..efb575a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1592,6 +1592,9 @@ extern gro_result_t	napi_frags_finish(struct napi_struct *napi,
 					  gro_result_t ret);
 extern struct sk_buff *	napi_frags_skb(struct napi_struct *napi);
 extern gro_result_t	napi_gro_frags(struct napi_struct *napi);
+extern int netdev_mp_port_attach(struct net_device *dev,
+				 struct mpassthru_port *port);
+extern void netdev_mp_port_detach(struct net_device *dev);
 
 static inline void napi_free_frags(struct napi_struct *napi)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index f769098..ecbb6b1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2469,6 +2469,34 @@ void netif_nit_deliver(struct sk_buff *skb)
 	rcu_read_unlock();
 }
 
+/* Export two functions to assign/de-assign mp_port pointer
+ * to a net device.
+ */
+
+int netdev_mp_port_attach(struct net_device *dev,
+			struct mpassthru_port *port)
+{
+	/* locked by mp_mutex */
+	if (rcu_dereference(dev->mp_port))
+		return -EBUSY;
+
+	rcu_assign_pointer(dev->mp_port, port);
+
+	return 0;
+}
+EXPORT_SYMBOL(netdev_mp_port_attach);
+
+void netdev_mp_port_detach(struct net_device *dev)
+{
+	/* locked by mp_mutex */
+	if (!rcu_dereference(dev->mp_port))
+		return;
+
+	rcu_assign_pointer(dev->mp_port, NULL);
+	synchronize_rcu();
+}
+EXPORT_SYMBOL(netdev_mp_port_detach);
+
 /**
  *	netif_receive_skb - process receive buffer from network
  *	@skb: buffer to process
-- 
1.5.4.4
