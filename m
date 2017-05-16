From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 02/15] tcp: introduce tcp_jiffies32
Date: Tue, 16 May 2017 14:00:01 -0700
Message-ID: <20170516210014.31176-3-edumazet@google.com>
References: <20170516210014.31176-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:33385 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751300AbdEPV17 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 17:27:59 -0400
Received: by mail-pg0-f53.google.com with SMTP id u187so82194738pgb.0
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 14:27:59 -0700 (PDT)
In-Reply-To: <20170516210014.31176-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We abuse tcp_time_stamp for two different cases :

1) base to generate TCP Timestamp options (RFC 7323)

2) A 32bit version of jiffies since some TCP fields
   are 32bit wide to save memory.

Since we want in the future to have 1ms TCP TS clock,
regardless of HZ value, we want to cleanup things.

tcp_jiffies32 is the truncated jiffies value,
which will be used only in places where we want a 'host'
timestamp.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index b4dc93dae98c2d175ccadce150083705d237555e..4b45be5708215bae4551a5430b63ab2777baf447 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -700,11 +700,14 @@ u32 __tcp_select_window(struct sock *sk);
 
 void tcp_send_window_probe(struct sock *sk);
 
-/* TCP timestamps are only 32-bits, this causes a slight
- * complication on 64-bit systems since we store a snapshot
- * of jiffies in the buffer control blocks below.  We decided
- * to use only the low 32-bits of jiffies and hide the ugly
- * casts with the following macro.
+/* TCP uses 32bit jiffies to save some space.
+ * Note that this is different from tcp_time_stamp, which
+ * historically has been the same until linux-4.13.
+ */
+#define tcp_jiffies32 ((u32)jiffies)
+
+/* Generator for TCP TS option (RFC 7323)
+ * Currently tied to 'jiffies' but will soon be driven by 1 ms clock.
  */
 #define tcp_time_stamp		((__u32)(jiffies))
 
-- 
2.13.0.303.g4ebf302169-goog
