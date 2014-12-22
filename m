From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: caif: Fix napi poll list corruption
Date: Mon, 22 Dec 2014 20:35:25 +1100
Message-ID: <20141222093525.GA18616@gondor.apana.org.au>
References: <20141220002327.GA31975@gondor.apana.org.au>
 <5497D3D9.2070509@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Vrabel <david.vrabel@citrix.com>, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org, konrad.wilk@oracle.com,
	boris.ostrovsky@oracle.com, edumazet@google.com,
	"David S. Miller" <davem@davemloft.net>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:47443 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753733AbaLVJfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 04:35:40 -0500
Content-Disposition: inline
In-Reply-To: <5497D3D9.2070509@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 22, 2014 at 04:18:33PM +0800, Jason Wang wrote:
>
> btw, looks like at least caif_virtio has the same issue.

Good catch.

-- >8 --
The commit d75b1ade567ffab085e8adbbdacf0092d10cd09c (net: less
interrupt masking in NAPI) breaks caif.

It is now required that if the entire budget is consumed when poll
returns, the napi poll_list must remain empty.  However, like some
other drivers caif tries to do a last-ditch check and if there is
more work it will call napi_schedule and then immediately process
some of this new work.  Should the entire budget be consumed while
processing such new work then we will violate the new caller
contract.

This patch fixes this by not touching any work when we reschedule
in caif.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/caif/caif_virtio.c b/drivers/net/caif/caif_virtio.c
index a5fefb9..b306210 100644
--- a/drivers/net/caif/caif_virtio.c
+++ b/drivers/net/caif/caif_virtio.c
@@ -257,7 +257,6 @@ static int cfv_rx_poll(struct napi_struct *napi, int quota)
 	struct vringh_kiov *riov = &cfv->ctx.riov;
 	unsigned int skb_len;
 
-again:
 	do {
 		skb = NULL;
 
@@ -322,7 +321,6 @@ exit:
 		    napi_schedule_prep(napi)) {
 			vringh_notify_disable_kern(cfv->vr_rx);
 			__napi_schedule(napi);
-			goto again;
 		}
 		break;

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
