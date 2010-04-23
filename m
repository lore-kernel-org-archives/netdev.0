From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Fri, 23 Apr 2010 12:26:06 +0200
Message-ID: <1272018366.7895.7930.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:59830 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163Ab0DWK0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 06:26:19 -0400
Received: by bwz19 with SMTP id 19so13078bwz.1
        for <netdev@vger.kernel.org>; Fri, 23 Apr 2010 03:26:17 -0700 (PDT)
In-Reply-To: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 23 avril 2010 =C3=A0 16:12 +0800, Changli Gao a =C3=A9crit =
:
> batch skb dequeueing from softnet input_pkt_queue.
>=20
> batch skb dequeueing from softnet input_pkt_queue to reduce potential=
 lock
> contention when RPS is enabled.
>=20
> Note: in the worst case, the number of packets in a softnet_data may =
be double
> of netdev_max_backlog.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----

Oops, reading it again, I found process_backlog() was still taking the
lock twice, if only one packet is waiting in input_pkt_queue.

Possible fix, on top of your patch :

diff --git a/net/core/dev.c b/net/core/dev.c
index 0eddd23..0569be7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3296,8 +3296,9 @@ static int process_backlog(struct napi_struct *na=
pi, int quota)
 #endif
 	napi->weight =3D weight_p;
 	local_irq_disable();
-	while (1) {
+	while (work < quota) {
 		struct sk_buff *skb;
+		unsigned int qlen;
=20
 		while ((skb =3D __skb_dequeue(&sd->process_queue))) {
 			local_irq_enable();
@@ -3308,13 +3309,15 @@ static int process_backlog(struct napi_struct *=
napi, int quota)
 		}
=20
 		rps_lock(sd);
-		input_queue_head_add(sd, skb_queue_len(&sd->input_pkt_queue));
-		skb_queue_splice_tail_init(&sd->input_pkt_queue,
-					   &sd->process_queue);
-		if (skb_queue_empty(&sd->process_queue)) {
+		qlen =3D skb_queue_len(&sd->input_pkt_queue);
+		if (qlen) {
+			input_queue_head_add(sd, qlen);
+			skb_queue_splice_tail_init(&sd->input_pkt_queue,
+						   &sd->process_queue);
+		}
+		if (qlen < quota - work) {
 			__napi_complete(napi);
-			rps_unlock(sd);
-			break;
+			quota =3D work + qlen;
 		}
 		rps_unlock(sd);
 	}


