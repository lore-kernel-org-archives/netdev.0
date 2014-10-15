From: Pan Jiafei <Jiafei.Pan@freescale.com>
Subject: [PATCH] net: use hardware buffer pool to allocate skb
Date: Wed, 15 Oct 2014 11:26:11 +0800
Message-ID: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Jiafei.Pan@freescale.com>,
	<LeoLi@freescale.com>, <linux-doc@vger.kernel.org>
To: <davem@davemloft.net>, <jkosina@suse.cz>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In some platform, there are some hardware block provided
to manage buffers to improve performance. So in some case,
it is expected that the packets received by some generic
NIC should be put into such hardware managed buffers
directly, so that such buffer can be released by hardware
or by driver.

This patch provide such general APIs for generic NIC to
use hardware block managed buffers without any modification
for generic NIC drivers.
In this patch, the following fields are added to "net_device":
    void *hw_skb_priv;
    struct sk_buff *(*alloc_hw_skb)(void *hw_skb_priv, unsigned int length);
    void (*free_hw_skb)(struct sk_buff *skb);
so in order to let generic NIC driver to use hardware managed
buffers, the function "alloc_hw_skb" and "free_hw_skb"
provide implementation for allocate and free hardware managed
buffers. "hw_skb_priv" is provided to pass some private data for
these two functions.

When the socket buffer is allocated by these APIs, "hw_skb_state"
is provided in struct "sk_buff". this argument can indicate
that the buffer is hardware managed buffer, this buffer
should freed by software or by hardware.

Documentation on how to use this featue can be found at
<file:Documentation/networking/hw_skb.txt>.

Signed-off-by: Pan Jiafei <Jiafei.Pan@freescale.com>
---
 Documentation/networking/hw_skb.txt | 117 ++++++++++++++++++++++++++++++++++++
 include/linux/netdevice.h           |   5 ++
 include/linux/skbuff.h              |  16 +++++
 net/Kconfig                         |  10 +++
 net/core/skbuff.c                   |  28 +++++++++
 5 files changed, 176 insertions(+)
 create mode 100644 Documentation/networking/hw_skb.txt

diff --git a/Documentation/networking/hw_skb.txt b/Documentation/networking/hw_skb.txt
new file mode 100644
index 0000000..256f3fc
--- /dev/null
+++ b/Documentation/networking/hw_skb.txt
@@ -0,0 +1,117 @@
+Document for using hardware managed SKB.
+
+1. Description
+
+In some platform, there are some hardware block provided
+to manage buffers to improve performance. So in some case,
+it is expected that the packets received by some generic
+NIC should be put into such hardware managed buffers
+directly, so that such buffer can be released by hardware
+or by driver.
+
+2. Related Struct Definition
+
+Some general APIs are provided for generic NIC to use hardware
+block managed buffers without any modification for generic NIC
+drivers.
+
+1)Kernel Configuration Item
+
+	"CONFIG_USE_HW_SKB"
+
+2)The DEVICE structure
+
+	struct net_device {
+		...
+	#ifdef CONFIG_USE_HW_SKB
+		void *hw_skb_priv;
+		struct sk_buff *(*alloc_hw_skb)(void *hw_skb_priv, unsigned int length);
+		void (*free_hw_skb)(struct sk_buff *skb);
+	#endif
+		...
+	}
+
+"hw_skb_priv" is private data for "alloc_hw_skb" and "free_hw_skb" functions.
+"alloc_hw_skb" is for allocating skb by using hardware managed buffer.
+"free_hw_skb" is for freeing skb allocated by hardware manager buffer.
+
+3)struct sk_buff - socket buffer
+
+	struct sk_buff {
+		...
+	#ifdef CONFIG_SKB_USE_HW_BP
+		__u32 			hw_skb_state;
+		void			*hw_skb_priv;
+		void 			(*free_hw_skb)(struct sk_buff *skb);
+	#endif
+		...
+	}
+
+	/* hw_skb_state list */
+	enum hw_skb_state {
+		/* If set, SKB use hardware managed buffer */
+		IS_HW_SKB = 1 << 0,
+		/* If set, and skb can be freed by software by calling
+		 * netdev->free_hw_skb
+		 */
+		HW_SKB_SW_FREE = 1 << 1,
+	};
+
+"hw_skb_priv" and "free_hw_skb" are the same with the field in the
+struct "net_device"
+
+After calling "alloc_hw_skb" to allocate skb by using hardware managed
+buffers, "hw_skb_priv" and "free_hw_skb" is set in SKB driver:
+	skb->hw_skb_priv = dev->hw_skb_priv;
+	skb->free_hw_skb = dev->free_hw_skb;
+So that when "struct net_device	*dev" is changed after the skb is allocated,
+It is be confirmed that this skb can be freed by the method synced
+with allocation.
+
+"hw_skb_state" indicates that the state of SKB. When the skb is allocated
+by "alloc_hw_skb" function, the flag of "IS_HW_SKB" is set by
+"__netdev_alloc_skb" function in skbuff.c when returned from "alloc_hw_skb".
+But in "alloc_hw_skb", "HW_SKB_SW_FREE" must be set if the skb should be
+freed by calling "free_hw_skb", otherwise, the skb will never be freed by
+any driver until it is freed by hardware block.
+
+SKB using hardware managed buffer is not recycleable.
+
+3. How to use this feature
+
+For example, driver "A" wants the third-party NIC driver "B" to
+store the data in some hardware managed buffer then send to "A".
+
+1) Select "CONFIG_USE_HW_SKB" to enable this feature.
+
+2) In driver "A", implement the function "alloc_hw_skb" and
+"free_hw_skb". For example:
+
+struct sk_buff *alloc_hw_skb(void *priv, unsigned int length)
+{
+	buf = alloc_hw_buffer();
+	skb = build_skb(buf, ...);
+	if (skb)
+		skb->hw_skb_state |= HW_SKB_SW_FREE;
+
+	return skb;
+}
+
+void free_hw_skb(struct sk_buff *skb)
+{
+	free_hw_buffer(skb->head);
+}
+
+3) In driver "A", get "net_device" handle of net device case using
+driver "B".
+	...
+	net_dev_b->hw_skb_priv = priv;
+	net_dev_b->alloc_hw_skb = alloc_hw_skb;
+	net_dev_b->free_hw_skb = free_hw_skb;
+	...
+
+4) Then, when driver "B" wants to allocate skb, "alloc_hw_skb"
+will be called to allocate hardware manager skb firstly, if
+failed, the normal skb will also be allocate, if successed,
+the skb will be freed by calling free_hw_skb when "kfree_skb"
+is called to free this skb.
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 838407a..42b6158 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1689,6 +1689,11 @@ struct net_device {
 	struct lock_class_key *qdisc_tx_busylock;
 	int group;
 	struct pm_qos_request	pm_qos_req;
+#ifdef CONFIG_USE_HW_SKB
+	void *hw_skb_priv;
+	struct sk_buff *(*alloc_hw_skb)(void *hw_skb_priv, unsigned int length);
+	void (*free_hw_skb)(struct sk_buff *skb);
+#endif
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 776104b..d9afdeb 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -436,6 +436,16 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
 }
 
 
+/* hw_skb_state list */
+enum hw_skb_state {
+	/* If set, SKB use hardware managed buffer */
+	IS_HW_SKB = 1 << 0,
+	/* If set, and skb can be freed by software by calling
+	 * netdev->free_hw_skb
+	 */
+	HW_SKB_SW_FREE = 1 << 1,
+};
+
 /** 
  *	struct sk_buff - socket buffer
  *	@next: Next buffer in list
@@ -646,6 +656,12 @@ struct sk_buff {
 	__u16			network_header;
 	__u16			mac_header;
 
+#ifdef CONFIG_USE_HW_SKB
+	__u32			hw_skb_state;
+	void			*hw_skb_priv;
+	void			(*free_hw_skb)(struct sk_buff *skb);
+#endif
+
 	__u32			headers_end[0];
 
 	/* These elements must be at the end, see alloc_skb() for details.  */
diff --git a/net/Kconfig b/net/Kconfig
index d6b138e..346e021 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -291,6 +291,16 @@ config NET_FLOW_LIMIT
 	  with many clients some protection against DoS by a single (spoofed)
 	  flow that greatly exceeds average workload.
 
+config USE_HW_SKB
+	bool "NIC use hardware managed buffer to build skb"
+	depends on INET
+	---help---
+	  If select this, the third party drivers will use hardware managed
+	  buffers to allocate SKB without any modification for the driver.
+
+	  Documentation on how to use this featue can be found at
+	  <file:Documentation/networking/hw_skb.txt>.
+
 menu "Network testing"
 
 config NET_PKTGEN
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7b3df0d..f8603e5 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -415,6 +415,19 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 	unsigned int fragsz = SKB_DATA_ALIGN(length + NET_SKB_PAD) +
 			      SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 
+#ifdef CONFIG_USE_HW_SKB
+	if (dev->alloc_hw_skb) {
+		skb = dev->alloc_hw_skb(dev->hw_skb_priv, length);
+		if (likely(skb)) {
+			skb->hw_skb_state |= IS_HW_SKB;
+			skb->hw_skb_priv = dev->hw_skb_priv;
+			skb->free_hw_skb = dev->free_hw_skb;
+			skb_reserve(skb, NET_SKB_PAD);
+			skb->dev = dev;
+			return skb;
+		}
+	}
+#endif
 	if (fragsz <= PAGE_SIZE && !(gfp_mask & (__GFP_WAIT | GFP_DMA))) {
 		void *data;
 
@@ -432,6 +445,7 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 		skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask,
 				  SKB_ALLOC_RX, NUMA_NO_NODE);
 	}
+
 	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
 		skb->dev = dev;
@@ -483,6 +497,15 @@ static void skb_clone_fraglist(struct sk_buff *skb)
 
 static void skb_free_head(struct sk_buff *skb)
 {
+#ifdef CONFIG_USE_HW_SKB
+	if (skb->hw_skb_state & IS_HW_SKB) {
+		if (skb->hw_skb_state & HW_SKB_SW_FREE) {
+			BUG_ON(!skb->free_hw_skb);
+			skb->free_hw_skb(skb);
+		}
+		return;
+	}
+#endif
 	if (skb->head_frag)
 		put_page(virt_to_head_page(skb->head));
 	else
@@ -506,6 +529,10 @@ static void skb_release_data(struct sk_buff *skb)
 	 * If skb buf is from userspace, we need to notify the caller
 	 * the lower device DMA has done;
 	 */
+#ifdef CONFIG_USE_HW_SKB
+	if (skb->hw_skb_state & IS_HW_SKB)
+		goto skip_callback;
+#endif
 	if (shinfo->tx_flags & SKBTX_DEV_ZEROCOPY) {
 		struct ubuf_info *uarg;
 
@@ -514,6 +541,7 @@ static void skb_release_data(struct sk_buff *skb)
 			uarg->callback(uarg, true);
 	}
 
+skip_callback:
 	if (shinfo->frag_list)
 		kfree_skb_list(shinfo->frag_list);
 
-- 
2.1.0.27.g96db324

