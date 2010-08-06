From: xiaohui.xin@intel.com
Subject: [RFC PATCH v9 04/16] Add a function make external buffer owner to query capability.
Date: Fri,  6 Aug 2010 17:23:32 +0800
Message-ID: <1281086624-5765-5-git-send-email-xiaohui.xin@intel.com>
References: <1281086624-5765-1-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-2-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-3-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-4-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1281086624-5765-4-git-send-email-xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

    The external buffer owner can use the functions to get
    the capability of the underlying NIC driver.

    Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
    Signed-off-by: Zhao Yu <yzhaonew@gmail.com>
    Reviewed-by: Jeff Dike <jdike@linux.intel.com>

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
1.5.4.4
