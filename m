From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net] tcp: init tcp_options before using it.
Date: Mon,  8 May 2017 17:57:57 +0800
Message-ID: <1494237477-19023-1-git-send-email-liuhangbin@gmail.com>
Cc: Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35854 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753808AbdEHJ6R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 05:58:17 -0400
Received: by mail-pf0-f195.google.com with SMTP id v14so9184201pfd.3
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 02:58:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I searched 4308fc58dced ("tcp: Document use of undefined variable") in
archive list, but did not find the thread. So I'm not sure why we only
add a description about un-initialized value.

Even we don't use tmp_opt.sack_ok, I think it would be more safe to
initialize the value before using it. Just as other caller did.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 net/ipv4/tcp_minisocks.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 717be4d..6ca2546 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -85,8 +85,6 @@ tcp_timewait_check_oow_rate_limit(struct inet_timewait_sock *tw,
  * spinlock it. I do not want! Well, probability of misbehaviour
  * is ridiculously low and, seems, we could use some mb() tricks
  * to avoid misread sequence numbers, states etc.  --ANK
- *
- * We don't need to initialize tmp_out.sack_ok as we don't use the results
  */
 enum tcp_tw_status
 tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
@@ -96,7 +94,7 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 	struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
 	bool paws_reject = false;
 
-	tmp_opt.saw_tstamp = 0;
+	memset(&tmp_opt, 0, sizeof(tmp_opt));
 	if (th->doff > (sizeof(*th) >> 2) && tcptw->tw_ts_recent_stamp) {
 		tcp_parse_options(skb, &tmp_opt, 0, NULL);
 
@@ -542,8 +540,6 @@ EXPORT_SYMBOL(tcp_create_openreq_child);
  *
  * XXX (TFO) - The current impl contains a special check for ack
  * validation and inside tcp_v4_reqsk_send_ack(). Can we do better?
- *
- * We don't need to initialize tmp_opt.sack_ok as we don't use the results
  */
 
 struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
@@ -557,7 +553,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	bool paws_reject = false;
 	bool own_req;
 
-	tmp_opt.saw_tstamp = 0;
+	memset(&tmp_opt, 0, sizeof(tmp_opt));
 	if (th->doff > (sizeof(struct tcphdr)>>2)) {
 		tcp_parse_options(skb, &tmp_opt, 0, NULL);
 
-- 
2.5.5
