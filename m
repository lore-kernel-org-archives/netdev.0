From: Vincent Bernat <vincent@bernat.im>
Subject: [PATCH] veth: delay peer link configuration after interfaces are tied
Date: Mon, 30 May 2016 12:13:47 +0200
Message-ID: <1464603227-25355-1-git-send-email-vincent@bernat.im>
References: <574C0697.6060506@6wind.com>
Cc: Vincent Bernat <vincent@bernat.im>
To: "David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:38528 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752561AbcE3KNv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 May 2016 06:13:51 -0400
In-Reply-To: <574C0697.6060506@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the peer link is created, its "iflink" information is not
advertised through netlink. If a user is maintaining a cache from all
updates, it will miss this information:

    2: veth0@NONE: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default
        link/ether ae:0e:08:af:fb:a0 brd ff:ff:ff:ff:ff:ff
    3: veth1@veth0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN group default
        link/ether 3a:31:f1:36:2e:e5 brd ff:ff:ff:ff:ff:ff

To avoid this situation, the peer link is only configured after both
interfaces are tied together:

    3: veth0@veth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default
        link/ether ee:0d:80:46:36:fe brd ff:ff:ff:ff:ff:ff
    4: veth1@veth0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN group default
        link/ether ba:25:bc:7a:0d:c8 brd ff:ff:ff:ff:ff:ff

Signed-off-by: Vincent Bernat <vincent@bernat.im>
---
 drivers/net/veth.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index f37a6e61d4ad..7580f6765948 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -432,10 +432,6 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 
 	netif_carrier_off(peer);
 
-	err = rtnl_configure_link(peer, ifmp);
-	if (err < 0)
-		goto err_configure_peer;
-
 	/*
 	 * register dev last
 	 *
@@ -466,8 +462,17 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 
 	priv = netdev_priv(peer);
 	rcu_assign_pointer(priv->peer, dev);
+
+	err = rtnl_configure_link(peer, ifmp);
+	if (err < 0)
+		goto err_configure_link;
 	return 0;
 
+err_configure_link:
+	RCU_INIT_POINTER(priv->peer, NULL);
+	priv = netdev_priv(dev);
+	RCU_INIT_POINTER(priv->peer, NULL);
+	unregister_netdevice(dev);
 err_register_dev:
 	/* nothing to do */
 err_configure_peer:
-- 
2.8.1
