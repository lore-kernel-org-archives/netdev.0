From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/12] switchdev: Add support for flood control
Date: Wed, 28 Oct 2015 10:16:54 +0100
Message-ID: <1446023825-7162-2-git-send-email-jiri@resnulli.us>
References: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, sagir@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:37544 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932124AbbJ1JRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 05:17:14 -0400
Received: by wicfv8 with SMTP id fv8so4704119wic.0
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 02:17:13 -0700 (PDT)
In-Reply-To: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Allow devices supporting this feature to control the flooding of unknown
unicast traffic, by making switchdev infrastructure propagate this setting
to the switch driver.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 Documentation/networking/switchdev.txt | 3 +++
 net/switchdev/switchdev.c              | 5 ++++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index 0714fe5..ce510e1 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -298,6 +298,9 @@ packets up to the bridge driver for flooding.  This is not ideal as the number
 of ports scale in the L2 domain as the device is much more efficient at
 flooding packets that software.
 
+If supported by the device, flood control can be offloaded to it, preventing
+certain netdevs from flooding unicast traffic for which there is no FDB entry.
+
 IGMP Snooping
 ^^^^^^^^^^^^^
 
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 1eb76956..8950d39 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -746,7 +746,7 @@ int switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 		.id = SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
 	};
 	u16 mode = BRIDGE_MODE_UNDEF;
-	u32 mask = BR_LEARNING | BR_LEARNING_SYNC;
+	u32 mask = BR_LEARNING | BR_LEARNING_SYNC | BR_FLOOD;
 	int err;
 
 	err = switchdev_port_attr_get(dev, &attr);
@@ -817,6 +817,9 @@ static int switchdev_port_br_setlink_protinfo(struct net_device *dev,
 			err = switchdev_port_br_setflag(dev, attr,
 							BR_LEARNING_SYNC);
 			break;
+		case IFLA_BRPORT_UNICAST_FLOOD:
+			err = switchdev_port_br_setflag(dev, attr, BR_FLOOD);
+			break;
 		default:
 			err = -EOPNOTSUPP;
 			break;
-- 
1.9.3
