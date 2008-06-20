From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH net-next 7/8] macvlan: Check return of dev_set_allmulti
Date: Fri, 20 Jun 2008 08:55:45 +0800
Message-ID: <485B0011.7060601@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, NETDEV <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60885 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754672AbYFTA7x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 20:59:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

allmulti might overflow.
Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
dev_set_promiscuity/allmulti return error number if overflow happened.

Here, we check the positive increment for allmulti to get error return.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/macvlan.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index c36a03a..b0ed18f 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -190,8 +190,13 @@ static int macvlan_open(struct net_device *dev)
 	err = dev_unicast_add(lowerdev, dev->dev_addr, ETH_ALEN);
 	if (err < 0)
 		return err;
-	if (dev->flags & IFF_ALLMULTI)
-		dev_set_allmulti(lowerdev, 1);
+	if (dev->flags & IFF_ALLMULTI) {
+		err = dev_set_allmulti(lowerdev, 1);
+		if (err < 0) {
+			dev_unicast_delete(lowerdev, dev->dev_addr, ETH_ALEN);
+			return err;
+		}
+	}
 
 	hlist_add_head_rcu(&vlan->hlist, &port->vlan_hash[dev->dev_addr[5]]);
 	return 0;
-- 
1.5.3.4



