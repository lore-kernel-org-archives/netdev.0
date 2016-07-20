From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: [PATCH] ieee802154: check device type
Date: Wed, 20 Jul 2016 10:43:11 +0200
Message-ID: <1469004191-30920-1-git-send-email-vegard.nossum@oracle.com>
Cc: linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	Vegard Nossum <vegard.nossum@oracle.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Alexander Aring <alex.aring@gmail.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Sergey Lapin <slapin@ossfans.org>
To: Alexander Aring <aar@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:49945 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662AbcGTIoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 04:44:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've observed a NULL pointer dereference in ieee802154_del_iface() during
netlink fuzzing. It's the ->wpan_phy dereference here:

        phy = dev->ieee802154_ptr->wpan_phy;

My bet is that we're not checking that this is an IEEE802154 interface,
so let's do what ieee802154_nl_get_dev() is doing. (Maybe we should even
be calling this directly?)

Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: Alexander Aring <alex.aring@gmail.com>
Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Cc: Sergey Lapin <slapin@ossfans.org>
Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
---
 net/ieee802154/nl-phy.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index 77d7301..dc2960b 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -286,9 +286,12 @@ int ieee802154_del_iface(struct sk_buff *skb, struct genl_info *info)
 	if (name[nla_len(info->attrs[IEEE802154_ATTR_DEV_NAME]) - 1] != '\0')
 		return -EINVAL; /* name should be null-terminated */
 
+	rc = -ENODEV;
 	dev = dev_get_by_name(genl_info_net(info), name);
 	if (!dev)
-		return -ENODEV;
+		return rc;
+	if (dev->type != ARPHRD_IEEE802154)
+		goto out;
 
 	phy = dev->ieee802154_ptr->wpan_phy;
 	BUG_ON(!phy);
@@ -342,6 +345,7 @@ nla_put_failure:
 	nlmsg_free(msg);
 out_dev:
 	wpan_phy_put(phy);
+out:
 	if (dev)
 		dev_put(dev);
 
-- 
1.9.1
