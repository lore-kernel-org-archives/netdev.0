From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: EINVAL when using connect() for udp sockets
Date: Tue, 28 Mar 2017 17:52:36 -0700
Message-ID: <1490748756.24891.27.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAEnbY+cYpX8naDpRkXgwCP=i64AwWgK9=_7AacmYip-ykot7mQ@mail.gmail.com>
         <CAEnbY+fPLamzXF8nOF-SEFE8LaE88XAyKNt81zs6bM866R4oGg@mail.gmail.com>
         <1490246287.16816.201.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpVVBfwd7P0-dY08Bw7QNr_w77va4AEMFj5xMuOddQoq2g@mail.gmail.com>
         <1490397560.24891.0.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpUQ52aiKQntMsrm2aMQ56G=tHCpN93A0+mffss+6m39jw@mail.gmail.com>
         <1490742712.24891.25.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daurnimator <quae@daurnimator.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        William Ahern <william@25thandclement.com>,
        "Santi T." <santitm99@gmail.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33236 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932571AbdC2Awj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 20:52:39 -0400
Received: by mail-pg0-f67.google.com with SMTP id 79so350760pgf.0
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 17:52:39 -0700 (PDT)
In-Reply-To: <1490742712.24891.25.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-03-28 at 16:11 -0700, Eric Dumazet wrote:

> Yes, this looks better.
> 
> Although you probably need to change a bit later this part :
> 
> if (!inet->inet_saddr)
> 	inet->inet_saddr = fl4->saddr;  /* Update source address */
> 

I came up with the following tested patch for IPv4

diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index f915abff1350a86af8d5bb89725b751c061b0fb5..1454b6191e0d38ffae0ae260578858285bc5f77b 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -40,7 +40,7 @@ int __ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 	sk_dst_reset(sk);
 
 	oif = sk->sk_bound_dev_if;
-	saddr = inet->inet_saddr;
+	saddr = (sk->sk_userlocks & SOCK_BINDADDR_LOCK) ? inet->inet_saddr : 0;
 	if (ipv4_is_multicast(usin->sin_addr.s_addr)) {
 		if (!oif)
 			oif = inet->mc_index;
@@ -64,9 +64,8 @@ int __ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 		err = -EACCES;
 		goto out;
 	}
-	if (!inet->inet_saddr)
+	if (!(sk->sk_userlocks & SOCK_BINDADDR_LOCK)) {
 		inet->inet_saddr = fl4->saddr;	/* Update source address */
-	if (!inet->inet_rcv_saddr) {
 		inet->inet_rcv_saddr = fl4->saddr;
 		if (sk->sk_prot->rehash)
 			sk->sk_prot->rehash(sk);
