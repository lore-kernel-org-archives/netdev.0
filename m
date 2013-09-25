From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v3 1/2] dev: update __dev_notify_flags() to send rtnl msg
Date: Wed, 25 Sep 2013 12:02:44 +0200
Message-ID: <1380103365-5185-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20130924094707.41641042@nehalam.linuxnetplumber.net>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:36474 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832Ab3IYKC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 06:02:57 -0400
In-Reply-To: <20130924094707.41641042@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch only prepares the next one, there is no functional change.
Now, __dev_notify_flags() can also be used to notify flags changes via
rtnetlink.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v3: add patch #1
    use __dev_notify_flags() to notify rxflags (note that notifier chains are
    not called when flags IFF_PROMISC and IFF_ALLMULTI are changed)

v2: rework the patch to avoid double notification

 include/linux/netdevice.h |  4 +++-
 net/core/dev.c            | 11 ++++++-----
 net/core/rtnetlink.c      |  3 +--
 3 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3de49aca4519..4466db0cb673 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2368,7 +2368,9 @@ extern int		dev_ethtool(struct net *net, struct ifreq *);
 extern unsigned int	dev_get_flags(const struct net_device *);
 extern int		__dev_change_flags(struct net_device *, unsigned int flags);
 extern int		dev_change_flags(struct net_device *, unsigned int);
-extern void		__dev_notify_flags(struct net_device *, unsigned int old_flags);
+void			__dev_notify_flags(struct net_device *,
+					   unsigned int old_flags,
+					   unsigned int gchanges);
 extern int		dev_change_name(struct net_device *, const char *);
 extern int		dev_set_alias(struct net_device *, const char *, size_t);
 extern int		dev_change_net_namespace(struct net_device *,
diff --git a/net/core/dev.c b/net/core/dev.c
index 5c713f2239cc..1222309feeaa 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5069,10 +5069,14 @@ int __dev_change_flags(struct net_device *dev, unsigned int flags)
 	return ret;
 }
 
-void __dev_notify_flags(struct net_device *dev, unsigned int old_flags)
+void __dev_notify_flags(struct net_device *dev, unsigned int old_flags,
+			unsigned int gchanges)
 {
 	unsigned int changes = dev->flags ^ old_flags;
 
+	if (gchanges)
+		rtmsg_ifinfo(RTM_NEWLINK, dev, gchanges);
+
 	if (changes & IFF_UP) {
 		if (dev->flags & IFF_UP)
 			call_netdevice_notifiers(NETDEV_UP, dev);
@@ -5108,10 +5112,7 @@ int dev_change_flags(struct net_device *dev, unsigned int flags)
 		return ret;
 
 	changes = old_flags ^ dev->flags;
-	if (changes)
-		rtmsg_ifinfo(RTM_NEWLINK, dev, changes);
-
-	__dev_notify_flags(dev, old_flags);
+	__dev_notify_flags(dev, old_flags, changes);
 	return ret;
 }
 EXPORT_SYMBOL(dev_change_flags);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2a0e21de3060..4aedf03da052 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1647,9 +1647,8 @@ int rtnl_configure_link(struct net_device *dev, const struct ifinfomsg *ifm)
 	}
 
 	dev->rtnl_link_state = RTNL_LINK_INITIALIZED;
-	rtmsg_ifinfo(RTM_NEWLINK, dev, ~0U);
 
-	__dev_notify_flags(dev, old_flags);
+	__dev_notify_flags(dev, old_flags, ~0U);
 	return 0;
 }
 EXPORT_SYMBOL(rtnl_configure_link);
-- 
1.8.2.1
