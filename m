From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH] core: Correct an over-stringent device loop detection.
Date: Sat,  2 May 2015 21:33:44 -0400
Message-ID: <1430616824-9006-1-git-send-email-vyasevic@redhat.com>
Cc: jpirko@redhat.com, vfalico@gmail.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:34815 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807AbbECBd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2015 21:33:58 -0400
Received: by qgfi89 with SMTP id i89so52371763qgf.1
        for <netdev@vger.kernel.org>; Sat, 02 May 2015 18:33:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code in __netdev_upper_dev_link() has an over-stringent
loop detection logic that actually prevents valid configurations
from working correctly.

In particular, the logic returns an error if an upper device
is already in the list of all upper devices for a given dev.
This particular check seems to be a overzealous as it disallows
perfectly valid configurations.  For example:
  # ip l a link eth0 name eth0.10 type vlan id 10
  # ip l a dev br0 typ bridge
  # ip l s eth0.10 master br0
  # ip l s eth0 master br0  <--- Will fail

If you switch the last two commands (add eth0 first), then both
will succeed.  If after that, you remove eth0 and try to re-add
it, it will fail!

It appears to be enough to simply check adj_list to keeps things
safe.

I've tried stacking multiple devices multiple times in all different
combinations, and either rx_handler registration prevented the stacking
of the device linking cought the error.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index c7ba038..2c1c67f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5209,7 +5209,7 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 	if (__netdev_find_adj(upper_dev, dev, &upper_dev->all_adj_list.upper))
 		return -EBUSY;
 
-	if (__netdev_find_adj(dev, upper_dev, &dev->all_adj_list.upper))
+	if (__netdev_find_adj(dev, upper_dev, &dev->adj_list.upper))
 		return -EEXIST;
 
 	if (master && netdev_master_upper_dev_get(dev))
-- 
1.9.3
