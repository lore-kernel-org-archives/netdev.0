From: sfeldma@gmail.com
Subject: [PATCH net-next v3 4/4] rocker: handle setting bridge ageing_time
Date: Thu,  8 Oct 2015 19:23:20 -0700
Message-ID: <1444357400-37078-5-git-send-email-sfeldma@gmail.com>
References: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
Cc: davem@davemloft.net, jiri@resnulli.us, siva.mannem.lnx@gmail.com,
	pjonnala@broadcom.com, stephen@networkplumber.org,
	roopa@cumulusnetworks.com, andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34692 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932265AbbJICU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 22:20:29 -0400
Received: by padhy16 with SMTP id hy16so71429582pad.1
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 19:20:28 -0700 (PDT)
In-Reply-To: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

The FDB cleanup timer will get rescheduled to re-evaluate FDB entries
based on new ageing_time.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index cf91ffc..eafa907 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4361,6 +4361,18 @@ static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
 	return err;
 }
 
+static int rocker_port_bridge_ageing_time(struct rocker_port *rocker_port,
+					  struct switchdev_trans *trans,
+					  u32 ageing_time)
+{
+	if (!switchdev_trans_ph_prepare(trans)) {
+		rocker_port->ageing_time = clock_t_to_jiffies(ageing_time);
+		mod_timer(&rocker_port->rocker->fdb_cleanup_timer, jiffies);
+	}
+
+	return 0;
+}
+
 static int rocker_port_attr_set(struct net_device *dev,
 				struct switchdev_attr *attr,
 				struct switchdev_trans *trans)
@@ -4378,6 +4390,10 @@ static int rocker_port_attr_set(struct net_device *dev,
 		err = rocker_port_brport_flags_set(rocker_port, trans,
 						   attr->u.brport_flags);
 		break;
+	case SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME:
+		err = rocker_port_bridge_ageing_time(rocker_port, trans,
+						     attr->u.ageing_time);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
-- 
1.7.10.4
