From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [AX25] kernel panic
Date: Fri, 28 Mar 2008 13:07:21 +0100
Message-ID: <20080328120721.GA11060@ami.dom.local>
References: <20080318212531.GA2031@electric-eye.fr.zoreil.com> <47E0C261.3000106@free.fr> <47E17E2E.9050105@free.fr> <20080320073021.GA4037@ff.dom.local> <47E2EC1B.9070405@free.fr> <20080322113620.GA3213@ami.dom.local> <47E68CA1.2040904@free.fr> <20080324205104.GA3721@ami.dom.local> <47E8FCE2.6000308@free.fr> <20080326183538.GA14266@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@o2.pl>
To: Bernard Pidoux <bpidoux@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.226]:26820 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155AbYC1MBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 08:01:33 -0400
Received: by wr-out-0506.google.com with SMTP id c48so132226wra.1
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 05:01:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080326183538.GA14266@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2008 at 07:35:38PM +0100, Jarek Poplawski wrote:
...
> OK, here is the next try. (Apply after all previous patches to any 2.6.24.x;
> there would be more noise, so revert it after catching some data.)

Bernard, I fucked it up with this #3: (changed macro to function at
the last minute). I'm currently reading this, and maybe I'll figure
out something, but if it's not a big problem for you to repeat this
after adding this #4 (after all previous) it should be 'a bit' easier.
(But no need to hurry.)

Very sorry,
Jarek P.

(debugging patch #4)
---

diff -Nurp 2.6.24.3-with3/include/net/sock.h 2.6.24.3-with4/include/net/sock.h
--- 2.6.24.3-with3/include/net/sock.h	2008-03-26 19:10:33.000000000 +0100
+++ 2.6.24.3-with4/include/net/sock.h	2008-03-28 12:42:19.000000000 +0100
@@ -1414,20 +1414,18 @@ extern int sysctl_optmem_max;
 extern __u32 sysctl_wmem_default;
 extern __u32 sysctl_rmem_default;
 
-static inline int sock_debug_ax25(struct sk_buff *skb, struct sock *ax25_sk)
-{
-	struct sock *sk = skb->sk;
-
-	if (sk && sk->sk_socket && sk->sk_socket->sk != sk) {
-		if (net_ratelimit())
-			printk(KERN_INFO "AX25: %s, %d, %p, %p, %p, %p, %p\n",
-				__FUNCTION__, __LINE__, sk, sk->sk_socket,
-				sk->sk_socket->sk, ax25_sk,
-				ax25_sk == NULL ? NULL : ax25_sk->sk_socket);
-		skb->destructor = NULL;
-		return 1;
-	}
-	return 0;
-}
+#define sock_debug_ax25(__skb, __ax25_sk) 					\
+({										\
+	struct sock *__sk = __skb->sk;						\
+										\
+	if (__sk && __sk->sk_socket && __sk->sk_socket->sk != __sk) {		\
+		if (net_ratelimit())						\
+			printk(KERN_INFO "AX25: %s, %d, %p, %p, %p, %p, %p\n",	\
+				__FUNCTION__, __LINE__, __sk, __sk->sk_socket,	\
+				__sk->sk_socket->sk, __ax25_sk,			\
+				__ax25_sk == NULL ? NULL : __ax25_sk->sk_socket);	\
+		__skb->destructor = NULL;					\
+	}									\
+})
 
 #endif	/* _SOCK_H */
diff -Nurp 2.6.24.3-with3/net/ax25/af_ax25.c 2.6.24.3-with4/net/ax25/af_ax25.c
--- 2.6.24.3-with3/net/ax25/af_ax25.c	2008-03-26 18:52:54.000000000 +0100
+++ 2.6.24.3-with4/net/ax25/af_ax25.c	2008-03-28 12:50:35.000000000 +0100
@@ -866,6 +866,9 @@ static int ax25_create(struct net *net, 
 
 	ax25->sk    = sk;
 
+	if (net_ratelimit())
+		printk(KERN_INFO "AX25+ %s, %d, %p, %p\n", __FUNCTION__, __LINE__, sk, sock);
+
 	return 0;
 }
 
@@ -939,6 +942,10 @@ struct sock *ax25_make_new(struct sock *
 	sk->sk_ax25_debug = 1;
 	ax25->sk    = sk;
 
+	if (net_ratelimit())
+		printk(KERN_INFO "AX25; %s, %d, %p, %p\n",
+			 __FUNCTION__, __LINE__, sk, sk->sk_socket);
+
 	return sk;
 }
 
