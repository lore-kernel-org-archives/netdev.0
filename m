From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net 2/2] tcp: don't over-send F-RTO probes
Date: Mon, 18 May 2015 12:31:45 -0700
Message-ID: <1431977505-15014-2-git-send-email-ycheng@google.com>
References: <1431977505-15014-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:36525 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932358AbbERTcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 15:32:41 -0400
Received: by igbpi8 with SMTP id pi8so57564405igb.1
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 12:32:40 -0700 (PDT)
In-Reply-To: <1431977505-15014-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After sending the new data packets to probe (step 2), F-RTO may
incorrectly send more probes if the next ACK advances SND_UNA and
does not sack new packet. However F-RTO RFC 5682 probes at most
once. This bug may cause sender to always send new data instead of
repairing holes, inducing longer HoL blocking on the receiver for
the application.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9faf775..243d674 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2710,9 +2710,9 @@ static void tcp_process_loss(struct sock *sk, int flag, bool is_dupack)
 		    tcp_try_undo_loss(sk, true))
 			return;
 
-		if (after(tp->snd_nxt, tp->high_seq) &&
-		    (flag & FLAG_DATA_SACKED || is_dupack)) {
-			tp->frto = 0; /* Loss was real: 2nd part of step 3.a */
+		if (after(tp->snd_nxt, tp->high_seq)) {
+			if (flag & FLAG_DATA_SACKED || is_dupack)
+				tp->frto = 0; /* Step 3.a. loss was real */
 		} else if (flag & FLAG_SND_UNA_ADVANCED && !recovered) {
 			tp->high_seq = tp->snd_nxt;
 			__tcp_push_pending_frames(sk, tcp_current_mss(sk),
-- 
2.2.0.rc0.207.ga3a616c
