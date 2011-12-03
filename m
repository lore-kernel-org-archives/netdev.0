From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SYN attack, with FIN flag set
Date: Sat, 03 Dec 2011 10:41:42 +0100
Message-ID: <1322905302.2762.106.camel@edumazet-laptop>
References: <1755dc626dee301261ef4fe4cd66fd47@visp.net.lb>
	 <1322897233.2762.79.camel@edumazet-laptop>
	 <1322898902.2762.81.camel@edumazet-laptop>
	 <b3ae04aef6b0ce233e8e8978782d1ccc@visp.net.lb>
	 <1322902401.2762.85.camel@edumazet-laptop>
	 <4ED9E5FA.30204@msgid.tls.msk.ru>
	 <73da1a18b48dc3097acd6728be208c66@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Tokarev <mjt@tls.msk.ru>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:44437 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728Ab1LCJlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2011 04:41:47 -0500
Received: by bkbzv3 with SMTP id zv3so70516bkb.19
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2011 01:41:46 -0800 (PST)
In-Reply-To: <73da1a18b48dc3097acd6728be208c66@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 03 d=C3=A9cembre 2011 =C3=A0 11:07 +0200, Denys Fedoryshchenk=
o a =C3=A9crit :
>  No,no, as i understand it is just threating SYN+FIN as plain SYN.
>  I think if it incurr additional expenses (verification), no need may=
be=20
>  to fix it, it is job of iptables.
>  But is FIN to listening socket - legitimate? Shouldn't it be dropped=
?
>=20


Host network stack is optimized for the fast path (legitimate traffic)

=46irewalls are optimized to the opposite, to let protected machines do=
ing
their jobs without slow checks.

If we add all possible counter measures in tcp stack, it would be maybe
2 times slower than it is...

Remember than SYN|FIN messages are maybe 0.000001% of total Internet
trafic, since they are not legitimate.

In the case of SYN packet, flow is :

1) IP stack : ip_rcv(), ip_route_input_noref(), ip_rcv_finish()

2) TCP stack :=20
	tcp_v4_rcv(),
	__inet_lookup_skb() [ find the listener socket ]
	bh_lock_sock_nested(sk) [ lock the socket ]
	tcp_v4_do_rcv()
	tcp_v4_hnd_req()
	inet_csk_search_req() [ try to find a previous SYN_RECV sock]
	tcp_rcv_state_process()
		tcp_v4_conn_request(sk, skb)

So it appears we go too far, we should drop FIN messages at this point.

What about following patch then ?

The added test is hit only for SYN messages, this seems not a very
expensive test.


[PATCH] tcp: drop SYN+FIN messages

Denys Fedoryshchenko reported that SYN+FIN attacks were bringing his
linux machines to their limits.

Dont call conn_request() if the TCP flags includes SYN flag

Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp_input.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 52b5c2d..d54c942 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5809,6 +5809,8 @@ int tcp_rcv_state_process(struct sock *sk, struct=
 sk_buff *skb,
 			goto discard;
=20
 		if (th->syn) {
+			if (th->fin)
+				goto discard;
 			if (icsk->icsk_af_ops->conn_request(sk, skb) < 0)
 				return 1;
=20
