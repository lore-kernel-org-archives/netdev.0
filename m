From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH net-next v2] vlan: add 802.1q netpoll support
Date: Thu, 8 Dec 2011 11:20:49 -0500
Message-ID: <20111208162049.GF30652@kvack.org>
References: <20111207010424.GA16496@kvack.org> <20111208.000730.63159506168958262.davem@davemloft.net> <20111208153558.GE30652@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:49605 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751094Ab1LHQUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 11:20:50 -0500
Content-Disposition: inline
In-Reply-To: <20111208153558.GE30652@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 08, 2011 at 10:35:58AM -0500, Benjamin LaHaise wrote:
> Please have a look at net/bridge/br_device.c:br_netpoll_setup() which is 
> where the approach came from.

And I was blind.  I see what you mean about not invoking the 
poll_controller of the underlying device.  Here's a respin.  Boot tested 
on the same forced_eth system.

		-ben
---snip---
[PATCH net-next v2] vlan: add 802.1q netpoll support

Add netpoll support to 802.1q vlan devices.  Based on the netpoll support
in the bridging code.  Tested on a forced_eth device with netconsole.

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org> 
---
vlan.h     |    5 +++++
 vlan_dev.c |   59 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 64 insertions(+)

diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 9fd45f3..df562b5 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -40,6 +40,8 @@ struct vlan_pcpu_stats {
 	u32			tx_dropped;
 };
 
+struct netpoll;
+
 /**
  *	struct vlan_dev_info - VLAN private device data
  *	@nr_ingress_mappings: number of ingress priority mappings
@@ -67,6 +69,9 @@ struct vlan_dev_info {
 
 	struct proc_dir_entry			*dent;
 	struct vlan_pcpu_stats __percpu		*vlan_pcpu_stats;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	struct netpoll				*netpoll;
+#endif
 };
 
 static inline struct vlan_dev_info *vlan_dev_info(const struct net_device *dev)
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 2b5fcde..0071829 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -33,6 +33,7 @@
 #include "vlan.h"
 #include "vlanproc.h"
 #include <linux/if_vlan.h>
+#include <linux/netpoll.h>
 
 /*
  *	Rebuild the Ethernet MAC header. This is called after an ARP
@@ -158,6 +159,8 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 
 	skb_set_dev(skb, vlan_dev_info(dev)->real_dev);
 	len = skb->len;
+	if (netpoll_tx_running(dev))
+		return skb->dev->netdev_ops->ndo_start_xmit(skb, skb->dev);
 	ret = dev_queue_xmit(skb);
 
 	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
@@ -660,6 +663,57 @@ static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_device *dev, st
 	return stats;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+void vlan_dev_poll_controller(struct net_device *dev)
+{
+	return;
+}
+
+int vlan_dev_netpoll_setup(struct net_device *dev, struct netpoll_info *npinfo)
+{
+	struct vlan_dev_info *info = vlan_dev_info(dev);
+	struct net_device *real_dev = info->real_dev;
+	struct netpoll *netpoll;
+	int err = 0;
+
+	netpoll = kzalloc(sizeof(*netpoll), GFP_KERNEL);
+	err = -ENOMEM;
+	if (!netpoll)
+		goto out;
+
+	netpoll->dev = real_dev;
+	strlcpy(netpoll->dev_name, real_dev->name, IFNAMSIZ);
+
+	err = __netpoll_setup(netpoll);
+	if (err) {
+		kfree(netpoll);
+		goto out;
+	}
+
+	info->netpoll = netpoll;
+
+out:
+	return err;
+}
+
+void vlan_dev_netpoll_cleanup(struct net_device *dev)
+{
+	struct vlan_dev_info *info = vlan_dev_info(dev);
+	struct netpoll *netpoll = info->netpoll;
+
+	if (!netpoll)
+		return;
+
+	info->netpoll = NULL;
+
+        /* Wait for transmitting packets to finish before freeing. */
+        synchronize_rcu_bh();
+
+        __netpoll_cleanup(netpoll);
+        kfree(netpoll);
+}
+#endif /* CONFIG_NET_POLL_CONTROLLER */
+
 static const struct ethtool_ops vlan_ethtool_ops = {
 	.get_settings	        = vlan_ethtool_get_settings,
 	.get_drvinfo	        = vlan_ethtool_get_drvinfo,
@@ -688,6 +742,11 @@ static const struct net_device_ops vlan_netdev_ops = {
 	.ndo_fcoe_get_wwn	= vlan_dev_fcoe_get_wwn,
 	.ndo_fcoe_ddp_target	= vlan_dev_fcoe_ddp_target,
 #endif
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= vlan_dev_poll_controller,
+	.ndo_netpoll_setup	= vlan_dev_netpoll_setup,
+	.ndo_netpoll_cleanup	= vlan_dev_netpoll_cleanup,
+#endif
 	.ndo_fix_features	= vlan_dev_fix_features,
 };
 
