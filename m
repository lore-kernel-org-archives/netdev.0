From: sfeldma@gmail.com
Subject: [PATCH net-next v3 2/4] switchdev: skip over ports returning -EOPNOTSUPP when recursing ports
Date: Thu,  8 Oct 2015 19:23:18 -0700
Message-ID: <1444357400-37078-3-git-send-email-sfeldma@gmail.com>
References: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
Cc: davem@davemloft.net, jiri@resnulli.us, siva.mannem.lnx@gmail.com,
	pjonnala@broadcom.com, stephen@networkplumber.org,
	roopa@cumulusnetworks.com, andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34633 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932262AbbJICUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 22:20:25 -0400
Received: by padhy16 with SMTP id hy16so71428235pad.1
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 19:20:25 -0700 (PDT)
In-Reply-To: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

This allows us to recurse over all the ports, skipping over unsupporting
ports.  Without the change, the recursion would stop at first unsupported
port.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |    1 +
 net/switchdev/switchdev.c |    9 ++++++++-
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 61f129b..1ce7083 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -16,6 +16,7 @@
 #include <linux/list.h>
 
 #define SWITCHDEV_F_NO_RECURSE		BIT(0)
+#define SWITCHDEV_F_SKIP_EOPNOTSUPP	BIT(1)
 
 struct switchdev_trans_item {
 	struct list_head list;
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 6e4a4f9..7a9ab90 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -147,7 +147,7 @@ static int __switchdev_port_attr_set(struct net_device *dev,
 		return ops->switchdev_port_attr_set(dev, attr, trans);
 
 	if (attr->flags & SWITCHDEV_F_NO_RECURSE)
-		return err;
+		goto done;
 
 	/* Switch device port(s) may be stacked under
 	 * bond/team/vlan dev, so recurse down to set attr on
@@ -156,10 +156,17 @@ static int __switchdev_port_attr_set(struct net_device *dev,
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
 		err = __switchdev_port_attr_set(lower_dev, attr, trans);
+		if (err == -EOPNOTSUPP &&
+		    attr->flags & SWITCHDEV_F_SKIP_EOPNOTSUPP)
+			continue;
 		if (err)
 			break;
 	}
 
+done:
+	if (err == -EOPNOTSUPP && attr->flags & SWITCHDEV_F_SKIP_EOPNOTSUPP)
+		err = 0;
+
 	return err;
 }
 
-- 
1.7.10.4
