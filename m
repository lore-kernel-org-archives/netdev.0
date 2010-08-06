From: Greg KH <gregkh@suse.de>
Subject: [08/38] arp_notify: allow drivers to explicitly request a notification event.
Date: Fri, 06 Aug 2010 11:30:29 -0700
Message-ID: <20100806183200.774085783@clark.site>
References: <20100806183250.GA23019@kroah.com>
Cc: stable-review@kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	Ian Campbell <ian.campbell@citrix.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:48578 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761857Ab0HFSf1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Aug 2010 14:35:27 -0400
In-Reply-To: <20100806183250.GA23019@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2.6.35-stable review patch.  If anyone has any objections, please let us know.

------------------

From: Ian Campbell <Ian.Campbell@citrix.com>

commit 06c4648d46d1b757d6b9591a86810be79818b60c upstream.

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
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 include/linux/netdevice.h |    2 ++
 include/linux/notifier.h  |    1 +
 net/ipv4/devinet.c        |    1 +
 net/sched/sch_generic.c   |   18 ++++++++++++++++++
 4 files changed, 22 insertions(+)

--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1775,6 +1775,8 @@ extern void netif_carrier_on(struct net_
 
 extern void netif_carrier_off(struct net_device *dev);
 
+extern void netif_notify_peers(struct net_device *dev);
+
 /**
  *	netif_dormant_on - mark device as dormant.
  *	@dev: network device
--- a/include/linux/notifier.h
+++ b/include/linux/notifier.h
@@ -210,6 +210,7 @@ static inline int notifier_to_errno(int
 #define NETDEV_POST_INIT	0x0010
 #define NETDEV_UNREGISTER_BATCH 0x0011
 #define NETDEV_BONDING_DESLAVE  0x0012
+#define NETDEV_NOTIFY_PEERS	0x0012
 
 #define SYS_DOWN	0x0001	/* Notify of system down */
 #define SYS_RESTART	SYS_DOWN
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1081,6 +1081,7 @@ static int inetdev_event(struct notifier
 		}
 		ip_mc_up(in_dev);
 		/* fall through */
+	case NETDEV_NOTIFY_PEERS:
 	case NETDEV_CHANGEADDR:
 		/* Send gratuitous ARP to notify of link change */
 		if (IN_DEV_ARP_NOTIFY(in_dev)) {
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -327,6 +327,24 @@ void netif_carrier_off(struct net_device
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


