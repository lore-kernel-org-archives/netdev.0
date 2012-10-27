From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/12] net, ixgbe: handle link local multicast addresses in SR-IOV mode
Date: Fri, 26 Oct 2012 17:08:29 -0700
Message-ID: <1351296518-31174-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1351296518-31174-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27325 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934313Ab2J0AIm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2012 20:08:42 -0400
In-Reply-To: <1351296518-31174-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

In SR-IOV mode the PF driver acts as the uplink port and is
used to send control packets e.g. lldpad, stp, etc.

   eth0.1     eth0.2     eth0
   VF         VF         PF
   |          |          |   <-- stand-in for uplink
   |          |          |
  --------------------------
  |  Embedded Switch       |
  --------------------------
              |
             MAC   <-- uplink

But the embedded switch is setup to forward multicast addresses
to all interfaces both VFs and PF and onto the physical link.
This results in reserved MAC addresses used by control protocols
to be forwarded over the switch onto the VF.

In the LLDP case the PF sends an LLDPDU and it is currently
being forwarded to all the VFs who then see the PF as a peer.
This is incorrect.

This patch adds the multicast addresses to the RAR table in the
hardware to prevent this behavior.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  2 +-
 drivers/net/ethernet/intel/ixgbevf/vf.c       |  3 +++
 include/linux/etherdevice.h                   | 19 +++++++++++++++++++
 net/bridge/br_device.c                        |  2 +-
 net/bridge/br_input.c                         | 15 ---------------
 net/bridge/br_private.h                       |  1 -
 net/bridge/br_sysfs_br.c                      |  3 ++-
 7 files changed, 26 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 88d636a..97bab45 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6967,7 +6967,7 @@ static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		return -EINVAL;
 	}
 
-	if (is_unicast_ether_addr(addr)) {
+	if (is_unicast_ether_addr(addr) || is_link_local(addr)) {
 		u32 rar_uc_entries = IXGBE_MAX_PF_MACVLANS;
 
 		if (netdev_uc_count(dev) < rar_uc_entries)
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 5fa397b..c0fd1ef 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -331,6 +331,9 @@ static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw,
 	netdev_for_each_mc_addr(ha, netdev) {
 		if (i == cnt)
 			break;
+		if (is_link_local(ha->addr))
+			continue;
+
 		vector_list[i++] = ixgbevf_mta_vector(hw, ha->addr);
 	}
 
diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index b006ba0..45ded4b 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -51,6 +51,25 @@ extern struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
 #define alloc_etherdev(sizeof_priv) alloc_etherdev_mq(sizeof_priv, 1)
 #define alloc_etherdev_mq(sizeof_priv, count) alloc_etherdev_mqs(sizeof_priv, count, count)
 
+/* Reserved Ethernet Addresses per IEEE 802.1Q */
+static const u8 br_reserved_address[ETH_ALEN] = { 0x01, 0x80, 0xc2, 0x00, 0x00, 0x00 };
+
+/**
+ * is_link_local -  Determine if given Eth addr is a link local mcast address.
+ * @addr: Pointer to a six-byte array containing the Ethernet address
+ *
+ * Return true if address is link local reserved addr (01:80:c2:00:00:0X) per
+ * IEEE 802.1Q 8.6.3 Frame filtering.
+ */
+static inline int is_link_local(const unsigned char *dest)
+{
+	__be16 *a = (__be16 *)dest;
+	static const __be16 *b = (const __be16 *)br_reserved_address;
+	static const __be16 m = cpu_to_be16(0xfff0);
+
+	return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | ((a[2] ^ b[2]) & m)) == 0;
+}
+
 /**
  * is_zero_ether_addr - Determine if give Ethernet address is all zeros.
  * @addr: Pointer to a six-byte array containing the Ethernet address
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 070e8a6..d41b6f9 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -356,7 +356,7 @@ void br_dev_setup(struct net_device *dev)
 	br->bridge_id.prio[0] = 0x80;
 	br->bridge_id.prio[1] = 0x00;
 
-	memcpy(br->group_addr, br_group_address, ETH_ALEN);
+	memcpy(br->group_addr, br_reserved_address, ETH_ALEN);
 
 	br->stp_enabled = BR_NO_STP;
 	br->group_fwd_mask = BR_GROUPFWD_DEFAULT;
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 76f15fd..d047978 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -19,9 +19,6 @@
 #include <linux/export.h>
 #include "br_private.h"
 
-/* Bridge group multicast address 802.1d (pg 51). */
-const u8 br_group_address[ETH_ALEN] = { 0x01, 0x80, 0xc2, 0x00, 0x00, 0x00 };
-
 /* Hook for brouter */
 br_should_route_hook_t __rcu *br_should_route_hook __read_mostly;
 EXPORT_SYMBOL(br_should_route_hook);
@@ -127,18 +124,6 @@ static int br_handle_local_finish(struct sk_buff *skb)
 	return 0;	 /* process further */
 }
 
-/* Does address match the link local multicast address.
- * 01:80:c2:00:00:0X
- */
-static inline int is_link_local(const unsigned char *dest)
-{
-	__be16 *a = (__be16 *)dest;
-	static const __be16 *b = (const __be16 *)br_group_address;
-	static const __be16 m = cpu_to_be16(0xfff0);
-
-	return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | ((a[2] ^ b[2]) & m)) == 0;
-}
-
 /*
  * Return NULL if skb is handled
  * note: already called with rcu_read_lock
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 9b278c4..65b191a 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -288,7 +288,6 @@ struct br_input_skb_cb {
 	pr_debug("%s: " format,  (br)->dev->name, ##args)
 
 extern struct notifier_block br_device_notifier;
-extern const u8 br_group_address[ETH_ALEN];
 
 /* called under bridge lock */
 static inline int br_is_root_bridge(const struct net_bridge *br)
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index c5c0593..e157b0d 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -14,6 +14,7 @@
 #include <linux/capability.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/if_bridge.h>
 #include <linux/rtnetlink.h>
 #include <linux/spinlock.h>
@@ -310,7 +311,7 @@ static ssize_t store_group_addr(struct device *d,
 
 	/* Must be 01:80:c2:00:00:0X */
 	for (i = 0; i < 5; i++)
-		if (new_addr[i] != br_group_address[i])
+		if (new_addr[i] != br_reserved_address[i])
 			return -EINVAL;
 
 	if (new_addr[5] & ~0xf)
-- 
1.7.11.7
