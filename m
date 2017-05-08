From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v3] ipv6: reorder ip6_route_dev_notifier after ipv6_dev_notf
Date: Mon,  8 May 2017 10:12:13 -0700
Message-ID: <1494263533-22325-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: andreyknvl@google.com, dsahern@gmail.com,
        Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33000 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753819AbdEHRM1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 13:12:27 -0400
Received: by mail-pf0-f195.google.com with SMTP id b23so10588870pfc.0
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 10:12:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For each netns (except init_net), we initialize its null entry
in 3 places:

1) The template itself, as we use kmemdup()
2) Code around dst_init_metrics() in ip6_route_net_init()
3) ip6_route_dev_notify(), which is supposed to initialize it after
   loopback registers

Unfortunately the last one still happens in a wrong order because
we expect to initialize net->ipv6.ip6_null_entry->rt6i_idev to
net->loopback_dev's idev, thus we have to do that after we add
idev to loopback. However, this notifier has priority == 0 same as
ipv6_dev_notf, and ipv6_dev_notf is registered after
ip6_route_dev_notifier so it is called actually after
ip6_route_dev_notifier. This is similar to commit 2f460933f58e
("ipv6: initialize route null entry in addrconf_init()") which
fixes init_net.

Fix it by picking a smaller priority for ip6_route_dev_notifier.
Also, we have to release the refcnt accordingly when unregistering
loopback_dev because device exit functions are called before subsys
exit functions.

Acked-by: David Ahern <dsahern@gmail.com>
Tested-by: David Ahern <dsahern@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/addrconf.h |  2 ++
 net/ipv6/addrconf.c    |  1 +
 net/ipv6/route.c       | 13 +++++++++++--
 3 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 2452e64..b43a4ee 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -20,6 +20,8 @@
 #define ADDRCONF_TIMER_FUZZ		(HZ / 4)
 #define ADDRCONF_TIMER_FUZZ_MAX		(HZ)
 
+#define ADDRCONF_NOTIFY_PRIORITY	0
+
 #include <linux/in.h>
 #include <linux/in6.h>
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 77a4bd5..8d297a7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3548,6 +3548,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
  */
 static struct notifier_block ipv6_dev_notf = {
 	.notifier_call = addrconf_notify,
+	.priority = ADDRCONF_NOTIFY_PRIORITY,
 };
 
 static void addrconf_type_change(struct net_device *dev, unsigned long event)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 2f11366..dc61b0b 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3709,7 +3709,10 @@ static int ip6_route_dev_notify(struct notifier_block *this,
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 	struct net *net = dev_net(dev);
 
-	if (event == NETDEV_REGISTER && (dev->flags & IFF_LOOPBACK)) {
+	if (!(dev->flags & IFF_LOOPBACK))
+		return NOTIFY_OK;
+
+	if (event == NETDEV_REGISTER) {
 		net->ipv6.ip6_null_entry->dst.dev = dev;
 		net->ipv6.ip6_null_entry->rt6i_idev = in6_dev_get(dev);
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
@@ -3718,6 +3721,12 @@ static int ip6_route_dev_notify(struct notifier_block *this,
 		net->ipv6.ip6_blk_hole_entry->dst.dev = dev;
 		net->ipv6.ip6_blk_hole_entry->rt6i_idev = in6_dev_get(dev);
 #endif
+	 } else if (event == NETDEV_UNREGISTER) {
+		in6_dev_put(net->ipv6.ip6_null_entry->rt6i_idev);
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+		in6_dev_put(net->ipv6.ip6_prohibit_entry->rt6i_idev);
+		in6_dev_put(net->ipv6.ip6_blk_hole_entry->rt6i_idev);
+#endif
 	}
 
 	return NOTIFY_OK;
@@ -4024,7 +4033,7 @@ static struct pernet_operations ip6_route_net_late_ops = {
 
 static struct notifier_block ip6_route_dev_notifier = {
 	.notifier_call = ip6_route_dev_notify,
-	.priority = 0,
+	.priority = ADDRCONF_NOTIFY_PRIORITY - 10,
 };
 
 void __init ip6_route_init_special_entries(void)
-- 
2.5.5
