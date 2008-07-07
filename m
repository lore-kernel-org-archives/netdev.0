From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: v3 [PATCH net-next 6/7] macvlan: Check return of dev_set_allmulti
Date: Mon, 07 Jul 2008 10:38:24 +0800
Message-ID: <487181A0.7070202@cn.fujitsu.com>
References: <48718014.4030009@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51371 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750827AbYGGCnB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jul 2008 22:43:01 -0400
In-Reply-To: <48718014.4030009@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

allmulti might overflow.
Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
dev_set_promiscuity/allmulti return error number if overflow happened.

Here, we check the positive increment for allmulti to get error return.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
Acked-by: Patrick McHardy <kaber@trash.net>
---
 drivers/net/macvlan.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index c36a03a..a857330 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -189,12 +189,20 @@ static int macvlan_open(struct net_device *dev)
 
 	err = dev_unicast_add(lowerdev, dev->dev_addr, ETH_ALEN);
 	if (err < 0)
-		return err;
-	if (dev->flags & IFF_ALLMULTI)
-		dev_set_allmulti(lowerdev, 1);
+		goto out;
+	if (dev->flags & IFF_ALLMULTI) {
+		err = dev_set_allmulti(lowerdev, 1);
+		if (err < 0)
+			goto del_unicast;
+	}
 
 	hlist_add_head_rcu(&vlan->hlist, &port->vlan_hash[dev->dev_addr[5]]);
 	return 0;
+
+del_unicast:
+	dev_unicast_delete(lowerdev, dev->dev_addr, ETH_ALEN);
+out:
+	return err;
 }
 
 static int macvlan_stop(struct net_device *dev)


