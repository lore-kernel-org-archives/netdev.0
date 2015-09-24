From: sfeldma@gmail.com
Subject: [PATCH net-next 2/4] switchdev: skip over ports returning -EOPNOTSUPP when recursing ports
Date: Thu, 24 Sep 2015 13:59:28 -0700
Message-ID: <1443128370-27353-3-git-send-email-sfeldma@gmail.com>
References: <1443128370-27353-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33598 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897AbbIXU4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 16:56:41 -0400
Received: by pacex6 with SMTP id ex6so83046349pac.0
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 13:56:40 -0700 (PDT)
In-Reply-To: <1443128370-27353-1-git-send-email-sfeldma@gmail.com>
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
index 54b2faa..22a6dbe 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -15,6 +15,7 @@
 #include <linux/notifier.h>
 
 #define SWITCHDEV_F_NO_RECURSE		BIT(0)
+#define SWITCHDEV_F_SKIP_EOPNOTSUPP	BIT(1)
 
 enum switchdev_trans {
 	SWITCHDEV_TRANS_NONE,
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index fda38f8..5c30da0 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -73,7 +73,7 @@ static int __switchdev_port_attr_set(struct net_device *dev,
 		return ops->switchdev_port_attr_set(dev, attr);
 
 	if (attr->flags & SWITCHDEV_F_NO_RECURSE)
-		return err;
+		goto done;
 
 	/* Switch device port(s) may be stacked under
 	 * bond/team/vlan dev, so recurse down to set attr on
@@ -82,10 +82,17 @@ static int __switchdev_port_attr_set(struct net_device *dev,
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
 		err = __switchdev_port_attr_set(lower_dev, attr);
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
