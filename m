From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: cubic: fix bug in bictcp_acked()
Date: Mon, 05 Aug 2013 20:05:12 -0700
Message-ID: <1375758312.4457.69.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	netdev <netdev@vger.kernel.org>, Van Jacobson <vanj@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:61504 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753566Ab3HFDFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 23:05:15 -0400
Received: by mail-pa0-f45.google.com with SMTP id bg4so143195pad.4
        for <netdev@vger.kernel.org>; Mon, 05 Aug 2013 20:05:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While investigating about strange increase of retransmit rates
on hosts ~24 days after boot, Van found hystart was disabled
if ca->epoch_start was 0, as following condition is true
when tcp_time_stamp high order bit is set.

(s32)(tcp_time_stamp - ca->epoch_start) < HZ

Quoting Van :

 At initialization & after every loss ca->epoch_start is set to zero so
 I believe that the above line will turn off hystart as soon as the 2^31
 bit is set in tcp_time_stamp & hystart will stay off for 24 days.
 I think we've observed that cubic's restart is too aggressive without
 hystart so this might account for the higher drop rate we observe.

Diagnosed-by: Van Jacobson <vanj@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_cubic.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index a9077f4..2b8671d 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -414,7 +414,7 @@ static void bictcp_acked(struct sock *sk, u32 cnt, s32 rtt_us)
 		return;
 
 	/* Discard delay samples right after fast recovery */
-	if ((s32)(tcp_time_stamp - ca->epoch_start) < HZ)
+	if (ca->epoch_start && (s32)(tcp_time_stamp - ca->epoch_start) < HZ)
 		return;
 
 	delay = (rtt_us << 3) / USEC_PER_MSEC;
