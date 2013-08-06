From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: cubic: fix overflow error in bictcp_update()
Date: Mon, 05 Aug 2013 17:10:15 -0700
Message-ID: <1375747815.4457.59.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Van Jacobson <vanj@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:46556 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218Ab3HFAKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 20:10:18 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro12so4008828pbb.27
        for <netdev@vger.kernel.org>; Mon, 05 Aug 2013 17:10:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 17a6e9f1aa9 ("tcp_cubic: fix clock dependency") added an
overflow error in bictcp_update() in following code :

/* change the unit from HZ to bictcp_HZ */
t = ((tcp_time_stamp + msecs_to_jiffies(ca->delay_min>>3) -
      ca->epoch_start) << BICTCP_HZ) / HZ;

Because msecs_to_jiffies() being unsigned long, compiler does
implicit type promotion.

We really want to constrain (tcp_time_stamp - ca->epoch_start)
to a signed 32bit value, or else 't' has unexpected high values.

This bugs triggers an increase of retransmit rates ~24 days after
boot [1], as the high order bit of tcp_time_stamp flips.

[1] for hosts with HZ=1000

Big thanks to Van Jacobson for spotting this problem.

Diagnosed-by: Van Jacobson <vanj@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
---
 net/ipv4/tcp_cubic.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index a9077f4..b6b591f 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -206,8 +206,8 @@ static u32 cubic_root(u64 a)
  */
 static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
 {
-	u64 offs;
-	u32 delta, t, bic_target, max_cnt;
+	u32 delta, bic_target, max_cnt;
+	u64 offs, t;
 
 	ca->ack_cnt++;	/* count the number of ACKs */
 
@@ -250,9 +250,11 @@ static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
 	 * if the cwnd < 1 million packets !!!
 	 */
 
+	t = (s32)(tcp_time_stamp - ca->epoch_start);
+	t += msecs_to_jiffies(ca->delay_min >> 3);
 	/* change the unit from HZ to bictcp_HZ */
-	t = ((tcp_time_stamp + msecs_to_jiffies(ca->delay_min>>3)
-	      - ca->epoch_start) << BICTCP_HZ) / HZ;
+	t <<= BICTCP_HZ;
+	do_div(t, HZ);
 
 	if (t < ca->bic_K)		/* t - K */
 		offs = ca->bic_K - t;
