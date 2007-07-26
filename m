From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/6] [NET]: Take dev_base_lock when moving device name hash list entry
Date: Thu, 26 Jul 2007 17:09:30 +0800
Message-ID: <E1IDzLe-0000A4-00@gondolin.me.apana.org.au>
References: <20070726090725.GA510@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1309 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753915AbXGZJJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 05:09:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: Take dev_base_lock when moving device name hash list entry

When we added name-based hashing the dev_base_lock was designated as the
lock to take when changing the name hash list.  Unfortunately, because
it was a preexisting lock that just happened to be taken in the right
spots we neglected to take it in dev_change_name.

The race can affect calles of __dev_get_by_name that do so without taking
the RTNL.  They may end up walking down the wrong hash chain and end up
missing the device that they're looking for.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/core/dev.c |    4 ++++
 1 files changed, 4 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index a284c9b..0a35c15 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -839,8 +839,12 @@ int dev_change_name(struct net_device *dev, char *newname)
 		strlcpy(dev->name, newname, IFNAMSIZ);
 
 	device_rename(&dev->dev, dev->name);
+
+	write_lock_bh(&dev_base_lock);
 	hlist_del(&dev->name_hlist);
 	hlist_add_head(&dev->name_hlist, dev_name_hash(dev->name));
+	write_unlock_bh(&dev_base_lock);
+
 	raw_notifier_call_chain(&netdev_chain, NETDEV_CHANGENAME, dev);
 
 	return err;
