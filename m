From: Michael Marineau <mike@marineau.org>
Subject: Re: [PATCH -net-next 3/4] firmware: convert tg3 driver to
	request_firmware()
Date: Tue, 6 Jan 2009 22:17:24 -0500
Message-ID: <20090107031724.GA6118@porter.dyn.128.marineau.org>
References: <1230626497.24796.26.camel@jaswinder.satnam> <49620AFE.6040409@hartkopp.net> <20090105.160112.119906029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: oliver@hartkopp.net, jaswinder@infradead.org, jgarzik@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org, mchan@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090105.160112.119906029.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 05, 2009 at 04:01:12PM -0800, David Miller wrote:
> From: Oliver Hartkopp <oliver@hartkopp.net>
> Date: Mon, 05 Jan 2009 14:28:30 +0100
> 
> > 2. I got this inconsistent lock state, i've not seen before:
> 
> I know what causes it.  It's this change:
> 
> commit 22604c866889c4b2e12b73cbf1683bda1b72a313
> Author: Michael Marineau <mike@marineau.org>
> Date:   Sun Jan 4 17:18:51 2009 -0800
> 
>     net: Fix for initial link state in 2.6.28
> 
> It causes us to now call the linkwatch even trigger code inside of
> software interrupt context, but that is illegal because that code path
> takes the dev_base_lock rwlock as a writer.
> 
> I'm going to revert, and Michael will need to find a way to fix the
> initial link state issue without adding locking problems :-)

Ok, here's another try. Rather than find a safer way to sync up the
operstate variable with the normal state flags I decided to just nuke
operstate entirely, it just duplicated what was already in the state
flags for the most part. The patch is a bit large for -stable so I'll
submit a different workaround that can go into the 2.6.28 series.

As a side note operstate's sibling link_mode could also be changed to a
state flag but it isn't the problem child so I'll leave it alone unless
someone thinks that'd be a good change.

Thoughts?


From: Michael Marineau <mike@marineau.org>
Date: Tue, 6 Jan 2009 00:48:02 -0500
Subject: [PATCH] Fold net_device.operstate into net_device.state

The variable operstate in the net_device structure typically held
nothing beyond what was already in the normal state flags (carrier_ok,
etc). operstate's main purpose is to allow user space to set a network
interface to a dormant state. Keeping operstate and state in sync is a
bit awkward so this patch removes operstate and replaces it by using the
state flags instead. Setting the interface to dormant from user-space is
now handled by netif_userspace_dormant to parallel the netif_dormant set
of functions that drivers use.

This resolves a regression that was introduced by commit
b47300168e770b60ab96c8924854c3 which stopped prevented operstate from
being kept in sync with state before the device is registered. This
caused drivers that set things like the carrier state before registering
to mis-report their initial state, breaking NetworkManager, dhcpcd, etc.

Signed-off-by: Michael Marineau <mike@marineau.org>
---
 drivers/net/macvlan.c     |    2 +-
 include/linux/netdevice.h |   45 +++++++++++++++++++++++++++++++++++++++++----
 net/8021q/vlan.c          |    2 +-
 net/bridge/br_netlink.c   |    3 +--
 net/core/dev.c            |   25 +++++++++++++++++++++++++
 net/core/link_watch.c     |   45 +++++++++------------------------------------
 net/core/net-sysfs.c      |    4 +---
 net/core/rtnetlink.c      |   23 ++++++++---------------
 8 files changed, 87 insertions(+), 62 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 590039c..2ae1d3d 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -394,7 +394,7 @@ static void macvlan_transfer_operstate(struct net_device *dev)
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	const struct net_device *lowerdev = vlan->lowerdev;
 
-	if (lowerdev->operstate == IF_OPER_DORMANT)
+	if (netif_dormant(lowerdev) || netif_userspace_dormant(lowerdev))
 		netif_dormant_on(dev);
 	else
 		netif_dormant_off(dev);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e26f549..fdc1c61 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -277,6 +277,7 @@ enum netdev_state_t
 	__LINK_STATE_NOCARRIER,
 	__LINK_STATE_LINKWATCH_PENDING,
 	__LINK_STATE_DORMANT,
+	__LINK_STATE_USERSPACE_DORMANT,
 };
 
 
@@ -582,8 +583,7 @@ struct net_device
         unsigned short          priv_flags; /* Like 'flags' but invisible to userspace. */
 	unsigned short		padded;	/* How much padding added by alloc_netdev() */
 
-	unsigned char		operstate; /* RFC2863 operstate */
-	unsigned char		link_mode; /* mapping policy to operstate */
+	unsigned char		link_mode; /* control dormant/up transition */
 
 	unsigned		mtu;	/* interface MTU value		*/
 	unsigned short		type;	/* interface hardware type	*/
@@ -1256,6 +1256,7 @@ extern void		netif_nit_deliver(struct sk_buff *skb);
 extern int		dev_valid_name(const char *name);
 extern int		dev_ioctl(struct net *net, unsigned int cmd, void __user *);
 extern int		dev_ethtool(struct net *net, struct ifreq *);
+extern unsigned char	dev_get_operstate(const struct net_device *);
 extern unsigned		dev_get_flags(const struct net_device *);
 extern int		dev_change_flags(struct net_device *, unsigned);
 extern int		dev_change_name(struct net_device *, const char *);
@@ -1366,6 +1367,42 @@ static inline int netif_dormant(const struct net_device *dev)
 	return test_bit(__LINK_STATE_DORMANT, &dev->state);
 }
 
+/**
+ *	netif_userspace_dormant_on - mark device as dormant
+ *	@dev: network device
+ *
+ * Mark device as dormant (as per RFC2863).
+ *
+ * User-space may have a device set to dormant until it performs some form
+ * of authentication or other initialization. This flag is only used for
+ * interacting with user-space. Drivers should not change this flag.
+ */
+static inline void netif_userspace_dormant_on(struct net_device *dev)
+{
+	set_bit(__LINK_STATE_USERSPACE_DORMANT, &dev->state);
+}
+
+/**
+ *	netif_userspace_dormant_off - set device as not dormant.
+ *	@dev: network device
+ *
+ * User-space has marked the device is not dormant.
+ */
+static inline void netif_userspace_dormant_off(struct net_device *dev)
+{
+	clear_bit(__LINK_STATE_USERSPACE_DORMANT, &dev->state);
+}
+
+/**
+ *	netif_dormant - test if a device is dormant
+ *	@dev: network device
+ *
+ * Check if device is marked as dormant by user-space.
+ */
+static inline int netif_userspace_dormant(const struct net_device *dev)
+{
+	return test_bit(__LINK_STATE_USERSPACE_DORMANT, &dev->state);
+}
 
 /**
  *	netif_oper_up - test if device is operational
@@ -1374,8 +1411,8 @@ static inline int netif_dormant(const struct net_device *dev)
  * Check if carrier is operational
  */
 static inline int netif_oper_up(const struct net_device *dev) {
-	return (dev->operstate == IF_OPER_UP ||
-		dev->operstate == IF_OPER_UNKNOWN /* backward compat */);
+	return (netif_carrier_ok(dev) && !netif_dormant(dev) &&
+			!netif_userspace_dormant(dev));
 }
 
 /**
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index f0e335a..5ddcfa8 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -189,7 +189,7 @@ static void vlan_transfer_operstate(const struct net_device *dev,
 	 * of real device, also must allow supplicant running
 	 * on VLAN device
 	 */
-	if (dev->operstate == IF_OPER_DORMANT)
+	if (netif_dormant(dev) || netif_userspace_dormant(dev))
 		netif_dormant_on(vlandev);
 	else
 		netif_dormant_off(vlandev);
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index ba7be19..6c3b90b 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -39,7 +39,6 @@ static int br_fill_ifinfo(struct sk_buff *skb, const struct net_bridge_port *por
 	const struct net_device *dev = port->dev;
 	struct ifinfomsg *hdr;
 	struct nlmsghdr *nlh;
-	u8 operstate = netif_running(dev) ? dev->operstate : IF_OPER_DOWN;
 
 	pr_debug("br_fill_info event %d port %s master %s\n",
 		 event, dev->name, br->dev->name);
@@ -59,7 +58,7 @@ static int br_fill_ifinfo(struct sk_buff *skb, const struct net_bridge_port *por
 	NLA_PUT_STRING(skb, IFLA_IFNAME, dev->name);
 	NLA_PUT_U32(skb, IFLA_MASTER, br->dev->ifindex);
 	NLA_PUT_U32(skb, IFLA_MTU, dev->mtu);
-	NLA_PUT_U8(skb, IFLA_OPERSTATE, operstate);
+	NLA_PUT_U8(skb, IFLA_OPERSTATE, dev_get_operstate(dev));
 
 	if (dev->addr_len)
 		NLA_PUT(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr);
diff --git a/net/core/dev.c b/net/core/dev.c
index 9174c77..e328b2c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3341,6 +3341,30 @@ static void dev_addr_discard(struct net_device *dev)
 }
 
 /**
+ *	dev_get_operstate - get the state to report to userspace
+ *	@dev: device
+ *
+ *	Get the current interface state, as per RFC2863.
+ *	See Documentation/networking/operstates.txt
+ */
+unsigned char dev_get_operstate(const struct net_device *dev)
+{
+	if (netif_running(dev)) {
+		if (!netif_carrier_ok(dev))
+			if (dev->ifindex != dev->iflink)
+				return IF_OPER_LOWERLAYERDOWN;
+			else
+				return IF_OPER_DOWN;
+		else if (netif_dormant(dev) || netif_userspace_dormant(dev))
+			return IF_OPER_DORMANT;
+		else
+			return IF_OPER_UP;
+	}
+	else
+		return IF_OPER_DOWN;
+}
+
+/**
  *	dev_get_flags - get flags reported to userspace
  *	@dev: device
  *
@@ -4958,6 +4982,7 @@ EXPORT_SYMBOL(unregister_netdevice);
 EXPORT_SYMBOL(unregister_netdevice_notifier);
 EXPORT_SYMBOL(net_enable_timestamp);
 EXPORT_SYMBOL(net_disable_timestamp);
+EXPORT_SYMBOL(dev_get_operstate);
 EXPORT_SYMBOL(dev_get_flags);
 
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index bf8f7af..89fa3b8 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -38,42 +38,14 @@ static DECLARE_DELAYED_WORK(linkwatch_work, linkwatch_event);
 static struct net_device *lweventlist;
 static DEFINE_SPINLOCK(lweventlist_lock);
 
-static unsigned char default_operstate(const struct net_device *dev)
+/* Set the user-space dormant flag if link_mode calls for it so that
+ * the correct operstate is reported. */
+static void set_default_operstate(struct net_device *dev)
 {
-	if (!netif_carrier_ok(dev))
-		return (dev->ifindex != dev->iflink ?
-			IF_OPER_LOWERLAYERDOWN : IF_OPER_DOWN);
-
-	if (netif_dormant(dev))
-		return IF_OPER_DORMANT;
-
-	return IF_OPER_UP;
-}
-
-
-static void rfc2863_policy(struct net_device *dev)
-{
-	unsigned char operstate = default_operstate(dev);
-
-	if (operstate == dev->operstate)
-		return;
-
-	write_lock_bh(&dev_base_lock);
-
-	switch(dev->link_mode) {
-	case IF_LINK_MODE_DORMANT:
-		if (operstate == IF_OPER_UP)
-			operstate = IF_OPER_DORMANT;
-		break;
-
-	case IF_LINK_MODE_DEFAULT:
-	default:
-		break;
-	}
-
-	dev->operstate = operstate;
-
-	write_unlock_bh(&dev_base_lock);
+	if (dev->link_mode == IF_LINK_MODE_DORMANT && netif_oper_up(dev))
+		netif_userspace_dormant_on(dev);
+	else
+		netif_userspace_dormant_off(dev);
 }
 
 
@@ -178,7 +150,8 @@ static void __linkwatch_run_queue(int urgent_only)
 		 */
 		clear_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state);
 
-		rfc2863_policy(dev);
+		set_default_operstate(dev);
+
 		if (dev->flags & IFF_UP) {
 			if (netif_carrier_ok(dev))
 				dev_activate(dev);
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 92d6b94..ea90f43 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -156,9 +156,7 @@ static ssize_t show_operstate(struct device *dev,
 	unsigned char operstate;
 
 	read_lock(&dev_base_lock);
-	operstate = netdev->operstate;
-	if (!netif_running(netdev))
-		operstate = IF_OPER_DOWN;
+	operstate = dev_get_operstate(netdev);
 	read_unlock(&dev_base_lock);
 
 	if (operstate >= ARRAY_SIZE(operstates))
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 4dfb6b4..f03bacf 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -525,29 +525,23 @@ EXPORT_SYMBOL_GPL(rtnl_put_cacheinfo);
 
 static void set_operstate(struct net_device *dev, unsigned char transition)
 {
-	unsigned char operstate = dev->operstate;
+	int oldstate = netif_userspace_dormant(dev);
+
+	if (!netif_oper_up(dev))
+		return;
 
 	switch(transition) {
 	case IF_OPER_UP:
-		if ((operstate == IF_OPER_DORMANT ||
-		     operstate == IF_OPER_UNKNOWN) &&
-		    !netif_dormant(dev))
-			operstate = IF_OPER_UP;
+		netif_userspace_dormant_off(dev);
 		break;
 
 	case IF_OPER_DORMANT:
-		if (operstate == IF_OPER_UP ||
-		    operstate == IF_OPER_UNKNOWN)
-			operstate = IF_OPER_DORMANT;
+		netif_userspace_dormant_on(dev);
 		break;
 	}
 
-	if (dev->operstate != operstate) {
-		write_lock_bh(&dev_base_lock);
-		dev->operstate = operstate;
-		write_unlock_bh(&dev_base_lock);
+	if (oldstate != netif_userspace_dormant(dev))
 		netdev_state_change(dev);
-	}
 }
 
 static void copy_rtnl_link_stats(struct rtnl_link_stats *a,
@@ -626,8 +620,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 
 	NLA_PUT_STRING(skb, IFLA_IFNAME, dev->name);
 	NLA_PUT_U32(skb, IFLA_TXQLEN, dev->tx_queue_len);
-	NLA_PUT_U8(skb, IFLA_OPERSTATE,
-		   netif_running(dev) ? dev->operstate : IF_OPER_DOWN);
+	NLA_PUT_U8(skb, IFLA_OPERSTATE, dev_get_operstate(dev));
 	NLA_PUT_U8(skb, IFLA_LINKMODE, dev->link_mode);
 	NLA_PUT_U32(skb, IFLA_MTU, dev->mtu);
 
-- 
1.6.0.4
