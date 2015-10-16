From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/16] net: introduce pre-change upper device notifier
Date: Fri, 16 Oct 2015 14:01:22 +0200
Message-ID: <1444996897-2708-2-git-send-email-jiri@resnulli.us>
References: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org, tgraf@suug.ch, jhs@mojatatu.com,
	sagir@mellanox.com, mattyk@mellanox.com, aviadr@mellanox.com
To: netdev@vger.kernel.org, ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:38603 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753525AbbJPMBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 08:01:42 -0400
Received: by wicll6 with SMTP id ll6so7343372wic.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 05:01:41 -0700 (PDT)
In-Reply-To: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This newly introduced netdevice notifier is called before actual change
upper happens. That provides a possibility for notifier handlers to
know upper change will happen and react to it, including possibility to
forbid the change. That is valuable for drivers which can check if the
upper device linkage is supported and forbid that in case it is not.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/netdevice.h | 1 +
 net/core/dev.c            | 9 +++++++++
 2 files changed, 10 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b337440..69fdd42 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2106,6 +2106,7 @@ struct pcpu_sw_netstats {
 #define NETDEV_PRECHANGEMTU	0x0017 /* notify before mtu change happened */
 #define NETDEV_CHANGEINFODATA	0x0018
 #define NETDEV_BONDING_INFO	0x0019
+#define NETDEV_PRECHANGEUPPER	0x001A
 
 int register_netdevice_notifier(struct notifier_block *nb);
 int unregister_netdevice_notifier(struct notifier_block *nb);
diff --git a/net/core/dev.c b/net/core/dev.c
index a229bf0..1225b4b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5346,6 +5346,12 @@ static int __netdev_upper_dev_link(struct net_device *dev,
 	changeupper_info.master = master;
 	changeupper_info.linking = true;
 
+	ret = call_netdevice_notifiers_info(NETDEV_PRECHANGEUPPER, dev,
+					    &changeupper_info.info);
+	ret = notifier_to_errno(ret);
+	if (ret)
+		return ret;
+
 	ret = __netdev_adjacent_dev_link_neighbour(dev, upper_dev, private,
 						   master);
 	if (ret)
@@ -5488,6 +5494,9 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 	changeupper_info.master = netdev_master_upper_dev_get(dev) == upper_dev;
 	changeupper_info.linking = false;
 
+	call_netdevice_notifiers_info(NETDEV_PRECHANGEUPPER, dev,
+				      &changeupper_info.info);
+
 	__netdev_adjacent_dev_unlink_neighbour(dev, upper_dev);
 
 	/* Here is the tricky part. We must remove all dev's lower
-- 
1.9.3
