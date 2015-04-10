From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp/dccp: do not block bh too long in
 inet_twdr_twkill_work()
Date: Fri, 10 Apr 2015 04:19:07 -0700
Message-ID: <1428664747.25985.298.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:34151 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755405AbbDJLTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 07:19:11 -0400
Received: by iedfl3 with SMTP id fl3so16475663ied.1
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 04:19:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

I have seen inet_twdr_twkill_work() blocking softirq for
periods up to 1.5 seconds, depending on number of timewait sockets.

This is an unacceptable source of latency.

Note that inet_twdr_do_twkill_work() releases death_lock spinlock
for every tw handled, but does not take care of bh enabling.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_timewait_sock.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 6d592f8555fb..9c7f480d6ad8 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -303,11 +303,9 @@ void inet_twdr_twkill_work(struct work_struct *work)
 				continue;
 
 			while (inet_twdr_do_twkill_work(twdr, i) != 0) {
-				if (need_resched()) {
-					spin_unlock_bh(&twdr->death_lock);
-					schedule();
-					spin_lock_bh(&twdr->death_lock);
-				}
+				spin_unlock_bh(&twdr->death_lock);
+				cond_resched();
+				spin_lock_bh(&twdr->death_lock);
 			}
 
 			twdr->thread_slots &= ~(1 << i);
