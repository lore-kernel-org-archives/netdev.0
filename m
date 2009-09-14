From: Moni Shoua <monis@Voltaire.COM>
Subject: Re: [PATCH RESEND] bonding: remap muticast addresses without using
 dev_close() and dev_open()
Date: Mon, 14 Sep 2009 12:38:13 +0300
Message-ID: <4AAE0F05.1050502@Voltaire.COM>
References: <4AA39E42.9070702@Voltaire.COM>	<4AA8B19F.2080704@voltaire.com>	<4AA8BD09.2010607@Voltaire.COM> <20090911.123652.92869438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@voltaire.com, fubar@us.ibm.com,
	jgunthorpe@obsidianresearch.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:26154 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751276AbZINJiT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2009 05:38:19 -0400
In-Reply-To: <20090911.123652.92869438.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> But unfortunately this patch doesn't apply to net-next-2.6 and
> you'll need to respin it against current sources so I can apply
> it, thanks.
The patch was written against linux-2.6 but I just pulled net-next-2.6 (git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git) and found out that besides offsets it applies well.
Is the URL above correct? Anyway, I add here the one that I took from net-next-2.6. Please let me know if it still doesn't apply. Thanks
-------------------------------------------------------------------------------

This patch fixes commit e36b9d16c6a6d0f59803b3ef04ff3c22c3844c10. The approach
there is to call dev_close()/dev_open() whenever the device type is changed in
order to remap the device IP multicast addresses to HW multicast addresses.
This approach suffers from 2 drawbacks:

*. It assumes tha the device is UP when calling dev_close(), or otherwise
   dev_close() has no affect. It is worth to mention that initscripts (Redhat)
   and sysconfig (Suse) doesn't act the same in this matter. 
*. dev_close() has other side affects, like deleting entries from the routing
   table, which might be unnecessary.

The fix here is to directly remap the IP multicast addresses to HW multicast
addresses for a bonding device that changes its type, and nothing else.
   
Reported-by:   Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Signed-off-by: Moni Shoua <monis@voltaire.com>
--
 drivers/net/bonding/bond_main.c |    9 ++++++---
 include/linux/igmp.h            |    2 ++
 include/linux/netdevice.h       |    3 ++-
 include/linux/notifier.h        |    2 ++
 include/net/addrconf.h          |    2 ++
 net/core/dev.c                  |    4 ++--
 net/ipv4/devinet.c              |    6 ++++++
 net/ipv4/igmp.c                 |   22 ++++++++++++++++++++++
 net/ipv6/addrconf.c             |   19 +++++++++++++++++++
 net/ipv6/mcast.c                |   19 +++++++++++++++++++
 10 files changed, 82 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a7e731f..6419cf9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1211,7 +1211,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 			write_unlock_bh(&bond->curr_slave_lock);
 			read_unlock(&bond->lock);
 
-			netdev_bonding_change(bond->dev);
+			netdev_bonding_change(bond->dev, NETDEV_BONDING_FAILOVER);
 
 			read_lock(&bond->lock);
 			write_lock_bh(&bond->curr_slave_lock);
@@ -1469,14 +1469,17 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	 */
 	if (bond->slave_cnt == 0) {
 		if (bond_dev->type != slave_dev->type) {
-			dev_close(bond_dev);
 			pr_debug("%s: change device type from %d to %d\n",
 				bond_dev->name, bond_dev->type, slave_dev->type);
+
+			netdev_bonding_change(bond_dev, NETDEV_BONDING_OLDTYPE);
+
 			if (slave_dev->type != ARPHRD_ETHER)
 				bond_setup_by_slave(bond_dev, slave_dev);
 			else
 				ether_setup(bond_dev);
-			dev_open(bond_dev);
+
+			netdev_bonding_change(bond_dev, NETDEV_BONDING_NEWTYPE);
 		}
 	} else if (bond_dev->type != slave_dev->type) {
 		pr_err(DRV_NAME ": %s ether type (%d) is different "
diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 92fbd8c..fe158e0 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -233,6 +233,8 @@ extern void ip_mc_init_dev(struct in_device *);
 extern void ip_mc_destroy_dev(struct in_device *);
 extern void ip_mc_up(struct in_device *);
 extern void ip_mc_down(struct in_device *);
+extern void ip_mc_unmap(struct in_device *);
+extern void ip_mc_remap(struct in_device *);
 extern void ip_mc_dec_group(struct in_device *in_dev, __be32 addr);
 extern void ip_mc_inc_group(struct in_device *in_dev, __be32 addr);
 extern void ip_mc_rejoin_group(struct ip_mc_list *im);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 65ee192..f46db6c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1873,7 +1873,8 @@ extern void		__dev_addr_unsync(struct dev_addr_list **to, int *to_count, struct
 extern int		dev_set_promiscuity(struct net_device *dev, int inc);
 extern int		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
-extern void		netdev_bonding_change(struct net_device *dev);
+extern void		netdev_bonding_change(struct net_device *dev,
+					      unsigned long event);
 extern void		netdev_features_change(struct net_device *dev);
 /* Load a device via the kmod */
 extern void		dev_load(struct net *net, const char *name);
diff --git a/include/linux/notifier.h b/include/linux/notifier.h
index 81bc252..44428d2 100644
--- a/include/linux/notifier.h
+++ b/include/linux/notifier.h
@@ -199,6 +199,8 @@ static inline int notifier_to_errno(int ret)
 #define NETDEV_FEAT_CHANGE	0x000B
 #define NETDEV_BONDING_FAILOVER 0x000C
 #define NETDEV_PRE_UP		0x000D
+#define NETDEV_BONDING_OLDTYPE  0x000E
+#define NETDEV_BONDING_NEWTYPE  0x000F
 
 #define SYS_DOWN	0x0001	/* Notify of system down */
 #define SYS_RESTART	SYS_DOWN
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 7b55ab2..0f7c378 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -143,6 +143,8 @@ extern int __ipv6_dev_mc_dec(struct inet6_dev *idev, const struct in6_addr *addr
 extern int ipv6_dev_mc_dec(struct net_device *dev, const struct in6_addr *addr);
 extern void ipv6_mc_up(struct inet6_dev *idev);
 extern void ipv6_mc_down(struct inet6_dev *idev);
+extern void ipv6_mc_unmap(struct inet6_dev *idev);
+extern void ipv6_mc_remap(struct inet6_dev *idev);
 extern void ipv6_mc_init_dev(struct inet6_dev *idev);
 extern void ipv6_mc_destroy_dev(struct inet6_dev *idev);
 extern void addrconf_dad_failure(struct inet6_ifaddr *ifp);
diff --git a/net/core/dev.c b/net/core/dev.c
index f843a0c..f6a4495 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1017,9 +1017,9 @@ void netdev_state_change(struct net_device *dev)
 }
 EXPORT_SYMBOL(netdev_state_change);
 
-void netdev_bonding_change(struct net_device *dev)
+void netdev_bonding_change(struct net_device *dev, unsigned long event)
 {
-	call_netdevice_notifiers(NETDEV_BONDING_FAILOVER, dev);
+	call_netdevice_notifiers(event, dev);
 }
 EXPORT_SYMBOL(netdev_bonding_change);
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 3863c3a..07336c6 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1087,6 +1087,12 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 	case NETDEV_DOWN:
 		ip_mc_down(in_dev);
 		break;
+	case NETDEV_BONDING_OLDTYPE:
+		ip_mc_unmap(in_dev);
+		break;
+	case NETDEV_BONDING_NEWTYPE:
+		ip_mc_remap(in_dev);
+		break;
 	case NETDEV_CHANGEMTU:
 		if (inetdev_valid_mtu(dev->mtu))
 			break;
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 01b4284..d41e5de 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1298,6 +1298,28 @@ void ip_mc_dec_group(struct in_device *in_dev, __be32 addr)
 	}
 }
 
+/* Device changing type */
+
+void ip_mc_unmap(struct in_device *in_dev)
+{
+	struct ip_mc_list *i;
+
+	ASSERT_RTNL();
+
+	for (i = in_dev->mc_list; i; i = i->next)
+		igmp_group_dropped(i);
+}
+
+void ip_mc_remap(struct in_device *in_dev)
+{
+	struct ip_mc_list *i;
+
+	ASSERT_RTNL();
+
+	for (i = in_dev->mc_list; i; i = i->next)
+		igmp_group_added(i);
+}
+
 /* Device going down */
 
 void ip_mc_down(struct in_device *in_dev)
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c9b3690..f216a41 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -137,6 +137,8 @@ static DEFINE_SPINLOCK(addrconf_verify_lock);
 static void addrconf_join_anycast(struct inet6_ifaddr *ifp);
 static void addrconf_leave_anycast(struct inet6_ifaddr *ifp);
 
+static void addrconf_bonding_change(struct net_device *dev,
+				    unsigned long event);
 static int addrconf_ifdown(struct net_device *dev, int how);
 
 static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags);
@@ -2582,6 +2584,10 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 				return notifier_from_errno(err);
 		}
 		break;
+	case NETDEV_BONDING_OLDTYPE:
+	case NETDEV_BONDING_NEWTYPE:
+		addrconf_bonding_change(dev, event);
+		break;
 	}
 
 	return NOTIFY_OK;
@@ -2595,6 +2601,19 @@ static struct notifier_block ipv6_dev_notf = {
 	.priority = 0
 };
 
+static void addrconf_bonding_change(struct net_device *dev, unsigned long event)
+{
+	struct inet6_dev *idev;
+	ASSERT_RTNL();
+
+	idev = __in6_dev_get(dev);
+
+	if (event == NETDEV_BONDING_NEWTYPE)
+		ipv6_mc_remap(idev);
+	else if (event == NETDEV_BONDING_OLDTYPE)
+		ipv6_mc_unmap(idev);
+}
+
 static int addrconf_ifdown(struct net_device *dev, int how)
 {
 	struct inet6_dev *idev;
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 71c3dac..f9fcf69 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2249,6 +2249,25 @@ static void igmp6_timer_handler(unsigned long data)
 	ma_put(ma);
 }
 
+/* Device changing type */
+
+void ipv6_mc_unmap(struct inet6_dev *idev)
+{
+	struct ifmcaddr6 *i;
+
+	/* Install multicast list, except for all-nodes (already installed) */
+
+	read_lock_bh(&idev->lock);
+	for (i = idev->mc_list; i; i = i->next)
+		igmp6_group_dropped(i);
+	read_unlock_bh(&idev->lock);
+}
+
+void ipv6_mc_remap(struct inet6_dev *idev)
+{
+	ipv6_mc_up(idev);
+}
+
 /* Device going down */
 
 void ipv6_mc_down(struct inet6_dev *idev)
