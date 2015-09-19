From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] inet: fix races in reqsk_queue_hash_req()
Date: Sat, 19 Sep 2015 09:48:04 -0700
Message-ID: <1442681284.29850.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Ying Cai <ycai@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34519 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754814AbbISQsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 12:48:07 -0400
Received: by padhy16 with SMTP id hy16so77683194pad.1
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 09:48:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Before allowing lockless LISTEN processing, we need to make
sure to arm the SYN_RECV timer before the req socket is visible
in hash tables.

Also, req->rsk_hash should be written before we set rsk_refcnt
to a non zero value.

Fixes: fa76ce7328b2 ("inet: get rid of central tcp/dccp listener timer")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ying Cai <ycai@google.com>
---
 net/ipv4/inet_connection_sock.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 134957159c27..7bb9c39e0a4d 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -685,20 +685,20 @@ void reqsk_queue_hash_req(struct request_sock_queue *queue,
 	req->num_timeout = 0;
 	req->sk = NULL;
 
+	setup_timer(&req->rsk_timer, reqsk_timer_handler, (unsigned long)req);
+	mod_timer_pinned(&req->rsk_timer, jiffies + timeout);
+	req->rsk_hash = hash;
+
 	/* before letting lookups find us, make sure all req fields
 	 * are committed to memory and refcnt initialized.
 	 */
 	smp_wmb();
 	atomic_set(&req->rsk_refcnt, 2);
-	setup_timer(&req->rsk_timer, reqsk_timer_handler, (unsigned long)req);
-	req->rsk_hash = hash;
 
 	spin_lock(&queue->syn_wait_lock);
 	req->dl_next = lopt->syn_table[hash];
 	lopt->syn_table[hash] = req;
 	spin_unlock(&queue->syn_wait_lock);
-
-	mod_timer_pinned(&req->rsk_timer, jiffies + timeout);
 }
 EXPORT_SYMBOL(reqsk_queue_hash_req);
 
