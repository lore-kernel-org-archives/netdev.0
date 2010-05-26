From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 2/3] arp_notify: allow drivers to explicitly request a notification event.
Date: Wed, 26 May 2010 11:09:42 +0100
Message-ID: <1274868583-26291-2-git-send-email-ian.campbell@citrix.com>
References: <1274868492.24218.7350.camel@zakaz.uk.xensource.com>
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	"David S. Miller" <davem@davemloft.net>, stable@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:42423 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933948Ab0EZKI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 06:08:57 -0400
In-Reply-To: <1274868492.24218.7350.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently such notifications are only generated when the device comes up or the
address changes. However one use case for these notifications is to enable
faster network recovery after a virtual machine migration (by causing switches
to relearn their MAC tables). A migration appears to the network stack as a
temporary loss of carrier and therefore does not trigger either of the current
conditions. Rather than adding carrier up as a trigger (which can cause issues
when interfaces a flapping) simply add an interface which the driver can use
to explicitly trigger the notification.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: stable@kernel.org
---
 include/linux/netdevice.h |    2 ++
 include/linux/notifier.h  |    1 +
 net/ipv4/devinet.c        |    1 +
 net/sched/sch_generic.c   |   18 ++++++++++++++++++
 4 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index fa8b476..4737996 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1661,6 +1661,8 @@ extern void netif_carrier_on(struct net_device *dev);
 
 extern void netif_carrier_off(struct net_device *dev);
 
+extern void netif_notify_peers(struct net_device *dev);
+
 /**
  *	netif_dormant_on - mark device as dormant.
  *	@dev: network device
diff --git a/include/linux/notifier.h b/include/linux/notifier.h
index fee6c2f..45477f2 100644
--- a/include/linux/notifier.h
+++ b/include/linux/notifier.h
@@ -203,6 +203,7 @@ static inline int notifier_to_errno(int ret)
 #define NETDEV_BONDING_NEWTYPE  0x000F
 #define NETDEV_POST_INIT	0x0010
 #define NETDEV_UNREGISTER_BATCH 0x0011
+#define NETDEV_NOTIFY_PEERS	0x0012
 
 #define SYS_DOWN	0x0001	/* Notify of system down */
 #define SYS_RESTART	SYS_DOWN
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 90e3d63..c12777f 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1081,6 +1081,7 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 		}
 		ip_mc_up(in_dev);
 		/* fall through */
+	case NETDEV_NOTIFY_PEERS:
 	case NETDEV_CHANGEADDR:
 		/* Send gratuitous ARP to notify of link change */
 		if (IN_DEV_ARP_NOTIFY(in_dev)) {
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index ff4dd53..2d7ca9e 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -325,6 +325,24 @@ void netif_carrier_off(struct net_device *dev)
 }
 EXPORT_SYMBOL(netif_carrier_off);
 
+/**
+ * 	netif_notify_peers - notify network peers about existence of @dev
+ * 	@dev: network device
+ *
+ * Generate traffic such that interested network peers are aware of
+ * @dev, such as by generating a gratuitous ARP. This may be used when
+ * a device wants to inform the rest of the network about some sort of
+ * reconfiguration such as a failover event or virtual machine
+ * migration.
+ */
+void netif_notify_peers(struct net_device *dev)
+{
+	rtnl_lock();
+	call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, dev);
+	rtnl_unlock();
+}
+EXPORT_SYMBOL(netif_notify_peers);
+
 /* "NOOP" scheduler: the best scheduler, recommended for all interfaces
    under all circumstances. It is difficult to invent anything faster or
    cheaper.
-- 
1.5.6.5

