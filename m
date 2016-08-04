From: Liang Ge <lungothrin@gmail.com>
Subject: [PATCH] tcp-tso: fix faulty logic in tcp_tso_should_defer
Date: Thu, 4 Aug 2016 12:01:02 +0800
Message-ID: <75F60345-2612-4EF8-A7C3-8F0E1E6215B3@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: edumazet@google.com, herbert@gondor.apana.org.au,
	=?utf-8?B?6auY5piM5Yip?= <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33167 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbcHDEQQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 00:16:16 -0400
Received: by mail-pa0-f68.google.com with SMTP id q2so15620546pap.0
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2016 21:16:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


code does not match comment

	head = tcp_write_queue_head(sk);
	skb_mstamp_get(&now);
	age = skb_mstamp_us_delta(&now, &head->skb_mstamp);
	/* If next ACK is likely to come too late (half srtt), do not defer */
	if (age < (tp->srtt_us >> 4))
		goto send_now;

This bug will cause TSO packets being transmitted too early, and force
software to tear them apart.

When ack clocking is likely to broke, this check will try to push out
some EXTRA probe the first chance possible. Some transmission has
already happened due to Eric's work.

This patch fix the check.
---
 net/ipv4/tcp_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b26aa87..7082964 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1833,7 +1833,7 @@ static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb,
 	skb_mstamp_get(&now);
 	age = skb_mstamp_us_delta(&now, &head->skb_mstamp);
 	/* If next ACK is likely to come too late (half srtt), do not defer */
-	if (age < (tp->srtt_us >> 4))
+	if (age > (tp->srtt_us >> 4))
 		goto send_now;
 
 	/* Ok, it looks like it is advisable to defer. */
-- 
1.8.3.1
