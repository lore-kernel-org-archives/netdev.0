From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [2.6.34-rc1] CPU stalls when closing TCP sockets.
Date: Wed, 10 Mar 2010 06:44:00 +0900
Message-ID: <201003100644.CGG18721.JOHOFOMQVFSFtL@I-love.SAKURA.ne.jp>
References: <201003090319.o293J6WF026448@www262.sakura.ne.jp>
	<1268116647.2819.64.camel@edumazet-laptop>
	<201003090654.o296sCnh065487@www262.sakura.ne.jp>
	<1268150156.3113.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	paulmck@linux.vnet.ibm.com, shemminger@vyatta.com
To: eric.dumazet@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:62244 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752234Ab0CIVoD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Mar 2010 16:44:03 -0500
In-Reply-To: <1268150156.3113.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Eric Dumazet wrote:
> Le mardi 09 mars 2010 a 15:54 +0900, Tetsuo Handa a ecrit :
> > Eric Dumazet wrote:
> > > Nothing comes to my mind, I'll try to reproduce this here.
> > 
> > When stopped at (8), Ctrl-C doesn't work.
> > 
> > > Is 2.6.33 OK ?
> > 
> > Yes. 2.6.33 and earlier are OK.
> 
> OK thanks !
> 
> I believe commit d218d11133d888f9745802146a50255a4781d37a
> (tcp: Generalized TTL Security Mechanism) might be the bug origin.

Yes. "git bisect" reported that
d218d11133d888f9745802146a50255a4781d37a is first bad commit.
Your patch (although I needed to change like below in order to
apply on linux-2.6.34-rc1) fixes the CPU stalls.

Thank you.

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c3588b4..3f8d08f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1651,13 +1651,13 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	if (!sk)
 		goto no_tcp_socket;
 
-	if (iph->ttl < inet_sk(sk)->min_ttl)
-		goto discard_and_relse;
-
 process:
 	if (sk->sk_state == TCP_TIME_WAIT)
 		goto do_time_wait;
 
+	if (iph->ttl < inet_sk(sk)->min_ttl)
+		goto discard_and_relse;
+
 	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
 	nf_reset(skb);
