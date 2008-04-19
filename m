From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] net: add destructor for skb data (rewritten)
Date: Sat, 19 Apr 2008 13:46:01 +0400
Message-ID: <20080419094600.GA11682@2ka.mipt.ru>
References: <200804181421.25828.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Max Krasnyansky <maxk@qualcomm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:37400 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752922AbYDSJq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Apr 2008 05:46:57 -0400
Content-Disposition: inline
In-Reply-To: <200804181421.25828.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 18, 2008 at 02:21:25PM +1000, Rusty Russell (rusty@rustcorp.com.au) wrote:
> If we want to notify something when an skb is truly finished (such as
> for tun vringfd support), we need a destructor on the data.

Can we put its invokation before pages are freed?

> +static void shinfo_put(struct skb_shared_info *shinfo, bool nohdr)
> +{
> +	struct skb_shared_info *orig;
> +
> +	do {
> +		if (atomic_sub_return(nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
> +				      &shinfo->dataref))
> +			return;
> +
> +		if (shinfo->nr_frags) {
> +			int i;
> +			for (i = 0; i < shinfo->nr_frags; i++)
> +				put_page(shinfo->frags[i].page);
> +		}
> +
> +		if (shinfo->frag_list)
> +			skb_drop_list(&shinfo->frag_list);
> +
> +		orig = shinfo->orig;
> +		if (shinfo->destructor)
> +			shinfo->destructor(shinfo);

If it is first, we can process handle pages inside destructor, otherwise
they can be out of our control.

> +		else
> +			kfree(skb_shinfo_to_head(shinfo));
> +
> +		/* We hold a payload reference to our parent. */
> +		nohdr = true;
> +	} while ((shinfo = orig) != NULL);
> +}

-- 
	Evgeniy Polyakov
