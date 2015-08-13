From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] inet: fix races with reqsk timers
Date: Thu, 13 Aug 2015 13:44:34 -0700
Message-ID: <1439498674.7960.14.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439222953.1084.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150810.211821.2246516216165801977.davem@davemloft.net>
	 <1439497173.7960.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36143 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753969AbbHMUok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 16:44:40 -0400
Received: by pacrr5 with SMTP id rr5so44597920pac.3
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 13:44:40 -0700 (PDT)
In-Reply-To: <1439497173.7960.13.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-08-13 at 13:19 -0700, Eric Dumazet wrote:

> 
> A caller handler can not call del_timer_sync()

A timer handler can not call del_timer_sync()

I am testing a minimal fix :

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
