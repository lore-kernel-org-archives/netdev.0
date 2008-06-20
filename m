From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH net-next 7/8] macvlan: Check return of dev_set_allmulti
Date: Fri, 20 Jun 2008 23:08:22 +0800
Message-ID: <485BC7E6.20308@cn.fujitsu.com>
References: <485B0011.7060601@cn.fujitsu.com> <485B7C32.8080605@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	NETDEV <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54776 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755941AbYFTPMR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2008 11:12:17 -0400
In-Reply-To: <485B7C32.8080605@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy said the following on 2008-6-20 17:45:
> Please change this to use gotos for rollback on error.
> 

allmulti might overflow.
Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
dev_set_promiscuity/allmulti return error number if overflow happened.

Here, we check the positive increment for allmulti to get error return.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
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
-- 
1.5.3.4


