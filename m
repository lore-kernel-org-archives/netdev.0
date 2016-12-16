From: henrik@austad.us
Subject: [TSN RFC v2 3/9] TSN: Add the standard formerly known as AVB to the kernel
Date: Fri, 16 Dec 2016 18:59:07 +0100
Message-ID: <1481911153-549-4-git-send-email-henrik@austad.us>
References: <1481911153-549-1-git-send-email-henrik@austad.us>
Cc: Richard Cochran <richardcochran@gmail.com>, henrik@austad.us,
        linux-media@vger.kernel.org, alsa-devel@vger.kernel.org,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Henrik Austad <haustad@cisco.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <1481911153-549-1-git-send-email-henrik@austad.us>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Henrik Austad <henrik@austad.us>

TSN provides a mechanism to create reliable, jitter-free, low latency
guaranteed bandwidth links over a local network. It does this by
reserving a path through the network. Support for TSN must be found in
both the NIC as well as in the network itself.

This adds required hooks into netdev_ops so that the core TSN driver can
use this when configuring a new NIC or setting up a new link. It also
provides hook for removing a link and reducing the idle_slope parameter on
the NIC.

(We need to set the PCP values when we first configure the link. This
 value should not change as long as we have valid streams running, and in
 most cases, the PCP for the domain will not change.)

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Henrik Austad <haustad@cisco.com>
---
 include/linux/netdevice.h | 44 ++++++++++++++++++++++++++++++++++++++++++++
 net/Kconfig               |  1 +
 net/tsn/Kconfig           | 32 ++++++++++++++++++++++++++++++++
 3 files changed, 77 insertions(+)
 create mode 100644 net/tsn/Kconfig

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e16a2a9..0d758aa 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -112,6 +112,15 @@ enum netdev_tx {
 };
 typedef enum netdev_tx netdev_tx_t;
 
+#if IS_ENABLED(CONFIG_TSN)
+enum sr_class {
+	SR_CLASS_A = 1,
+	SR_CLASS_B = 2,
+	SR_CLASS_LAST,
+	SR_CLASS_ERR,
+};
+#endif
+
 /*
  * Current order: NETDEV_TX_MASK > NET_XMIT_MASK >= 0 is significant;
  * hard_start_xmit() return < NET_XMIT_MASK means skb was consumed.
@@ -944,6 +953,31 @@ struct netdev_xdp {
  *
  * void (*ndo_poll_controller)(struct net_device *dev);
  *
+ *	TSN functions (if CONFIG_TSN)
+ *
+ * int (*ndo_tsn_capable)(struct net_device *dev);
+ *	If a particular device is capable of sustaining TSN traffic
+ *	provided current configuration
+ *
+ * int (*ndo_tsn_link_configure)(struct net_device *dev,
+ *				 enum sr_class class,
+ *				 u16 framesize,
+ *				 u16 vid,
+ *				 u8 add_link,
+ *				 u8 pcp_hi,
+ *				 u8 pcp_lo)
+);
+ *     Configure a NIC to handle TSN-streams
+ *     - Update the bandwidth for the particular stream-class.
+ *     - The framesize is the size of the _entire_ frame (not just the payload)
+ *       since the full size is required to allocate bandwidth through
+ *       the credit based shaper in the NIC
+ *     - the vlan_id is the configured vlan for TSN in this session.
+ *     - add_link: if the link should be added or subtracted from the current
+ *       budget.
+ *    - u8 pcp_hi: 802.1Q priority value for high-class traffic (class A)
+ *    - u8 pcp_lo: 802.1Q priority value for low-class traffic (class B)
+ *
  *	SR-IOV management functions.
  * int (*ndo_set_vf_mac)(struct net_device *dev, int vf, u8* mac);
  * int (*ndo_set_vf_vlan)(struct net_device *dev, int vf, u16 vlan,
@@ -1185,6 +1219,16 @@ struct net_device_ops {
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	int			(*ndo_busy_poll)(struct napi_struct *dev);
 #endif
+
+#if IS_ENABLED(CONFIG_TSN)
+	int			(*ndo_tsn_capable)(struct net_device *dev);
+	int			(*ndo_tsn_link_configure)(struct net_device *dev,
+							  enum sr_class class,
+							  u16 framesize,
+							  u16 vid, u8 add_link,
+							  u8 pcp_hi, u8 pcp_lo);
+#endif	/* CONFIG_TSN */
+
 	int			(*ndo_set_vf_mac)(struct net_device *dev,
 						  int queue, u8 *mac);
 	int			(*ndo_set_vf_vlan)(struct net_device *dev,
diff --git a/net/Kconfig b/net/Kconfig
index 7b6cd34..19b8f9a 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -215,6 +215,7 @@ source "net/802/Kconfig"
 source "net/bridge/Kconfig"
 source "net/dsa/Kconfig"
 source "net/8021q/Kconfig"
+source "net/tsn/Kconfig"
 source "net/decnet/Kconfig"
 source "net/llc/Kconfig"
 source "net/ipx/Kconfig"
diff --git a/net/tsn/Kconfig b/net/tsn/Kconfig
new file mode 100644
index 0000000..1fc3c1d
--- /dev/null
+++ b/net/tsn/Kconfig
@@ -0,0 +1,32 @@
+#
+# Configuration for 802.1 Time Sensitive Networking (TSN)
+#
+
+config TSN
+	tristate "802.1 TSN Support"
+	depends on VLAN_8021Q && PTP_1588_CLOCK && CONFIGFS_FS
+	---help---
+	  Select this if you want to enable TSN on capable interfaces.
+
+	  TSN allows you to set up deterministic links on your LAN (only
+	  L2 is currently supported). Once loaded, the driver will probe
+	  all available interfaces if they are capable of supporting TSN
+	  links.
+
+	  Once loaded, a directory in configfs called tsn/ will expose
+	  the capable NICs and allow userspace to create
+	  links. Userspace must provide us with a StreamID as well as
+	  reserving bandwidth through the network and once this is done,
+	  a new link can be created by issuing a mkdir() in configfs and
+	  updating the attributes for the new link.
+
+	  TSN itself does not produce nor consume data, it is dependent
+	  upon 'shims' doing this, which can be virtually anything. ALSA
+	  is a good candidate.
+
+	  For more information, refer to the TSN-documentation in the
+	  kernel documentation repository.
+
+	  The resulting module will be called 'tsn'
+
+	  If unsure, say N.
-- 
2.7.4
