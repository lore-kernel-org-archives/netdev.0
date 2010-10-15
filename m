From: xiaohui.xin@intel.com
Subject: [PATCH v13 10/16] Add a hook to intercept external buffers from NIC driver.
Date: Fri, 15 Oct 2010 17:12:11 +0800
Message-ID: <33f51c5eddec843260451eccbfa3c5fdea13b479.1287132437.git.xiaohui.xin@intel.com>
References: <1287133937-5538-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60392 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754659Ab0JOIxB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 04:53:01 -0400
In-Reply-To: <1287133937-5538-1-git-send-email-xiaohui.xin@intel.com>
In-Reply-To: <fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1287132437.git.xiaohui.xin@intel.com>
References: <fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1287132437.git.xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Xiaohui <xiaohui.xin@intel.com>

The hook is called in __netif_receive_skb().

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 net/core/dev.c |   37 +++++++++++++++++++++++++++++++++++++
 1 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index e48639d..235eaab 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2814,6 +2814,37 @@ int __skb_bond_should_drop(struct sk_buff *skb, struct net_device *master)
 }
 EXPORT_SYMBOL(__skb_bond_should_drop);
 
+#if defined(CONFIG_MEDIATE_PASSTHRU) || defined(CONFIG_MEDIATE_PASSTHRU_MODULE)
+/* Add a hook to intercept mediate passthru(zero-copy) packets,
+ * and insert it to the socket queue owned by mp_port specially.
+ */
+static inline struct sk_buff *handle_mpassthru(struct sk_buff *skb,
+					       struct packet_type **pt_prev,
+					       int *ret,
+					       struct net_device *orig_dev)
+{
+	struct mp_port *mp_port = NULL;
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
 static int __netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
@@ -2891,6 +2922,11 @@ static int __netif_receive_skb(struct sk_buff *skb)
 ncls:
 #endif
 
+	/* To intercept mediate passthru(zero-copy) packets here */
+	skb = handle_mpassthru(skb, &pt_prev, &ret, orig_dev);
+	if (!skb)
+		goto out;
+
 	/* Handle special case of bridge or macvlan */
 	rx_handler = rcu_dereference(skb->dev->rx_handler);
 	if (rx_handler) {
@@ -2991,6 +3027,7 @@ err:
 EXPORT_SYMBOL(netdev_mp_port_prep);
 #endif
 
+
 /**
  *	netif_receive_skb - process receive buffer from network
  *	@skb: buffer to process
-- 
1.7.3

