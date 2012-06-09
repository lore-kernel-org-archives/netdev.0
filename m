From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] dummy: fix rcu_sched self-detected stalls
Date: Sat, 09 Jun 2012 12:59:06 +0200
Message-ID: <1339239546.6001.177.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:51700 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884Ab2FIK7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 06:59:09 -0400
Received: by wibhn6 with SMTP id hn6so1334461wib.1
        for <netdev@vger.kernel.org>; Sat, 09 Jun 2012 03:59:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Trying to "modprobe dummy numdummies=30000" triggers :

INFO: rcu_sched self-detected stall on CPU { 8} (t=60000 jiffies)

After this splat, RTNL is locked and reboot is needed.

We must call cond_resched() to avoid this, even holding RTNL.

Also remove the ~32767 limit on number of dummies (PAGE_SIZE*8)

Tested with "modprobe dummy numdummies=128000"
(it took ~12 minutes, because of sysfs)

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/dummy.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 442d91a..004ca81 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -160,12 +160,14 @@ static struct rtnl_link_ops dummy_link_ops __read_mostly = {
 module_param(numdummies, int, 0);
 MODULE_PARM_DESC(numdummies, "Number of dummy pseudo devices");
 
-static int __init dummy_init_one(void)
+static int __init dummy_init_one(int index)
 {
 	struct net_device *dev_dummy;
 	int err;
+	char name[64];
 
-	dev_dummy = alloc_netdev(0, "dummy%d", dummy_setup);
+	sprintf(name, "dummy%d", index);
+	dev_dummy = alloc_netdev(0, name, dummy_setup);
 	if (!dev_dummy)
 		return -ENOMEM;
 
@@ -187,8 +189,10 @@ static int __init dummy_init_module(void)
 	rtnl_lock();
 	err = __rtnl_link_register(&dummy_link_ops);
 
-	for (i = 0; i < numdummies && !err; i++)
-		err = dummy_init_one();
+	for (i = 0; i < numdummies && !err; i++) {
+		err = dummy_init_one(i);
+		cond_resched();
+	}
 	if (err < 0)
 		__rtnl_link_unregister(&dummy_link_ops);
 	rtnl_unlock();
