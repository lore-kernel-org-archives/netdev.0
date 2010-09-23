From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH] br2684: fix scheduling while atomic
Date: Thu, 23 Sep 2010 13:50:54 +0200
Message-ID: <1285242654-9891-1-git-send-email-karl@hiramoto.org>
References: <20100922144329.0cb3cf86@thirdoffive.cmf.nrl.navy.mil>
Cc: davem@davemloft.net, chas@cmf.nrl.navy.mil,
	Karl Hiramoto <karl@hiramoto.org>
To: netdev@vger.kernel.org, mmvinni@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:41706 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754667Ab0IWLvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 07:51:38 -0400
Received: from homiemail-a28.g.dreamhost.com (caiajhbdccac.dreamhost.com [208.97.132.202])
	by hapkido.dreamhost.com (Postfix) with ESMTP id C69D917AA73
	for <netdev@vger.kernel.org>; Thu, 23 Sep 2010 04:51:37 -0700 (PDT)
In-Reply-To: <20100922144329.0cb3cf86@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You can't call atomic_notifier_chain_unregister() while in atomic context.

Fix, call un/register_atmdevice_notifier in module __init and __exit.

Bug report:
http://comments.gmane.org/gmane.linux.network/172603

Signed-off-by: Karl Hiramoto <karl@hiramoto.org>
---
 net/atm/br2684.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 651babd..ad2b232 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -399,12 +399,6 @@ static void br2684_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 			unregister_netdev(net_dev);
 			free_netdev(net_dev);
 		}
-		read_lock_irq(&devs_lock);
-		if (list_empty(&br2684_devs)) {
-			/* last br2684 device */
-			unregister_atmdevice_notifier(&atm_dev_notifier);
-		}
-		read_unlock_irq(&devs_lock);
 		return;
 	}
 
@@ -675,7 +669,6 @@ static int br2684_create(void __user *arg)
 
 	if (list_empty(&br2684_devs)) {
 		/* 1st br2684 device */
-		register_atmdevice_notifier(&atm_dev_notifier);
 		brdev->number = 1;
 	} else
 		brdev->number = BRPRIV(list_entry_brdev(br2684_devs.prev))->number + 1;
@@ -815,6 +808,7 @@ static int __init br2684_init(void)
 		return -ENOMEM;
 #endif
 	register_atm_ioctl(&br2684_ioctl_ops);
+	register_atmdevice_notifier(&atm_dev_notifier);
 	return 0;
 }
 
@@ -830,9 +824,7 @@ static void __exit br2684_exit(void)
 #endif
 
 
-	/* if not already empty */
-	if (!list_empty(&br2684_devs))
-		unregister_atmdevice_notifier(&atm_dev_notifier);
+	unregister_atmdevice_notifier(&atm_dev_notifier);
 
 	while (!list_empty(&br2684_devs)) {
 		net_dev = list_entry_brdev(br2684_devs.next);
-- 
1.7.2.2

