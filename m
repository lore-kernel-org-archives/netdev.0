From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ipv6: only call ip6_route_dev_notify() once for NETDEV_UNREGISTER
Date: Tue, 20 Jun 2017 11:42:27 -0700
Message-ID: <1497984147-15011-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: jeffy.chen@rock-chips.com, Cong Wang <xiyou.wangcong@gmail.com>,
        David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34287 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750951AbdFTSmg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 14:42:36 -0400
Received: by mail-pg0-f67.google.com with SMTP id j186so23262314pge.1
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 11:42:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 242d3a49a2a1 ("ipv6: reorder ip6_route_dev_notifier after ipv6_dev_notf")
I assumed NETDEV_REGISTER and NETDEV_UNREGISTER are paired,
unfortunately, as reported by jeffy, netdev_wait_allrefs()
could rebroadcast NETDEV_UNREGISTER event until all refs are
gone.

We have to add an additional check to avoid this corner case.
For netdev_wait_allrefs() dev->reg_state is NETREG_UNREGISTERED,
for dev_change_net_namespace(), dev->reg_state is
NETREG_REGISTERED. So check for dev->reg_state != NETREG_UNREGISTERED.

Fixes: 242d3a49a2a1 ("ipv6: reorder ip6_route_dev_notifier after ipv6_dev_notf")
Reported-by: jeffy <jeffy.chen@rock-chips.com>
Cc: David Ahern <dsahern@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/route.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 7cebd95..322bd62 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3722,7 +3722,11 @@ static int ip6_route_dev_notify(struct notifier_block *this,
 		net->ipv6.ip6_blk_hole_entry->dst.dev = dev;
 		net->ipv6.ip6_blk_hole_entry->rt6i_idev = in6_dev_get(dev);
 #endif
-	 } else if (event == NETDEV_UNREGISTER) {
+	 } else if (event == NETDEV_UNREGISTER &&
+		    dev->reg_state != NETREG_UNREGISTERED) {
+		/* NETDEV_UNREGISTER could be fired for multiple times by
+		 * netdev_wait_allrefs(). Make sure we only call this once.
+		 */
 		in6_dev_put(net->ipv6.ip6_null_entry->rt6i_idev);
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 		in6_dev_put(net->ipv6.ip6_prohibit_entry->rt6i_idev);
-- 
2.5.5
