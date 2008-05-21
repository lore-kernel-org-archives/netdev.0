From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: [PATCH RFC] net/bonding: announce fail-over for the active-backup
 mode
Date: Wed, 21 May 2008 15:50:55 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0805211550060.27300@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:40073 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754209AbYEUMvA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2008 08:51:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enhance bonding to announce fail-over for the active-backup mode through the
netdev events notifier chain mechanism. Such an event can be of use for the
RDMA CM (communication manager) to let native RDMA ULPs (eg NFS-RDMA, iSER)
always be aligned with the IP stack, in the sense that they use the same
ports/links as the stack does. More usages can be done to allow monitoring
tools based on netlink events be aware to bonding failover.

Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>

Index: linux-2.6.26-rc2/drivers/net/bonding/bond_main.c
===================================================================
--- linux-2.6.26-rc2.orig/drivers/net/bonding/bond_main.c	2008-05-13 10:02:22.000000000 +0300
+++ linux-2.6.26-rc2/drivers/net/bonding/bond_main.c	2008-05-15 12:29:44.000000000 +0300
@@ -1117,6 +1117,7 @@ void bond_change_active_slave(struct bon
 			bond->send_grat_arp = 1;
 		} else
 			bond_send_gratuitous_arp(bond);
+		netdev_bonding_change(bond->dev);
 	}
 }

Index: linux-2.6.26-rc2/include/linux/notifier.h
===================================================================
--- linux-2.6.26-rc2.orig/include/linux/notifier.h	2008-05-13 10:02:30.000000000 +0300
+++ linux-2.6.26-rc2/include/linux/notifier.h	2008-05-13 11:50:44.000000000 +0300
@@ -197,6 +197,7 @@ static inline int notifier_to_errno(int
 #define NETDEV_GOING_DOWN	0x0009
 #define NETDEV_CHANGENAME	0x000A
 #define NETDEV_FEAT_CHANGE	0x000B
+#define NETDEV_BONDING_FAILOVER 0x000C

 #define SYS_DOWN	0x0001	/* Notify of system down */
 #define SYS_RESTART	SYS_DOWN
Index: linux-2.6.26-rc2/include/linux/netdevice.h
===================================================================
--- linux-2.6.26-rc2.orig/include/linux/netdevice.h	2008-05-13 10:02:30.000000000 +0300
+++ linux-2.6.26-rc2/include/linux/netdevice.h	2008-05-13 11:50:20.000000000 +0300
@@ -1459,6 +1459,7 @@ extern void		__dev_addr_unsync(struct de
 extern void		dev_set_promiscuity(struct net_device *dev, int inc);
 extern void		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
+extern void		netdev_bonding_change(struct net_device *dev);
 extern void		netdev_features_change(struct net_device *dev);
 /* Load a device via the kmod */
 extern void		dev_load(struct net *net, const char *name);
Index: linux-2.6.26-rc2/net/core/dev.c
===================================================================
--- linux-2.6.26-rc2.orig/net/core/dev.c	2008-05-13 10:02:31.000000000 +0300
+++ linux-2.6.26-rc2/net/core/dev.c	2008-05-13 11:50:49.000000000 +0300
@@ -956,6 +956,12 @@ void netdev_state_change(struct net_devi
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
