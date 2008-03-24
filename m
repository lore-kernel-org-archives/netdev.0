From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [AX25] kernel panic
Date: Mon, 24 Mar 2008 21:51:05 +0100
Message-ID: <20080324205104.GA3721@ami.dom.local>
References: <47DF9D21.20807@free.fr> <20080318212531.GA2031@electric-eye.fr.zoreil.com> <47E0C261.3000106@free.fr> <47E17E2E.9050105@free.fr> <20080320073021.GA4037@ff.dom.local> <47E2EC1B.9070405@free.fr> <20080322113620.GA3213@ami.dom.local> <47E68CA1.2040904@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@o2.pl>
To: Bernard Pidoux <bpidoux@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:36798 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543AbYCXUq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 16:46:56 -0400
Received: by fg-out-1718.google.com with SMTP id l27so3115916fgb.17
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2008 13:46:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <47E68CA1.2040904@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 23, 2008 at 06:00:17PM +0100, Bernard Pidoux wrote:
...
> Here is the result of your patch :
>
>
> WARNING: at net/core/sock.c:1522 sock_def_write_space()
> Pid: 3452, comm: mkiss Not tainted 2.6.24.3 #2
...

Thanks. Here is one more (to apply after the previous one).

Happy Holidays...
Jarek P.

---

diff -Nurp 2.6.24.3-with1/include/net/sock.h 2.6.24.3-with2/include/net/sock.h
--- 2.6.24.3-with1/include/net/sock.h	2008-01-24 23:58:37.000000000 +0100
+++ 2.6.24.3-with2/include/net/sock.h	2008-03-24 21:14:43.000000000 +0100
@@ -263,6 +263,7 @@ struct sock {
   	int			(*sk_backlog_rcv)(struct sock *sk,
 						  struct sk_buff *skb);  
 	void                    (*sk_destruct)(struct sock *sk);
+	int			sk_ax25_debug;
 };
 
 /*
diff -Nurp 2.6.24.3-with1/net/ax25/af_ax25.c 2.6.24.3-with2/net/ax25/af_ax25.c
--- 2.6.24.3-with1/net/ax25/af_ax25.c	2008-01-24 23:58:37.000000000 +0100
+++ 2.6.24.3-with2/net/ax25/af_ax25.c	2008-03-23 00:53:51.000000000 +0100
@@ -936,6 +936,7 @@ struct sock *ax25_make_new(struct sock *
 	}
 
 	sk->sk_protinfo = ax25;
+	sk->sk_ax25_debug = 1;
 	ax25->sk    = sk;
 
 	return sk;
diff -Nurp 2.6.24.3-with1/net/core/sock.c 2.6.24.3-with2/net/core/sock.c
--- 2.6.24.3-with1/net/core/sock.c	2008-03-22 12:10:10.000000000 +0100
+++ 2.6.24.3-with2/net/core/sock.c	2008-03-24 21:43:46.000000000 +0100
@@ -1519,6 +1519,9 @@ static void sock_def_write_space(struct 
 	if ((atomic_read(&sk->sk_wmem_alloc) << 1) <= sk->sk_sndbuf) {
 		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep)) {
 			if (!sk->sk_socket || sk->sk_socket->sk != sk) {
+				if (net_ratelimit())
+					printk(KERN_INFO "sk_ax25_debug = %d, %p\n",
+						 sk->sk_ax25_debug, sk->sk_socket);
 				WARN_ON_ONCE(1);
 				sk->sk_socket = NULL;
 				sk->sk_sleep = NULL;
