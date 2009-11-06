From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 16/17] ieee802154: add PHY_NAME to LIST_IFACE command results
Date: Fri,  6 Nov 2009 15:39:40 +0300
Message-ID: <1257511181-19403-17-git-send-email-dbaryshkov@gmail.com>
References: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, Sergey Lapin <slapin@ossfans.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:64606 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759129AbZKFMlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 07:41:05 -0500
Received: by ey-out-2122.google.com with SMTP id 25so248343eya.19
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2009 04:41:10 -0800 (PST)
In-Reply-To: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 net/ieee802154/nl-mac.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/ieee802154/nl-mac.c b/net/ieee802154/nl-mac.c
index e8816bf..135c167 100644
--- a/net/ieee802154/nl-mac.c
+++ b/net/ieee802154/nl-mac.c
@@ -33,6 +33,7 @@
 #include <net/nl802154.h>
 #include <net/ieee802154.h>
 #include <net/ieee802154_netdev.h>
+#include <net/wpan-phy.h>
 
 #include "ieee802154.h"
 
@@ -251,6 +252,7 @@ static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 pid,
 	u32 seq, int flags, struct net_device *dev)
 {
 	void *hdr;
+	struct wpan_phy *phy;
 
 	pr_debug("%s\n", __func__);
 
@@ -259,7 +261,11 @@ static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 pid,
 	if (!hdr)
 		goto out;
 
+	phy = ieee802154_mlme_ops(dev)->get_phy(dev);
+	BUG_ON(!phy);
+
 	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_PHY_NAME, wpan_phy_name(phy));
 	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
 
 	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
@@ -268,9 +274,11 @@ static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 pid,
 		ieee802154_mlme_ops(dev)->get_short_addr(dev));
 	NLA_PUT_U16(msg, IEEE802154_ATTR_PAN_ID,
 		ieee802154_mlme_ops(dev)->get_pan_id(dev));
+	wpan_phy_put(phy);
 	return genlmsg_end(msg, hdr);
 
 nla_put_failure:
+	wpan_phy_put(phy);
 	genlmsg_cancel(msg, hdr);
 out:
 	return -EMSGSIZE;
-- 
1.6.5

