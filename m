From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: When TCP keepalives tuned shorter than retransmission timeouts
Date: Tue, 26 Nov 2013 07:51:55 -0800 (PST)
Message-ID: <4b6029b3-55da-441a-9550-0fed3b49506a@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28625 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756983Ab3KZPvz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 10:51:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of our customers have tcp socket level options set to:
TCP_KEEPIDLE 60
TCP_KEEPINTVL 6=20
TCP_KEEPCNT 10

And when the peer is dead they expect the connection to timeout in 2 mi=
nutes instead of the
15 minutes from retransmission timeouts.
(We know the tunables are set very low.)

As this code in tcp_keepalive_timer() indicates we skip keepalive probe=
s if there are packets in flight
Or we have more data to send:
/* It is alive without keepalive 8) */
=A0=A0=A0=A0=A0=A0=A0 if (tp->packets_out || tcp_send_head(sk))
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto resched;

The reason I guess is why burden the network with keepalive packets whe=
n
somebody else (retransmissions) is doing it for you.

The change we tried was to not actually send the keepalive probes in th=
is situation but keep counting them as sent.=20
To not do this when the receiver window is closed we check tp->snd_wnd.=
 Maybe there are other (more correct ?) ways to do that.=20
By the way, we didn't try to address yet the similar issue when the com=
munication with peer dies
after the receiver closes the window.

This is the code change we tried.
--- tcp_timer.c.orig=A0=A0=A0 2013-11-25 07:09:18.328112851 -0800
+++ tcp_timer.c 2013-11-25 08:06:47.339666980 -0800
@@ -588,18 +588,13 @@
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 }
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 }
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 tcp_send_active_reset(sk,=
 GFP_ATOMIC);
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto death;
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 tcp_done(sk);
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto out;
=A0=A0=A0=A0=A0=A0=A0 }

=A0=A0=A0=A0=A0=A0=A0 if (!sock_flag(sk, SOCK_KEEPOPEN) || sk->sk_state=
 =3D=3D TCP_CLOSE)
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto out;

-=A0=A0=A0=A0=A0=A0 elapsed =3D keepalive_time_when(tp);
-
-=A0=A0=A0=A0=A0=A0 /* It is alive without keepalive 8) */
-=A0=A0=A0=A0=A0=A0 if (tp->packets_out || tcp_send_head(sk))
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto resched;
-
=A0=A0=A0=A0=A0=A0=A0 elapsed =3D keepalive_time_elapsed(tp);

=A0=A0=A0=A0=A0=A0=A0 if (elapsed >=3D keepalive_time_when(tp)) {
@@ -615,8 +610,9 @@
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 t=
cp_write_err(sk);
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0g=
oto out;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 }
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (tcp_write_wakeup(sk) <=3D=
 0) {
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 ics=
k->icsk_probes_out++;
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (tp->packets_out || tcp_=
send_head(sk) || (tcp_write_wakeup(sk) <=3D 0)) {
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if =
(tp->snd_wnd)
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 icsk->icsk_probes_out++;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 e=
lapsed =3D keepalive_intvl_when(tp);
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 } else {
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 /=
* If keepalive was lost due to local congestion,
@@ -631,12 +627,7 @@

=A0=A0=A0=A0=A0=A0=A0 sk_mem_reclaim(sk);

-resched:
=A0=A0=A0=A0=A0=A0=A0 inet_csk_reset_keepalive_timer (sk, elapsed);
-=A0=A0=A0=A0=A0=A0 goto out;
-
-death:
-=A0=A0=A0=A0=A0=A0 tcp_done(sk);

out:
=A0=A0=A0=A0=A0=A0=A0 bh_unlock_sock(sk);

We seek your opinion.

Thanks.

Venkat
