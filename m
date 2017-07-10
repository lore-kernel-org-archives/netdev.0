From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [GIT] Networking
Date: Mon, 10 Jul 2017 22:00:48 +0800
Message-ID: <20170710140048.GA15408@gondor.apana.org.au>
References: <20170708.113644.1272962770645338865.davem@davemloft.net>
 <CA+55aFzocFTX5JR9oG_5uKw-fT6OJUMkD71sypbec7JP=_qwpg@mail.gmail.com>
 <20170709191131.GB22224@oracle.com>
 <20170709.214043.1361767365552001158.davem@davemloft.net>
 <20170710100531.GA14940@gondor.apana.org.au>
 <20170710121002.GB21587@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
        akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Miloslav =?utf-8?B?VHJtYcSN?= <mitr@redhat.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170710121002.GB21587@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 10, 2017 at 08:10:02AM -0400, Sowmini Varadhan wrote:
>
> The reason that the WARN_ON is triggered is that af_alg_accept() calls
> sock_init_data() which does 
> 
>    2636         if (sock) {
>     :
>    2639                 sock->sk        =       sk;

Oh yes.  This started out with just sock_init_data which would
not have triggered your warning.  Then someone came along and
added sock_graft which basically duplicates work already done in
sock_init_data.

In fact the reason they wanted sock_graft was purely to call
security_sock_graft to initialise some SELinux state.  So we
could avoid your warning by calling that directly.

---8<---
crypto: af_alg - Avoid sock_graft call warning

The newly added sock_graft warning triggers in af_alg_accept.
It's harmless as we're essentially doing sock->sk = sock->sk.

The sock_graft call is actually redundant because all the work
it does is subsumed by sock_init_data.  However, it was added
to placate SELinux as it uses it to initialise its internal state.

This patch avoisd the warning by making the SELinux call directly.

Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/crypto/af_alg.c b/crypto/af_alg.c
index 3556d8e..92a3d54 100644
--- a/crypto/af_alg.c
+++ b/crypto/af_alg.c
@@ -287,7 +287,7 @@ int af_alg_accept(struct sock *sk, struct socket *newsock, bool kern)
 		goto unlock;
 
 	sock_init_data(newsock, sk2);
-	sock_graft(sk2, newsock);
+	security_sock_graft(sk2, newsock);
 	security_sk_clone(sk, sk2);
 
 	err = type->accept(ask->private, sk2);
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
