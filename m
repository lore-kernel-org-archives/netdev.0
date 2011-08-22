From: Li Yu <raise.sail@gmail.com>
Subject: [PATCH] fix pushed_seq in keepalive / zero window probe timer
Date: Mon, 22 Aug 2011 14:57:21 +0800
Message-ID: <4E51FDD1.2010607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	davem@davemloft.net, ilpo.jarvinen@helsinki.fi
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:64381 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806Ab1HVG5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 02:57:35 -0400
Received: by pzk37 with SMTP id 37so8193213pzk.1
        for <netdev@vger.kernel.org>; Sun, 21 Aug 2011 23:57:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In tcp_write_wakeup(), we may split the probe segment since send window=
 or mss is larger than it.
so I think that we should update tp->pushed_seq after tcp_fragment(), i=
s it right? thanks.

Signed-off-by: Li Yu <raise.sail@gmail.com>
CC: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
CC: David S. Miller <davem@davemloft.net>
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 882e0b0..659a71f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2784,9 +2784,6 @@ int tcp_write_wakeup(struct sock *sk)
 		unsigned int mss =3D tcp_current_mss(sk);
 		unsigned int seg_size =3D tcp_wnd_end(tp) - TCP_SKB_CB(skb)->seq;
=20
-		if (before(tp->pushed_seq, TCP_SKB_CB(skb)->end_seq))
-			tp->pushed_seq =3D TCP_SKB_CB(skb)->end_seq;
-
 		/* We are probing the opening of a window
 		 * but the window size is !=3D 0
 		 * must have been a result SWS avoidance ( sender )
@@ -2803,8 +2800,11 @@ int tcp_write_wakeup(struct sock *sk)
 		TCP_SKB_CB(skb)->flags |=3D TCPHDR_PSH;
 		TCP_SKB_CB(skb)->when =3D tcp_time_stamp;
 		err =3D tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
-		if (!err)
+		if (!err) {
 			tcp_event_new_data_sent(sk, skb);
+			if (before(tp->pushed_seq, TCP_SKB_CB(skb)->end_seq))
+				tp->pushed_seq =3D TCP_SKB_CB(skb)->end_seq;
+		}
 		return err;
 	} else {
 		if (between(tp->snd_up, tp->snd_una + 1, tp->snd_una + 0xFFFF))

