From: sfeldma@gmail.com
Subject: [PATCH net-next v7 10/24] switchdev: add bridge port flags attr
Date: Sun, 10 May 2015 09:47:55 -0700
Message-ID: <1431276489-64199-11-git-send-email-sfeldma@gmail.com>
References: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:33810 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715AbbEJQrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 12:47:11 -0400
Received: by pdbqa5 with SMTP id qa5so125545380pdb.1
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 09:47:11 -0700 (PDT)
In-Reply-To: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

rocker: use switchdev get/set attr for bridge port flags

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker.c |   25 +++++++++++++++++++++++++
 include/net/switchdev.h              |    2 ++
 2 files changed, 27 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 8408480..ceb6a64 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4394,6 +4394,9 @@ static int rocker_port_attr_get(struct net_device *dev,
 		attr->ppid.id_len = sizeof(rocker->hw.id);
 		memcpy(&attr->ppid.id, &rocker->hw.id, attr->ppid.id_len);
 		break;
+	case SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS:
+		attr->brport_flags = rocker_port->brport_flags;
+		break;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -4411,6 +4414,24 @@ static void rocker_port_trans_abort(struct rocker_port *rocker_port)
 	}
 }
 
+static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
+					enum switchdev_trans trans,
+					unsigned long brport_flags)
+{
+	unsigned long orig_flags;
+	int err = 0;
+
+	orig_flags = rocker_port->brport_flags;
+	rocker_port->brport_flags = brport_flags;
+	if ((orig_flags ^ rocker_port->brport_flags) & BR_LEARNING)
+		err = rocker_port_set_learning(rocker_port, trans);
+
+	if (trans == SWITCHDEV_TRANS_PREPARE)
+		rocker_port->brport_flags = orig_flags;
+
+	return err;
+}
+
 static int rocker_port_attr_set(struct net_device *dev,
 				struct switchdev_attr *attr)
 {
@@ -4433,6 +4454,10 @@ static int rocker_port_attr_set(struct net_device *dev,
 		err = rocker_port_stp_update(rocker_port, attr->trans,
 					     attr->stp_state);
 		break;
+	case SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS:
+		err = rocker_port_brport_flags_set(rocker_port, attr->trans,
+						   attr->brport_flags);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index e598c2d..6cf6de1 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -27,6 +27,7 @@ enum switchdev_attr_id {
 	SWITCHDEV_ATTR_UNDEFINED,
 	SWITCHDEV_ATTR_PORT_PARENT_ID,
 	SWITCHDEV_ATTR_PORT_STP_STATE,
+	SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS,
 };
 
 struct switchdev_attr {
@@ -36,6 +37,7 @@ struct switchdev_attr {
 	union {
 		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
 		u8 stp_state;				/* PORT_STP_STATE */
+		unsigned long brport_flags;		/* PORT_BRIDGE_FLAGS */
 	};
 };
 
-- 
1.7.10.4
