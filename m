From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: make challenge acks less predictable
Date: Fri, 08 Jul 2016 18:33:06 +0200
Message-ID: <1467995586.30694.34.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yue Cao <ycao009@ucr.edu>,
	Zhiyun Qian <zhiyunq@cs.ucr.edu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:33505 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755171AbcGHQdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 12:33:11 -0400
Received: by mail-yw0-f195.google.com with SMTP id i12so9237218ywa.0
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 09:33:11 -0700 (PDT)
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
to remove the host limit. This might be done later.

Fixes: 282f23c6ee34 ("tcp: implement RFC 5961 3.2")
Reported-by: Yue Cao <ycao009@ucr.edu>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 9ae929395b24..391ed93a8e49 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -732,7 +732,7 @@ tcp_limit_output_bytes - INTEGER
 tcp_challenge_ack_limit - INTEGER
 	Limits number of Challenge ACK sent per second, as recommended
 	in RFC 5961 (Improving TCP's Robustness to Blind In-Window Attacks)
-	Default: 100
+	Default: 1000
 
 UDP variables:
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d6c8f4cd0800..25f95a41090a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -87,7 +87,7 @@ int sysctl_tcp_adv_win_scale __read_mostly = 1;
 EXPORT_SYMBOL(sysctl_tcp_adv_win_scale);
 
 /* rfc5961 challenge ack rate limiting */
-int sysctl_tcp_challenge_ack_limit = 100;
+int sysctl_tcp_challenge_ack_limit = 1000;
 
 int sysctl_tcp_stdurg __read_mostly;
 int sysctl_tcp_rfc1337 __read_mostly;
@@ -3455,10 +3455,11 @@ not_rate_limited:
 static void tcp_send_challenge_ack(struct sock *sk, const struct sk_buff *skb)
 {
 	/* unprotected vars, we dont care of overwrites */
-	static u32 challenge_timestamp;
+	static unsigned int challenge_window = HZ;
+	static unsigned long challenge_timestamp;
 	static unsigned int challenge_count;
 	struct tcp_sock *tp = tcp_sk(sk);
-	u32 now;
+	unsigned long now;
 
 	/* First check our per-socket dupack rate limit. */
 	if (tcp_oow_rate_limited(sock_net(sk), skb,
@@ -3467,9 +3468,11 @@ static void tcp_send_challenge_ack(struct sock *sk, const struct sk_buff *skb)
 		return;
 
 	/* Then check the check host-wide RFC 5961 rate limit. */
-	now = jiffies / HZ;
-	if (now != challenge_timestamp) {
+	now = jiffies;
+	if (time_before(now, challenge_timestamp) ||
+	    time_after_eq(now, challenge_timestamp + challenge_window)) {
 		challenge_timestamp = now;
+		challenge_window = HZ/2 + prandom_u32_max(HZ);
 		challenge_count = 0;
 	}
 	if (++challenge_count <= sysctl_tcp_challenge_ack_limit) {
