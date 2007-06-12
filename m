From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] pktgen IPSEC 3/4: Introduce xfrm SAD only lookup
Date: Tue, 12 Jun 2007 15:45:18 +0200
Message-ID: <466EA36E.80206@trash.net>
References: <1181649373.4060.50.camel@localhost>	 <1181649628.4060.54.camel@localhost>  <1181649715.4060.56.camel@localhost> <1181649791.4060.59.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, James Morris <jmorris@namei.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36582 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756087AbXFLNsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 09:48:13 -0400
In-Reply-To: <1181649791.4060.59.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looks good too me, just a few minor nitpicks as usual :)

jamal wrote:
>     [XFRM] Introduce standalone SAD lookup
>
> +struct xfrm_state *
> +xfrm_stateonly_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
> +		    unsigned short family, u8 mode, u8 proto, u32 reqid)
> +{
> +	unsigned int h = xfrm_dst_hash(daddr, saddr, reqid, family);
> +	struct xfrm_state *rx = NULL, *x = NULL;
> +	struct hlist_node *entry;
> +
> +	spin_lock(&xfrm_state_lock);
> +	hlist_for_each_entry(x, entry, xfrm_state_bydst+h, bydst) {
> +		if (x->props.family == family &&
> +		    x->props.reqid == reqid &&
> +		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
> +		    xfrm_state_addr_check(x, daddr, saddr, family) &&
> +		    mode == x->props.mode &&
> +		    proto == x->id.proto)  {
> +

^^ please delete empty line
> +			if (x->km.state != XFRM_STATE_VALID)
> +					continue;

^ one indentation level too much

> +			else {
> +				rx = x;
> +				break;
> +			}

The whole thing could be compacted by moving the XFRM_STATE_VALID
check to the first condition:

		if (x->props.family == family &&
		    x->props.reqid == reqid &&
		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
		    xfrm_state_addr_check(x, daddr, saddr, family) &&
		    mode == x->props.mode &&
		    proto == x->id.proto &&
		    x->km.state == XFRM_STATE_VALID) {
			rx = x;
			break;
		}

or alternatively turn the != XFRM_STATE_VALID into == if you
want to keep the first condition similar to xfrm_state_find
(but the mode and proto conditions are reversed anyways).

BTW, wouldn't it make sense to allow use of the SPI as well?
