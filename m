From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] dummy: fix rcu_sched self-detected stalls
Date: Mon, 11 Jun 2012 09:11:57 +0200
Message-ID: <1339398717.6001.1538.camel@edumazet-glaptop>
References: <1339239546.6001.177.camel@edumazet-glaptop>
	 <20120610.224800.602807319671005890.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:36240 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483Ab2FKHMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 03:12:02 -0400
Received: by eeit10 with SMTP id t10so1704216eei.19
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 00:12:00 -0700 (PDT)
In-Reply-To: <20120610.224800.602807319671005890.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Trying to "modprobe dummy numdummies=30000" triggers :

INFO: rcu_sched self-detected stall on CPU { 8} (t=60000 jiffies)

After this splat, RTNL is locked and reboot is needed.

We must call cond_resched() to avoid this, even holding RTNL.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/dummy.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 442d91a..bab0158 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -187,8 +187,10 @@ static int __init dummy_init_module(void)
 	rtnl_lock();
 	err = __rtnl_link_register(&dummy_link_ops);
 
-	for (i = 0; i < numdummies && !err; i++)
+	for (i = 0; i < numdummies && !err; i++) {
 		err = dummy_init_one();
+		cond_resched();
+	}
 	if (err < 0)
 		__rtnl_link_unregister(&dummy_link_ops);
 	rtnl_unlock();
