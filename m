From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: linux kernel 2.6.18-20 bug: rcu_read_unlock in __sock_create
Date: Wed, 15 Aug 2007 16:33:35 +0800
Message-ID: <E1ILEJr-0005Fl-00@gondolin.me.apana.org.au>
References: <af57f1ac0708141130v729fa636k3150673809ec20a8@mail.gmail.com>
Cc: linux-kernel@vger.kernel.org
To: 123.oleg@gmail.com (oleg 123), davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3277 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754727AbXHOIdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 04:33:42 -0400
In-Reply-To: <af57f1ac0708141130v729fa636k3150673809ec20a8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

oleg 123 <123.oleg@gmail.com> wrote:
>
> There is a bug in __sock_create() function (net/socket.c).
> If an error occur in LSM hook security_socket_post_create, then unneeded
> rcu_read_unlock() is made in __sock_create.

Well spotted! Please cc netdev@vger.kernel.org for networking
issues.

[NET]: Fix unbalanced rcu_read_unlock in __sock_create

The recent RCU work created an unbalanced rcu_read_unlock
in __sock_create.  This patch fixes that.  Reported by
oleg 123.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/socket.c b/net/socket.c
index ec07703..7d44453 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1168,7 +1168,7 @@ static int __sock_create(int family, int type, int protocol,
 	module_put(pf->owner);
 	err = security_socket_post_create(sock, family, type, protocol, kern);
 	if (err)
-		goto out_release;
+		goto out_sock_release;
 	*res = sock;
 
 	return 0;
