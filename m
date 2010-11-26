From: Nagendra Tomar <tomer_iisc@yahoo.com>
Subject: [PATCH] net: Fix __inet_inherit_port() to correctly increment bsockets and num_owners
Date: Thu, 25 Nov 2010 21:09:51 -0800 (PST)
Message-ID: <801098.19711.qm@web53707.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web53707.mail.re2.yahoo.com ([206.190.37.28]:30285 "HELO
	web53707.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750803Ab0KZFQd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Nov 2010 00:16:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


inet sockets corresponding to passive connections are added to the bind hash
using ___inet_inherit_port(). These sockets are later removed from the bind 
hash using __inet_put_port(). These two functions are not exactly symmetrical. 
__inet_put_port() decrements hashinfo->bsockets and tb->num_owners, whereas 
___inet_inherit_port() does not increment them. This results in both of these 
going to -ve values.

This patch fixes this by calling inet_bind_hash() from ___inet_inherit_port(),
which does the right thing.

Signed-off-by: Nagendra Singh Tomar <tomer_iisc@yahoo.com>

---
--- linux-2.6.36.1/net/ipv4/inet_hashtables.c.orig	2010-11-25 14:56:37.902456597 -0500
+++ linux-2.6.36.1/net/ipv4/inet_hashtables.c	2010-11-25 15:44:15.038403317 -0500
@@ -107,12 +107,10 @@ void __inet_inherit_port(struct sock *sk
 	const int bhash = inet_bhashfn(sock_net(sk), inet_sk(child)->inet_num,
 			table->bhash_size);
 	struct inet_bind_hashbucket *head = &table->bhash[bhash];
-	struct inet_bind_bucket *tb;
 
 	spin_lock(&head->lock);
-	tb = inet_csk(sk)->icsk_bind_hash;
-	sk_add_bind_node(child, &tb->owners);
-	inet_csk(child)->icsk_bind_hash = tb;
+	inet_bind_hash(child, inet_csk(sk)->icsk_bind_hash, 
+			inet_sk(child)->inet_num);
 	spin_unlock(&head->lock);
 }
 EXPORT_SYMBOL_GPL(__inet_inherit_port);
---



      
