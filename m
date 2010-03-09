From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [2.6.34-rc1] CPU stalls when closing TCP sockets.
Date: Tue, 09 Mar 2010 16:55:56 +0100
Message-ID: <1268150156.3113.12.camel@edumazet-laptop>
References: <201003090319.o293J6WF026448@www262.sakura.ne.jp>
	 <1268116647.2819.64.camel@edumazet-laptop>
	 <201003090654.o296sCnh065487@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	paulmck@linux.vnet.ibm.com,
	Stephen Hemminger <shemminger@vyatta.com>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:51519 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753Ab0CIP4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 10:56:05 -0500
In-Reply-To: <201003090654.o296sCnh065487@www262.sakura.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 mars 2010 =C3=A0 15:54 +0900, Tetsuo Handa a =C3=A9crit :
> Eric Dumazet wrote:
> > Nothing comes to my mind, I'll try to reproduce this here.
>=20
> When stopped at (8), Ctrl-C doesn't work.
>=20
> > Is 2.6.33 OK ?
>=20
> Yes. 2.6.33 and earlier are OK.

OK thanks !

I believe commit d218d11133d888f9745802146a50255a4781d37a
(tcp: Generalized TTL Security Mechanism) might be the bug origin.

I am testing following patch, based on latest net-2.6 tree (including
the LINUX_MIB_TCPMINTTLDROP bit)

[PATCH] tcp: Fix tcp_v4_rcv()

Commit d218d111 (tcp: Generalized TTL Security Mechanism) added a bug
for TIMEWAIT sockets. We should not test min_ttl for TW sockets.

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 8d51d39..70df409 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1651,15 +1651,15 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	if (!sk)
 		goto no_tcp_socket;
=20
+process:
+	if (sk->sk_state =3D=3D TCP_TIME_WAIT)
+		goto do_time_wait;
+
 	if (unlikely(iph->ttl < inet_sk(sk)->min_ttl)) {
 		NET_INC_STATS_BH(net, LINUX_MIB_TCPMINTTLDROP);
 		goto discard_and_relse;
 	}
=20
-process:
-	if (sk->sk_state =3D=3D TCP_TIME_WAIT)
-		goto do_time_wait;
-
 	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
 	nf_reset(skb);


