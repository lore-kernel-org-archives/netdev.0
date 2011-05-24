From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: use synchronize_rcu_expedited()
Date: Tue, 24 May 2011 11:07:32 +0200
Message-ID: <1306228052.3026.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39454 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753287Ab1EXJHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 05:07:36 -0400
Received: by wwa36 with SMTP id 36so7086131wwa.1
        for <netdev@vger.kernel.org>; Tue, 24 May 2011 02:07:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

synchronize_rcu() is very slow in various situations (HZ=100,
CONFIG_NO_HZ=y, CONFIG_PREEMPT=n)

Extract from my (mostly idle) 8 core machine :

 synchronize_rcu() in 99985 us
 synchronize_rcu() in 79982 us
 synchronize_rcu() in 87612 us
 synchronize_rcu() in 79827 us
 synchronize_rcu() in 109860 us
 synchronize_rcu() in 98039 us
 synchronize_rcu() in 89841 us
 synchronize_rcu() in 79842 us
 synchronize_rcu() in 80151 us
 synchronize_rcu() in 119833 us
 synchronize_rcu() in 99858 us
 synchronize_rcu() in 73999 us
 synchronize_rcu() in 79855 us
 synchronize_rcu() in 79853 us


When we hold RTNL mutex, we would like to spend some cpu cycles but not
block too long other processes waiting for this mutex.

We also want to setup/dismantle network features as fast as possible at
boot/shutdown time.

This patch makes synchronize_net() call the expedited version if RTNL is
locked.

synchronize_rcu_expedited() typical delay is about 20 us on my machine.

 synchronize_rcu_expedited() in 18 us
 synchronize_rcu_expedited() in 18 us
 synchronize_rcu_expedited() in 18 us
 synchronize_rcu_expedited() in 18 us
 synchronize_rcu_expedited() in 20 us
 synchronize_rcu_expedited() in 16 us
 synchronize_rcu_expedited() in 20 us
 synchronize_rcu_expedited() in 18 us
 synchronize_rcu_expedited() in 18 us


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
CC: Ben Greear <greearb@candelatech.com>
---
 net/core/dev.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index bcb05cb..ec11d75 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5954,7 +5954,10 @@ EXPORT_SYMBOL(free_netdev);
 void synchronize_net(void)
 {
 	might_sleep();
-	synchronize_rcu();
+	if (rtnl_is_locked())
+		synchronize_rcu_expedited();
+	else
+		synchronize_rcu();
 }
 EXPORT_SYMBOL(synchronize_net);
 


