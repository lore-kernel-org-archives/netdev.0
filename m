From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [TCP] Fixed bug that hid sockets in tcp_diag
Date: Wed, 6 Oct 2004 13:58:01 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041006035801.GA15940@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="r5Pyd7+fXNt84Ff3"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        Arnaldo Carvalho de Melo <acme@conectiva.com.br>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This patch squashes a bug in tcp_diag which was created when the
sk_* loops replaced the original for loops.  It's a pity that these
sk_*/hlist_*/list_* loops don't take an arbitrary expression as an
argument for continue.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/tcp_diag.c 1.18 vs edited =====
--- 1.18/net/ipv4/tcp_diag.c	2004-10-04 07:26:12 +10:00
+++ edited/net/ipv4/tcp_diag.c	2004-10-06 13:43:17 +10:00
@@ -495,21 +495,22 @@
 			sk_for_each(sk, node, &tcp_listening_hash[i]) {
 				struct inet_opt *inet = inet_sk(sk);
 				if (num < s_num)
-					continue;
+					goto next_listen;
 				if (!(r->tcpdiag_states&TCPF_LISTEN) ||
 				    r->id.tcpdiag_dport)
-					continue;
+					goto next_listen;
 				if (r->id.tcpdiag_sport != inet->sport &&
 				    r->id.tcpdiag_sport)
-					continue;
+					goto next_listen;
 				if (bc && !tcpdiag_bc_run(RTA_DATA(bc), RTA_PAYLOAD(bc), sk))
-					continue;
+					goto next_listen;
 				if (tcpdiag_fill(skb, sk, r->tcpdiag_ext,
 						 NETLINK_CB(cb->skb).pid,
 						 cb->nlh->nlmsg_seq) <= 0) {
 					tcp_listen_unlock();
 					goto done;
 				}
+next_listen:
 				++num;
 			}
 		}
@@ -537,22 +538,23 @@
 			struct inet_opt *inet = inet_sk(sk);
 
 			if (num < s_num)
-				continue;
+				goto next_normal;
 			if (!(r->tcpdiag_states & (1 << sk->sk_state)))
-				continue;
+				goto next_normal;
 			if (r->id.tcpdiag_sport != inet->sport &&
 			    r->id.tcpdiag_sport)
-				continue;
+				goto next_normal;
 			if (r->id.tcpdiag_dport != inet->dport && r->id.tcpdiag_dport)
-				continue;
+				goto next_normal;
 			if (bc && !tcpdiag_bc_run(RTA_DATA(bc), RTA_PAYLOAD(bc), sk))
-				continue;
+				goto next_normal;
 			if (tcpdiag_fill(skb, sk, r->tcpdiag_ext,
 					 NETLINK_CB(cb->skb).pid,
 					 cb->nlh->nlmsg_seq) <= 0) {
 				read_unlock_bh(&head->lock);
 				goto done;
 			}
+next_normal:
 			++num;
 		}
 
@@ -562,21 +564,22 @@
 				struct inet_opt *inet = inet_sk(sk);
 
 				if (num < s_num)
-					continue;
+					goto next_dying;
 				if (r->id.tcpdiag_sport != inet->sport &&
 				    r->id.tcpdiag_sport)
-					continue;
+					goto next_dying;
 				if (r->id.tcpdiag_dport != inet->dport &&
 				    r->id.tcpdiag_dport)
-					continue;
+					goto next_dying;
 				if (bc && !tcpdiag_bc_run(RTA_DATA(bc), RTA_PAYLOAD(bc), sk))
-					continue;
+					goto next_dying;
 				if (tcpdiag_fill(skb, sk, r->tcpdiag_ext,
 						 NETLINK_CB(cb->skb).pid,
 						 cb->nlh->nlmsg_seq) <= 0) {
 					read_unlock_bh(&head->lock);
 					goto done;
 				}
+next_dying:
 				++num;
 			}
 		}

--r5Pyd7+fXNt84Ff3--
