From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun issue after e0b46d0ee9c: tun: Use iovec iterators
Date: Sat, 29 Nov 2014 07:59:35 +0800
Message-ID: <20141128235935.GA2178@gondor.apana.org.au>
References: <5478CC27.9040705@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:53164 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345AbaK2AAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 19:00:10 -0500
Content-Disposition: inline
In-Reply-To: <5478CC27.9040705@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 28, 2014 at 05:25:27PM -0200, Marcelo Ricardo Leitner wrote:
> 
> I saw there are tun updates on Dave's queue but none seemed to handle this.
> 
> I can't use current net-next
> (799d2fff1858004526ad75d66a5dd8a5cce6ad40) on a kvm hypervisor
> because tun got clogged somehow. Bisected down to:
> 
> commit e0b46d0ee9c240c7430a47e9b0365674d4a04522
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Fri Nov 7 21:22:23 2014 +0800

Does this patch help?

-- >8 --
Subject: tun: Fix GSO meta-data handling in tun_get_user

When we write the GSO meta-data in tun_get_user we end up advancing
the IO vector twice, thus exhausting the user buffer before we can
finish writing the packet.

Fixes: f5ff53b4d97c ("{macvtap,tun}_get_user(): switch to iov_iter")
Reported-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 4b743c6..9357871 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1052,7 +1052,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 
 		if (gso.hdr_len > len)
 			return -EINVAL;
-		iov_iter_advance(from, tun->vnet_hdr_sz);
+		iov_iter_advance(iter, tun->vnet_hdr_sz - sizeof(gso));
 	}
 
 	if ((tun->flags & TUN_TYPE_MASK) == TUN_TAP_DEV) {

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
