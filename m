From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: inet_diag: always export IPV6_V6ONLY sockopt
Date: Thu, 09 Jul 2015 19:30:30 +0200
Message-ID: <1436463030.24939.47.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1436431347-720-1-git-send-email-phil@nwl.cc>
	 <1436446677.24939.20.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150709163829.GB1911@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33525 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918AbbGIRaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 13:30:35 -0400
Received: by wiwl6 with SMTP id l6so25260920wiw.0
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 10:30:34 -0700 (PDT)
In-Reply-To: <20150709163829.GB1911@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-07-09 at 18:38 +0200, Phil Sutter wrote:
> Is it possible to select that in a generic way? If I didn't misread the
> code, 'ss -l' filters them out locally. It looks like sk->sk_state can
> be used to determine that, but it seems to be used for TCP states only?
> Or is the value 10 (TCP_LISTEN) used for e.g. UDP as well?

You could specifically filter TCP_LISTEN | TCP_CLOSE

Like in :

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 9bc26677058e..c3b1f3a0f4cf 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -152,8 +152,8 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 				       inet6_sk(sk)->tclass) < 0)
 				goto errout;
 
-		if (ipv6_only_sock(sk) &&
-		    nla_put_u8(skb, INET_DIAG_SKV6ONLY, 1))
+		if (((1 << sk->sk_state) & (TCPF_LISTEN | TCPF_CLOSE)) &&
+		    nla_put_u8(skb, INET_DIAG_SKV6ONLY, ipv6_only_sock(sk)))
 			goto errout;
 	}
 #endif
