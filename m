From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] netem: free skb's in tree on reset
Date: Sun, 6 Oct 2013 15:16:49 -0700
Message-ID: <20131006151649.38038c0e@nehalam.linuxnetplumber.net>
References: <20131006151533.52988624@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:43401 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500Ab3JIVUA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 17:20:00 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so1544896pdj.8
        for <netdev@vger.kernel.org>; Wed, 09 Oct 2013 14:19:59 -0700 (PDT)
In-Reply-To: <20131006151533.52988624@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Netem can leak memory because packets get stored in red-black
tree and it is not cleared on reset.

Reported by: =D0=A1=D0=B5=D1=80=D0=B3=D0=B5=D0=B5=D0=B2 =D0=A1=D0=B5=D1=
=80=D0=B3=D0=B5=D0=B9 <adron@yapic.net>
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/sched/sch_netem.c	2013-10-06 15:10:03.957219532 -0700
+++ b/net/sched/sch_netem.c	2013-10-06 15:10:10.521150202 -0700
@@ -358,6 +358,21 @@ static psched_time_t packet_len_2_sched_
 	return PSCHED_NS2TICKS(ticks);
 }
=20
+static void tfifo_reset(struct Qdisc *sch)
+{
+	struct netem_sched_data *q =3D qdisc_priv(sch);
+	struct rb_node *p;
+
+	while ((p =3D rb_first(&q->t_root)) {
+		struct sk_buff *skb =3D netem_rb_to_skb(p);
+
+		rb_erase(p, &q->t_root);
+		skb->next =3D NULL;
+		skb->prev =3D NULL;
+		kfree_skb(skb);
+	}
+}
+
 static void tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
 {
 	struct netem_sched_data *q =3D qdisc_priv(sch);
@@ -610,6 +625,7 @@ static void netem_reset(struct Qdisc *sc
 	struct netem_sched_data *q =3D qdisc_priv(sch);
=20
 	qdisc_reset_queue(sch);
+	tfifo_reset(sch);
 	if (q->qdisc)
 		qdisc_reset(q->qdisc);
 	qdisc_watchdog_cancel(&q->watchdog);
