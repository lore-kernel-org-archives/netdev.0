From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [TCP] Show all SYN_RECV sockets in /proc/net/tcp
Date: Wed, 6 Oct 2004 12:06:50 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041006020650.GA14583@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="OgqxwSJOaUobr8KG"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

I was fixing the tcp_diag so that it shows SYN_RECV sockets properly.
I found that /proc/net/tcp didn't do it correctly either.  So here is
a small patch to fix /proc/net/tcp.

The logic in there stinks though so I'd love to see a rewrite.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/tcp_ipv4.c 1.99 vs edited =====
--- 1.99/net/ipv4/tcp_ipv4.c	2004-09-15 06:57:07 +10:00
+++ edited/net/ipv4/tcp_ipv4.c	2004-10-06 11:25:04 +10:00
@@ -2175,8 +2175,14 @@
 		sk	  = sk_next(st->syn_wait_sk);
 		st->state = TCP_SEQ_STATE_LISTENING;
 		read_unlock_bh(&tp->syn_wait_lock);
-	} else
+	} else {
+	       	tp = tcp_sk(sk);
+		read_lock_bh(&tp->syn_wait_lock);
+		if (tp->listen_opt && tp->listen_opt->qlen)
+			goto start_req;
+		read_unlock_bh(&tp->syn_wait_lock);
 		sk = sk_next(sk);
+	}
 get_sk:
 	sk_for_each_from(sk, node) {
 		if (sk->sk_family == st->family) {
@@ -2186,6 +2192,7 @@
 	       	tp = tcp_sk(sk);
 		read_lock_bh(&tp->syn_wait_lock);
 		if (tp->listen_opt && tp->listen_opt->qlen) {
+start_req:
 			st->uid		= sock_i_uid(sk);
 			st->syn_wait_sk = sk;
 			st->state	= TCP_SEQ_STATE_OPENREQ;

--OgqxwSJOaUobr8KG--
