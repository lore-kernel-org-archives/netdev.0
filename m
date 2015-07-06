From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC net-next 2/6] net: Preparation for vrf device
Date: Mon,  6 Jul 2015 09:03:16 -0600
Message-ID: <1436195001-4818-3-git-send-email-dsa@cumulusnetworks.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:38234 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbbGFPDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 11:03:33 -0400
Received: by igrv9 with SMTP id v9so117436807igr.1
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 08:03:32 -0700 (PDT)
In-Reply-To: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a VRF_MASTER flag for interfaces and helper functions for determining
if a device is a VRF_MASTER.

Also, add link attribute for passing VRF_TABLE id.

Both are used in the following patch that adds a VRF device driver.

Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/linux/netdevice.h    | 21 +++++++++++++++++++++
 include/uapi/linux/if_link.h |  9 +++++++++
 2 files changed, 30 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e20979dfd6a9..142cb64f139c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1274,6 +1274,7 @@ enum netdev_priv_flags {
 	IFF_XMIT_DST_RELEASE_PERM	= 1<<22,
 	IFF_IPVLAN_MASTER		= 1<<23,
 	IFF_IPVLAN_SLAVE		= 1<<24,
+	IFF_VRF_MASTER		        = 1<<25,
 };
 
 #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
@@ -1301,6 +1302,7 @@ enum netdev_priv_flags {
 #define IFF_XMIT_DST_RELEASE_PERM	IFF_XMIT_DST_RELEASE_PERM
 #define IFF_IPVLAN_MASTER		IFF_IPVLAN_MASTER
 #define IFF_IPVLAN_SLAVE		IFF_IPVLAN_SLAVE
+#define IFF_VRF_MASTER		        IFF_VRF_MASTER
 
 /**
  *	struct net_device - The DEVICE structure.
@@ -1417,6 +1419,7 @@ enum netdev_priv_flags {
  *	@dn_ptr:	DECnet specific data
  *	@ip6_ptr:	IPv6 specific data
  *	@ax25_ptr:	AX.25 specific data
+ *	@vrf_ptr:	VRF specific data
  *	@ieee80211_ptr:	IEEE 802.11 specific data, assign before registering
  *
  *	@last_rx:	Time of last Rx
@@ -1629,6 +1632,7 @@ struct net_device {
 	struct dn_dev __rcu     *dn_ptr;
 	struct inet6_dev __rcu	*ip6_ptr;
 	void			*ax25_ptr;
+	struct net_vrf_dev      *vrf_ptr;
 	struct wireless_dev	*ieee80211_ptr;
 	struct wpan_dev		*ieee802154_ptr;
 #if IS_ENABLED(CONFIG_MPLS_ROUTING)
@@ -3781,6 +3785,23 @@ static inline bool netif_supports_nofcs(struct net_device *dev)
 	return dev->priv_flags & IFF_SUPP_NOFCS;
 }
 
+static inline bool netif_is_vrf(struct net_device *dev)
+{
+	return dev->priv_flags & IFF_VRF_MASTER;
+}
+
+static inline bool netif_idx_is_vrf(struct net *net, int idx)
+{
+	struct net_device *dev = dev_get_by_index(net, idx);
+	bool rc = false;
+
+	if (dev) {
+		rc = netif_is_vrf(dev);
+		dev_put(dev);
+	}
+	return rc;
+}
+
 /* This device needs to keep skb dst for qdisc enqueue or ndo_start_xmit() */
 static inline void netif_keep_dst(struct net_device *dev)
 {
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 2c7e8e3d3981..bfbb4d8eeec2 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -339,6 +339,15 @@ enum macvlan_macaddr_mode {
 
 #define MACVLAN_FLAG_NOPROMISC	1
 
+/* VRF section */
+enum {
+	IFLA_VRF_UNSPEC,
+	IFLA_VRF_TABLE,
+	__IFLA_VRF_MAX
+};
+
+#define IFLA_VRF_MAX (__IFLA_VRF_MAX - 1)
+
 /* IPVLAN section */
 enum {
 	IFLA_IPVLAN_UNSPEC,
-- 
2.3.2 (Apple Git-55)
