From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] inet: fix races with reqsk timers
Date: Mon, 10 Aug 2015 09:09:13 -0700
Message-ID: <1439222953.1084.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33410 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717AbbHJQJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 12:09:16 -0400
Received: by pdrh1 with SMTP id h1so54982671pdr.0
        for <netdev@vger.kernel.org>; Mon, 10 Aug 2015 09:09:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

reqsk_queue_destroy() and reqsk_queue_unlink() should use
del_timer_sync() instead of del_timer() before calling reqsk_put(),
otherwise we could free a req still used by another cpu.

But before doing so, reqsk_queue_destroy() must release syn_wait_lock
spinlock or risk a dead lock, as reqsk_timer_handler() might
need to take this same spinlock from reqsk_queue_unlink() (called from
inet_csk_reqsk_queue_drop())

Fixes: fa76ce7328b2 ("inet: get rid of central tcp/dccp listener timer")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/request_sock.c         |    8 +++++++-
 net/ipv4/inet_connection_sock.c |    2 +-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index 87b22c0..b42f0e2 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -103,10 +103,16 @@ void reqsk_queue_destroy(struct request_sock_queue *queue)
 			spin_lock_bh(&queue->syn_wait_lock);
 			while ((req = lopt->syn_table[i]) != NULL) {
 				lopt->syn_table[i] = req->dl_next;
+				/* Because of following del_timer_sync(),
+				 * we must release the spinlock here
+				 * or risk a dead lock.
+				 */
+				spin_unlock_bh(&queue->syn_wait_lock);
 				atomic_inc(&lopt->qlen_dec);
-				if (del_timer(&req->rsk_timer))
+				if (del_timer_sync(&req->rsk_timer))
 					reqsk_put(req);
 				reqsk_put(req);
+				spin_lock_bh(&queue->syn_wait_lock);
 			}
 			spin_unlock_bh(&queue->syn_wait_lock);
 		}
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 60021d0..05e3145 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -593,7 +593,7 @@ static bool reqsk_queue_unlink(struct request_sock_queue *queue,
 	}
 
 	spin_unlock(&queue->syn_wait_lock);
-	if (del_timer(&req->rsk_timer))
+	if (del_timer_sync(&req->rsk_timer))
 		reqsk_put(req);
 	return found;
 }
