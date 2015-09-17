From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp_cubic: do not set epoch_start in the future
Date: Thu, 17 Sep 2015 08:38:00 -0700
Message-ID: <1442504280.16225.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Jana Iyengar <jri@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36798 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663AbbIQPiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 11:38:03 -0400
Received: by padhk3 with SMTP id hk3so22759407pad.3
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 08:38:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Tracking idle time in bictcp_cwnd_event() is imprecise, as epoch_start
is normally set at ACK processing time, not at send time.

Doing a proper fix would need to add an additional state variable,
and does not seem worth the trouble, given CUBIC bug has been there
forever before Jana noticed it.

Let's simply not set epoch_start in the future, otherwise
bictcp_update() could overflow and CUBIC would again
grow cwnd too fast.

This was detected thanks to a packetdrill test Neal wrote that was flaky
before applying this fix.

Fixes: 30927520dbae ("tcp_cubic: better follow cubic curve after idle period")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Cc: Jana Iyengar <jri@google.com>
---
 net/ipv4/tcp_cubic.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index c6ded6b2a79f..448c2615fece 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -154,14 +154,20 @@ static void bictcp_init(struct sock *sk)
 static void bictcp_cwnd_event(struct sock *sk, enum tcp_ca_event event)
 {
 	if (event == CA_EVENT_TX_START) {
-		s32 delta = tcp_time_stamp - tcp_sk(sk)->lsndtime;
 		struct bictcp *ca = inet_csk_ca(sk);
+		u32 now = tcp_time_stamp;
+		s32 delta;
+
+		delta = now - tcp_sk(sk)->lsndtime;
 
 		/* We were application limited (idle) for a while.
 		 * Shift epoch_start to keep cwnd growth to cubic curve.
 		 */
-		if (ca->epoch_start && delta > 0)
+		if (ca->epoch_start && delta > 0) {
 			ca->epoch_start += delta;
+			if (after(ca->epoch_start, now))
+				ca->epoch_start = now;
+		}
 		return;
 	}
 }
