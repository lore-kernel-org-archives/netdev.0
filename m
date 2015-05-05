From: sfeldma@gmail.com
Subject: [PATCH net-next v5 09/21] switchdev: add bridge port flags attr
Date: Tue,  5 May 2015 10:34:45 -0700
Message-ID: <1430847297-15728-10-git-send-email-sfeldma@gmail.com>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:34626 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965346AbbEEReL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 13:34:11 -0400
Received: by pdbqa5 with SMTP id qa5so202981953pdb.1
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 10:34:10 -0700 (PDT)
In-Reply-To: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
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
index 7060311..067a4ec2 100644
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
@@ -4387,6 +4407,10 @@ static int rocker_port_attr_set(struct net_device *dev,
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
