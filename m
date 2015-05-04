From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 0.5/4] netconsole: remove unnecessary
 netconsole_target_get/out() from write_msg()
Date: Mon, 4 May 2015 16:03:54 -0400
Message-ID: <20150504200354.GH1971@htj.duckdns.org>
References: <1430505220-25160-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:33088 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbbEDUD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 16:03:58 -0400
Content-Disposition: inline
In-Reply-To: <1430505220-25160-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 958d3e14720a35c6103668c69d58751b36053d69 Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj@kernel.org>
Date: Mon, 4 May 2015 15:57:54 -0400

write_msg() grabs target_list_lock and walks target_list invoking
netpool_send_udp() on each target.  Curiously, it protects each
iteration with netconsole_target_get/put() even though it never
releases target_list_lock which protects all the members.

While this doesn't harm anything, it doesn't serve any purpose either.
The items on the list can't go away while target_list_lock is held.
Remove the unnecessary get/put pair.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: David Miller <davem@davemloft.net>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
Hello,

If anyone wants the whole series to be reposted, please let me know.
The updated patchset is available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git review-netconsole-ext-console

Thanks.

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
