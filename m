From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net] sctp: fix missing wake ups in some situations
Date: Fri,  8 Sep 2017 11:35:21 -0300
Message-ID: <202d7b2e172746c0bed742255bc1583beca45fce.1504880548.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Harald Welte <laforge@gnumonks.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:34586 "EHLO
        mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754978AbdIHOfl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 10:35:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit fb586f25300f ("sctp: delay calls to sk_data_ready() as much as
possible") minimized the number of wake ups that are triggered in case
the association receives a packet with multiple data chunks on it and/or
when io_events are enabled and then commit 0970f5b36659 ("sctp: signal
sk_data_ready earlier on data chunks reception") moved the wake up to as
soon as possible. It thus relies on the state machine running later to
clean the flag that the event was already generated.

The issue is that there are 2 call paths that calls
sctp_ulpq_tail_event() outside of the state machine, causing the flag to
linger and possibly omitting a needed wake up in the sequence.

One of the call paths is when enabling SCTP_SENDER_DRY_EVENTS via
setsockopt(SCTP_EVENTS), as noticed by Harald Welte. The other is when
partial reliability triggers removal of chunks from the send queue when
the application calls sendmsg().

This commit fixes it by not setting the flag in case the socket is not
owned by the user, as it won't be cleaned later. This works for
user-initiated calls and also for rx path processing.

Fixes: fb586f25300f ("sctp: delay calls to sk_data_ready() as much as possible")
Reported-by: Harald Welte <laforge@gnumonks.org>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---

Hi. Please consider this one for -stable. Thanks

 net/sctp/ulpqueue.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 0225d62a869f8deff10565c4625df0a10464ce87..a71be33f3afeb0aaaef174ee082c4c547aab1e2d 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -265,7 +265,8 @@ int sctp_ulpq_tail_event(struct sctp_ulpq *ulpq, struct sctp_ulpevent *event)
 		sctp_ulpq_clear_pd(ulpq);
 
 	if (queue == &sk->sk_receive_queue && !sp->data_ready_signalled) {
-		sp->data_ready_signalled = 1;
+		if (!sock_owned_by_user(sk))
+			sp->data_ready_signalled = 1;
 		sk->sk_data_ready(sk);
 	}
 	return 1;
-- 
2.13.5
