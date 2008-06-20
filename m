From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH net-next 8/8] 8021q: Check return of dev_set_promiscuity/allmulti
Date: Fri, 20 Jun 2008 08:55:59 +0800
Message-ID: <485B001F.1070407@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49984 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754424AbYFTBAC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 21:00:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_set_promiscuity/allmulti might overflow.
Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
dev_set_promiscuity/allmulti return error number if overflow happened.

Here, we check all positive increment for promiscuity and allmulti
to get error return.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/8021q/vlan_dev.c |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 5d055c2..1f2669b 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -547,12 +547,23 @@ static int vlan_dev_open(struct net_device *dev)
 	}
 	memcpy(vlan->real_dev_addr, real_dev->dev_addr, ETH_ALEN);
 
-	if (dev->flags & IFF_ALLMULTI)
-		dev_set_allmulti(real_dev, 1);
-	if (dev->flags & IFF_PROMISC)
-		dev_set_promiscuity(real_dev, 1);
+	if (dev->flags & IFF_ALLMULTI) {
+		err = dev_set_allmulti(real_dev, 1);
+		if (err < 0)
+			goto out;
+	}
+	if (dev->flags & IFF_PROMISC) {
+		err = dev_set_promiscuity(real_dev, 1);
+		if (err < 0)
+			goto out;
+	}
 
 	return 0;
+
+out:
+	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
+		dev_unicast_delete(real_dev, dev->dev_addr, dev->addr_len);
+	return err;
 }
 
 static int vlan_dev_stop(struct net_device *dev)
-- 
1.5.3.4



