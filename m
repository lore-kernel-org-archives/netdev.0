From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] rfs: Receive Flow Steering
Date: Fri, 02 Apr 2010 18:28:55 +0200
Message-ID: <1270225735.11099.20.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004012045560.4252@pokey.mtv.corp.google.com>
	 <1270197304.1936.179.camel@edumazet-laptop>
	 <1270211871.11099.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f217.google.com ([209.85.218.217]:52485 "EHLO
	mail-bw0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168Ab0DBQ3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 12:29:00 -0400
Received: by bwz9 with SMTP id 9so1719325bwz.29
        for <netdev@vger.kernel.org>; Fri, 02 Apr 2010 09:28:59 -0700 (PDT)
In-Reply-To: <1270211871.11099.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some more thoughts ...

Do we really want to call inet_rps_record_flow(sk) from inet_sendmsg() &
inet_sendpage() ?

This seems not necessary to me...


This bit :

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f4df5f9..3060c17 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1674,6 +1674,10 @@ process:
 
 	skb->dev = NULL;
 
+#ifdef CONFIG_RPS
+	inet_sk(sk)->rxhash = skb->rxhash;
+#endif
+
 	bh_lock_sock_nested(sk);
 	ret = 0;
 	if (!sock_owned_by_user(sk)) {



1) It's not pretty, could you define a helper ?

2) Why should we set inet_sk(sk)->rxhash at each packet ?

rxhash is a constant given the (src,dst,sport,dport) tuple and could be
set at connection time. This way we could set inet_sk(sk)->rxhash both
for TCP and UDP.

(Currently, you dont set inet_sk(sk)->rxhash on UDP)



