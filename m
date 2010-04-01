From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Undefined behaviour of connect(fd, NULL, 0);
Date: Thu, 1 Apr 2010 11:00:23 +0800
Message-ID: <n2w412e6f7f1003312000o3a69802j120acd3946458517@mail.gmail.com>
References: <20100331223637.31f5f6ed@notabene.brown> <20100331114936.3549ca90@s6510>
	<20100401072412.032aa8e6@notabene.brown> <20100331.141732.225997212.davem@davemloft.net>
	<20100401090756.69bfb57d@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:61702 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755798Ab0DADAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 23:00:44 -0400
Received: by gwaa18 with SMTP id a18so566910gwa.19
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 20:00:43 -0700 (PDT)
In-Reply-To: <20100401090756.69bfb57d@notabene.brown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think the following patch is what Neil wants. The old code implies that
connect(fd, NULL, 0) is used to check the socket connecting status, but
Stephen's patch breaks it. The old code is wrong when it checks the address's
faimly but not check the sizeof of the address to determine the family member
is valid or not before.

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index be1a6ac..3ff51f0 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -576,7 +576,8 @@ int inet_stream_connect(struct socket *sock,
struct sockaddr *uaddr,

 	lock_sock(sk);

-	if (uaddr->sa_family == AF_UNSPEC) {
+	if (addr_len >= sizeof(uaddr->sa_family) &&
+	    uaddr->sa_family == AF_UNSPEC) {
 		err = sk->sk_prot->disconnect(sk, flags);
 		sock->state = err ? SS_DISCONNECTING : SS_UNCONNECTED;
 		goto out;
