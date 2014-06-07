From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 RESEND 4/4] net: dev: don't set the same mac address for netdev
Date: Sat, 7 Jun 2014 15:45:43 +0800
Message-ID: <1402127143-6456-5-git-send-email-dingtianhong@huawei.com>
References: <1402127143-6456-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <kaber@trash.net>, <davem@davemloft.net>, <edumazet@google.com>,
	<vyasevic@redhat.com>, <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:48751 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752813AbaFGHq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jun 2014 03:46:28 -0400
In-Reply-To: <1402127143-6456-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most of netdev just link bond, team, vlan will set the mac address
and propagate to the upperdev or lowerdev regardless the mac address
is same or not, setting a same mac address make no sense for most of
the netdev, but some netdev need a flag to see whether the ndo_set_mac_address()
is called and decide what to do next, so don't do anything if the address
has already been set by user and it is the same as before, otherwise set
the same address to the netdev.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/core/dev.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index b0fb3dd..201d88b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5572,6 +5572,13 @@ int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
 	if (!netif_device_present(dev))
 		return -ENODEV;
 
+	/* If the address has already been set by user and it
+	 * is the same as before, don't do anything.
+	 */
+	if (dev->addr_assign_type == NET_ADDR_SET &&
+	    ether_addr_equal_64bits(dev->dev_addr, sa->sa_data))
+		return 0;
+
 	old_sa.sa_family = dev->type;
 	ether_addr_copy(old_sa.sa_data, dev->dev_addr);
 
-- 
1.8.0
