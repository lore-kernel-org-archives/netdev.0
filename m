From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: v3 [PATCH net-next 7/7] 8021q: Check return of dev_set_promiscuity/allmulti
Date: Mon, 07 Jul 2008 10:38:56 +0800
Message-ID: <487181C0.2000700@cn.fujitsu.com>
References: <48718014.4030009@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65344 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751922AbYGGCnd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jul 2008 22:43:33 -0400
In-Reply-To: <48718014.4030009@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_set_promiscuity/allmulti might overflow.
Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
dev_set_promiscuity/allmulti return error number if overflow happened.

Here, we check all positive increment for promiscuity and allmulti
to get error return.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
Acked-by: Patrick McHardy <kaber@trash.net>
---
 net/8021q/vlan_dev.c |   27 +++++++++++++++++++++------
 1 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 5d055c2..083e0c8 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -543,16 +543,31 @@ static int vlan_dev_open(struct net_device *dev)
 	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr)) {
 		err = dev_unicast_add(real_dev, dev->dev_addr, ETH_ALEN);
 		if (err < 0)
-			return err;
+			goto out;
 	}
-	memcpy(vlan->real_dev_addr, real_dev->dev_addr, ETH_ALEN);
 
-	if (dev->flags & IFF_ALLMULTI)
-		dev_set_allmulti(real_dev, 1);
-	if (dev->flags & IFF_PROMISC)
-		dev_set_promiscuity(real_dev, 1);
+	if (dev->flags & IFF_ALLMULTI) {
+		err = dev_set_allmulti(real_dev, 1);
+		if (err < 0)
+			goto del_unicast;
+	}
+	if (dev->flags & IFF_PROMISC) {
+		err = dev_set_promiscuity(real_dev, 1);
+		if (err < 0)
+			goto clear_allmulti;
+	}
 
+	memcpy(vlan->real_dev_addr, real_dev->dev_addr, ETH_ALEN);
 	return 0;
+
+clear_allmulti:
+	if (dev->flags & IFF_ALLMULTI)
+		dev_set_allmulti(real_dev, -1);
+del_unicast:
+	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
+		dev_unicast_delete(real_dev, dev->dev_addr, ETH_ALEN);
+out:
+	return err;
 }
 
 static int vlan_dev_stop(struct net_device *dev)


