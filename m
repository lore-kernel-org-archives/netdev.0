From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ipv6: reorder ip6_route_dev_notifier after ipv6_dev_notf
Date: Wed,  3 May 2017 22:07:32 -0700
Message-ID: <1493874452-3050-2-git-send-email-xiyou.wangcong@gmail.com>
Cc: andreyknvl@google.com, dsahern@gmail.com,
        Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:32998 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754164AbdEDFHq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 01:07:46 -0400
Received: by mail-pg0-f66.google.com with SMTP id s62so654301pgc.0
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 22:07:46 -0700 (PDT)
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
net->loopback_dev's idev, so we have to do that after we add
idev to it. However, this notifier has priority == 0 same as
ipv6_dev_notf, and ipv6_dev_notf is registered after
ip6_route_dev_notifier so it is called actually after
ip6_route_dev_notifier.

Fix it by specifying a smaller priority for ip6_route_dev_notifier.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 2f11366..4dbf7e2 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -4024,7 +4024,7 @@ static struct pernet_operations ip6_route_net_late_ops = {
 
 static struct notifier_block ip6_route_dev_notifier = {
 	.notifier_call = ip6_route_dev_notify,
-	.priority = 0,
+	.priority = -10, /* Must be called after addrconf_notify!! */
 };
 
 void __init ip6_route_init_special_entries(void)
-- 
2.5.5
