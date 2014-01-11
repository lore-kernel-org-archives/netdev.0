From: Christian Engelmayer <cengelma@gmx.at>
Subject: [PATCH] ieee802154: Fix memory leak in ieee802154_add_iface()
Date: Sat, 11 Jan 2014 22:19:30 +0100
Message-ID: <20140111221930.7255e2be@spike>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:62127 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750900AbaAKVTc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Jan 2014 16:19:32 -0500
Received: from spike ([81.217.122.98]) by mail.gmx.com (mrgmx101) with ESMTPSA
 (Nemesis) id 0M04uG-1VEXBW2jk4-00uFDe for <netdev@vger.kernel.org>; Sat, 11
 Jan 2014 22:19:30 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a memory leak in the ieee802154_add_iface() error handling path.
Detected by Coverity: CID 710490.

Signed-off-by: Christian Engelmayer <cengelma@gmx.at>
---
This patch fixes an issue introduced in 

   commit 90c049b2c6ae26d1a4d526d660a976620eaa554a
   Author: alex.bluesman.smirnov@gmail.com <alex.bluesman.smirnov@gmail.com>
   Date:   Tue May 15 20:50:27 2012 +0000

ieee802154: interface type to be added
---
 net/ieee802154/nl-phy.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index d08c7a4..89b265a 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -221,8 +221,10 @@ int ieee802154_add_iface(struct sk_buff *skb, struct genl_info *info)
 
 	if (info->attrs[IEEE802154_ATTR_DEV_TYPE]) {
 		type = nla_get_u8(info->attrs[IEEE802154_ATTR_DEV_TYPE]);
-		if (type >= __IEEE802154_DEV_MAX)
-			return -EINVAL;
+		if (type >= __IEEE802154_DEV_MAX) {
+			rc = -EINVAL;
+			goto nla_put_failure;
+		}
 	}
 
 	dev = phy->add_iface(phy, devname, type);
-- 
1.8.3.2
