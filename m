From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC, PATCH] net: suspicious test in dev_change_name()
Date: Fri, 30 Oct 2009 10:20:04 +0100
Message-ID: <4AEAAFC4.9050309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35071 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755737AbZJ3JUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 05:20:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While preparing a patch for net-next-2.6, I noticed following code in dev_change_name()

int err = 0;
...
        ret = call_netdevice_notifiers(NETDEV_CHANGENAME, dev);
        ret = notifier_to_errno(ret);

        if (ret) {
<< HERE >>      if (err) {
                        printk(KERN_ERR
                               "%s: name change rollback failed: %d.\n",
                               dev->name, ret);
                } else {
                        err = ret;
                        memcpy(dev->name, oldname, IFNAMSIZ);
                        goto rollback;
                }
        }


It seems intent was to test if notifier_to_errno() was null ?

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/core/dev.c b/net/core/dev.c
index b8f74cf..029cd41 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -939,9 +939,9 @@ rollback:
 	write_unlock_bh(&dev_base_lock);
 
 	ret = call_netdevice_notifiers(NETDEV_CHANGENAME, dev);
-	ret = notifier_to_errno(ret);
 
 	if (ret) {
+		err = notifier_to_errno(ret);
 		if (err) {
 			printk(KERN_ERR
 			       "%s: name change rollback failed: %d.\n",
