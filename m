From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: v4 [PATCH 9/9] 8021q: Check return of dev_set_promiscuity/allmulti
Date: Tue, 15 Jul 2008 10:59:49 +0800
Message-ID: <487C12A5.8010505@cn.fujitsu.com>
References: <487C0ABA.1070506@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63827 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757753AbYGODEw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2008 23:04:52 -0400
In-Reply-To: <487C0ABA.1070506@cn.fujitsu.com>
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




