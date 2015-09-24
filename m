From: sfeldma@gmail.com
Subject: [PATCH net-next 4/4] rocker: handle setting bridge ageing_time
Date: Thu, 24 Sep 2015 13:59:30 -0700
Message-ID: <1443128370-27353-5-git-send-email-sfeldma@gmail.com>
References: <1443128370-27353-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36755 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754111AbbIXU4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 16:56:39 -0400
Received: by pacgz1 with SMTP id gz1so673447pac.3
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 13:56:38 -0700 (PDT)
In-Reply-To: <1443128370-27353-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

The FDB cleanup timer will get rescheduled to re-evaluate FDB entries
based on new ageing_time.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 32c5429..99ec715 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4382,6 +4382,24 @@ static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
 	return err;
 }
 
+static int rocker_port_bridge_set(struct rocker_port *rocker_port,
+				  enum switchdev_trans trans,
+				  struct switchdev_attr_bridge *bridge)
+{
+	switch (bridge->attr) {
+	case IFLA_BR_AGEING_TIME:
+		if (trans == SWITCHDEV_TRANS_PREPARE)
+			return 0;
+		rocker_port->ageing_time = clock_t_to_jiffies(bridge->val);
+		mod_timer(&rocker_port->rocker->fdb_cleanup_timer, jiffies);
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
 static int rocker_port_attr_set(struct net_device *dev,
 				struct switchdev_attr *attr)
 {
@@ -4409,6 +4427,10 @@ static int rocker_port_attr_set(struct net_device *dev,
 		err = rocker_port_brport_flags_set(rocker_port, attr->trans,
 						   attr->u.brport_flags);
 		break;
+	case SWITCHDEV_ATTR_BRIDGE:
+		err = rocker_port_bridge_set(rocker_port, attr->trans,
+					     &attr->u.bridge);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
-- 
1.7.10.4
