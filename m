From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH] tcp: undo spurious timeout after SACK reneging
Date: Sun, 24 Mar 2013 13:42:25 -0700
Message-ID: <1364157745-24866-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	nanditad@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f201.google.com ([209.85.128.201]:46378 "EHLO
	mail-ve0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753869Ab3CXUm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 16:42:28 -0400
Received: by mail-ve0-f201.google.com with SMTP id 14so560889vea.0
        for <netdev@vger.kernel.org>; Sun, 24 Mar 2013 13:42:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On SACK reneging the sender immediately retransmits and forces a
timeout but disables Eifel (undo). If the (buggy) receiver does not
drop any packet this can trigger a false slow-start retransmit storm
driven by the ACKs of the original packets. This can be detected with
undo and TCP timestamps.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b2b3619..6d9ca35 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1858,11 +1858,8 @@ void tcp_enter_loss(struct sock *sk, int how)
 	if (tcp_is_reno(tp))
 		tcp_reset_reno_sack(tp);
 
-	if (!how) {
-		/* Push undo marker, if it was plain RTO and nothing
-		 * was retransmitted. */
-		tp->undo_marker = tp->snd_una;
-	} else {
+	tp->undo_marker = tp->snd_una;
+	if (how) {
 		tp->sacked_out = 0;
 		tp->fackets_out = 0;
 	}
-- 
1.8.1.3
