From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: don't call strlen() on the user buffer in
 packet_bind_spkt()
Date: Tue, 28 Feb 2017 05:42:53 -0800
Message-ID: <1488289373.9415.251.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170228131759.110380-1-glider@google.com>
         <1488288789.9415.249.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alexander Potapenko <glider@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35762 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750957AbdB1Nng (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 08:43:36 -0500
In-Reply-To: <1488288789.9415.249.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-02-28 at 05:33 -0800, Eric Dumazet wrote:

> It looks a bug in this implementation of strlcpy() then.
> 

Apparently strlcpy(dest, src, size)  returns strlen(src), so we can not
use it in this context.

> sizeof(name) is 15.
> 
> If you use strncpy(X, uaddr->sa_data, 15) , then you might access
> uaddr->sa_data[14] and this would still be wrong, since sa_data has 14
> bytes only :
> 
> 
> struct sockaddr {
>   sa_family_t sa_family;
>   char        sa_data[14];
> };


Maybe then :
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2bd0d1949312c3d71c4b33529316dcfe76fa28f1..d2e7caa79d2604363316c7316864bed1f4971d29 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3103,7 +3103,7 @@ static int packet_bind_spkt(struct socket *sock, struct sockaddr *uaddr,
 			    int addr_len)
 {
 	struct sock *sk = sock->sk;
-	char name[15];
+	char name[sizeof(uaddr->sa_data) + 1];
 
 	/*
 	 *	Check legality
@@ -3111,7 +3111,8 @@ static int packet_bind_spkt(struct socket *sock, struct sockaddr *uaddr,
 
 	if (addr_len != sizeof(struct sockaddr))
 		return -EINVAL;
-	strlcpy(name, uaddr->sa_data, sizeof(name));
+	memcpy(name, uaddr->sa_data, sizeof(uaddr->sa_data));
+	name[sizeof(uaddr->sa_data)] = 0;
 
 	return packet_do_bind(sk, name, 0, pkt_sk(sk)->num);
 }
