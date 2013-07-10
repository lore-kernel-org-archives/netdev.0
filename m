From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH] ifb: fix rcu_sched self-detected stalls
Date: Wed, 10 Jul 2013 12:04:02 +0800
Message-ID: <51DCDD32.30102@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:49029 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710Ab3GJEGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 00:06:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to the commit 16b0dc29c1af9df341428f4c49ada4f626258082
(dummy: fix rcu_sched self-detected stalls)

Eric Dumazet fix the problem in dummy, but the ifb will occur the
same problem like the dummy modules.

Trying to "modprobe ifb numifbs=30000" triggers :

INFO: rcu_sched self-detected stall on CPU

After this splat, RTNL is locked and reboot is needed.

We must call cond_resched() to avoid this, even holding RTNL.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ifb.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index dc9f6a4..a11f7a4 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -292,8 +292,10 @@ static int __init ifb_init_module(void)
 	rtnl_lock();
 	err = __rtnl_link_register(&ifb_link_ops);
 
-	for (i = 0; i < numifbs && !err; i++)
+	for (i = 0; i < numifbs && !err; i++) {
 		err = ifb_init_one(i);
+		cond_resched();
+	}
 	if (err)
 		__rtnl_link_unregister(&ifb_link_ops);
 	rtnl_unlock();
-- 
1.8.0
