From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH bluetooth-next v3] ieee802154: fix netns settings
Date: Thu,  5 Feb 2015 18:21:30 +0100
Message-ID: <1423156890-13382-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1DEA1346-A348-434E-90F3-80E9EDC7E181@holtmann.org>
Cc: alex.aring@gmail.com, netdev@vger.kernel.org, davem@davemloft.net,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:52155 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758438AbbBERVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 12:21:48 -0500
In-Reply-To: <1DEA1346-A348-434E-90F3-80E9EDC7E181@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

6LoWPAN currently doesn't supports x-netns and works only in init_net.

With this patch, we ensure that:
 - the wpan interface cannot be moved to another netns;
 - the 6lowpan interface cannot be moved to another netns;
 - the wpan interface is in the same netns than the 6lowpan interface;
 - the 6lowpan interface is in init_net.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Acked-by: Alexander Aring <alex.aring@gmail.com>
---

Note: only compile tested.

v3: rebase on head of bluetooth-next
    add the Acked-by line

v2: update patch title
    rebase the patch on bluetooth-next
    update flag features in cfg802154_netdev_notifier_call

 net/ieee802154/6lowpan/core.c | 6 ++++--
 net/ieee802154/core.c         | 1 +
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/6lowpan/core.c b/net/ieee802154/6lowpan/core.c
index 055fbb71ba6f..dfd3c6007f60 100644
--- a/net/ieee802154/6lowpan/core.c
+++ b/net/ieee802154/6lowpan/core.c
@@ -126,6 +126,7 @@ static void lowpan_setup(struct net_device *dev)
 	dev->header_ops		= &lowpan_header_ops;
 	dev->ml_priv		= &lowpan_mlme;
 	dev->destructor		= free_netdev;
+	dev->features		|= NETIF_F_NETNS_LOCAL;
 }
 
 static int lowpan_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -148,10 +149,11 @@ static int lowpan_newlink(struct net *src_net, struct net_device *dev,
 
 	pr_debug("adding new link\n");
 
-	if (!tb[IFLA_LINK])
+	if (!tb[IFLA_LINK] ||
+	    !net_eq(dev_net(dev), &init_net))
 		return -EINVAL;
 	/* find and hold real wpan device */
-	real_dev = dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
+	real_dev = dev_get_by_index(dev_net(dev), nla_get_u32(tb[IFLA_LINK]));
 	if (!real_dev)
 		return -ENODEV;
 	if (real_dev->type != ARPHRD_IEEE802154) {
diff --git a/net/ieee802154/core.c b/net/ieee802154/core.c
index 18bc7e738507..888d0991c761 100644
--- a/net/ieee802154/core.c
+++ b/net/ieee802154/core.c
@@ -225,6 +225,7 @@ static int cfg802154_netdev_notifier_call(struct notifier_block *nb,
 	switch (state) {
 		/* TODO NETDEV_DEVTYPE */
 	case NETDEV_REGISTER:
+		dev->features |= NETIF_F_NETNS_LOCAL;
 		wpan_dev->identifier = ++rdev->wpan_dev_id;
 		list_add_rcu(&wpan_dev->list, &rdev->wpan_dev_list);
 		rdev->devlist_generation++;
-- 
2.2.2
