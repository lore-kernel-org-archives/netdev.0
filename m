From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v1] tun: Cleanup error handling in tun_set_iff()
Date: Mon, 03 Aug 2009 12:12:43 -0400
Message-ID: <20090803161242.12947.14620.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:35126 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755228AbZHCQMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 12:12:49 -0400
Received: from g4t0009.houston.hp.com (g4t0009.houston.hp.com [16.234.32.26])
	by g5t0009.atlanta.hp.com (Postfix) with ESMTP id 3F0C5302FD
	for <netdev@vger.kernel.org>; Mon,  3 Aug 2009 16:12:50 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert some pointless gotos into returns and ensure tun_attach() errors are
handled correctly.

Signed-off-by: Paul Moore <paul.moore@hp.com>

--

I'm sending this as an RFC patch because I'm not entirely certain that the
changes to the tun_attach() error handling code are 100% correct, although I
strongly suspect that the current behavor of simply returning an error code
without any cleanup is broken.  Can anyone comment on this?
---

 drivers/net/tun.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 4a0db7a..b6d06fd 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -938,13 +938,10 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		err = tun_attach(tun, file);
 		if (err < 0)
 			return err;
-	}
-	else {
+	} else {
 		char *name;
 		unsigned long flags = 0;
 
-		err = -EINVAL;
-
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
@@ -958,7 +955,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 			flags |= TUN_TAP_DEV;
 			name = "tap%d";
 		} else
-			goto failed;
+			return -EINVAL;
 
 		if (*ifr->ifr_name)
 			name = ifr->ifr_name;
@@ -976,10 +973,11 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		tun->flags = flags;
 		tun->txflt.count = 0;
 
-		err = -ENOMEM;
 		sk = sk_alloc(net, AF_UNSPEC, GFP_KERNEL, &tun_proto);
-		if (!sk)
+		if (!sk) {
+			err = -ENOMEM;
 			goto err_free_dev;
+		}
 
 		init_waitqueue_head(&tun->socket.wait);
 		sock_init_data(&tun->socket, sk);
@@ -1010,7 +1008,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 
 		err = tun_attach(tun, file);
 		if (err < 0)
-			goto failed;
+			goto err_unreg_dev;
 	}
 
 	DBG(KERN_INFO "%s: tun_set_iff\n", tun->dev->name);
@@ -1039,11 +1037,14 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 	strcpy(ifr->ifr_name, tun->dev->name);
 	return 0;
 
+ err_unreg_dev:
+	rtnl_lock();
+	unregister_netdevice(tun->dev);
+	rtnl_unlock();
  err_free_sk:
 	sock_put(sk);
  err_free_dev:
 	free_netdev(dev);
- failed:
 	return err;
 }
 

