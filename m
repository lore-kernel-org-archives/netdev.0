From: xiaohui.xin@intel.com
Subject: [RFC PATCH v7 12/19] Add a hook to intercept external buffers from NIC driver.
Date: Sat,  5 Jun 2010 18:14:51 +0800
Message-ID: <1275732899-5423-12-git-send-email-xiaohui.xin@intel.com>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-2-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-3-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-4-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-5-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-6-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-7-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-8-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-9-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-10-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-11-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1275732899-5423-11-git-send-email-xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

The hook is called in netif_receive_skb().
Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 net/core/dev.c |   35 +++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 37b389a..dc2f225 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2548,6 +2548,37 @@ err:
 EXPORT_SYMBOL(netdev_mp_port_prep);
 #endif
 
+#if defined(CONFIG_MEDIATE_PASSTHRU) || defined(CONFIG_MEDIATE_PASSTHRU_MODULE)
+/* Add a hook to intercept mediate passthru(zero-copy) packets,
+ * and insert it to the socket queue owned by mp_port specially.
+ */
+static inline struct sk_buff *handle_mpassthru(struct sk_buff *skb,
+					       struct packet_type **pt_prev,
+					       int *ret,
+					       struct net_device *orig_dev)
+{
+	struct mpassthru_port *mp_port = NULL;
+	struct sock *sk = NULL;
+
+	if (!dev_is_mpassthru(skb->dev))
+		return skb;
+	mp_port = skb->dev->mp_port;
+
+	if (*pt_prev) {
+		*ret = deliver_skb(skb, *pt_prev, orig_dev);
+		*pt_prev = NULL;
+	}
+
+	sk = mp_port->sock->sk;
+	skb_queue_tail(&sk->sk_receive_queue, skb);
+	sk->sk_state_change(sk);
+
+	return NULL;
+}
+#else
+#define handle_mpassthru(skb, pt_prev, ret, orig_dev)     (skb)
+#endif
+
 /**
  *	netif_receive_skb - process receive buffer from network
  *	@skb: buffer to process
@@ -2629,6 +2660,10 @@ int netif_receive_skb(struct sk_buff *skb)
 ncls:
 #endif
 
+	/* To intercept mediate passthru(zero-copy) packets here */
+	skb = handle_mpassthru(skb, &pt_prev, &ret, orig_dev);
+	if (!skb)
+		goto out;
 	skb = handle_bridge(skb, &pt_prev, &ret, orig_dev);
 	if (!skb)
 		goto out;
-- 
1.5.4.4
