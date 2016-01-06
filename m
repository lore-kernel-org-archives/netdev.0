From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net] tcp: fix zero cwnd in tcp_cwnd_reduction
Date: Wed,  6 Jan 2016 12:42:38 -0800
Message-ID: <1452112958-1589-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, oleksandr@natalenko.name,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36484 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761AbcAFUnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 15:43:24 -0500
Received: by mail-pa0-f50.google.com with SMTP id yy13so146992974pab.3
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 12:43:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 3759824da87b ("tcp: PRR uses CRB mode by default and SS mode
conditionally") introduced a bug that cwnd may become 0 when both
inflight and sndcnt are 0 (cwnd = inflight + sndcnt). This may lead
to a div-by-zero if the connection starts another cwnd reduction
phase by setting tp->prior_cwnd to the current cwnd (0) in
tcp_init_cwnd_reduction().

To prevent this we skip PRR operation when nothing is acked or
sacked. Then cwnd must be positive in all cases as long as ssthresh
is positive:

1) The proportional reduction mode
   inflight > ssthresh > 0

2) The reduction bound mode
  a) inflight == ssthresh > 0

  b) inflight < ssthresh
     sndcnt > 0 since newly_acked_sacked > 0 and inflight < ssthresh

Therefore in all cases inflight and sndcnt can not both be 0.
We check invalid tp->prior_cwnd to avoid potential div0 bugs.

In reality this bug is triggered only with a sequence of less common
events.  For example, the connection is terminating an ECN-triggered
cwnd reduction with an inflight 0, then it receives reordered/old
ACKs or DSACKs from prior transmission (which acks nothing). Or the
connection is in fast recovery stage that marks everything lost,
but fails to retransmit due to local issues, then receives data
packets from other end which acks nothing.

Fixes: 3759824da87b ("tcp: PRR uses CRB mode by default and SS mode conditionally")
Reported-by: Oleksandr Natalenko <oleksandr@natalenko.name>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2d656ee..d4c5115 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2478,6 +2478,9 @@ static void tcp_cwnd_reduction(struct sock *sk, const int prior_unsacked,
 	int newly_acked_sacked = prior_unsacked -
 				 (tp->packets_out - tp->sacked_out);
 
+	if (newly_acked_sacked <= 0 || WARN_ON_ONCE(!tp->prior_cwnd))
+		return;
+
 	tp->prr_delivered += newly_acked_sacked;
 	if (delta < 0) {
 		u64 dividend = (u64)tp->snd_ssthresh * tp->prr_delivered +
-- 
2.6.0.rc2.230.g3dd15c0
