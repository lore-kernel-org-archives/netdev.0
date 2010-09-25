From: xiaohui.xin@intel.com
Subject: [PATCH v11 04/17]Add a function make external buffer owner to query capability.
Date: Sat, 25 Sep 2010 12:27:22 +0800
Message-ID: <6df1b1c2d2ffe70da911984c7fe6fab16f23043b.1285385607.git.xiaohui.xin@intel.com>
References: <1285388855-27410-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	herbert@gondor.hengli.com.au, jdike@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27792 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751431Ab0IYEKp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Sep 2010 00:10:45 -0400
In-Reply-To: <1285388855-27410-1-git-send-email-xiaohui.xin@intel.com>
In-Reply-To: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285385607.git.xiaohui.xin@intel.com>
References: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285385607.git.xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Xiaohui <xiaohui.xin@intel.com>

The external buffer owner can use the functions to get
the capability of the underlying NIC driver.

---
 include/linux/netdevice.h |    2 +
 net/core/dev.c            |   49 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 51 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index aba0308..5f192de 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1599,6 +1599,8 @@ extern gro_result_t	napi_frags_finish(struct napi_struct *napi,
 					  gro_result_t ret);
 extern struct sk_buff *	napi_frags_skb(struct napi_struct *napi);
 extern gro_result_t	napi_gro_frags(struct napi_struct *napi);
+extern int netdev_mp_port_prep(struct net_device *dev,
+				struct mpassthru_port *port);
 
 static inline void napi_free_frags(struct napi_struct *napi)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index 264137f..636f11b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2468,6 +2468,55 @@ void netif_nit_deliver(struct sk_buff *skb)
 	rcu_read_unlock();
 }
 
+/* To support meidate passthru(zero-copy) with NIC driver,
+ * we'd better query NIC driver for the capability it can
+ * provide, especially for packet split mode, now we only
+ * query for the header size, and the payload a descriptor
+ * may carry. If a driver does not use the API to export,
+ * then we may try to use a default value, currently,
+ * we use the default value from an IGB driver. Now,
+ * it's only called by mpassthru device.
+ */
+#if defined(CONFIG_MEDIATE_PASSTHRU) || defined(CONFIG_MEDIATE_PASSTHRU_MODULE)
+int netdev_mp_port_prep(struct net_device *dev,
+		struct mpassthru_port *port)
+{
+	int rc;
+	int npages, data_len;
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (ops->ndo_mp_port_prep) {
+		rc = ops->ndo_mp_port_prep(dev, port);
+		if (rc)
+			return rc;
+	} else {
+		/* If the NIC driver did not report this,
+		 * then we try to use default value.
+		 */
+		port->hdr_len = 128;
+		port->data_len = 2048;
+		port->npages = 1;
+	}
+
+	if (port->hdr_len <= 0)
+		goto err;
+
+	npages = port->npages;
+	data_len = port->data_len;
+	if (npages <= 0 || npages > MAX_SKB_FRAGS ||
+			(data_len < PAGE_SIZE * (npages - 1) ||
+			 data_len > PAGE_SIZE * npages))
+		goto err;
+
+	return 0;
+err:
+	dev_warn(&dev->dev, "invalid page constructor parameters\n");
+
+	return -EINVAL;
+}
+EXPORT_SYMBOL(netdev_mp_port_prep);
+#endif
+
 /**
  *	netif_receive_skb - process receive buffer from network
  *	@skb: buffer to process
-- 
1.7.3

