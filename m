From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 15507] New: kernel misses 3rd part of tcp
 handshake (ACK), stays in SYN_RECV state
Date: Fri, 19 Mar 2010 15:46:39 +0100
Message-ID: <1269009999.3048.45.camel@edumazet-laptop>
References: <bug-15507-10286@http.bugzilla.kernel.org/>
	 <20100318160103.cc28c367.akpm@linux-foundation.org>
	 <1268953951.2894.194.camel@edumazet-laptop>  <4BA365BA.4040309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Joshua Roys <roysjosh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:36946 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968Ab0CSOqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 10:46:45 -0400
Received: by bwz1 with SMTP id 1so96418bwz.21
        for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 07:46:43 -0700 (PDT)
In-Reply-To: <4BA365BA.4040309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 19 mars 2010 =C3=A0 07:53 -0400, Joshua Roys a =C3=A9crit :

>=20
> Gah!  You've got to be kidding :)  If that's what it is, close the=20
> bug...  and I'll go read some man-pages!

So I checked FC12 httpd and yes, it does use DEFER_ACCEPT (setting val
to 1 second).


So you hit a problem that was corrected by following commit.

Time to bug RedHat I suppose...



commit d1b99ba41d6c5aa1ed2fc634323449dd656899e9
Author: Julian Anastasov <ja@ssi.bg>
Date:   Mon Oct 19 10:01:56 2009 +0000

    tcp: accept socket after TCP_DEFER_ACCEPT period
   =20
    Willy Tarreau and many other folks in recent years
    were concerned what happens when the TCP_DEFER_ACCEPT period
    expires for clients which sent ACK packet. They prefer clients
    that actively resend ACK on our SYN-ACK retransmissions to be
    converted from open requests to sockets and queued to the
    listener for accepting after the deferring period is finished.
    Then application server can decide to wait longer for data
    or to properly terminate the connection with FIN if read()
    returns EAGAIN which is an indication for accepting after
    the deferring period. This change still can have side effects
    for applications that expect always to see data on the accepted
    socket. Others can be prepared to work in both modes (with or
    without TCP_DEFER_ACCEPT period) and their data processing can
    ignore the read=3DEAGAIN notification and to allocate resources for
    clients which proved to have no data to send during the deferring
    period. OTOH, servers that use TCP_DEFER_ACCEPT=3D1 as flag (not
    as a timeout) to wait for data will notice clients that didn't
    send data for 3 seconds but that still resend ACKs.
    Thanks to Willy Tarreau for the initial idea and to
    Eric Dumazet for the review and testing the change.
   =20
    Signed-off-by: Julian Anastasov <ja@ssi.bg>
    Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 624c3c9..4c03598 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -641,8 +641,8 @@ struct sock *tcp_check_req(struct sock *sk, struct =
sk_buff *skb,
        if (!(flg & TCP_FLAG_ACK))
                return NULL;
=20
-       /* If TCP_DEFER_ACCEPT is set, drop bare ACK. */
-       if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
+       /* While TCP_DEFER_ACCEPT is active, drop bare ACK. */
+       if (req->retrans < inet_csk(sk)->icsk_accept_queue.rskq_defer_a=
ccept &&
            TCP_SKB_CB(skb)->end_seq =3D=3D tcp_rsk(req)->rcv_isn + 1) =
{
                inet_rsk(req)->acked =3D 1;
                return NULL;



