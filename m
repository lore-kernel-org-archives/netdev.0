From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] clean up tcp_sk(), 2.6.0
Date: Wed, 31 Dec 2003 11:12:07 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031231101207.GA7829@elte.hu>
References: <20031230163230.GA12553@elte.hu> <20031230144608.4c7e66f2.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031230144608.4c7e66f2.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <davem@redhat.com> wrote:

> On Tue, 30 Dec 2003 17:32:30 +0100
> Ingo Molnar <mingo@elte.hu> wrote:
> 
> > i recently wasted a few hours on a bug where i used "tcp_sk(sock)"
> > instead of "tcp_sk(sock->sk)" - the former, while being blatantly
> > incorrect, compiles just fine on 2.6.0. The patch below is equivalent to
> > the define but is also type-safe. Compiles cleanly & boots fine on
> > 2.6.0.
> 
> Applied, and I'll happily accept patches for udp_sk() and all
> the other ones too :)

sure - patch for udp_sk, inet6_sk/raw6_sk and inet_sk attached. Compiles
cleanly and boots. The inet_sk one uncovered a couple of other bugs in
my code. (The other defines for protocol-private sockets seem to be safe
because they all use ->sk_protinfo which forces the type.)

	Ingo

--- linux/include/linux/udp.h.orig
+++ linux/include/linux/udp.h
@@ -60,7 +60,10 @@ struct udp_sock {
 	struct udp_opt	  udp;
 };
 
-#define udp_sk(__sk) (&((struct udp_sock *)__sk)->udp)
+static inline struct udp_opt * udp_sk(const struct sock *__sk)
+{
+	return &((struct udp_sock *)__sk)->udp;
+}
 
 #endif
 
--- linux/include/linux/ipv6.h.orig
+++ linux/include/linux/ipv6.h
@@ -270,8 +270,15 @@ struct tcp6_sock {
 	struct ipv6_pinfo inet6;
 };
 
-#define inet6_sk(__sk) ((struct raw6_sock *)__sk)->pinet6
-#define raw6_sk(__sk) (&((struct raw6_sock *)__sk)->raw6)
+static inline struct ipv6_pinfo * inet6_sk(const struct sock *__sk)
+{
+	return ((struct raw6_sock *)__sk)->pinet6;
+}
+
+static inline struct raw6_opt * raw6_sk(const struct sock *__sk)
+{
+	return &((struct raw6_sock *)__sk)->raw6;
+}
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 #define __ipv6_only_sock(sk)	(inet6_sk(sk)->ipv6only)
--- linux/include/linux/ip.h.orig
+++ linux/include/linux/ip.h
@@ -159,7 +159,10 @@ struct inet_sock {
 	struct inet_opt   inet;
 };
 
-#define inet_sk(__sk) (&((struct inet_sock *)__sk)->inet)
+static inline struct inet_opt * inet_sk(const struct sock *__sk)
+{
+	return &((struct inet_sock *)__sk)->inet;
+}
 
 #endif
 
