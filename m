From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] sch_red: fix red_change
Date: Thu, 01 Dec 2011 22:06:34 +0100
Message-ID: <1322773594.2750.28.camel@edumazet-laptop>
References: <1322684749.2602.3.camel@edumazet-laptop>
	 <20111130143642.7130aa2b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Graf <tgraf@infradead.org>, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:45005 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212Ab1LAVGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 16:06:41 -0500
Received: by faaq16 with SMTP id q16so1754750faa.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 13:06:40 -0800 (PST)
In-Reply-To: <20111130143642.7130aa2b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 30 novembre 2011 =C3=A0 14:36 -0800, Stephen Hemminger a =C3=
=A9crit :

> (Almost) nobody uses RED because they can't figure it out.
> According to Wikipedia, VJ says that:=20
>  "there are not one, but two bugs in classic RED."

RED is useful for high throughput routers, I doubt many linux machines
act as such devices.

I was considering adding Adaptative RED (Sally Floyd, Ramakrishna
Gummadi, Scott Shender), August 2001=20

In this version, maxp is dynamic (from 1% to 50%), and user only have t=
o
setup min_th (target average queue size)
(max_th and wq (burst in linux RED) are automatically setup)


By the way it seems we have a small bug in red_change()

if (skb_queue_empty(&sch->q))
	red_end_of_idle_period(&q->parms);

=46irst, if queue is empty, we should call
red_start_of_idle_period(&q->parms);

Second, since we dont use anymore sch->q, but q->qdisc, the test is
meaningless.

Oh well...

[PATCH] sch_red: fix red_change()

Now RED is classful, we must check q->qdisc->q.qlen, and if queue is em=
pty,
we start an idle period, not end it.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 6649463..d617161 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -209,8 +209,8 @@ static int red_change(struct Qdisc *sch, struct nla=
ttr *opt)
 				 ctl->Plog, ctl->Scell_log,
 				 nla_data(tb[TCA_RED_STAB]));
=20
-	if (skb_queue_empty(&sch->q))
-		red_end_of_idle_period(&q->parms);
+	if (!q->qdisc->q.qlen)
+		red_start_of_idle_period(&q->parms);
=20
 	sch_tree_unlock(sch);
 	return 0;
