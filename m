From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: tun: Optimise handling of bogus gso->hdr_len
Date: Thu, 4 Jun 2009 21:06:00 +1000
Message-ID: <20090604110600.GA28453@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58267 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752002AbZFDLGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 07:06:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

tun: Optimise handling of bogus gso->hdr_len

As all current versions of virtio_net generate a value for the
header length that's too small, we should optimise this so that
we don't copy it twice.  This can be done by ensuring that it is
at least as large as the place where we'll write the checksum.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 735bf41..00d00ad 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -563,6 +563,10 @@ static __inline__ ssize_t tun_get_user(struct tun_struct *tun,
 		if (memcpy_fromiovec((void *)&gso, iv, sizeof(gso)))
 			return -EFAULT;
 
+		if ((gso.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
+		    gso.csum_start + gso.csum_offset + 2 > gso.hdr_len)
+			gso.hdr_len = gso.csum_start + gso.csum_offset + 2;
+
 		if (gso.hdr_len > len)
 			return -EINVAL;
 	}

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
