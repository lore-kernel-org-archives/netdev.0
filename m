From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/8] Move the get_net() from sock_copy()
Date: Wed, 31 Oct 2007 16:44:40 +0300
Message-ID: <472886C8.5010601@openvz.org>
References: <472885B1.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:40686 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755253AbXJaMmZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 08:42:25 -0400
In-Reply-To: <472885B1.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sock_copy() is supposed to just clone the socket. In a perfect
world it has to be just memcpy, but we have to handle the security
mark correctly. All the extra setup must be performed in sk_clone() 
call, so move the get_net() into more proper place.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/sock.c b/net/core/sock.c
index fdacf9c..9c2dbfa 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -864,7 +864,6 @@ static void sock_copy(struct sock *nsk, const struct sock *osk)
 #endif
 
 	memcpy(nsk, osk, osk->sk_prot->obj_size);
-	get_net(nsk->sk_net);
 #ifdef CONFIG_SECURITY_NETWORK
 	nsk->sk_security = sptr;
 	security_sk_clone(osk, nsk);
@@ -958,6 +957,7 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
 		sock_copy(newsk, sk);
 
 		/* SANITY */
+		get_net(newsk->sk_net);
 		sk_node_init(&newsk->sk_node);
 		sock_lock_init(newsk);
 		bh_lock_sock(newsk);
-- 
1.5.3.4

