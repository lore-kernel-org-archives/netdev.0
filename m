From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Netlink socket leaks
Date: Sun, 3 May 2015 08:04:28 +0800
Message-ID: <20150503000428.GA16211@gondor.apana.org.au>
References: <CANaxB-weCVV0eQqRMnH59psXavrckip+Wfep2gdGLiw9rz3B5g@mail.gmail.com>
 <CANaxB-zvU0St+TkniHu9AKsW0Pd_j3BK17EfzCB+ghmDC0U22g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ying Xue <ying.xue@windriver.com>
To: Andrey Wagin <avagin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:44512 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995AbbECAEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2015 20:04:33 -0400
Content-Disposition: inline
In-Reply-To: <CANaxB-zvU0St+TkniHu9AKsW0Pd_j3BK17EfzCB+ghmDC0U22g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 02, 2015 at 02:31:09AM +0300, Andrey Wagin wrote:
>
> A socket leaks if it is released by sk_release_kernel(). The problem
> is that netlink_insert() and netlink_remove() is called when a socket
> has different values of sk->sk_net.

I think we simply need to revert
c243d7e20996254f89c28d4838b5feca735c030d.

---8<---
Subject: Revert "net: kernel socket should be released in init_net namespace"

This reverts commit c243d7e20996254f89c28d4838b5feca735c030d.

That patch is solving a non-existant problem while creating a
real problem.  Just because a socket is allocated in the init
name space doesn't mean that it gets hashed in the init name space.

When we unhash it the name space must be the same as the one
we had when we hashed it.  So this patch is completely bogus
and causes socket leaks.

Reported-by: Andrey Wagin <avagin@gmail.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/sock.c b/net/core/sock.c
index e891bcf..292f422 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1474,8 +1474,8 @@ void sk_release_kernel(struct sock *sk)
 		return;
 
 	sock_hold(sk);
-	sock_net_set(sk, get_net(&init_net));
 	sock_release(sk->sk_socket);
+	sock_net_set(sk, get_net(&init_net));
 	sock_put(sk);
 }
 EXPORT_SYMBOL(sk_release_kernel);
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
