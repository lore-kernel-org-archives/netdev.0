From: sfeldma@gmail.com
Subject: [PATCH net-next v4 05/24] rocker: use swdev get/set attr for bridge port flags
Date: Sun, 12 Apr 2015 23:16:59 -0700
Message-ID: <1428905838-14920-6-git-send-email-sfeldma@gmail.com>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:35073 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753387AbbDMGQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 02:16:38 -0400
Received: by pddn5 with SMTP id n5so96463310pdd.2
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 23:16:37 -0700 (PDT)
In-Reply-To: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   31 +++++++++++++++++++++++++++++--
 1 file changed, 29 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 80c7f6f..9bd4fc6 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -359,6 +359,8 @@ static void *__rocker_port_alloc(struct rocker_port *rocker_port,
 		if (elem)
 			INIT_LIST_HEAD(elem);
 		break;
+	default:
+		break;
 	}
 
 	return elem ? elem + 1 : NULL;
@@ -4332,6 +4334,9 @@ static int rocker_port_attr_get(struct net_device *dev, struct swdev_attr *attr)
 		attr->ppid.id_len = sizeof(rocker->hw.id);
 		memcpy(&attr->ppid.id, &rocker->hw.id, attr->ppid.id_len);
 		break;
+	case SWDEV_ATTR_PORT_BRIDGE_FLAGS:
+		attr->brport_flags = rocker_port->brport_flags;
+		break;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -4349,6 +4354,23 @@ static void rocker_port_trans_abort(struct rocker_port *rocker_port)
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
+	if (rocker_port->trans == SWDEV_TRANS_PREPARE)
+		rocker_port->brport_flags = orig_flags;
+
+	return err;
+}
+
 static int rocker_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
@@ -4363,12 +4385,18 @@ static int rocker_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
 	case SWDEV_TRANS_ABORT:
 		rocker_port_trans_abort(rocker_port);
 		return 0;
+	default:
+		break;
 	}
 
 	switch (attr->id) {
 	case SWDEV_ATTR_PORT_STP_STATE:
 		err = rocker_port_stp_update(rocker_port, attr->stp_state);
 		break;
+	case SWDEV_ATTR_PORT_BRIDGE_FLAGS:
+		err = rocker_port_brport_flags_set(rocker_port,
+						   attr->brport_flags);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -4772,8 +4800,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_carrier_init(rocker_port);
 
 	dev->features |= NETIF_F_NETNS_LOCAL |
-			 NETIF_F_HW_VLAN_CTAG_FILTER |
-			 NETIF_F_HW_SWITCH_OFFLOAD;
+			 NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	err = register_netdev(dev);
 	if (err) {
-- 
1.7.10.4
