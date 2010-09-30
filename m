From: xiaohui.xin@intel.com
Subject: [PATCH v12 02/17] Add a new struct for device to manipulate external buffer.
Date: Thu, 30 Sep 2010 22:04:19 +0800
Message-ID: <f66051069519bbf129b2712db52c27f243a6b971.1285853725.git.xiaohui.xin@intel.com>
References: <1285855474-12110-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285855474-12110-1-git-send-email-xiaohui.xin@intel.com>
In-Reply-To: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285853725.git.xiaohui.xin@intel.com>
References: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285853725.git.xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

Add a structure in structure net_device, the new field is
named as mp_port. It's for mediate passthru (zero-copy).
It contains the capability for the net device driver,
a socket, and an external buffer creator, external means
skb buffer belongs to the device may not be allocated from
kernel space.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 include/linux/netdevice.h |   25 ++++++++++++++++++++++++-
 1 files changed, 24 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index fa8b476..9ef9bf1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -530,6 +530,28 @@ struct netdev_queue {
 	unsigned long		tx_dropped;
 } ____cacheline_aligned_in_smp;
 
+/*The structure for mediate passthru(zero-copy). */
+struct mp_port	{
+	/* the header len */
+	int		hdr_len;
+	/* the max payload len for one descriptor */
+	int		data_len;
+	/* the pages for DMA in one time */
+	int		npages;
+	/* the socket bind to */
+	struct socket	*sock;
+	/* the header len for virtio-net */
+	int		vnet_hlen;
+	/* the external buffer page creator */
+	struct skb_ext_page *(*ctor)(struct mp_port *,
+				struct sk_buff *, int);
+	/* the hash function attached to find according
+	 * backend ring descriptor info for one external
+	 * buffer page.
+	 */
+	struct skb_ext_page *(*hash)(struct net_device *,
+				struct page *);
+};
 
 /*
  * This structure defines the management hooks for network devices.
@@ -952,7 +974,8 @@ struct net_device {
 	struct macvlan_port	*macvlan_port;
 	/* GARP */
 	struct garp_port	*garp_port;
-
+	/* mpassthru */
+	struct mp_port		*mp_port;
 	/* class/net/name entry */
 	struct device		dev;
 	/* space for optional device, statistics, and wireless sysfs groups */
-- 
1.7.3
