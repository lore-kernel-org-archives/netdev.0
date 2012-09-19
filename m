From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [RFC PATCH] tcp: use of undefined variable
Date: Wed, 19 Sep 2012 15:46:06 +0100
Message-ID: <20120919144557.16956.11280.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:36251 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752725Ab2ISO2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 10:28:10 -0400
Received: from localhost.localdomain (earthlight.etchedpixels.co.uk [81.2.110.250])
	by lxorguk.ukuu.org.uk (8.14.5/8.14.1) with ESMTP id q8JF0Z5U013204
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 16:00:45 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>

Both tcp_timewait_state_process and tcp_check_req use the same basic
construct of

	struct tcp_options received tmp_opt;
	tmp_opt.saw_tstamp = 0;

then call

	tcp_parse_options

However if they are fed a frame containing a TCP_SACK then tbe code
behaviour is undefined because opt_rx->sack_ok is undefined data.

This ought to be documented if it is intentional.

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 net/ipv4/tcp_minisocks.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index e965319..a4ace80 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -85,6 +85,8 @@ static bool tcp_in_window(u32 seq, u32 end_seq, u32 s_win, u32 e_win)
  * spinlock it. I do not want! Well, probability of misbehaviour
  * is ridiculously low and, seems, we could use some mb() tricks
  * to avoid misread sequence numbers, states etc.  --ANK
+ *
+ * We don't need to initialize tmp_out.sack_ok as we don't use the results
  */
 enum tcp_tw_status
 tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
@@ -96,6 +98,7 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 	bool paws_reject = false;
 
 	tmp_opt.saw_tstamp = 0;
+
 	if (th->doff > (sizeof(*th) >> 2) && tcptw->tw_ts_recent_stamp) {
 		tcp_parse_options(skb, &tmp_opt, &hash_location, 0, NULL);
 
@@ -522,6 +525,8 @@ EXPORT_SYMBOL(tcp_create_openreq_child);
  *
  * XXX (TFO) - The current impl contains a special check for ack
  * validation and inside tcp_v4_reqsk_send_ack(). Can we do better?
+ *
+ * We don't need to initialize tmp_opt.sack_ok as we don't use the results
  */
 
 struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
