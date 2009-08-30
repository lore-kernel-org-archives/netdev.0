From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] net: Fix sock freeing before sock_init_data() with
 __sk_free()
Date: Mon, 31 Aug 2009 00:23:40 +0200
Message-ID: <20090830222340.GA17454@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:39337 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752902AbZH3WYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 18:24:01 -0400
Received: by bwz19 with SMTP id 19so2486043bwz.37
        for <netdev@vger.kernel.org>; Sun, 30 Aug 2009 15:24:02 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After recent changes sk_free() frees socks conditionally and depends
on sk_wmem_alloc beeing set e.g. in sock_init_data(). But in some
cases sk_free() is called earlier, usually after other alloc errors.
This patch fixes it by exporting and using __sk_free() directly.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 include/net/sock.h |    1 +
 net/ax25/af_ax25.c |    6 +++---
 net/core/sock.c    |    6 ++++--
 net/irda/af_irda.c |    4 ++--
 net/tipc/socket.c  |    2 +-
 5 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 950409d..e76ef65 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -935,6 +935,7 @@ extern void release_sock(struct sock *sk);
 extern struct sock		*sk_alloc(struct net *net, int family,
 					  gfp_t priority,
 					  struct proto *prot);
+extern void			__sk_free(struct sock *sk);
 extern void			sk_free(struct sock *sk);
 extern void			sk_release_kernel(struct sock *sk);
 extern struct sock		*sk_clone(const struct sock *sk,
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index da0f64f..c05738c 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -851,7 +851,7 @@ static int ax25_create(struct net *net, struct socket *sock, int protocol)
 
 	ax25 = sk->sk_protinfo = ax25_create_cb();
 	if (!ax25) {
-		sk_free(sk);
+		__sk_free(sk);
 		return -ENOMEM;
 	}
 
@@ -876,7 +876,7 @@ struct sock *ax25_make_new(struct sock *osk, struct ax25_dev *ax25_dev)
 		return NULL;
 
 	if ((ax25 = ax25_create_cb()) == NULL) {
-		sk_free(sk);
+		__sk_free(sk);
 		return NULL;
 	}
 
@@ -886,7 +886,7 @@ struct sock *ax25_make_new(struct sock *osk, struct ax25_dev *ax25_dev)
 	case SOCK_SEQPACKET:
 		break;
 	default:
-		sk_free(sk);
+		__sk_free(sk);
 		ax25_cb_put(ax25);
 		return NULL;
 	}
diff --git a/net/core/sock.c b/net/core/sock.c
index bbb25be..92793be 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1031,7 +1031,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 }
 EXPORT_SYMBOL(sk_alloc);
 
-static void __sk_free(struct sock *sk)
+void __sk_free(struct sock *sk)
 {
 	struct sk_filter *filter;
 
@@ -1054,13 +1054,15 @@ static void __sk_free(struct sock *sk)
 	put_net(sock_net(sk));
 	sk_prot_free(sk->sk_prot_creator, sk);
 }
+EXPORT_SYMBOL(__sk_free);
 
 void sk_free(struct sock *sk)
 {
 	/*
 	 * We substract one from sk_wmem_alloc and can know if
 	 * some packets are still in some tx queue.
-	 * If not null, sock_wfree() will call __sk_free(sk) later
+	 * If not null, sock_wfree() will call __sk_free(sk) later.
+	 * (Before sock_init_data() etc. use __sk_free() instead.)
 	 */
 	if (atomic_dec_and_test(&sk->sk_wmem_alloc))
 		__sk_free(sk);
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 50b43c5..9ed2060 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -1118,12 +1118,12 @@ static int irda_create(struct net *net, struct socket *sock, int protocol)
 			self->max_sdu_size_rx = TTP_SAR_UNBOUND;
 			break;
 		default:
-			sk_free(sk);
+			__sk_free(sk);
 			return -ESOCKTNOSUPPORT;
 		}
 		break;
 	default:
-		sk_free(sk);
+		__sk_free(sk);
 		return -ESOCKTNOSUPPORT;
 	}
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 1848693..4c8435a 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -228,7 +228,7 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol)
 	tp_ptr = tipc_createport_raw(sk, &dispatch, &wakeupdispatch,
 				     TIPC_LOW_IMPORTANCE);
 	if (unlikely(!tp_ptr)) {
-		sk_free(sk);
+		__sk_free(sk);
 		return -ENOMEM;
 	}
 
