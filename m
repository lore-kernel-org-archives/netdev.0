From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] inet: fix potential deadlock in reqsk_queue_unlink()
Date: Thu, 13 Aug 2015 15:44:51 -0700
Message-ID: <1439505891.7960.38.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439222953.1084.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150810.211821.2246516216165801977.davem@davemloft.net>
	 <1439497173.7960.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1439498674.7960.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:34720 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754186AbbHMWow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 18:44:52 -0400
Received: by pdbfa8 with SMTP id fa8so24180480pdb.1
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 15:44:52 -0700 (PDT)
In-Reply-To: <1439498674.7960.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When replacing del_timer() with del_timer_sync(), I introduced
a deadlock condition :

reqsk_queue_unlink() is called from inet_csk_reqsk_queue_drop()

inet_csk_reqsk_queue_drop() can be called from many contexts,
one being the timer handler itself (reqsk_timer_handler()).

In this case, del_timer_sync() loops forever.

Simple fix is to test if timer is pending.

Fixes: 2235f2ac75fd ("inet: fix races with reqsk timers")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Sorry for this very embarrassing bug, I should have caught it in my
tests :(

 net/ipv4/inet_connection_sock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 05e3145f7dc3..134957159c27 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -593,7 +593,7 @@ static bool reqsk_queue_unlink(struct request_sock_queue *queue,
 	}
 
 	spin_unlock(&queue->syn_wait_lock);
-	if (del_timer_sync(&req->rsk_timer))
+	if (timer_pending(&req->rsk_timer) && del_timer_sync(&req->rsk_timer))
 		reqsk_put(req);
 	return found;
 }
