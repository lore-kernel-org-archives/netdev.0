From: sfeldma@gmail.com
Subject: [PATCH net-next v2 4/4] rocker: handle setting bridge ageing_time
Date: Wed,  7 Oct 2015 23:04:43 -0700
Message-ID: <1444284283-33601-5-git-send-email-sfeldma@gmail.com>
References: <1444284283-33601-1-git-send-email-sfeldma@gmail.com>
Cc: davem@davemloft.net, jiri@resnulli.us, siva.mannem.lnx@gmail.com,
	pjonnala@broadcom.com, stephen@networkplumber.org,
	roopa@cumulusnetworks.com, andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34266 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967AbbJHGBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 02:01:55 -0400
Received: by padhy16 with SMTP id hy16so44375641pad.1
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 23:01:54 -0700 (PDT)
In-Reply-To: <1444284283-33601-1-git-send-email-sfeldma@gmail.com>
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
index cf91ffc..3c7f9ae 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4361,6 +4361,24 @@ static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
 	return err;
 }
 
+static int rocker_port_bridge_set(struct rocker_port *rocker_port,
+				  struct switchdev_trans *trans,
+				  struct switchdev_attr_bridge *bridge)
+{
+	switch (bridge->attr) {
+	case IFLA_BR_AGEING_TIME:
+		if (switchdev_trans_ph_prepare(trans))
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
 				struct switchdev_attr *attr,
 				struct switchdev_trans *trans)
@@ -4378,6 +4396,10 @@ static int rocker_port_attr_set(struct net_device *dev,
 		err = rocker_port_brport_flags_set(rocker_port, trans,
 						   attr->u.brport_flags);
 		break;
+	case SWITCHDEV_ATTR_ID_BRIDGE:
+		err = rocker_port_bridge_set(rocker_port, trans,
+					     &attr->u.bridge);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
-- 
1.7.10.4
