From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] sch_htb.c consume the classes's tokens bellow the HTB_CAN_SEND
 level
Date: Tue, 03 Nov 2009 10:41:38 +0800
Message-ID: <4AEF9862.8040404@gmail.com>
Reply-To: xiaosuo@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: devik@cdi.cz, netdev@vger.kernel.org, xiaosuo <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:63836 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756037AbZKCClg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 21:41:36 -0500
Received: by ywh40 with SMTP id 40so5071271ywh.33
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2009 18:41:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sch_htb.c consume the classes's tokens bellow the HTB_CAN_SEND level.

When a class enters HTB_MAY_BORROW state, it relies on its parents to
sent packets. The parent class in HTB_CAN_SEND state only consumes
itself and its parents's tokens, but ADD tokens to the classes under its
level. It is totally wrong. It means that a class, which sends packets
in ceil rate, can also enter HTB_CAN_SEND state now and then.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>

----
net/sched/sch_htb.c | 3 +--
1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 85acab9..2705702 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -629,11 +629,10 @@ static void htb_charge_class(struct htb_sched *q, struct htb_class *cl,
 		if (cl->level >= level) {
 			if (cl->level == level)
 				cl->xstats.lends++;
-			htb_accnt_tokens(cl, bytes, diff);
 		} else {
 			cl->xstats.borrows++;
-			cl->tokens += diff;	/* we moved t_c; update tokens */
 		}
+		htb_accnt_tokens(cl, bytes, diff);
 		htb_accnt_ctokens(cl, bytes, diff);
 		cl->t_c = q->now;
 


