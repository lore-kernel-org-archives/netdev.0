From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 2/3] xfrm: Fix offload dev state addition to
 occur after insertion
Date: Thu, 26 Oct 2017 08:16:11 +0200
Message-ID: <20171026061610.GR3323@secunet.com>
References: <1508857831-55824-1-git-send-email-avivh@mellanox.com>
 <1508857831-55824-2-git-send-email-avivh@mellanox.com>
 <20171025072214.GP3323@secunet.com>
 <0101015f53a726b1-d5731696-249f-449c-8c84-1d047cfaffb0-000000@us-west-2.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev-owner@vger.kernel.org" <netdev-owner@vger.kernel.org>,
        "avivh@mellanox.com" <avivh@mellanox.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Boris Pismenny <borisp@mellanox.com>,
        "Yossi Kuperman" <yossiku@mellanox.com>,
        Yevgeny Kliteynik <kliteyn@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Aviv Heller <aviv@avivh.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:40508 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750884AbdJZGQO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 02:16:14 -0400
Content-Disposition: inline
In-Reply-To: <0101015f53a726b1-d5731696-249f-449c-8c84-1d047cfaffb0-000000@us-west-2.amazonses.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 25, 2017 at 01:09:44PM +0000, Aviv Heller wrote:
> -----Original message-----
> > From: Steffen Klassert
> > Sent: Wednesday, October 25 2017, 10:22 am
> > To: avivh@mellanox.com
> > Cc: Herbert Xu; Boris Pismenny; Yossi Kuperman; Yevgeny Kliteynik; netdev@vger.kernel.org
> > Subject: Re: [PATCH net-next 2/3] xfrm: Fix offload dev state addition to occur after insertion
> > 
> > On Tue, Oct 24, 2017 at 06:10:30PM +0300, avivh@mellanox.com wrote:
> > > From: Aviv Heller <avivh@mellanox.com>
> > > 
> > > Adding the state to the offload device prior to replay init in
> > > xfrm_state_construct() will result in NULL dereference if a matching
> > > ESP packet is received in between.
> > > 
> > > Adding it after insertion also has the benefit of the driver not having
> > > to check whether a state with the same match criteria already exists,
> > > but forces us to use an atomic type for the offload_handle, to make
> > > certain a stack-read/driver-write race won't result in reading corrupt
> > > data.
> > 
> > No, this will add multiple atomic operations to the packet path,
> > even in the non offloaded case.
> > 
> > I think the problem is that we set XFRM_STATE_VALID to early.
> > This was not a problem before we had offloading because
> > it was not possible to lookup this state before we inserted
> > it into the SADB. Now that the driver holds a subset of states
> > too, we need to make sure the state is fully initialized
> > before we mark it as valid.
> > 
> > The patch below should do it, in combination with your patch 1/3.
> > 
> > Could you please test this?
> > 
> > diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
> > index b997f13..96eb263 100644
> > --- a/net/xfrm/xfrm_user.c
> > +++ b/net/xfrm/xfrm_user.c
> > @@ -587,10 +587,6 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
> >  	if (attrs[XFRMA_OUTPUT_MARK])
> >  		x->props.output_mark = nla_get_u32(attrs[XFRMA_OUTPUT_MARK]);
> >  
> > -	err = __xfrm_init_state(x, false, attrs[XFRMA_OFFLOAD_DEV]);
> > -	if (err)
> > -		goto error;
> > -
> >  	if (attrs[XFRMA_SEC_CTX]) {
> >  		err = security_xfrm_state_alloc(x,
> >  						nla_data(attrs[XFRMA_SEC_CTX]));
> > @@ -620,6 +616,10 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
> >  	/* override default values from above */
> >  	xfrm_update_ae_params(x, attrs, 0);
> >  
> > +	err = __xfrm_init_state(x, false, attrs[XFRMA_OFFLOAD_DEV]);
> > +	if (err)
> > +		goto error;
> > +
> >  	return x;
> >  
> >  error:
> > 
> 
> Hi Steffen,
> 
> This patch does not work, due to:
> 	if (!x->type_offload)
> 		return -EINVAL;
> 
> test in xfrm_dev_state_add().

There is certainly a way arround that :)
The easiest I can think of would be to propagate XFRM_STATE_VALID
only after the state is inserted into the SADBs. I.e. move the
setting of XFRM_STATE_VALID out of __xfrm_init_state() and let the
callers do it.

> 
> I agree with your analysis, and that we take a little performance hit due to the atomics, but we get the benefit of calling xfrm_dev_state_add() after the state is completely initialized, and passed the criteria for addition by xfrm_state_add().

We already have too many of these atomic operatons in the
packet path, adding more is a no go.
