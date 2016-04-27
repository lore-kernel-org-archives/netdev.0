From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next v2] ipvlan: Fix failure path in dev registration during link creation
Date: Wed, 27 Apr 2016 14:59:27 -0700
Message-ID: <1461794367-39825-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>,
	"Eric W . Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33660 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752288AbcD0V7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 17:59:35 -0400
Received: by mail-pa0-f66.google.com with SMTP id vv3so7141056pab.0
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 14:59:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

When newlink creation fails at device-registration, the port->count
is decremented twice. Francesco Ruggeri (fruggeri@arista.com) found
this issue in Macvlan and the same exists in IPvlan driver too.

While fixing this issue I noticed another issue of missing unregister
in case of failure, so adding it to the fix which is similar to the
macvlan fix by Francesco in commit 308379607548 ("macvlan: fix failure
during registration v3")

Reported-by: Francesco Ruggeri <fruggeri@arista.com>
Signed-off-by: Mahesh Bandewar <maheshb@google.com>
CC: Eric Dumazet <edumazet@google.com>
CC: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 57941d3f4227..1c4d395fbd49 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -113,6 +113,7 @@ static int ipvlan_init(struct net_device *dev)
 {
 	struct ipvl_dev *ipvlan = netdev_priv(dev);
 	const struct net_device *phy_dev = ipvlan->phy_dev;
+	struct ipvl_port *port = ipvlan->port;
 
 	dev->state = (dev->state & ~IPVLAN_STATE_MASK) |
 		     (phy_dev->state & IPVLAN_STATE_MASK);
@@ -128,6 +129,8 @@ static int ipvlan_init(struct net_device *dev)
 	if (!ipvlan->pcpu_stats)
 		return -ENOMEM;
 
+	port->count += 1;
+
 	return 0;
 }
 
@@ -481,27 +484,21 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 
 	dev->priv_flags |= IFF_IPVLAN_SLAVE;
 
-	port->count += 1;
 	err = register_netdevice(dev);
 	if (err < 0)
-		goto ipvlan_destroy_port;
+		return err;
 
 	err = netdev_upper_dev_link(phy_dev, dev);
-	if (err)
-		goto ipvlan_destroy_port;
+	if (err) {
+		unregister_netdevice(dev);
+		return err;
+	}
 
 	list_add_tail_rcu(&ipvlan->pnode, &port->ipvlans);
 	ipvlan_set_port_mode(port, mode);
 
 	netif_stacked_transfer_operstate(phy_dev, dev);
 	return 0;
-
-ipvlan_destroy_port:
-	port->count -= 1;
-	if (!port->count)
-		ipvlan_port_destroy(phy_dev);
-
-	return err;
 }
 
 static void ipvlan_link_delete(struct net_device *dev, struct list_head *head)
-- 
2.8.0.rc3.226.g39d4020
