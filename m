From: sfeldma@gmail.com
Subject: [PATCH net-next v2 05/26] rocker: use swdev get/set attr for bridge port flags
Date: Wed,  1 Apr 2015 03:07:41 -0700
Message-ID: <1427882882-2533-6-git-send-email-sfeldma@gmail.com>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34320 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597AbbDAKGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 06:06:34 -0400
Received: by pactp5 with SMTP id tp5so47801216pac.1
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 03:06:34 -0700 (PDT)
In-Reply-To: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 1b29b0a..7602973 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4230,6 +4230,9 @@ static int rocker_port_attr_get(struct net_device *dev, struct swdev_attr *attr)
 		attr->ppid.id_len = sizeof(rocker->hw.id);
 		memcpy(&attr->ppid.id, &rocker->hw.id, attr->ppid.id_len);
 		break;
+	case SWDEV_ATTR_PORT_BRIDGE_FLAGS:
+		attr->brport_flags = rocker_port->brport_flags;
+		break;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -4240,12 +4243,19 @@ static int rocker_port_attr_get(struct net_device *dev, struct swdev_attr *attr)
 static int rocker_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
+	unsigned long orig_flags;
 	int err = 0;
 
 	switch (attr->id) {
 	case SWDEV_ATTR_PORT_STP_STATE:
 		err = rocker_port_stp_update(rocker_port, attr->stp_state);
 		break;
+	case SWDEV_ATTR_PORT_BRIDGE_FLAGS:
+		orig_flags = rocker_port->brport_flags;
+		rocker_port->brport_flags = attr->brport_flags;
+		if ((orig_flags ^ rocker_port->brport_flags) & BR_LEARNING)
+			err = rocker_port_set_learning(rocker_port);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
-- 
1.7.10.4
