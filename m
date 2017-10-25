From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 2/3] xfrm: Fix offload dev state addition to
 occur after insertion
Date: Wed, 25 Oct 2017 09:22:14 +0200
Message-ID: <20171025072214.GP3323@secunet.com>
References: <1508857831-55824-1-git-send-email-avivh@mellanox.com>
 <1508857831-55824-2-git-send-email-avivh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Boris Pismenny <borisp@mellanox.com>,
        Yossi Kuperman <yossiku@mellanox.com>,
        "Yevgeny Kliteynik" <kliteyn@mellanox.com>,
        <netdev@vger.kernel.org>
To: <avivh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:39054 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751546AbdJYHWQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 03:22:16 -0400
Content-Disposition: inline
In-Reply-To: <1508857831-55824-2-git-send-email-avivh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 24, 2017 at 06:10:30PM +0300, avivh@mellanox.com wrote:
> From: Aviv Heller <avivh@mellanox.com>
> 
> Adding the state to the offload device prior to replay init in
> xfrm_state_construct() will result in NULL dereference if a matching
> ESP packet is received in between.
> 
> Adding it after insertion also has the benefit of the driver not having
> to check whether a state with the same match criteria already exists,
> but forces us to use an atomic type for the offload_handle, to make
> certain a stack-read/driver-write race won't result in reading corrupt
> data.

No, this will add multiple atomic operations to the packet path,
even in the non offloaded case.

I think the problem is that we set XFRM_STATE_VALID to early.
This was not a problem before we had offloading because
it was not possible to lookup this state before we inserted
it into the SADB. Now that the driver holds a subset of states
too, we need to make sure the state is fully initialized
before we mark it as valid.

The patch below should do it, in combination with your patch 1/3.

Could you please test this?

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index b997f13..96eb263 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -587,10 +587,6 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 	if (attrs[XFRMA_OUTPUT_MARK])
 		x->props.output_mark = nla_get_u32(attrs[XFRMA_OUTPUT_MARK]);
 
-	err = __xfrm_init_state(x, false, attrs[XFRMA_OFFLOAD_DEV]);
-	if (err)
-		goto error;
-
 	if (attrs[XFRMA_SEC_CTX]) {
 		err = security_xfrm_state_alloc(x,
 						nla_data(attrs[XFRMA_SEC_CTX]));
@@ -620,6 +616,10 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 	/* override default values from above */
 	xfrm_update_ae_params(x, attrs, 0);
 
+	err = __xfrm_init_state(x, false, attrs[XFRMA_OFFLOAD_DEV]);
+	if (err)
+		goto error;
+
 	return x;
 
 error:
