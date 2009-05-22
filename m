From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [mISDN PATCH v2 09/19] Fix TEI and SAPI handling
Date: Fri, 22 May 2009 23:53:14 +0200
Message-ID: <20090522215314.GA4592@uranus.ravnborg.org>
References: <cover.1243024967.git.kkeil@pingi.linux-pingi.de> <cbbb2723784ecf04bcec253c547a9464a2e722c7.1243024967.git.kkeil@pingi.linux-pingi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	i4ldeveloper@listserv.isdn4linux.de
To: Karsten Keil <keil@b1-systems.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfepb.post.tele.dk ([195.41.46.236]:57424 "EHLO
	pfepb.post.tele.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757270AbZEVVvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 17:51:01 -0400
Content-Disposition: inline
In-Reply-To: <cbbb2723784ecf04bcec253c547a9464a2e722c7.1243024967.git.kkeil@pingi.linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Karsten.

Flash from the past looking at some ISDN layer2.
Some comments below.

	Sam

>  struct layer2 *
> -create_l2(struct mISDNchannel *ch, u_int protocol, u_long options, u_long arg)
> +create_l2(struct mISDNchannel *ch, u_int protocol, u_long options, u_int tei,
> +		u_int sapi)

Unrealted to this specific patch...
Are there any specific reason why mISDN prefer bsd style (u_int)
rather then linux style (u32)?

>  
>  static struct layer2 *
> -create_new_tei(struct manager *mgr, int tei)
> +create_new_tei(struct manager *mgr, int tei, int sapi)
>  {

Here tei and sapi are passed as signed.
But valid sapi range is [0..63] and tei [0..127].
And create_l2 above uses unsigned.

This looks confusing.

>  	u_long		opt = 0;
>  	u_long		flags;
> @@ -791,7 +791,7 @@ create_new_tei(struct manager *mgr, int tei)
>  	if (mgr->ch.st->dev->Dprotocols
>  	  & ((1 << ISDN_P_TE_E1) | (1 << ISDN_P_NT_E1)))
>  		test_and_set_bit(OPTION_L2_PMX, &opt);
> -	l2 = create_l2(mgr->up, ISDN_P_LAPD_NT, (u_int)opt, (u_long)tei);
> +	l2 = create_l2(mgr->up, ISDN_P_LAPD_NT, (u_int)opt, tei, sapi);
>  	if (!l2) {
>  		printk(KERN_WARNING "%s:no memory for layer2\n", __func__);
>  		return NULL;
> @@ -839,12 +839,15 @@ new_tei_req(struct manager *mgr, u_char *dp)
>  	ri += dp[1];
>  	if (!mgr->up)
>  		goto denied;
> -	tei = get_free_tei(mgr);
> +	if (dp[3] != 0xff)
> +		tei = dp[3] >> 1; /* 3GPP TS 08.56 6.1.11.2 */
> +	else
> +		tei = get_free_tei(mgr);

You should check EA0 here before assuming that any values except
EA=1, tei=127 equals ptmp.


>  	if (tei < 0) {
>  		printk(KERN_WARNING "%s:No free tei\n", __func__);
>  		goto denied;
>  	}

So get_free_tei() may return a negative value indicating no free tei.
So that make my comment above void - but is this really the best way
to return an error. Possibly it is..


> -	l2 = create_new_tei(mgr, tei);
> +	l2 = create_new_tei(mgr, tei, 0);

In general I would prefer to read: SAPI_CALLCONTROL rahter than a hardcoded 0.

>  	if (!l2)
>  		goto denied;
>  	else
> @@ -976,8 +979,6 @@ create_teimgr(struct manager *mgr, struct channel_req *crq)
>  			__func__, dev_name(&mgr->ch.st->dev->dev),
>  			crq->protocol, crq->adr.dev, crq->adr.channel,
>  			crq->adr.sapi, crq->adr.tei);
> -	if (crq->adr.sapi != 0) /* not supported yet */
> -		return -EINVAL;
>  	if (crq->adr.tei > GROUP_TEI)
>  		return -EINVAL;
>  	if (crq->adr.tei < 64)
> @@ -1025,7 +1026,7 @@ create_teimgr(struct manager *mgr, struct channel_req *crq)
>  		return 0;
>  	}
>  	l2 = create_l2(crq->ch, crq->protocol, (u_int)opt,
> -		(u_long)crq->adr.tei);
> +		crq->adr.tei, crq->adr.sapi);
>  	if (!l2)
>  		return -ENOMEM;
>  	l2->tm = kzalloc(sizeof(struct teimgr), GFP_KERNEL);
> @@ -1166,7 +1167,7 @@ static int
>  check_data(struct manager *mgr, struct sk_buff *skb)
>  {
>  	struct mISDNhead	*hh =  mISDN_HEAD_P(skb);
> -	int			ret, tei;
> +	int			ret, tei, sapi;
>  	struct layer2		*l2;
>  
>  	if (*debug & DEBUG_L2_CTRL)
> @@ -1178,18 +1179,16 @@ check_data(struct manager *mgr, struct sk_buff *skb)
>  		return -ENOTCONN;
>  	if (skb->len != 3)
>  		return -ENOTCONN;
> -	if (skb->data[0] != 0)
> -		/* only SAPI 0 command */
> -		return -ENOTCONN;
> +	sapi = skb->data[0] >> 2;

PReviously there was an implicit check of EA0.
This is missed not that you read sapi and discard the two lower bits.

I also wonder if you remeber to check the command/response bit.
That was implicitly tested to be 0 before and also ignored now.


>  	if (!(skb->data[1] & 1)) /* invalid EA1 */
>  		return -EINVAL;
> -	tei = skb->data[1] >> 0;
> +	tei = skb->data[1] >> 1;

This looks like a bug-fix...

>  	if (tei > 63) /* not a fixed tei */
>  		return -ENOTCONN;
>  	if ((skb->data[2] & ~0x10) != SABME)
>  		return -ENOTCONN;
>  	/* We got a SABME for a fixed TEI */
> -	l2 = create_new_tei(mgr, tei);
> +	l2 = create_new_tei(mgr, tei, sapi);
>  	if (!l2)
>  		return -ENOMEM;
>  	ret = l2->ch.send(&l2->ch, skb);

