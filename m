From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: syncookies: do not use getnstimeofday()
Date: Wed, 19 Mar 2014 14:06:21 -0700
Message-ID: <1395263181.9114.69.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1379709176-1625-1-git-send-email-fw@strlen.de>
	 <1395261524.9114.60.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:53571 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752771AbaCSVGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 17:06:21 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so9490414pad.7
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 14:06:20 -0700 (PDT)
In-Reply-To: <1395261524.9114.60.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While it is true that getnstimeofday() uses about 40 cycles if TSC
is available, it can use 1600 cycles if hpet is the clocksource.

Switch to local_clock(). This one consumes 26 cycles and is not
impacted by a date/time change.

Fixes: 8c27bd75f04f ("tcp: syncookies: reduce cookie lifetime to 128 seconds")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Florian Westphal <fw@strlen.de>
---
 include/net/tcp.h |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index bb253b9b2f06..b7e524bb297e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -484,16 +484,15 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
  * This counter is used both as a hash input and partially encoded into
  * the cookie value.  A cookie is only validated further if the delta
  * between the current counter value and the encoded one is less than this,
- * i.e. a sent cookie is valid only at most for 128 seconds (or less if
+ * i.e. a sent cookie is valid only at most for 2*68 seconds (or less if
  * the counter advances immediately after a cookie is generated).
  */
 #define MAX_SYNCOOKIE_AGE 2
 
 static inline u32 tcp_cookie_time(void)
 {
-	struct timespec now;
-	getnstimeofday(&now);
-	return now.tv_sec >> 6; /* 64 seconds granularity */
+	/* 2^36 nsec = ~68.7 sec */
+	return local_clock() >> 36;
 }
 
 u32 __cookie_v4_init_sequence(const struct iphdr *iph, const struct tcphdr *th,
