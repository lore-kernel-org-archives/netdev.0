From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] fixing the cases where tcp_tw_bucket was accessed as a sock
Date: Wed, 15 Oct 2003 08:36:48 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031015113648.GD1174@conectiva.com.br>
References: <20031012131344.GH16182@conectiva.com.br> <20031013124930.0e75a325.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031013124930.0e75a325.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Mon, Oct 13, 2003 at 12:49:30PM -0700, David S. Miller escreveu:
> On Sun, 12 Oct 2003 10:13:44 -0300
> Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:
> 
> > 	The WARN_ON is just to be paranoid for a while, I should have done
> > that a loooong time ago :-\
> 
> I appreciate the intentions here but the resulting code is
> really a mess.  We have this thing now in in.h called
> "inet_something()" that tests TCP state, and then we have
> something similar for ipv6 in addrconf.c  :-)
> 
> Let's do one thing at a time.  First, fix the original bug
> in tcp_ipv4.c by just putting your inet_rcv_saddr() shorthand
> right there in tcp_ipv4.c and name it tcp4_rcv_saddr() or
> something like that.
> 
> Then we can move onto the rest of the changes and try to find
> a common place for the helper routines.
> 
> See what happens when you try to do too many things at one
> time :-)

:) Here is the first part:


===== net/ipv4/tcp_ipv4.c 1.69 vs edited =====
--- 1.69/net/ipv4/tcp_ipv4.c	Wed Oct  8 12:27:40 2003
+++ edited/net/ipv4/tcp_ipv4.c	Wed Oct 15 09:26:29 2003
@@ -178,9 +178,15 @@
 	tcp_sk(sk)->bind_hash = tb;
 }
 
+static inline const u32 tcp_v4_rcv_saddr(const struct sock *sk)
+{
+	return likely(sk->sk_state != TCP_TIME_WAIT) ?
+		inet_sk(sk)->rcv_saddr : tcptw_sk(sk)->tw_rcv_saddr;
+}
+
 static inline int tcp_bind_conflict(struct sock *sk, struct tcp_bind_bucket *tb)
 {
-	struct inet_opt *inet = inet_sk(sk);
+	const u32 sk_rcv_saddr = tcp_v4_rcv_saddr(sk);
 	struct sock *sk2;
 	struct hlist_node *node;
 	int reuse = sk->sk_reuse;
@@ -193,9 +199,9 @@
 		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if)) {
 			if (!reuse || !sk2->sk_reuse ||
 			    sk2->sk_state == TCP_LISTEN) {
-				struct inet_opt *inet2 = inet_sk(sk2);
-				if (!inet2->rcv_saddr || !inet->rcv_saddr ||
-				    inet2->rcv_saddr == inet->rcv_saddr)
+				const u32 sk2_rcv_saddr = tcp_v4_rcv_saddr(sk2);
+				if (!sk2_rcv_saddr || !sk_rcv_saddr ||
+				    sk2_rcv_saddr == sk_rcv_saddr)
 					break;
 			}
 		}
