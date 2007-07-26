From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/6] [NET]: Call uninit if necessary in register_netdevice
Date: Thu, 26 Jul 2007 17:09:08 +0800
Message-ID: <E1IDzLI-00009i-00@gondolin.me.apana.org.au>
References: <20070726090725.GA510@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1303 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756972AbXGZJJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 05:09:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: Call uninit if necessary in register_netdevice

This patch makes register_netdevice call dev->uninit if the regsitration
fails after dev->init has completed successfully.  Very few drivers use
the init/uninit calls but at least one (drivers/net/wan/sealevel.c) may
leak without this change.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/core/dev.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index ee40355..a284c9b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3333,7 +3333,7 @@ int register_netdevice(struct net_device *dev)
 
 	if (!dev_valid_name(dev->name)) {
 		ret = -EINVAL;
-		goto out;
+		goto err_uninit;
 	}
 
 	dev->ifindex = dev_new_index();
@@ -3347,7 +3347,7 @@ int register_netdevice(struct net_device *dev)
 			= hlist_entry(p, struct net_device, name_hlist);
 		if (!strncmp(d->name, dev->name, IFNAMSIZ)) {
 			ret = -EEXIST;
-			goto out;
+			goto err_uninit;
 		}
 	}
 
@@ -3407,7 +3407,7 @@ int register_netdevice(struct net_device *dev)
 
 	ret = netdev_register_sysfs(dev);
 	if (ret)
-		goto out;
+		goto err_uninit;
 	dev->reg_state = NETREG_REGISTERED;
 
 	/*
@@ -3432,6 +3432,11 @@ int register_netdevice(struct net_device *dev)
 
 out:
 	return ret;
+
+err_uninit:
+	if (dev->uninit)
+		dev->uninit(dev);
+	goto out;
 }
 
 /**
