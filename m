From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 4/7] netconsole: remove unnecessary netconsole_target_get/out() from write_msg()
Date: Thu, 14 May 2015 12:06:23 -0400
Message-ID: <1431619586-29187-5-git-send-email-tj@kernel.org>
References: <1431619586-29187-1-git-send-email-tj@kernel.org>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>
To: akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431619586-29187-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

write_msg() grabs target_list_lock and walks target_list invoking
netpool_send_udp() on each target.  Curiously, it protects each
iteration with netconsole_target_get/put() even though it never
releases target_list_lock which protects all the members.

While this doesn't harm anything, it doesn't serve any purpose either.
The items on the list can't go away while target_list_lock is held.
Remove the unnecessary get/put pair.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: David Miller <davem@davemloft.net>
---
 drivers/net/netconsole.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 15731d1..30c0524 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -744,7 +744,6 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
 
 	spin_lock_irqsave(&target_list_lock, flags);
 	list_for_each_entry(nt, &target_list, list) {
-		netconsole_target_get(nt);
 		if (nt->enabled && netif_running(nt->np.dev)) {
 			/*
 			 * We nest this inside the for-each-target loop above
@@ -760,7 +759,6 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
 				left -= frag;
 			}
 		}
-		netconsole_target_put(nt);
 	}
 	spin_unlock_irqrestore(&target_list_lock, flags);
 }
-- 
2.1.0
