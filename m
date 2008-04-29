From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC XFRM]: esp: fix scatterlist of out bounds access with crypto_eseqiv
Date: Tue, 29 Apr 2008 21:59:32 +0800
Message-ID: <20080429135932.GA20790@gondor.apana.org.au>
References: <48161D99.5070303@trash.net> <20080429014107.GA16700@gondor.apana.org.au> <4816AD93.5090404@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4816AD93.5090404@trash.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 29, 2008 at 07:09:39AM +0200, Patrick McHardy wrote:
> 
> I've attached two traces, the one from eseqiv and a similar
> one from authenc (I've manually overriden eseqiv by chainiv
> to test whether its responsible for the broken packets I was
> seeing, which turned out to be the case. I'll look into that).

Thanks, looks like I left out the sg_is_last check in restoring
adding scatterwalk_sg_next.  Worse yet, eseqiv doesn't even
encrypt the last block.  It's a good thing the hifn driver doesn't
work yet :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
commit 37a885564f7a0b687e0330fc6a43b0b2cddca7ea
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Tue Apr 29 21:53:52 2008 +0800

    [CRYPTO] api: Fix scatterwalk_sg_chain
    
    When I backed out of using the generic sg chaining (as it isn't currently
    portable) and introduced scatterwalk_sg_chain/scatterwalk_sg_next I left
    out the sg_is_last check in the latter.  This causes it to potentially
    dereference beyond the end of the sg array.
    
    As most uses of scatterwalk_sg_next are bound by an overall length, this
    only affected the chaining code in authenc and eseqiv. Thanks to Patrick
    McHardy for identifying this problem.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/crypto/scatterwalk.h b/include/crypto/scatterwalk.h
index 224658b..833d208 100644
--- a/include/crypto/scatterwalk.h
+++ b/include/crypto/scatterwalk.h
@@ -57,10 +57,14 @@ static inline void scatterwalk_sg_chain(struct scatterlist *sg1, int num,
 					struct scatterlist *sg2)
 {
 	sg_set_page(&sg1[num - 1], (void *)sg2, 0, 0);
+	sg1[num - 1].page_link &= ~0x02;
 }
 
 static inline struct scatterlist *scatterwalk_sg_next(struct scatterlist *sg)
 {
+	if (sg_is_last(sg))
+		return NULL;
+
 	return (++sg)->length ? sg : (void *)sg_page(sg);
 }
 
commit 325709763dffb453c6a710ca3dfe184e8909f27a
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Tue Apr 29 21:57:01 2008 +0800

    [CRYPTO] eseqiv: Fix off-by-one encryption
    
    After attaching the IV to the head during encryption, eseqiv does not
    increase the encryption length by that amount.  As such the last block
    of the actual plain text will be left unencrypted.
    
    Fortunately the only user of this code hifn currently crashes so this
    shouldn't affect anyone :)
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/crypto/eseqiv.c b/crypto/eseqiv.c
index b14f14e..881d309 100644
--- a/crypto/eseqiv.c
+++ b/crypto/eseqiv.c
@@ -136,7 +136,8 @@ static int eseqiv_givencrypt(struct skcipher_givcrypt_request *req)
 	}
 
 	ablkcipher_request_set_crypt(subreq, reqctx->src, dst,
-				     req->creq.nbytes, req->creq.info);
+				     req->creq.nbytes + ivsize,
+				     req->creq.info);
 
 	memcpy(req->creq.info, ctx->salt, ivsize);
 
