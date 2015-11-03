From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] switchdev: respect SKIP_EOPNOTSUPP flag in case there is no recursion
Date: Tue,  3 Nov 2015 17:40:53 +0100
Message-ID: <1446568853-8705-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:33623 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562AbbKCQk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 11:40:56 -0500
Received: by wijp11 with SMTP id p11so75605415wij.0
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 08:40:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Caller passing down the SKIP_EOPNOTSUPP switchdev flag expects that
-EOPNOTSUPP cannot be returned. But in case of direct op call without
recurtion, this may happen. So fix this by checking it always on the
end of __switchdev_port_attr_set function.

Fixes: 464314ea6c11 ("switchdev: skip over ports returning -EOPNOTSUPP when recursing ports")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/switchdev/switchdev.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 6dfd19e..f34e535 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -225,8 +225,10 @@ static int __switchdev_port_attr_set(struct net_device *dev,
 	struct list_head *iter;
 	int err = -EOPNOTSUPP;
 
-	if (ops && ops->switchdev_port_attr_set)
-		return ops->switchdev_port_attr_set(dev, attr, trans);
+	if (ops && ops->switchdev_port_attr_set) {
+		err = ops->switchdev_port_attr_set(dev, attr, trans);
+		goto done;
+	}
 
 	if (attr->flags & SWITCHDEV_F_NO_RECURSE)
 		goto done;
@@ -238,9 +240,6 @@ static int __switchdev_port_attr_set(struct net_device *dev,
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
 		err = __switchdev_port_attr_set(lower_dev, attr, trans);
-		if (err == -EOPNOTSUPP &&
-		    attr->flags & SWITCHDEV_F_SKIP_EOPNOTSUPP)
-			continue;
 		if (err)
 			break;
 	}
-- 
1.9.3
