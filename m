From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH 1/3] net: rename notifier defines for netdev
 type change
Date: Wed, 10 Mar 2010 21:28:56 +0100
Message-ID: <20100310202855.GD2834@psychotron.redhat.com>
References: <20100310202804.GC2834@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36251 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753859Ab0CJU3L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Mar 2010 15:29:11 -0500
Content-Disposition: inline
In-Reply-To: <20100310202804.GC2834@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since generally there could be more netdevices changing type other than bonding,
making this event type name "bonding-unrelated"

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_main.c |    6 ++++--
 include/linux/notifier.h        |    4 ++--
 net/ipv4/devinet.c              |    4 ++--
 net/ipv6/addrconf.c             |   16 ++++++++--------
 4 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 430c022..7eeb187 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1480,14 +1480,16 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 				 bond_dev->name,
 				 bond_dev->type, slave_dev->type);
 
-			netdev_bonding_change(bond_dev, NETDEV_BONDING_OLDTYPE);
+			netdev_bonding_change(bond_dev,
+					      NETDEV_PRE_TYPE_CHANGE);
 
 			if (slave_dev->type != ARPHRD_ETHER)
 				bond_setup_by_slave(bond_dev, slave_dev);
 			else
 				ether_setup(bond_dev);
 
-			netdev_bonding_change(bond_dev, NETDEV_BONDING_NEWTYPE);
+			netdev_bonding_change(bond_dev,
+					      NETDEV_POST_TYPE_CHANGE);
 		}
 	} else if (bond_dev->type != slave_dev->type) {
 		pr_err("%s ether type (%d) is different from other slaves (%d), can not enslave it.\n",
diff --git a/include/linux/notifier.h b/include/linux/notifier.h
index fee6c2f..f3635fc 100644
--- a/include/linux/notifier.h
+++ b/include/linux/notifier.h
@@ -199,8 +199,8 @@ static inline int notifier_to_errno(int ret)
 #define NETDEV_FEAT_CHANGE	0x000B
 #define NETDEV_BONDING_FAILOVER 0x000C
 #define NETDEV_PRE_UP		0x000D
-#define NETDEV_BONDING_OLDTYPE  0x000E
-#define NETDEV_BONDING_NEWTYPE  0x000F
+#define NETDEV_PRE_TYPE_CHANGE	0x000E
+#define NETDEV_POST_TYPE_CHANGE	0x000F
 #define NETDEV_POST_INIT	0x0010
 #define NETDEV_UNREGISTER_BATCH 0x0011
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 51ca946..c75320e 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1095,10 +1095,10 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 	case NETDEV_DOWN:
 		ip_mc_down(in_dev);
 		break;
-	case NETDEV_BONDING_OLDTYPE:
+	case NETDEV_PRE_TYPE_CHANGE:
 		ip_mc_unmap(in_dev);
 		break;
-	case NETDEV_BONDING_NEWTYPE:
+	case NETDEV_POST_TYPE_CHANGE:
 		ip_mc_remap(in_dev);
 		break;
 	case NETDEV_CHANGEMTU:
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 88fd8c5..bf5349b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -137,8 +137,8 @@ static DEFINE_SPINLOCK(addrconf_verify_lock);
 static void addrconf_join_anycast(struct inet6_ifaddr *ifp);
 static void addrconf_leave_anycast(struct inet6_ifaddr *ifp);
 
-static void addrconf_bonding_change(struct net_device *dev,
-				    unsigned long event);
+static void addrconf_type_change(struct net_device *dev,
+				 unsigned long event);
 static int addrconf_ifdown(struct net_device *dev, int how);
 
 static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags);
@@ -2582,9 +2582,9 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 				return notifier_from_errno(err);
 		}
 		break;
-	case NETDEV_BONDING_OLDTYPE:
-	case NETDEV_BONDING_NEWTYPE:
-		addrconf_bonding_change(dev, event);
+	case NETDEV_PRE_TYPE_CHANGE:
+	case NETDEV_POST_TYPE_CHANGE:
+		addrconf_type_change(dev, event);
 		break;
 	}
 
@@ -2599,16 +2599,16 @@ static struct notifier_block ipv6_dev_notf = {
 	.priority = 0
 };
 
-static void addrconf_bonding_change(struct net_device *dev, unsigned long event)
+static void addrconf_type_change(struct net_device *dev, unsigned long event)
 {
 	struct inet6_dev *idev;
 	ASSERT_RTNL();
 
 	idev = __in6_dev_get(dev);
 
-	if (event == NETDEV_BONDING_NEWTYPE)
+	if (event == NETDEV_POST_TYPE_CHANGE)
 		ipv6_mc_remap(idev);
-	else if (event == NETDEV_BONDING_OLDTYPE)
+	else if (event == NETDEV_PRE_TYPE_CHANGE)
 		ipv6_mc_unmap(idev);
 }
 
-- 
1.6.6.1

