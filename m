From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net] tcp: make challenge acks less predictable
Date: Sun, 10 Jul 2016 10:04:02 +0200
Message-ID: <1468137842.30694.58.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1467995586.30694.34.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAPzkZjz1R_T8q75LXLBc91j7YrngxdPc-o2Hpz+4YYyoWLantA@mail.gmail.com>
	 <1468052160.30694.51.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Zhiyun Qian <zhiyunq@cs.ucr.edu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Yuchung Cheng <ycheng@google.com>,
	NealCardwell <ncardwell@google.com>
To: Yue Cao <ycao009@ucr.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33795 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbcGJIEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2016 04:04:12 -0400
Received: by mail-wm0-f65.google.com with SMTP id w75so12818823wmd.1
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2016 01:04:11 -0700 (PDT)
In-Reply-To: <1468052160.30694.51.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Yue Cao claims that current host rate limiting of challenge ACKS
(RFC 5961) could leak enough information to allow a patient attacker
to hijack TCP sessions. He will soon provide details in an academic
paper.

This patch increases the default limit from 100 to 1000, and adds
some randomization so that the attacker can no longer hijack
sessions without spending a considerable amount of probes.

Based on initial analysis and patch from Linus.

Note that we also have per socket rate limiting, so it is tempting
to remove the host limit in the future.

v2: randomize the count of challenge acks per second, not the period.

Fixes: 282f23c6ee34 ("tcp: implement RFC 5961 3.2")
Reported-by: Yue Cao <ycao009@ucr.edu>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d6c8f4cd0800..91868bb17818 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -87,7 +87,7 @@ int sysctl_tcp_adv_win_scale __read_mostly = 1;
 EXPORT_SYMBOL(sysctl_tcp_adv_win_scale);
 
 /* rfc5961 challenge ack rate limiting */
-int sysctl_tcp_challenge_ack_limit = 100;
+int sysctl_tcp_challenge_ack_limit = 1000;
 
 int sysctl_tcp_stdurg __read_mostly;
 int sysctl_tcp_rfc1337 __read_mostly;
@@ -3458,7 +3458,7 @@ static void tcp_send_challenge_ack(struct sock *sk, const struct sk_buff *skb)
 	static u32 challenge_timestamp;
 	static unsigned int challenge_count;
 	struct tcp_sock *tp = tcp_sk(sk);
-	u32 now;
+	u32 count, now;
 
 	/* First check our per-socket dupack rate limit. */
 	if (tcp_oow_rate_limited(sock_net(sk), skb,
@@ -3466,13 +3466,18 @@ static void tcp_send_challenge_ack(struct sock *sk, const struct sk_buff *skb)
 				 &tp->last_oow_ack_time))
 		return;
 
-	/* Then check the check host-wide RFC 5961 rate limit. */
+	/* Then check host-wide RFC 5961 rate limit. */
 	now = jiffies / HZ;
 	if (now != challenge_timestamp) {
+		u32 half = (sysctl_tcp_challenge_ack_limit + 1) >> 1;
+
 		challenge_timestamp = now;
-		challenge_count = 0;
+		WRITE_ONCE(challenge_count, half +
+			   prandom_u32_max(sysctl_tcp_challenge_ack_limit));
 	}
-	if (++challenge_count <= sysctl_tcp_challenge_ack_limit) {
+	count = READ_ONCE(challenge_count);
+	if (count > 0) {
+		WRITE_ONCE(challenge_count, count - 1);
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPCHALLENGEACK);
 		tcp_send_ack(sk);
 	}
