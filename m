From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next] tcp: update reordering first before detecting loss
Date: Wed, 29 Apr 2015 11:28:30 -0700
Message-ID: <1430332110-10278-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:36864 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801AbbD2S2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 14:28:45 -0400
Received: by igblo3 with SMTP id lo3so56422088igb.0
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 11:28:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_mark_lost_retrans is not used when FACK is disabled. Since
tcp_update_reordering may disable FACK, it should be called first
before tcp_mark_lost_retrans.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Nandita Dukkipati <nanditad@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3a4d9b34..5136247 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1820,14 +1820,12 @@ advance_sp:
 	for (j = 0; j < used_sacks; j++)
 		tp->recv_sack_cache[i++] = sp[j];
 
-	tcp_mark_lost_retrans(sk);
-
-	tcp_verify_left_out(tp);
-
 	if ((state.reord < tp->fackets_out) &&
 	    ((inet_csk(sk)->icsk_ca_state != TCP_CA_Loss) || tp->undo_marker))
 		tcp_update_reordering(sk, tp->fackets_out - state.reord, 0);
 
+	tcp_mark_lost_retrans(sk);
+	tcp_verify_left_out(tp);
 out:
 
 #if FASTRETRANS_DEBUG > 0
-- 
2.2.0.rc0.207.ga3a616c
