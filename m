From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/3] tun: avoid extra timer schedule in tun_flow_cleanup()
Date: Fri, 20 Oct 2017 11:29:56 -0700
Message-ID: <20171020182957.32729-3-edumazet@google.com>
References: <20171020182957.32729-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jason Wang <jasowang@redhat.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:53778 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752369AbdJTSaF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 14:30:05 -0400
Received: by mail-pf0-f193.google.com with SMTP id t188so12194943pfd.10
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 11:30:05 -0700 (PDT)
In-Reply-To: <20171020182957.32729-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If tun_flow_cleanup() deleted all flows, no need to
arm the timer again. It will be armed next time
tun_flow_update() is called.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/tun.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index f9541f7f9fb7592b50ac818702006f4f1042b448..995887de5a98283382a631bcb8dfd874a4037ed3 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -461,11 +461,14 @@ static void tun_flow_cleanup(unsigned long data)
 
 		hlist_for_each_entry_safe(e, n, &tun->flows[i], hash_link) {
 			unsigned long this_timer;
-			count++;
+
 			this_timer = e->updated + delay;
-			if (time_before_eq(this_timer, jiffies))
+			if (time_before_eq(this_timer, jiffies)) {
 				tun_flow_delete(tun, e);
-			else if (time_before(this_timer, next_timer))
+				continue;
+			}
+			count++;
+			if (time_before(this_timer, next_timer))
 				next_timer = this_timer;
 		}
 	}
-- 
2.15.0.rc0.271.g36b669edcc-goog
