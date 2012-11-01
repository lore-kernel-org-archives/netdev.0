From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 2/3] eth: Make is_link_local() consistent with
 other address tests
Date: Thu, 1 Nov 2012 19:11:11 +0000
Message-ID: <1351797071.2883.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:39077 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752746Ab2KATLP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 15:11:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function name should include '_ether_addr'.
Return type should be bool.
Parameter name should be 'addr' not 'dest' (also matching kernel-doc).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    2 +-
 drivers/net/ethernet/intel/ixgbevf/vf.c           |    2 +-
 include/linux/etherdevice.h                       |    6 +++---
 net/bridge/br_input.c                             |    2 +-
 net/bridge/br_sysfs_br.c                          |    2 +-
 6 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e5f993e..d65e941 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6973,7 +6973,7 @@ static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		return -EINVAL;
 	}
 
-	if (is_unicast_ether_addr(addr) || is_link_local(addr)) {
+	if (is_unicast_ether_addr(addr) || is_link_local_ether_addr(addr)) {
 		u32 rar_uc_entries = IXGBE_MAX_PF_MACVLANS;
 
 		if (netdev_uc_count(dev) < rar_uc_entries)
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index c281ee9..f3d3947 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2979,7 +2979,7 @@ static int ixgbevf_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	unsigned short f;
 #endif
 	u8 *dst_mac = skb_header_pointer(skb, 0, 0, NULL);
-	if (!dst_mac || is_link_local(dst_mac)) {
+	if (!dst_mac || is_link_local_ether_addr(dst_mac)) {
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index c0fd1ef..0c94557 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -331,7 +331,7 @@ static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw,
 	netdev_for_each_mc_addr(ha, netdev) {
 		if (i == cnt)
 			break;
-		if (is_link_local(ha->addr))
+		if (is_link_local_ether_addr(ha->addr))
 			continue;
 
 		vector_list[i++] = ixgbevf_mta_vector(hw, ha->addr);
diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 45ded4b..7cf2516 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -55,15 +55,15 @@ extern struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
 static const u8 br_reserved_address[ETH_ALEN] = { 0x01, 0x80, 0xc2, 0x00, 0x00, 0x00 };
 
 /**
- * is_link_local -  Determine if given Eth addr is a link local mcast address.
+ * is_link_local_ether_addr - Determine if given Ethernet address is link-local
  * @addr: Pointer to a six-byte array containing the Ethernet address
  *
  * Return true if address is link local reserved addr (01:80:c2:00:00:0X) per
  * IEEE 802.1Q 8.6.3 Frame filtering.
  */
-static inline int is_link_local(const unsigned char *dest)
+static inline bool is_link_local_ether_addr(const u8 *addr)
 {
-	__be16 *a = (__be16 *)dest;
+	__be16 *a = (__be16 *)addr;
 	static const __be16 *b = (const __be16 *)br_reserved_address;
 	static const __be16 m = cpu_to_be16(0xfff0);
 
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index d047978..4b34207 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -147,7 +147,7 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 
 	p = br_port_get_rcu(skb->dev);
 
-	if (unlikely(is_link_local(dest))) {
+	if (unlikely(is_link_local_ether_addr(dest))) {
 		/*
 		 * See IEEE 802.1D Table 7-10 Reserved addresses
 		 *
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 82385fd..cffb76e 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -309,7 +309,7 @@ static ssize_t store_group_addr(struct device *d,
 		   &new_addr[3], &new_addr[4], &new_addr[5]) != 6)
 		return -EINVAL;
 
-	if (!is_link_local(new_addr))
+	if (!is_link_local_ether_addr(new_addr))
 		return -EINVAL;
 
 	if (new_addr[5] == 1 ||		/* 802.3x Pause address */
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
