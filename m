From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH net-next] strparser: Use delayed work instead of timer for msg timeout
Date: Fri, 20 Oct 2017 16:40:43 -0700
Message-ID: <20171020234043.2629-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        john.fastabend@gmail.com, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:46402 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752498AbdJTXlE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 19:41:04 -0400
Received: by mail-pf0-f195.google.com with SMTP id p87so13122479pfj.3
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 16:41:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sock lock may be taken in the message timer function which is a
problem since timers run in BH. Instead of timers use delayed_work.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Fixes: bbb03029a899 ("strparser: Generalize strparser")
Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 include/net/strparser.h   |  3 +--
 net/strparser/strparser.c | 17 ++++++++---------
 2 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/include/net/strparser.h b/include/net/strparser.h
index 7dc131d62ad5..d96b59f45eba 100644
--- a/include/net/strparser.h
+++ b/include/net/strparser.h
@@ -74,10 +74,9 @@ struct strparser {
 	u32 unrecov_intr : 1;
 
 	struct sk_buff **skb_nextp;
-	struct timer_list msg_timer;
 	struct sk_buff *skb_head;
 	unsigned int need_bytes;
-	struct delayed_work delayed_work;
+	struct delayed_work msg_timer_work;
 	struct work_struct work;
 	struct strp_stats stats;
 	struct strp_callbacks cb;
diff --git a/net/strparser/strparser.c b/net/strparser/strparser.c
index d4ea46a5f233..c5fda15ba319 100644
--- a/net/strparser/strparser.c
+++ b/net/strparser/strparser.c
@@ -49,7 +49,7 @@ static void strp_abort_strp(struct strparser *strp, int err)
 {
 	/* Unrecoverable error in receive */
 
-	del_timer(&strp->msg_timer);
+	cancel_delayed_work(&strp->msg_timer_work);
 
 	if (strp->stopped)
 		return;
@@ -68,7 +68,7 @@ static void strp_abort_strp(struct strparser *strp, int err)
 static void strp_start_timer(struct strparser *strp, long timeo)
 {
 	if (timeo)
-		mod_timer(&strp->msg_timer, timeo);
+		mod_delayed_work(strp_wq, &strp->msg_timer_work, timeo);
 }
 
 /* Lower lock held */
@@ -319,7 +319,7 @@ static int __strp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
 		eaten += (cand_len - extra);
 
 		/* Hurray, we have a new message! */
-		del_timer(&strp->msg_timer);
+		cancel_delayed_work(&strp->msg_timer_work);
 		strp->skb_head = NULL;
 		STRP_STATS_INCR(strp->stats.msgs);
 
@@ -450,9 +450,10 @@ static void strp_work(struct work_struct *w)
 	do_strp_work(container_of(w, struct strparser, work));
 }
 
-static void strp_msg_timeout(unsigned long arg)
+static void strp_msg_timeout(struct work_struct *w)
 {
-	struct strparser *strp = (struct strparser *)arg;
+	struct strparser *strp = container_of(w, struct strparser,
+					      msg_timer_work.work);
 
 	/* Message assembly timed out */
 	STRP_STATS_INCR(strp->stats.msg_timeouts);
@@ -505,9 +506,7 @@ int strp_init(struct strparser *strp, struct sock *sk,
 	strp->cb.read_sock_done = cb->read_sock_done ? : default_read_sock_done;
 	strp->cb.abort_parser = cb->abort_parser ? : strp_abort_strp;
 
-	setup_timer(&strp->msg_timer, strp_msg_timeout,
-		    (unsigned long)strp);
-
+	INIT_DELAYED_WORK(&strp->msg_timer_work, strp_msg_timeout);
 	INIT_WORK(&strp->work, strp_work);
 
 	return 0;
@@ -532,7 +531,7 @@ void strp_done(struct strparser *strp)
 {
 	WARN_ON(!strp->stopped);
 
-	del_timer_sync(&strp->msg_timer);
+	cancel_delayed_work_sync(&strp->msg_timer_work);
 	cancel_work_sync(&strp->work);
 
 	if (strp->skb_head) {
-- 
2.11.0
