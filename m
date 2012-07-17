From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netem: fix rate extension and drop accounting
Date: Tue, 17 Jul 2012 07:12:27 +0200
Message-ID: <1342501947.2626.9.camel@edumazet-glaptop>
References: <1341307524.2583.115.camel@edumazet-glaptop>
	 <CAPVr9VP7DniPZj4vZi_myJWfL5JLYKYTXXtrXcKHo9LjEQzjYw@mail.gmail.com>
	 <20120716232600.GI3415@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mark Gordon <msg@google.com>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Andreas Terzis <aterzis@google.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:57769 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665Ab2GQFMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 01:12:32 -0400
Received: by eekc13 with SMTP id c13so2920eek.19
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 22:12:31 -0700 (PDT)
In-Reply-To: <20120716232600.GI3415@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-17 at 01:26 +0200, Hagen Paul Pfeifer wrote:

> As Eric said: there are problems in combination with a static delay. During
> rate extension development we tested the raw/vanilla "rate" functionality.
> The rate part works faultless[TM] - at least independet of any other
> "delay-latency generator".

Well, to get correct rate, I use the following unofficial patch :

(Or else, the rate is really wrong)



diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index c412ad0..2740a75 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -433,16 +433,8 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 			delay += packet_len_2_sched_time(skb->len, q);
 
-			if (!skb_queue_empty(list)) {
-				/*
-				 * Last packet in queue is reference point (now).
-				 * First packet in queue is already in flight,
-				 * calculate this time bonus and substract
-				 * from delay.
-				 */
-				delay -= now - netem_skb_cb(skb_peek(list))->time_to_send;
+			if (!skb_queue_empty(list))
 				now = netem_skb_cb(skb_peek_tail(list))->time_to_send;
-			}
 		}
 
 		cb->time_to_send = now + delay;
