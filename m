From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: Fw: Nasty Oops in 2.6.0-test6 bind/SO_REUSEADDR
Date: Thu, 9 Oct 2003 23:36:44 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031010023644.GA8365@conectiva.com.br>
References: <20031008133345.49f71991.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Dan Merillat <dmerillat@sequiam.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031008133345.49f71991.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Wed, Oct 08, 2003 at 01:33:45PM -0700, David S. Miller escreveu:
> Arnaldo, I think this is another piece of fallout
> from the struct sock splitup you did ages ago.
> 
> I think it's dereferencing inet_sk(sk) for a time-wait
> socket, so we probably need a TCP_TIME_WAIT test plus
> some additional logic here?  Better check tcp_ipv6.c too.

Dan, could you please try with this patch?

- Arnaldo


===== net/ipv4/tcp_ipv4.c 1.69 vs edited =====
--- 1.69/net/ipv4/tcp_ipv4.c	Wed Oct  8 12:27:40 2003
+++ edited/net/ipv4/tcp_ipv4.c	Thu Oct  9 23:23:38 2003
@@ -186,7 +186,8 @@
 	int reuse = sk->sk_reuse;
 
 	sk_for_each_bound(sk2, node, &tb->owners) {
-		if (sk != sk2 &&
+		if (likely(sk->sk_state != TCP_TIME_WAIT) &&
+		    sk != sk2 &&
 		    !ipv6_only_sock(sk2) &&
 		    (!sk->sk_bound_dev_if ||
 		     !sk2->sk_bound_dev_if ||
===== net/ipv6/tcp_ipv6.c 1.74 vs edited =====
--- 1.74/net/ipv6/tcp_ipv6.c	Wed Oct  8 12:27:40 2003
+++ edited/net/ipv6/tcp_ipv6.c	Thu Oct  9 23:23:45 2003
@@ -101,7 +101,8 @@
 
 	/* We must walk the whole port owner list in this case. -DaveM */
 	sk_for_each_bound(sk2, node, &tb->owners) {
-		if (sk != sk2 &&
+		if (likely(sk->sk_state != TCP_TIME_WAIT) &&
+		    sk != sk2 &&
 		    (!sk->sk_bound_dev_if ||
 		     !sk2->sk_bound_dev_if ||
 		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if) &&
