From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: [RFC v2 PATCH 1/3] net/core: add NETDEV_BONDING_FAILOVER event
Date: Mon, 2 Jun 2008 13:42:52 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0806021342120.31515@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:16833 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758786AbYFBKmv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2008 06:42:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add NETDEV_BONDING_FAILOVER event to be used in a successive patch
by bonding to announce fail-over for the active-backup mode through the
netdev events notifier chain mechanism. Such an event can be of use for the
RDMA CM (communication manager) to let native RDMA ULPs (eg NFS-RDMA, iSER)
always be aligned with the IP stack, in the sense that they use the same
ports/links as the stack does. More usages can be done to allow monitoring
tools based on netlink events being aware to bonding fail-over.

Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>

 include/linux/netdevice.h |    1 +
 include/linux/notifier.h  |    1 +
 net/core/dev.c            |    6 ++++++
 3 files changed, 8 insertions(+)

- changes from v1
 * removed the event delivery to a separate patch as of the locking change

Index: netdev-2.6/include/linux/notifier.h
===================================================================
--- netdev-2.6.orig/include/linux/notifier.h	2008-06-02 08:33:18.000000000 +0300
+++ netdev-2.6/include/linux/notifier.h	2008-06-02 09:24:44.000000000 +0300
@@ -197,6 +197,7 @@ static inline int notifier_to_errno(int
 #define NETDEV_GOING_DOWN	0x0009
 #define NETDEV_CHANGENAME	0x000A
 #define NETDEV_FEAT_CHANGE	0x000B
+#define NETDEV_BONDING_FAILOVER 0x000C

 #define SYS_DOWN	0x0001	/* Notify of system down */
 #define SYS_RESTART	SYS_DOWN
Index: netdev-2.6/include/linux/netdevice.h
===================================================================
--- netdev-2.6.orig/include/linux/netdevice.h	2008-06-02 08:33:17.000000000 +0300
+++ netdev-2.6/include/linux/netdevice.h	2008-06-02 09:24:44.000000000 +0300
@@ -1479,6 +1479,7 @@ extern void		__dev_addr_unsync(struct de
 extern void		dev_set_promiscuity(struct net_device *dev, int inc);
 extern void		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
+extern void		netdev_bonding_change(struct net_device *dev);
 extern void		netdev_features_change(struct net_device *dev);
 /* Load a device via the kmod */
 extern void		dev_load(struct net *net, const char *name);
Index: netdev-2.6/net/core/dev.c
===================================================================
--- netdev-2.6.orig/net/core/dev.c	2008-06-02 08:33:19.000000000 +0300
+++ netdev-2.6/net/core/dev.c	2008-06-02 09:24:44.000000000 +0300
@@ -960,6 +960,12 @@ void netdev_state_change(struct net_devi
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
