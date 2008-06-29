From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH 4/5] ipvs: Put backup thread on mcast socket wait queue
Date: Sun, 29 Jun 2008 19:32:45 +0200
Message-ID: <1214760766-1526-5-git-send-email-sven.wegener@stealer.net>
References: <1214760766-1526-1-git-send-email-sven.wegener@stealer.net>
Cc: netdev@vger.kernel.org
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.stealer.net ([88.198.224.204]:55435 "EHLO
	smtp1.stealer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755226AbYF2SEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 14:04:54 -0400
In-Reply-To: <1214760766-1526-1-git-send-email-sven.wegener@stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of doing an endless loop with sleeping for one second, we now put the
backup thread onto the mcast socket wait queue and it gets woken up as soon as
we have data to process.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv4/ipvs/ip_vs_sync.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
index 26d58a6..fa49c24 100644
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -31,6 +31,7 @@
 #include <linux/udp.h>
 #include <linux/err.h>
 #include <linux/kthread.h>
+#include <linux/wait.h>
 
 #include <net/ip.h>
 #include <net/sock.h>
@@ -774,6 +775,10 @@ static int sync_thread_backup(void *data)
 		   ip_vs_backup_mcast_ifn, ip_vs_backup_syncid);
 
 	while (!kthread_should_stop()) {
+		wait_event_interruptible(*tinfo->sock->sk->sk_sleep,
+			 !skb_queue_empty(&tinfo->sock->sk->sk_receive_queue)
+			 || kthread_should_stop());
+
 		/* do we have data now? */
 		while (!skb_queue_empty(&(tinfo->sock->sk->sk_receive_queue))) {
 			len = ip_vs_receive(tinfo->sock, tinfo->buf,
@@ -789,8 +794,6 @@ static int sync_thread_backup(void *data)
 			ip_vs_process_message(tinfo->buf, len);
 			local_bh_enable();
 		}
-
-		msleep_interruptible(1000);
 	}
 
 	/* release the sending multicast socket */
-- 
1.5.6.1

