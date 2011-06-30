From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 2/5] ieee802154: support specifying hw address for created devices
Date: Thu, 30 Jun 2011 16:37:45 +0400
Message-ID: <1309437468-31021-3-git-send-email-dbaryshkov@gmail.com>
References: <1309437468-31021-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37174 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363Ab1F3MiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 08:38:08 -0400
Received: by mail-wy0-f174.google.com with SMTP id 8so1510445wyg.19
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2011 05:38:07 -0700 (PDT)
In-Reply-To: <1309437468-31021-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 net/ieee802154/nl-phy.c |   31 +++++++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index 02548b2..c64a38d 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -24,6 +24,7 @@
 
 #include <linux/kernel.h>
 #include <linux/slab.h>
+#include <linux/if_arp.h>
 #include <net/netlink.h>
 #include <net/genetlink.h>
 #include <net/wpan-phy.h>
@@ -213,12 +214,37 @@ static int ieee802154_add_iface(struct sk_buff *skb,
 		goto nla_put_failure;
 	}
 
+	if (info->attrs[IEEE802154_ATTR_HW_ADDR] &&
+	    nla_len(info->attrs[IEEE802154_ATTR_HW_ADDR]) !=
+			IEEE802154_ADDR_LEN) {
+		rc = -EINVAL;
+		goto nla_put_failure;
+	}
+
 	dev = phy->add_iface(phy, devname);
 	if (IS_ERR(dev)) {
 		rc = PTR_ERR(dev);
 		goto nla_put_failure;
 	}
 
+	if (info->attrs[IEEE802154_ATTR_HW_ADDR]) {
+		struct sockaddr addr;
+
+		addr.sa_family = ARPHRD_IEEE802154;
+		nla_memcpy(&addr.sa_data, info->attrs[IEEE802154_ATTR_HW_ADDR],
+				IEEE802154_ADDR_LEN);
+
+		/*
+		 * strangely enough, some callbacks (inetdev_event) from
+		 * dev_set_mac_address require RTNL_LOCK
+		 */
+		rtnl_lock();
+		rc = dev_set_mac_address(dev, &addr);
+		rtnl_unlock();
+		if (rc)
+			goto dev_unregister;
+	}
+
 	NLA_PUT_STRING(msg, IEEE802154_ATTR_PHY_NAME, wpan_phy_name(phy));
 	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
 
@@ -228,6 +254,11 @@ static int ieee802154_add_iface(struct sk_buff *skb,
 
 	return ieee802154_nl_reply(msg, info);
 
+dev_unregister:
+	rtnl_lock(); /* del_iface must be called with RTNL lock */
+	phy->del_iface(phy, dev);
+	dev_put(dev);
+	rtnl_unlock();
 nla_put_failure:
 	nlmsg_free(msg);
 out_dev:
-- 
1.7.5.4

