From: Jiri Kosina <jkosina@suse.cz>
Subject: Subject: [PATCH] Revert "[RTNETLINK]: Send a single notification on
 device state changes."
Date: Mon, 18 Feb 2008 00:31:09 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0802180027331.30955@jikos.suse.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org,
	Laszlo Attila Toth <panther@balabit.hu>,
	Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	=?ISO-8859-2?Q?Fran=E7ois_Valenduc?=
	<francois.valenduc@tvcablenet.be>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757553AbYBQXbW@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit 45b503548210fe6f23e92b856421c2a3f05fd034.

It contains deadlock, and breaks userspace applications (wpa_supplicant,
networkmanager). References:

http://bugzilla.kernel.org/show_bug.cgi?id=10002
http://bugzilla.kernel.org/show_bug.cgi?id=10002
---
 net/core/rtnetlink.c |   36 ++++++++++--------------------------
 1 files changed, 10 insertions(+), 26 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index ecb02af..61ac8d0 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -504,7 +504,7 @@ int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst, u32 id,
 
 EXPORT_SYMBOL_GPL(rtnl_put_cacheinfo);
 
-static int set_operstate(struct net_device *dev, unsigned char transition, bool send_notification)
+static void set_operstate(struct net_device *dev, unsigned char transition)
 {
 	unsigned char operstate = dev->operstate;
 
@@ -527,12 +527,8 @@ static int set_operstate(struct net_device *dev, unsigned char transition, bool
 		write_lock_bh(&dev_base_lock);
 		dev->operstate = operstate;
 		write_unlock_bh(&dev_base_lock);
-
-		if (send_notification)
-			netdev_state_change(dev);
-		return 1;
-	} else
-		return 0;
+		netdev_state_change(dev);
+	}
 }
 
 static void copy_rtnl_link_stats(struct rtnl_link_stats *a,
@@ -826,7 +822,6 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	if (tb[IFLA_BROADCAST]) {
 		nla_memcpy(dev->broadcast, tb[IFLA_BROADCAST], dev->addr_len);
 		send_addr_notify = 1;
-		modified = 1;
 	}
 
 	if (ifm->ifi_flags || ifm->ifi_change) {
@@ -839,23 +834,16 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		dev_change_flags(dev, flags);
 	}
 
-	if (tb[IFLA_TXQLEN]) {
-		if (dev->tx_queue_len != nla_get_u32(tb[IFLA_TXQLEN])) {
-			dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
-			modified = 1;
-		}
-	}
+	if (tb[IFLA_TXQLEN])
+		dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
 
 	if (tb[IFLA_OPERSTATE])
-		modified |= set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]), false);
+		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
 
 	if (tb[IFLA_LINKMODE]) {
-		if (dev->link_mode != nla_get_u8(tb[IFLA_LINKMODE])) {
-			write_lock_bh(&dev_base_lock);
-			dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
-			write_lock_bh(&dev_base_lock);
-			modified = 1;
-		}
+		write_lock_bh(&dev_base_lock);
+		dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
+		write_unlock_bh(&dev_base_lock);
 	}
 
 	err = 0;
@@ -869,10 +857,6 @@ errout:
 
 	if (send_addr_notify)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
-
-	if (modified)
-		netdev_state_change(dev);
-
 	return err;
 }
 
@@ -990,7 +974,7 @@ struct net_device *rtnl_create_link(struct net *net, char *ifname,
 	if (tb[IFLA_TXQLEN])
 		dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
 	if (tb[IFLA_OPERSTATE])
-		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]), true);
+		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
 	if (tb[IFLA_LINKMODE])
 		dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
 
-- 
1.5.2.4
