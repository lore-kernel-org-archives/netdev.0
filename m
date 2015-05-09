From: sfeldma@gmail.com
Subject: [PATCH net-next v6 10/23] switchdev: add bridge port flags attr
Date: Sat,  9 May 2015 10:40:12 -0700
Message-ID: <1431193225-807-11-git-send-email-sfeldma@gmail.com>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:36090 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545AbbEIRn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 13:43:27 -0400
Received: by pdea3 with SMTP id a3so114737108pde.3
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 10:43:27 -0700 (PDT)
In-Reply-To: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

rocker: use switchdev get/set attr for bridge port flags

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   24 ++++++++++++++++++++++++
 include/net/switchdev.h              |    2 ++
 2 files changed, 26 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 048d4b7..f9281ea 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4346,6 +4346,9 @@ static int rocker_port_attr_get(struct net_device *dev,
 		attr->ppid.id_len = sizeof(rocker->hw.id);
 		memcpy(&attr->ppid.id, &rocker->hw.id, attr->ppid.id_len);
 		break;
+	case SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS:
+		attr->brport_flags = rocker_port->brport_flags;
+		break;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -4363,6 +4366,23 @@ static void rocker_port_trans_abort(struct rocker_port *rocker_port)
 	}
 }
 
+static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
+					unsigned long brport_flags)
+{
+	unsigned long orig_flags;
+	int err = 0;
+
+	orig_flags = rocker_port->brport_flags;
+	rocker_port->brport_flags = brport_flags;
+	if ((orig_flags ^ rocker_port->brport_flags) & BR_LEARNING)
+		err = rocker_port_set_learning(rocker_port);
+
+	if (rocker_port->trans == SWITCHDEV_TRANS_PREPARE)
+		rocker_port->brport_flags = orig_flags;
+
+	return err;
+}
+
 static int rocker_port_attr_set(struct net_device *dev,
 				struct switchdev_attr *attr)
 {
@@ -4386,6 +4406,10 @@ static int rocker_port_attr_set(struct net_device *dev,
 	case SWITCHDEV_ATTR_PORT_STP_STATE:
 		err = rocker_port_stp_update(rocker_port, attr->stp_state);
 		break;
+	case SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS:
+		err = rocker_port_brport_flags_set(rocker_port,
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
