From: "David S. Miller" <davem@redhat.com>
Subject: Re: oops in tcp_v4_rcv.
Date: Wed, 28 May 2003 18:51:42 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030528.185142.85410989.davem@redhat.com>
References: <3ED55F4D.1070306@colorfullife.com>
	<20030528.184054.78710412.davem@redhat.com>
	<20030529015020.GS12434@conectiva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, netdev@oss.sgi.com, akpm@digeo.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br
In-Reply-To: <20030529015020.GS12434@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
   Date: Wed, 28 May 2003 22:50:20 -0300

   Em Wed, May 28, 2003 at 06:40:54PM -0700, David S. Miller escreveu:
   > I'll try to fix this.
   
   I'm as well looking at this, longstanding bug :-\

Here's a patch, should work:

--- include/net/tcp.h.~1~	Wed May 28 18:42:52 2003
+++ include/net/tcp.h	Wed May 28 18:49:47 2003
@@ -208,6 +208,8 @@
 #endif
 };
 
+#define tcptw_sk(__sk)	((struct tcp_tw_bucket *)(__sk))
+
 extern kmem_cache_t *tcp_timewait_cachep;
 
 static inline void tcp_tw_put(struct tcp_tw_bucket *tw)
@@ -246,7 +248,11 @@
 #endif /* __BIG_ENDIAN */
 #define TCP_IPV4_MATCH(__sk, __cookie, __saddr, __daddr, __ports, __dif)\
 	(((*((__u64 *)&(inet_sk(__sk)->daddr)))== (__cookie))	&&	\
-	 ((*((__u32 *)&(inet_sk(__sk)->dport)))== (__ports))   &&	\
+	 ((*((__u32 *)&(inet_sk(__sk)->dport)))== (__ports))	&&	\
+	 (!((__sk)->bound_dev_if) || ((__sk)->bound_dev_if == (__dif))))
+#define TCP_IPV4_TW_MATCH(__sk, __cookie, __saddr, __daddr, __ports, __dif)\
+	(((*((__u64 *)&(tcptw_sk(__sk)->daddr)))== (__cookie))	&&	\
+	 ((*((__u32 *)&(tcptw_sk(__sk)->dport)))== (__ports))	&&	\
 	 (!((__sk)->bound_dev_if) || ((__sk)->bound_dev_if == (__dif))))
 #else /* 32-bit arch */
 #define TCP_V4_ADDR_COOKIE(__name, __saddr, __daddr)
@@ -254,6 +260,11 @@
 	((inet_sk(__sk)->daddr			== (__saddr))	&&	\
 	 (inet_sk(__sk)->rcv_saddr		== (__daddr))	&&	\
 	 ((*((__u32 *)&(inet_sk(__sk)->dport)))== (__ports))	&&	\
+	 (!((__sk)->bound_dev_if) || ((__sk)->bound_dev_if == (__dif))))
+#define TCP_IPV4_TW_MATCH(__sk, __cookie, __saddr, __daddr, __ports, __dif)\
+	((tcptw_sk(__sk)->daddr			== (__saddr))	&&	\
+	 (tcptw_sk(__sk)->rcv_saddr		== (__daddr))	&&	\
+	 ((*((__u32 *)&(tcptw_sk(__sk)->dport)))== (__ports))	&&	\
 	 (!((__sk)->bound_dev_if) || ((__sk)->bound_dev_if == (__dif))))
 #endif /* 64-bit arch */
 
--- net/ipv4/tcp_ipv4.c.~1~	Wed May 28 18:44:59 2003
+++ net/ipv4/tcp_ipv4.c	Wed May 28 18:45:18 2003
@@ -509,7 +509,7 @@
 
 	/* Must check for a TIME_WAIT'er before going to listener hash. */
 	for (sk = (head + tcp_ehash_size)->chain; sk; sk = sk->next)
-		if (TCP_IPV4_MATCH(sk, acookie, saddr, daddr, ports, dif))
+		if (TCP_IPV4_TW_MATCH(sk, acookie, saddr, daddr, ports, dif))
 			goto hit;
 out:
 	read_unlock(&head->lock);
@@ -570,7 +570,7 @@
 	     skp = &sk2->next) {
 		tw = (struct tcp_tw_bucket *)sk2;
 
-		if (TCP_IPV4_MATCH(sk2, acookie, saddr, daddr, ports, dif)) {
+		if (TCP_IPV4_TW_MATCH(sk2, acookie, saddr, daddr, ports, dif)) {
 			struct tcp_opt *tp = tcp_sk(sk);
 
 			/* With PAWS, it is safe from the viewpoint
