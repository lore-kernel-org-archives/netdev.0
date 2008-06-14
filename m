From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 1/5] net/core: add NETDEV_BONDING_FAILOVER event
Date: Fri, 13 Jun 2008 18:12:00 -0700
Message-ID: <12134059253135-git-send-email-fubar@us.ibm.com>
References: <12134059242107-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@voltaire.com>,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:46263 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757596AbYFNBMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 21:12:17 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5E1C6BK007591
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 21:12:06 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5E1C6b5178950
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 19:12:06 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5E1C50L030207
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 19:12:06 -0600
In-Reply-To: <12134059242107-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@voltaire.com>

Add NETDEV_BONDING_FAILOVER event to be used in a successive patch
by bonding to announce fail-over for the active-backup mode through the
netdev events notifier chain mechanism. Such an event can be of use for the
RDMA CM (communication manager) to let native RDMA ULPs (eg NFS-RDMA, iSER)
always be aligned with the IP stack, in the sense that they use the same
ports/links as the stack does. More usages can be done to allow monitoring
tools based on netlink events being aware to bonding fail-over.

Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 include/linux/netdevice.h |    1 +
 include/linux/notifier.h  |    1 +
 net/core/dev.c            |    6 ++++++
 3 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f27fd20..e92fc83 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1479,6 +1479,7 @@ extern void		__dev_addr_unsync(struct dev_addr_list **to, int *to_count, struct
 extern void		dev_set_promiscuity(struct net_device *dev, int inc);
 extern void		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
+extern void		netdev_bonding_change(struct net_device *dev);
 extern void		netdev_features_change(struct net_device *dev);
 /* Load a device via the kmod */
 extern void		dev_load(struct net *net, const char *name);
diff --git a/include/linux/notifier.h b/include/linux/notifier.h
index 0ff6224..bd3d72d 100644
--- a/include/linux/notifier.h
+++ b/include/linux/notifier.h
@@ -197,6 +197,7 @@ static inline int notifier_to_errno(int ret)
 #define NETDEV_GOING_DOWN	0x0009
 #define NETDEV_CHANGENAME	0x000A
 #define NETDEV_FEAT_CHANGE	0x000B
+#define NETDEV_BONDING_FAILOVER 0x000C
 
 #define SYS_DOWN	0x0001	/* Notify of system down */
 #define SYS_RESTART	SYS_DOWN
diff --git a/net/core/dev.c b/net/core/dev.c
index 5829630..da8367c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -960,6 +960,12 @@ void netdev_state_change(struct net_device *dev)
 	}
 }
 
+void netdev_bonding_change(struct net_device *dev)
+{
+	call_netdevice_notifiers(NETDEV_BONDING_FAILOVER, dev);
+}
+EXPORT_SYMBOL(netdev_bonding_change);
+
 /**
  *	dev_load 	- load a network module
  *	@net: the applicable net namespace
-- 
1.5.2.4

